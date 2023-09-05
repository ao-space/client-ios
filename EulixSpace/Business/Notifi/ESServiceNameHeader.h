/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  ESServiceNameHeader.h
//  EulixSpace
//
//  Created by dazhou on 2022/7/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#ifndef ESServiceNameHeader_h
#define ESServiceNameHeader_h

#define ServiceName @"serviceName"
#define ApiName @"apiName"

// service name
#define eulixspaceAccountService @"eulixspace-account-service"
#define eulixspace_gateway @"eulixspace-gateway"
#define eulixspace_agent_service @"eulixspace-agent-service"

#define notification_get @"notification_get"

#define AGENT_V1_API_PASSTHROUGH  @"/agent/v1/api/passthrough"
#define AGENT_V1_API_PASSTHROUGH_PLAIN  @"/agent/v1/api/passthrough/plain"


// 接口1:验证安全密码(获取 SecurityTokenRes). 其他两步验证需要先调用本接口作为第一步验证. /v1/api/security/passwd/verify
#define security_passwd_verify @"security_passwd_verify"

// 接口2:绑定端直接修改(使用原密码) /v1/api/security/passwd/modify/binder
#define security_passwd_modify_binder @"security_passwd_modify_binder"

// 接口3: 绑定端设置密保邮箱(使用安全密码) /v1/api/security/email/set/binder
#define security_email_set_binder @"security_email_set_binder"

// 接口4: 验证密保邮箱(获取 SecurityTokenRes). 其他两步验证需要先调用本接口作为第一步验证.  /v1/api/security/email/verify
#define security_email_verify @"security_email_verify"

// 接口5: 绑定端直接重置(使用密保邮箱) /v1/api/security/passwd/reset/binder
#define security_passwd_reset_binder @"security_passwd_reset_binder"

// 接口6: 绑定端修改密保邮箱(使用原密保邮箱或安全密码) /v1/api/security/email/modify/binder
#define security_email_modify_binder @"security_email_modify_binder"

// 接口7: 获取邮箱配置信息列表 /v1/api/security/email/configurations
#define security_email_configurations @"security_email_configurations"

// 接口8:绑定端直接重置(called by system-agent)
#define api_security_passwd_reset_binder_local @"/api/security/passwd/reset/binder/local"

// 接口9: 绑定端设置密保邮箱(called by system-agent) /v1/api/security/email/set/binder/local   /agent/v1/api/passthrough
#define api_security_email_set_binder_local @"/api/security/email/set/binder/local"

// 接口10: 绑定端修改密保邮箱(called by system-agent) /v1/api/security/email/modify/binder/local  /agent/v1/api/passthrough
#define api_security_email_modify_binder_local @"/api/security/email/modify/binder/local"

// 接口11: 授权端申请修改 /v1/api/security/passwd/modify/auther/apply
#define security_passwd_modify_auther_apply @"security_passwd_modify_auther_apply"

// 接口12：绑定端是否允许修改密码 /v1/api/security/passwd/modify/binder/accept
#define security_passwd_modify_binder_accept @"security_passwd_modify_binder_accept"

// 接口13: 授权端提交修改 /v1/api/security/passwd/modify/auther
#define security_passwd_modify_auther @"security_passwd_modify_auther"

// 接口14: 授权端请求重置 /v1/api/security/passwd/reset/auther/apply
#define security_passwd_reset_auther_apply @"security_passwd_reset_auther_apply"

// 接口15: 绑定端允许重置 /v1/api/security/passwd/reset/binder/accept  貌似与接口23一样？？
#define security_passwd_reset_binder_accept @"security_passwd_reset_binder_accept"

// 接口16: 授权端提交重置(通过密保邮箱) /v1/api/security/passwd/reset/auther
#define security_passwd_reset_auther @"security_passwd_reset_auther"

// 接口17: 授权端提交重置(called by system-agent) /v1/api/security/passwd/reset/auther/local  /agent/v1/api/passthrough
#define api_security_passwd_reset_auther_local @"/api/security/passwd/reset/auther/local"

// 接口18: 授权端设置密保邮箱(通过安全密码) /v1/api/security/email/set/auther
#define security_email_set_auther @"security_email_set_auther"

// 接口19: 授权端设置密保邮箱(called by system-agent) /v1/api/security/email/set/auther/local  /agent/v1/api/passthrough
#define api_security_email_set_auther_local @"/api/security/email/set/auther/local"

// 接口20: 授权端修改密保邮箱(通过原密保邮箱或安全密码) /v1/api/security/email/modify/auther
#define security_email_modify_auther @"security_email_modify_auther"

// 接口21: 授权端修改密保邮箱(called by system-agent) /v1/api/security/email/modify/auther/local /agent/v1/api/passthrough
#define api_security_email_modify_auther_local @"/api/security/email/modify/auther/local"

// 接口22: 新设备申请重置(called by system-agent) /v1/api/security/passwd/reset/newdevice/apply/local /agent/v1/api/passthrough
#define api_security_passwd_reset_newdevice_apply_local @"/api/security/passwd/reset/newdevice/apply/local"

// 接口23: 新设备拉取推送(通过蓝牙/局域网)  /v1/api/security/message/poll/local
#define api_security_message_poll_local @"/api/security/message/poll/local"

