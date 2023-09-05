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
//  ESOptTypeHeader.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#ifndef ESOptTypeHeader_h
#define ESOptTypeHeader_h

// 授权端修改安全密码的申请
#define ESSecurityPasswordModifyApply @"security_passwd_mod_apply"
// 授权端重置安全密码的申请
#define ESSecurityPasswordResetApply @"security_passwd_reset_apply"


// 安保专用的poll推送允许结果
#define ESSecurityPasswordModifyAccept @"security_passwd_mod_accept"

//场景36    使用 UPS ，当市电断电且等到 UPS 耗电完成后，恢复供电，设备启动后，app 端可以获取盒子端的消息
#define ESUPSExhausted @"ups_exhausted"
//场景37    当市电断电或者拔掉电源等异常关机，恢复供电，设备启动后，app 端可以获取盒子端的消息
#define ESUPSShutdownAbnormal @"ups_shutdown_abnormal"
//场景38    UPS 启用状态下，UPS 的USB由连接状态变为断开连接
#define ESUPSDisconnected @"ups_disconnected"
//场景39    UPS 启用状态下，UPS 的USB由断开状态变为连接状态
#define ESUPSReconnected @"ups_reconnected"
//场景40    UPS 启用状态下，UPS 设备市电断开，傲空间进入 UPS 保护状态
#define ESUPSOnbattery @"ups_onbattery"
// 场景41    UPS 启用状态下，UPS 设备市电断开后恢复供电
#define ESUPSPowerRestored @"ups_power_restored"
// 场景42    当 CPU 温度超过90℃
#define ESCPUHightemp @"cpu_hightemp"
// 场景43    风扇转速为 0
#define ESFanspeedZero @"fanspeed_zero"
// 场景44    硬盘 温度超过65℃
#define ESDiskHightemp @"disk_hightemp"
// 场景45    smart 检测异常
#define ESDiskSmartErr @"disk_smart_err"

/**
 
 curl -X POST "http://172.17.0.1:5680/agent/v1/api/device/notify/test" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"events\": { \"busNumber\": 2, \"eventTime\": 1687939870 }, \"optType\": \"ups_exhausted\"}"
 
 cpu_hightemp 消息列表中 data 无内容
 ups_onbattery 这个 optType 轮询消息与消息中心都没相应数据
 ups_reconnected 这个 optType 轮询消息与消息中心都没相应数据
 */
#endif /* ESOptTypeHeader_h */
