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
//  ESDeviceInfoModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeviceInfoModel.h"
#import "ESDeviceInfoResultModel.h"

@implementation ESDeviceStorageInfoModel

- (CGFloat)usageProcess {
    if (self.totalSize > 0 && self.usagedSize > 0) {
        return self.usagedSize * 1.0 / self.totalSize;
    }
    return 0.0;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setTotalSize:[[aDecoder decodeObjectForKey:@"totalSize"] integerValue]];
        [self setUsagedSize:[[aDecoder decodeObjectForKey:@"usagedSize"] integerValue]];
        [self setFreeSize:[[aDecoder decodeObjectForKey:@"freeSize"] integerValue]];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.totalSize) forKey:@"totalSize"];
    [aCoder encodeObject:@(self.usagedSize) forKey:@"usagedSize"];
    [aCoder encodeObject:@(self.freeSize) forKey:@"freeSize"];
}

@end

@implementation ESServiceDetailModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setCreated:[[aDecoder decodeObjectForKey:@"created"] doubleValue]];
        [self setServiceName:[aDecoder decodeObjectForKey:@"serviceName"]];
        [self setVersion:[aDecoder decodeObjectForKey:@"version"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.created) forKey:@"created"];
    [aCoder encodeObject:self.serviceName forKey:@"serviceName"];
    [aCoder encodeObject:self.version forKey:@"version"];
}

@end

@implementation ESSystemInfoModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setSpaceVersion:[aDecoder decodeObjectForKey:@"spaceVersion"]];
        [self setOsVersion:[aDecoder decodeObjectForKey:@"osVersion"]];
        [self setServiceItems:[aDecoder decodeObjectForKey:@"serviceItems"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.spaceVersion forKey:@"spaceVersion"];
    [aCoder encodeObject:self.osVersion forKey:@"osVersion"];
    [aCoder encodeObject:self.serviceItems forKey:@"serviceItems"];
}

@end

@implementation ESDeviceInfoModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _systemInfo = [ESSystemInfoModel new];
        _storageInfo = [ESDeviceStorageInfoModel new];
    }
    return self;
}

- (void)updateWithDeviceInfoResultModel:(ESDeviceInfoResultModel *)resultModel {
    self.deviceName = resultModel.deviceName;
    self.productModel = resultModel.productModel;
    self.deviceLogoUrl = resultModel.deviceLogoUrl;
    self.snNumber = resultModel.snNumber;
    
    self.systemInfo.spaceVersion = resultModel.spaceVersion;
    self.systemInfo.osVersion = resultModel.osVersion;
    
    NSMutableArray *serviceDetailItems = [NSMutableArray array];
    [resultModel.serviceVersion enumerateObjectsUsingBlock:^(ESServiceInfoResultModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ESServiceDetailModel *detailItem = [ESServiceDetailModel new];
        detailItem.created = obj.created;
        detailItem.serviceName = obj.serviceName;
        detailItem.version = obj.version;
        
        [serviceDetailItems addObject:detailItem];
    }];
    
    self.systemInfo.serviceItems = [serviceDetailItems copy];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setDeviceName:[aDecoder decodeObjectForKey:@"deviceName"]];
        [self setProductModel:[aDecoder decodeObjectForKey:@"productModel"]];
        [self setDeviceLogoUrl:[aDecoder decodeObjectForKey:@"deviceLogoUrl"]];
        [self setSnNumber:[aDecoder decodeObjectForKey:@"snNumber"]];
        [self setSystemInfo:[aDecoder decodeObjectForKey:@"systemInfo"]];
        [self setStorageInfo:[aDecoder decodeObjectForKey:@"storageInfo"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.deviceName forKey:@"deviceName"];
    [aCoder encodeObject:self.productModel forKey:@"productModel"];
    [aCoder encodeObject:self.deviceLogoUrl forKey:@"deviceLogoUrl"];
    [aCoder encodeObject:self.snNumber forKey:@"snNumber"];
    [aCoder encodeObject:self.systemInfo forKey:@"systemInfo"];
    [aCoder encodeObject:self.storageInfo forKey:@"storageInfo"];
}

@end

