# Swagger 自动生成 api client

- swagger_to_objc.rb 主要做了以下
  1. 合并 所有服务的swagger文档
  1. 删除 go 语言的 xx. 前缀
  1. 删除  Request-Id (iOS 本地自动插入)  & userId(网关自动插入)
  1. 规律不需要的接口和 model
  1. 兼容 go 的泛型, 生成`固定类型类` ,修改 `接口返回类`为`固定类型类`
- config.yml 配置文件
  1. 配置项都有注释

# sort-Xcode-project-file

每次编译时会自动排序工程文件的顺序

集成参考:
[https://stackoverflow.com/questions/31532460/how-to-automatically-sort-by-name-in-xcode-project](https://stackoverflow.com/questions/31532460/how-to-automatically-sort-by-name-in-xcode-project)

# sync_images.sh

从 `${PROJECT_DIR}/Assets.xcassets` 文件夹中生成 `IMAGE_xxx`的宏

# sync_localizable.sh

从 `${PROJECT_DIR}/EulixSpace/Application/zh-Hans.lproj/Localizable.strings` 文件夹中生成 `TEXT_xxx`的本地化文本宏

# upload.sh

上传`ipa` 到 [https://code.eulix.xyz/bp/cicada/-/packages](https://code.eulix.xyz/bp/cicada/-/packages) 中

# build\_debug\_ipa.sh

1. 添加`-测试`后缀到 app 名称后面 (傲空间-测试)
1. 编译 debug 包
1. 上传到`https://res.space.eulix.xyz/clients/ios/debug/index.html`这个地方, 方便跟其他人远程调试

# upload_swagger.sh

1. 上传`文件`服务 的 `swagger` 到https://res.space.eulix.xyz/clients/ios/swagger/file.json
1. 上传`system-agent`服务 的 `swagger` 到https://res.space.eulix.xyz/clients/ios/swagger/system.json

- 文件服务如果不是最新, 找 @xuyang
- system-agent服务如果不是最新, 找 @wenchao


#  gitlab-ci

## 工具安装

需要挂代理或者 vpn 加速访问 github

`unset http_proxy https_proxy`

`export http_proxy=socks5://127.0.0.1:1080;export https_proxy=socks5://127.0.0.1:1080;`

or

`export http_proxy=http://127.0.0.1:1081;export https_proxy=http://127.0.0.1:1081;`

1. /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
1. brew install gitlab-runner
1. brew install oclint
1. brew install sonar-scanner
1. brew install rbenv
1. rbenv install 3.0.1
1. rbenv global 3.0.1
1. rbenv init
1. gem install fastlane
1. gem install cocoapods
1. curl -sL https://sentry.io/get-cli/ | bash
1. sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

## 注册 gitlab-runner 

https://docs.gitlab.com/runner/

