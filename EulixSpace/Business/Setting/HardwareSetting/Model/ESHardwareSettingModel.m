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
//  ESHardwareSettingModel.m
//  EulixSpace
//
//  Created by dazhou on 2023/6/15.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESHardwareSettingModel.h"
#import "ESNetworkRequestManager.h"
#import "ESCache.h"
#import "ESBoxManager.h"

@implementation ESHardwareSettingResp


@end

@implementation ESHardwareSettingModel

+ (void)reqHardwareSettingInfo:(void(^)(ESHardwareSettingModel * model))successBlock fail:(void(^)(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error))failBlock {
    NSString * key = [NSString stringWithFormat:@"%@_hardware_settings", ESBoxManager.activeBox.uniqueKey];
    ESHardwareSettingModel * localModel = [[ESCache defaultCache] objectForKey:key];
    if (localModel && successBlock) {
        successBlock(localModel);
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:@"hardware_settings" queryParams:nil header:nil body:nil modelName:@"ESHardwareSettingModel" successBlock:^(NSInteger requestId, ESHardwareSettingModel * response) {
        if (successBlock) {
            successBlock(response);
        }
        [[ESCache defaultCache] setObject:response forKey:key];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (failBlock) {
            failBlock(requestId, response, error);
        }
    }];
}

@end


@implementation ESAutoPowerOnModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"mSwitch"  : @"switch"};
}

@end

@implementation ESDiskSleepModel

@end

@implementation ESLedSwitchModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    ESLedSwitchModel * model = [[[self class] allocWithZone:zone] init];
    model.diskLed = self.diskLed;
    model.statusLed = self.statusLed;
    return model;
}

@end

@implementation ESDeviceTimingModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"weekday" : [NSNumber class] };
}

- (int)getStartUpHour {
    return [self.startupTimer componentsSeparatedByString:@":"].firstObject.intValue;
}

- (int)getStartUpMinute {
    return [self.startupTimer componentsSeparatedByString:@":"].lastObject.intValue;
}

- (int)getShutDownHour {
    return [self.shutdownTimer componentsSeparatedByString:@":"].firstObject.intValue;
}

- (int)getShutDownMinute {
    return [self.shutdownTimer componentsSeparatedByString:@":"].lastObject.intValue;
}

- (void)setStartUpTime:(int)hour minute:(int)minute {
    self.startupTimer = [NSString stringWithFormat:@"%02d:%02d", hour, minute];
}

- (void)setShutDownTime:(int)hour minute:(int)minute {
    self.shutdownTimer = [NSString stringWithFormat:@"%02d:%02d", hour, minute];
}

@end

@implementation ESDeviceTimingItemModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"weekday" : [NSNumber class] };
}

- (int)getHour {
    if (self.time.length == 4) {
        NSString * hour = [self.time substringToIndex:2];
        return hour.intValue;
    }
    return 0;
}

- (int)getMinute {
    if (self.time.length == 4) {
        NSString * minute = [self.time substringFromIndex:2];
        return minute.intValue;
    }
    return 0;
}

- (void)setTime:(int)hour minute:(int)minute {
    self.time = [NSString stringWithFormat:@"%02d%02d", hour, minute];
}

@end

@implementation ESUPSModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"mSwitch"  : @"switch"};
}
@end


@implementation ESDiskSmartResp

@end

@implementation ESDiskSmartModel

@end

@implementation ESDiskSmartReportModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"attributes" : [ESDiskSmartItemModel class] };
}
@end

@implementation ESDiskSmartItemModel

@end

@implementation ESDiskStatusItemModel

@end

@implementation ESDiskStatusModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"diskStatus" : [ESDiskStatusItemModel class] };
}

@end


@implementation ESCpuMemModel

@end

@implementation ESUPDInfoModel

@end


@implementation ESDeviceTrafficModel
@end
