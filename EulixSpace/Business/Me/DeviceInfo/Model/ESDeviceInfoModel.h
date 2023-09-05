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
//  ESDeviceInfoModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESDeviceStorageInfoModel : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) BOOL showBgImage;

@property (nonatomic, assign) UInt64 totalSize;
@property (nonatomic, assign) UInt64 usagedSize;
@property (nonatomic, assign) UInt64 freeSize;

@property (nonatomic, readonly) CGFloat usageProcess;

@end

@interface ESServiceDetailModel : NSObject

@property (nonatomic, assign) NSTimeInterval created;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, copy) NSString *version;

@end

@interface ESSystemInfoModel : NSObject

@property (nonatomic, copy) NSString *spaceVersion;
@property (nonatomic, copy) NSString *osVersion;

@property (nonatomic, copy) NSArray<ESServiceDetailModel *> *serviceItems;

@end

@class ESDeviceInfoResultModel;

@interface ESDeviceInfoModel : NSObject

@property (nonatomic, strong) ESSystemInfoModel *systemInfo;
@property (nonatomic, strong) ESDeviceStorageInfoModel *storageInfo;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *productModel;
@property (nonatomic, copy) NSString *deviceLogoUrl;
@property (nonatomic, copy) NSString *snNumber;

- (void)updateWithDeviceInfoResultModel:(ESDeviceInfoResultModel *)resultModel;

@end

NS_ASSUME_NONNULL_END
