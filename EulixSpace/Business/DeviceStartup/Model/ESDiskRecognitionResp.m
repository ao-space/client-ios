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
//  ESDiskRecognitionResp.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDiskRecognitionResp.h"


@implementation ESDiskInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"partedNames" : [NSString class],
             @"partedUniIds" : [NSString class]
    };
}

- (ESDiskStorageEnum)getDiskStorageEnum {
//    switch (self.transportType) {
//        case 1:
//            return ESDiskStorage_Disk1;
//        case 2:
//            return ESDiskStorage_Disk2;
//        case 3:
//            return ESDiskStorage_SSD;
//    }
//    return ESDiskStorage_UnKnown;
    
    return self.busNumber;
}

- (NSString *)getDiskName {
    if (self.busNumber == ESDiskStorage_Disk1) {
        return NSLocalizedString(@"Disk 1", @"磁盘 1");
    }
    if (self.busNumber == ESDiskStorage_Disk2) {
        return NSLocalizedString(@"Disk 2", @"磁盘 2");
    }
    if (self.busNumber == ESDiskStorage_SSD) {
        return NSLocalizedString(@"M2 SSD Cache", @"M.2 高速存储");
    }
    // 没匹配上就用服务端的来显示下
    return ESSafeString(self.displayName);
}

- (NSString *)getDiskShowText {
    return self.displayName;
}

// 判断当前存储是否可以扩容
- (BOOL)canExpand {
    return self.diskException == ESDiskExceptionType_Expand || self.diskException == ESDiskExceptionType_ExpandError;
}

// 获取磁盘类型，比如 HDD/SSD
- (NSString *)getDiskType {
    ESDiskStorageEnum de = [self getDiskStorageEnum];
    if (de == ESDiskStorage_SSD) {
        return @"SSD";
    }
    return @"HDD";
}

+ (NSString *)getDiskPhysicalName:(ESDiskStorageEnum)busNumber {
    if (busNumber == ESDiskStorage_Disk1) {
        return NSLocalizedString(@"Disk Physical 1", @"盘位 1");
    }
    if (busNumber == ESDiskStorage_Disk2) {
        return NSLocalizedString(@"Disk Physical 2", @"盘位 2");
    }
    if (busNumber == ESDiskStorage_SSD) {
        return NSLocalizedString(@"M2 SSD Cache Physical", @"M.2 盘位");
    }
    return @"";
}

@end

@implementation ESDiskListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"diskInfos" : [ESDiskInfoModel class] };
}

- (BOOL)hasDisk:(ESDiskStorageEnum)num {
    __block bool has = NO;
    [self.diskInfos enumerateObjectsUsingBlock:^(ESDiskInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ESDiskStorageEnum disk = [obj getDiskStorageEnum];
        if (disk == num) {
            has = YES;
            *stop = YES;
        }
    }];
    return has;
}

- (ESDiskInfoModel *)getDiskInfo:(ESDiskStorageEnum)num {
    __block ESDiskInfoModel * result = nil;
    [self.diskInfos enumerateObjectsUsingBlock:^(ESDiskInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ESDiskStorageEnum disk = [obj getDiskStorageEnum];
        if (disk == num) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

@end

@implementation ESDiskRecognitionResp

@end



@implementation ESSpaceReadyCheckResp

@end


@implementation ESSpaceReadyCheckResultModel

@end


@implementation ESDiskInitializeProgressModel

- (NSString *)toString {
    NSMutableString * mStr = [[NSMutableString alloc] init];
    [mStr appendFormat:@"initialCode:%ld, ", self.initialCode];
    [mStr appendFormat:@"initialMessage:%@, ", self.initialMessage];
    [mStr appendFormat:@"initialProgress:%ld", self.initialProgress];
    
    return mStr;
}

@end


@implementation ESDiskInitializeProgressResp

@end


@implementation ESDiskInitializeReq

- (instancetype)init {
    if (self = [super init]) {
        self.primaryStorageHwIds = [NSMutableArray array];
        self.raidDiskHwIds = [NSMutableArray array];
        self.secondaryStorageHwIds = [NSMutableArray array];
    }
    return self;
}

- (void)clearAllHwIds {
    [self.primaryStorageHwIds removeAllObjects];
    [self.raidDiskHwIds removeAllObjects];
    [self.secondaryStorageHwIds removeAllObjects];
}

@end


@implementation ESDiskManagementModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"PrimaryStorageHwIds" : [NSString class],
             @"diskManageInfos" : [ESDiskInfoModel class],
             @"primaryStorageHwIds" : [NSString class],
             @"raidDiskHwIds" : [NSString class],
             @"secondaryStorageMountPaths" : [NSString class],
    };
}

@end

@implementation ESDiskManagementListResp


@end


@implementation ESRaidInfoModel

@end


@implementation ESDiskManagementExpandReq

- (instancetype)init {
    if (self = [super init]) {
        self.raidDiskHwIds = [NSMutableArray array];
        self.secondaryStorageHwIds = [NSMutableArray array];
    }
    return self;
}

@end

@implementation ESDiskManagementExpandProgressModel

- (NSString *)toString {
    NSMutableString * mStr = [[NSMutableString alloc] init];
    [mStr appendFormat:@"expandCode:%ld, ", self.expandCode];
    [mStr appendFormat:@"expandMessage:%@, ", self.expandMessage];
    [mStr appendFormat:@"expandProgress:%ld", self.expandProgress];
    
    return mStr;
}

@end

@implementation ESDiskManagementExpandProgressResp


@end


