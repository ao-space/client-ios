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
//  ESBindInitResp.m
//  EulixSpace
//
//  Created by dazhou on 2022/11/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBindInitResp.h"
#import "ESBCResult.h"
#import "ESBoxManager.h"

@implementation ESBindInitResp


@end


@implementation ESBindNetworkModel

@end

@implementation ESBindInitResultModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"network" : [ESBindNetworkModel class]
    };
}


- (NSString *)linkName {
    __block ESBindNetworkModel *item = self.network.firstObject;
    [self.network enumerateObjectsUsingBlock:^(ESBindNetworkModel *_Nonnull obj,
                                               NSUInteger idx,
                                               BOOL *_Nonnull stop) {
        if (!obj.wire) {
            item = obj;
            *stop = YES;
        }
    }];
    if (!item) {
        return nil;
    }
    return item.wire ? NSLocalizedString(@"box_network_local_network", @"本地连接") : item.wifiName;
}

- (NSString *)realHost {
    return [NSString stringWithFormat:@"%@:5678", self.realIpAddress];
}

- (NSString *)realIpAddress {
    __block ESBindNetworkModel *item = self.network.firstObject;
    [self.network enumerateObjectsUsingBlock:^(ESBindNetworkModel *_Nonnull obj,
                                               NSUInteger idx,
                                               BOOL *_Nonnull stop) {
        if (!obj.wire) {
            item = obj;
            *stop = YES;
        }
    }];
    return item.ip;
}

- (BOOL)unpaired {
    return self.paired == ESPairStatusUnpaired || self.paired == ESPairStatusPairedWithoutAdmin;
}

- (BOOL)oldBox {
    return self.paired == ESPairStatusPairedWithoutAdmin || self.paired == ESPairStatusPaired;
}


@end


@implementation ESDeviceAbilityModel

- (BOOL)isRaspberryBox {
    return _deviceModelNumber < 200 && _deviceModelNumber >= 0;
}

- (BOOL)isGen2Box {
    return _deviceModelNumber < 300 && _deviceModelNumber >= 200;
}

//-100到-199
//虚拟机版本
//傲空间PC版
//
//-200到-299
//云试用容器版本
//傲空间在线版
//
//-300到-399
//PC容器版本
//傲空间PC版

- (BOOL)isTrialBox {
    return [self isPCTrialBox] || [self isOnlineTrialBox];
}

- (BOOL)isPCTrialBox {
    return [self isPCVersion] || [self isVMVersion];
}

- (BOOL)isOnlineTrialBox {
    return [self isOnlineVersion];
}

- (BOOL)isPCVersion {
    return _deviceModelNumber >= -399 && _deviceModelNumber <= -300;
}

- (BOOL)isVMVersion {
    return _deviceModelNumber >= -199 && _deviceModelNumber <= -100;
}

- (BOOL)isOnlineVersion {
    return _deviceModelNumber >= -299 && _deviceModelNumber <= -200;;
}

- (UIImage *)boxIcon {
    NSString *iconName = @"box_info_v1_logo";
    if ([self isPCTrialBox]) {
        iconName = @"box_info_logo_computer";
    } else if ([self isOnlineTrialBox]) {
        iconName = @"box_info_logo_cloud";
    } else if (![self isRaspberryBox]) {
        iconName = @"box_info_v2_logo";
    }
    
    return [UIImage imageNamed:iconName];
}

- (NSString *)boxName {
    if (self.openSource) {
        return NSLocalizedString(@"es_box_open_source", @"傲空间（开源版）");;
    }
    if ([self isPCTrialBox]) {
        return NSLocalizedString(@"box_pc", @"傲空间（私有部署）");
    } else if ([self isOnlineTrialBox]) {
        return NSLocalizedString(@"box_cloud", @"傲空间（在线版）");
    } else if ([self isRaspberryBox]) {
        return NSLocalizedString(@"box_gen_1", @"傲空间（第一代）");
    } else if ([self isGen2Box]) {
        return NSLocalizedString(@"box_gen_2", @"傲空间（第二代）");
    }
    
    return NSLocalizedString(@"box_default", @"傲空间");
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    if (![dic.allKeys containsObject:@"backupRestoreSupport"]) {
        self.backupRestoreSupport = YES;
    }
    
    if (![dic.allKeys containsObject:@"aospaceappSupport"]) {
        self.aospaceappSupport = YES;
    }
    if (![dic.allKeys containsObject:@"aospaceDevOptionSupport"]) {
        self.aospaceDevOptionSupport = YES;
    }
    
    return YES;
}
@end


@implementation ESDeviceAbilityResp

@end