// 接口24: 验证密保邮箱(获取 SecurityTokenRes).(called by system-agent) /v1/api/security/email/verify/local /agent/v1/api/passthrough
#define api_security_email_verify_local @"/api/security/email/verify/local"

// 接口25:新设备提交重置(called by system-agent) /v1/api/security/passwd/reset/newdevice/local /agent/v1/api/passthrough
#define api_security_passwd_reset_newdevice_local @"/api/security/passwd/reset/newdevice/local"

// 接口26：绑定端是否允许修改密码
#define device_hardware_info @"device_hardware_info"

// 接口27: 获取邮箱设置 (仅允许管理员调用) /v1/api/security/email/setting
#define security_email_setting @"security_email_setting"

// 安全密码相关的消息拉取接口（通过call接口） /v1/api/security/message/poll
#define security_message_poll @"security_message_poll"

// 新增接口: 局域网/蓝牙获取邮箱配置  /v1/api/security/email/setting/local
#define api_security_email_setting_local @"/api/security/email/setting/local"




// GET /agent/v1/api/disk/recognition 磁盘初始化时, 识别插入的磁盘信息。阻塞式接口 [客户端蓝牙、局域网调用]
#define AGENT_V1_API_DISK_RECOGNITION  @"/agent/v1/api/disk/recognition"


// GET /agent/v1/api/space/ready/check 磁盘初始化完成之后用于检测空间是否准备就绪，即软硬件环境检测。阻塞式接口 [客户端蓝牙、局域网调用]
#define AGENT_V1_API_SPACE_READY_CHECK  @"/agent/v1/api/space/ready/check"


// POST /agent/v1/api/disk/initialize  初始化任务在后台执行，客户端可以通过 `/disk/initialize/progress` 查询初始化进度。非阻塞式接口 [客户端蓝牙、局域网]
#define AGENT_V1_API_DISK_INITIALIZE  @"/agent/v1/api/disk/initialize"

// GET /agent/v1/api/disk/initialize/progress  获取初始化进度和状态。[客户端蓝牙、局域网、Call 调用(对应 eulixspace-agent-service)]
#define AGENT_V1_API_DISK_INITIALIZE_PROGRESS  @"/agent/v1/api/disk/initialize/progress"
#define disk_initialize_progress @"disk_initialize_progress"

// POST  /agent/v1/api/system/shutdown  关机 [蓝牙、局域网、Call 调用(对应 eulixspace-agent-service)]
#define AGENT_V1_API_SYSTEM_SHUTDOWN  @"/agent/v1/api/system/shutdown"
#define system_shutdown @"system_shutdown"

// GET /agent/v1/api/disk/management/list 磁盘管理列表。[局域网、蓝牙、Call调用(对应 eulixspace-agent-service)]
#define AGENT_V1_API_DISK_MANAGEMENT_LIST  @"/agent/v1/api/disk/management/list"
#define disk_management_list @"disk_management_list"

// GET /agent/v1/api/disk/management/raid/info 获取 磁盘 Raid信息。[Call调用(对应 eulixspace-agent-service)]
#define AGENT_V1_API_DISK_MANAGEMENT_RAID_INFO @"/agent/v1/api/disk/management/raid/info"
#define disk_management_raid_info @"disk_management_raid_info"

// POST /agent/v1/api/disk/management/expand 磁盘扩容。后台异步执行，客户端可以定时通过 `/disk/expand/progress` 查询初始化进度 [Call调用]
#define AGENT_V1_API_DISK_MANAGEMENT_EXPAND @"/agent/v1/api/disk/management/expand"
#define disk_management_expand @"disk_management_expand"

// GET /agent/v1/api/disk/management/expand/progress 获取扩容进度和状态。[Call调用(对应 eulixspace-agent-service)]
#define AGENT_V1_API_DISK_MANAGEMENT_EXPAND_PROGRESS @"/agent/v1/api/disk/management/expand/progress"
#define disk_management_expand_progress @"disk_management_expand_progress"



//下面3个接口以最终定义为准
// POST /agent/v1/api/network/config 网络配置。[客户端蓝牙、局域网、Call 调用(eulixspace-agent-service)]
#define AGENT_V1_API_NETWORK_CONFIG_POST @"/agent/v1/api/network/config"
#define network_config_update @"network_config_update"

// GET /agent/v1/api/network/config 获取网络信息。[客户端蓝牙、局域网、Call 调用(eulixspace-agent-service)]
#define AGENT_V1_API_NETWORK_CONFIG @"/agent/v1/api/network/config"
#define network_config @"network_config"

// POST /agent/v1/api/network/ignore 忽略此网络。删除网络连接。[客户端蓝牙、局域网、Call 调用(eulixspace-agent-service)]
#define AGENT_V1_API_NETWORK_IGNORE @"/agent/v1/api/network/ignore"
#define network_ignore @"network_ignore"


// GET /agent/v1/api/device/ability 获取设备能力 [蓝牙/局域网/网关调用(对应 eulixspace-agent-service)]
#define AGENT_V1_API_DEVICE_ABILITY @"/agent/v1/api/device/ability"
#define device_ability @"device_ability"


// GET /agent/v1/api/cert/get 获取局域网自签名证书 [客户端调用，局域网调用（对应 eulixspace-agent-service）]
#define AGENT_V1_API_CERT_GET @"/agent/v1/api/cert/get"
#define get_lan_cert @"get_lan_cert"

#endif /* ESServiceNameHeader_h */
