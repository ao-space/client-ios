# Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ! /bin/sh

rm -rf ./swagger/

git clone --depth=1 git@code.eulix.xyz:bp/box/system/eulixspace-agent.git ./swagger/eulixspace-agent
git clone --depth=1 git@code.eulix.xyz:bp/box/services/eulixspace-fileapi.git ./swagger/eulixspace-fileapi
git clone --depth=1 git@code.eulix.xyz:bp/box/services/eulixspace-account.git ./swagger/eulixspace-account
git clone --depth=1 git@code.eulix.xyz:bp/box/services/eulixspace-gateway.git ./swagger/eulixspace-gateway

ossutil rm oss://eulix-bp-res/clients/ios/swagger/system.json
ossutil rm oss://eulix-bp-res/clients/ios/swagger/file.json
ossutil rm oss://eulix-bp-res/clients/ios/swagger/gateway.json
ossutil rm oss://eulix-bp-res/clients/ios/swagger/account.json
ossutil rm oss://eulix-bp-res/clients/ios/swagger/upgrade.json

# 文件服务如果不是最新, 找 @xuyang
ossutil cp ./swagger/eulixspace-agent/docs/swagger.json oss://eulix-bp-res/clients/ios/swagger/system.json

# system-agent 服务如果不是最新, 找 @wenchao
ossutil cp ./swagger/eulixspace-fileapi/src/main/docs/swagger.json oss://eulix-bp-res/clients/ios/swagger/file.json

# gateway 服务如果不是最新, 找 @zhichuang
ossutil cp ./swagger/eulixspace-gateway/openapi/openapi.json oss://eulix-bp-res/clients/ios/swagger/gateway.json

# account 服务如果不是最新, 找 @suqin
ossutil cp ./swagger/eulixspace-account/openapi/openapi.json oss://eulix-bp-res/clients/ios/swagger/account.json

# upgrade 服务如果不是最新, 找 @wenchao 协助
ossutil cp ./swagger/eulixspace-agent/docs/upgrade.json oss://eulix-bp-res/clients/ios/swagger/upgrade.json

rm -rf ./swagger/
