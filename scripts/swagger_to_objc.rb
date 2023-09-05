# frozen_string_literal: true

require 'open-uri'
require 'json'
require 'yaml'

# 1. 合并 所有服务的swagger文档
# 1. 删除 go 语言的 xx. 前缀
# 1. 删除  Request-Id (iOS 本地自动插入)  & userId(网关自动插入)
# 1. 规律不需要的接口和 model
# 1. 兼容 go 的泛型, 生成`固定类型类` ,修改 `接口返回类`为`固定类型类`

# 服务列表
class ServiceList
  # 服务
  class Service
    def initialize(name, url)
      @name = name
      @url = url
      @config = YAML.safe_load(File.open(File.join(Dir.pwd, 'config.yml')))
    end

    # swagger 对应的 hash 定义
    def hash
      puts "swagger for #{@name}"
      result_json = nil
      URI.open(@url,
               'Accept' => 'application/json,*/*') do |http|
        result_json = http.read
      end

      # trim xxx.
      @config['trim_go_prefix'].each { |trim| result_json.gsub!(trim, '') }
      result_json.gsub!('222', 'time')
      result_hash = JSON.parse(result_json)
      if (result_hash['openapi'] != nil) 
        result_hash['openapi'] = '3.0.0'
        result_json = result_hash.to_json
      end
      File.open("#{@name}.ori.json", 'w') { |file| file.write(result_json) }

      # convert openapi_3 to swagger_2
      unless result_hash['openapi'].nil?
        puts "try to convert openapi_3 to swagger_2"
        `api-spec-converter --from=openapi_3 --to=swagger_2 --syntax=json #{@name}.ori.json > #{@name}.json`
        return JSON.parse(File.read("#{@name}.json"))
      end
      result_hash
    end
  end

  def add_service(name, url)
    @list = [] if @list.nil?
    @list.append(Service.new(name, url).hash)
  end

  def deep_dup(h)
    h.transform_values do |v|
      if v.is_a?(Hash)
        deep_dup(v)
      else
        begin
          v.dup
        rescue StandardError
          v
        end
      end
    end
  end

  def generate
    # 加载配置
    @config = YAML.safe_load(File.open(File.join(Dir.pwd, 'config.yml')))
    service_list = @config['service_list']
    service_list.each do |service|
      add_service(service['name'], service['url'])
    end
    total_hash = @list.first.dup
    total_hash['securityDefinitions'] = nil
    total_paths = total_hash['paths']

    total_models = total_hash['definitions']

    # merge all paths and definitions
    # 合并所有的请求 path 和 模型定义
    @list.each do |hash|
      total_paths.merge!(hash['paths'])
      total_models.merge!(hash['definitions']) unless hash['definitions'].nil?
    end

    # 移除不需要的 header 参数
    #  - Request-Id
    #  - userId
    trim_header_param = @config['trim_header_param']
    custom_model_list = []
    total_paths.each do |_path, value|
      value.each do |_method, value|
        # value['security'] = nil
        responses = value['responses']
        response_ok = responses['200'] unless responses.nil?
        schema = response_ok['schema'] unless response_ok.nil?
        all_of = schema['allOf'] unless schema.nil?
        # go 的定义里有泛型, 需要额外定义对应的返回类名
        # {
        #   "responses": {
        #     "200": {
        #       "description": "code=AG-200 成功",
        #       "schema": {
        #         "allOf": [{ !
        #             "$ref": "#/definitions/BaseRspStr"
        #           },
        #           {
        #             "type": "object",
        #             "properties": {
        #               "results": {
        #                 "$ref": "#/definitions/Info"
        #               }
        #             }
        #           }
        #         ]
        #       }
        #     }
        #   }
        # }
        # ======>
        #
        #
        # {
        #   "responses": {
        #     "200": { !!
        #       "description": "code=AG-200 成功",
        #       "schema": {
        #         "$ref": "#/definitions/RspInfo"
        #       }
        #     }
        #   }
        # }
        # 在 Rsp 这个基类上修改并成为一个固定类型的类
        # {
        #   "Rsp": { !!
        #     "type": "object",
        #     "properties": {
        #       "code": {
        #         "type": "string"
        #       },
        #       "message": {
        #         "type": "string"
        #       },
        #       "results": {} !!
        #     }
        #   }
        # }
        # ======>
        # 在 definitions 添加新增这个返回类
        # 在原先的类名前面 添加 Rsp
        # {
        #   "RspInfo": { !!
        #     "type": "object",
        #     "properties": {
        #       "code": {
        #         "type": "string"
        #       },
        #       "message": {
        #         "type": "string"
        #       },
        #       "results": {  "$ref": "#/definitions/Info" } !!
        #     }
        #   }
        # }
        unless all_of.nil? || all_of.count != 2
          # puts "allOf #{all_of.to_s}"
          rsp_ref = all_of.first
          # "$ref": "#/definitions/BaseRspStr"
          # 第一个是基类, 需要在definitions 找到并修改其中的results
          base_ref = rsp_ref['$ref'].sub('#/definitions/', '')
          # BaseRspStr
          object_ref = all_of.last
          # puts "rsp_ref #{base_ref}"
          # puts "object_ref #{object_ref.to_s}"
          # object_ref => {"type"=>"object", "properties"=>{"results"=>{"$ref"=>"#/definitions/BackupTransId"}}}
          properties = object_ref['properties']

          hash = { 'response_ok' => response_ok,
                   'properties' => properties,
                   'base_ref' => base_ref }
          custom_model_list.append(hash)
        end

        parameters = value['parameters']
        next if parameters.nil?

        # 删除 header 里参数
        # dup == copy
        parameters.dup.each_with_index do |config, _index|
          # puts "#{config.to_s} -> #{config['name']}"
          parameters.delete(config) if trim_header_param.include?(config['name'])
        end
      end
    end
    # 在#/definitions/中插入自定义类
    custom_model_list.each do |hash|
      response_ok = hash['response_ok']
      # puts response_ok
      properties_response = hash['properties']
      # puts properties_response
      # {"results"=>{"$ref"=>"#/definitions/BackupTransId"}}
      base_ref_name = hash['base_ref']
      base_rsp_config = deep_dup(total_models[base_ref_name])

      # puts base_rsp_config
      parameters_of_base_ref = base_rsp_config['properties']
      all_keys = properties_response.keys
      response_model_name = base_ref_name
      if all_keys.count == 1
        # 一般为泛型
        key = all_keys.first
        # key = results

        property_config = properties_response[key]
        # property_config = {"$ref"=>"#/definitions/BackupTransId"}

        ref = property_config['$ref']
        # ref => #/definitions/BackupTransId

        # 数组
        # {"type":"object","properties":{"results":{"type":"array","items":{"$ref":"#/definitions/AccountInfo"}}}}
        ref = property_config['items']['$ref'] if ref.nil? && property_config['items']
        next if ref.nil?

        model_name = ref.sub('#/definitions/', '')
        # model_name => BackupTransId

        model_name = "Rsp#{model_name}"
        # model_name => RspBackupTransId

        rsp_model = "#/definitions/#{model_name}"
        # rsp_model => #/definitions/RspBackupTransId

        response_model_name = model_name
        response_ok['schema'] = { '$ref' => rsp_model }
      end
      parameters_of_base_ref.dup.each do |key, _config|
        replacement = properties_response[key]
        unless replacement.nil?
          # puts replacement
          parameters_of_base_ref[key] = replacement
        end
      end
      # puts base_rsp_config
      # {"type"=>"object", "properties"=>{"code"=>{"description"=>"回应错误码", "type"=>"integer"}, "message"=>{"description"=>"错误描述信息", "type"=>"string"}, "requestId"=>{"description"=>"事务id", "type"=>"string"}, "results"=>{"$ref"=>"#/definitions/BackupTransId"}}}
      # 下面这个是数组返回
      # {"type"=>"object", "properties"=>{"code"=>{"type"=>"string"}, "message"=>{"type"=>"string"}, "requestId"=>{"type"=>"string"}, "results"=>{"type"=>"array", "items"=>{"$ref"=>"#/definitions/Network"}}}}
      total_models[response_model_name] = base_rsp_config
    end

    # ignore unused api or model
    deny_api_list = @config['deny_api']
    deny_api_prefix = @config['deny_api_prefix']
    deny_model_list = @config['deny_model']
    allow_paths = {}
    allow_models = {}

    total_paths.each_key do |path|
      ignore = false
      deny_api_prefix.each do |prefix|
        if path.start_with?(prefix)
          ignore = true
          break
        end
      end

      # 不需要的 api 中没有, 并且 前缀匹配中 也 没有
      if !deny_api_list.include?(path) && !ignore
        # puts "#{path}  ✅"
        allow_paths[path] = total_paths[path]
      end
    end

    total_models.each_key do |name|
      unless deny_model_list.include?(name)
        # puts "#{name}  ✅"
        allow_models[name] = total_models[name]
      end
    end

    total_hash['paths'] = allow_paths
    total_hash['definitions'] = allow_models

    total_json = 'total.json'
    File.write(total_json, total_hash.to_json)

    # download cli if no exist
    swagger_cli_version = @config['swagger_cli_version']
    swagger_cli_jar = "swagger-codegen-cli-#{swagger_cli_version}.jar"
    unless File.exist?(swagger_cli_jar)
      swagger_cli_uri = "#{@config['swagger_repo']}/#{swagger_cli_version}/#{swagger_cli_jar}"
      URI.open(swagger_cli_uri) do |image|
        File.open(swagger_cli_jar, 'wb') do |file|
          file.write(image.read)
        end
      end
    end

    # write objc config to file
    objc_config = 'objc.json'
    File.write(objc_config, @config['objc_config'].to_json)
    `rm -rf ./ESClient`
    `git clone -b dev --depth=1 git@code.eulix.xyz:bp/client/ios/esclient.git ./ESClient`
    `rm -rf ./ESClient/ESClient/`
    `java -jar #{swagger_cli_jar} generate -i #{total_json} -l objc -c #{objc_config} -o ./ESClient`
    `sed -i '' "s/AFNetworking/AFNetworking\\/NSURLSession/g" ./ESClient/ESClient.podspec`
    `sed -i '' "s/AFNetworking\\.h/AFHTTPSessionManager\\.h/g" ./ESClient/ESClient/Core/ESApiClient.h`
    # clean tmp file
    `rm -rf *.json`
  end
end

service_list = ServiceList.new
service_list.generate
