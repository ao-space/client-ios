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
//  ESHardwareSettingModel.h
//  EulixSpace
//
//  Created by dazhou on 2023/6/15.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBaseResp.h"
#import "ESServiceNameHeader.h"
#import "ESDiskRecognitionResp.h"

NS_ASSUME_NONNULL_BEGIN
@class ESHardwareSettingModel, ESAutoPowerOnModel, ESDiskSleepModel, ESLedSwitchModel, ESDeviceTimingModel, ESUPSModel;
@interface ESHardwareSettingResp : ESBaseResp
@property (nonatomic, strong) ESHardwareSettingModel * results;
@end

@interface ESHardwareSettingModel : NSObject
@property (nonatomic, assign) BOOL autoPowerOn;
@property (nonatomic, strong) ESDiskSleepModel * diskSleep;
@property (nonatomic, strong) ESLedSwitchModel * ledSwitch;
// 定时开关机
@property (nonatomic, strong) ESDeviceTimingModel * timing;
@property (nonatomic, strong) ESUPSModel * ups;


+ (void)reqHardwareSettingInfo:(void(^)(ESHardwareSettingModel * model))successBlock fail:(void(^)(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error))failBlock;
@end

@interface ESAutoPowerOnModel : NSObject
@property (nonatomic, assign) BOOL mSwitch;
@end

@interface ESDiskSleepModel : NSObject
//多少分钟后休眠, 0 为不休眠
@property (nonatomic, assign) long sleepAfter;
@end

@interface ESLedSwitchModel : NSObject
@property (nonatomic, assign) BOOL diskLed;
@property (nonatomic, assign) BOOL statusLed;
@end


@interface ESDeviceTimingItemModel : NSObject
// hhMM 格式
@property (nonatomic, strong) NSString * time;
// 1:星期一, ... 7:星期日
@property (nonatomic, strong) NSMutableArray<NSNumber *> * weekday;

- (int)getHour;
- (int)getMinute;
- (void)setTime:(int)hour minute:(int)minute;
@end

@interface ESDeviceTimingModel : NSObject
@property (nonatomic, assign) BOOL shutdown;
// hh:MM 格式
@property (nonatomic, strong) NSString * shutdownTimer;
@property (nonatomic, assign) BOOL startup;
// hh:MM 格式
@property (nonatomic, strong) NSString * startupTimer;
// 1:星期一, ... 7:星期日
@property (nonatomic, strong) NSMutableArray<NSNumber *> * weekday;

- (int)getStartUpHour;
- (int)getStartUpMinute;

- (int)getShutDownHour;
- (int)getShutDownMinute;

- (void)setStartUpTime:(int)hour minute:(int)minute;
- (void)setShutDownTime:(int)hour minute:(int)minute;

@end

@class ESUPDInfoModel;
@interface ESUPSModel : NSObject

@property (nonatomic, assign) BOOL mSwitch;
// 0 : 立即
@property (nonatomic, assign) long minsBeforeStandby;
@property (nonatomic, strong) ESUPDInfoModel * info;

@end

@interface ESUPDInfoModel : NSObject
//单位为百分比
@property (nonatomic, assign) float battery;
@property (nonatomic, strong) NSString * manufactory;
@property (nonatomic, strong) NSString * model;
//单位为分钟
@property (nonatomic, assign) float predictPowerTime;
@property (nonatomic, assign) BOOL status;
@end

@interface ESDiskSmartItemModel : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) long rawValue;
@property (nonatomic, assign) long threshold;
@property (nonatomic, assign) long value;
@property (nonatomic, assign) long worst;
@property (nonatomic, assign) BOOL exception;
@end

@interface ESDiskSmartReportModel : NSObject
@property (nonatomic, assign) BOOL healthy;
@property (nonatomic, assign) long nextTestTime;
@property (nonatomic, assign) long testTime;
@property (nonatomic, strong) NSMutableArray<ESDiskSmartItemModel *> * attributes;
@end

@interface ESDiskSmartModel : NSObject
@property (nonatomic, assign) BOOL testing;
@property (nonatomic, assign) long testProgress;
@property (nonatomic, strong) ESDiskSmartReportModel * smartReport;
@end



@interface ESDiskSmartResp : ESBaseResp
@property (nonatomic, strong) ESDiskSmartModel * results;
@end

typedef NS_ENUM(NSUInteger, ESDiskSmartStatus) {
    ESDiskSmartStatus_Normal = 0, // 正常
    ESDiskSmartStatus_Abnormal = 1, // 异常
    ESDiskSmartStatus_Unknown = 2, // 未知
};

@interface ESDiskStatusItemModel : NSObject
@property (nonatomic, assign) ESDiskStorageEnum busNumber;

//磁盘温度
@property (nonatomic, assign) long diskTemp;
//0 : 正常 1：异常 2.未知
@property (nonatomic, assign) ESDiskSmartStatus smartStatus;

@end

@interface ESDiskStatusModel : NSObject
// integer 风扇转速百分比 30 即表示30%
@property (nonatomic, assign) long fanSpeed;
@property (nonatomic, strong) NSMutableArray<ESDiskStatusItemModel *> * diskStatus;
@end

@interface ESCpuMemModel : NSObject
//cpu 温度
@property (nonatomic, assign) long cpuTemp;
//cpu 使用率
@property (nonatomic, assign) long cpuUsage;
//内存总大小
@property (nonatomic, assign) long memTotal;
//已使用内存
@property (nonatomic, assign) long memUsed;
@end

// 实时网络流量
@interface ESDeviceTrafficModel : NSObject
//下行速率
@property (nonatomic, assign) long receive;
//上行速率
@property (nonatomic, assign) long transmit;
@end

NS_ASSUME_NONNULL_END
