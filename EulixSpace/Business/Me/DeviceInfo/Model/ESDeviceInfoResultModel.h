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
//  ESDeviceInfoResultModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/7/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESServiceInfoResultModel : NSObject

@property (nonatomic, assign) NSTimeInterval created;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, copy) NSString *version;

@end

@interface ESServiceDetailResultModel : NSObject

@property (nonatomic, copy) NSString *Containers;
@property (nonatomic, assign) NSTimeInterval Created;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *Labels;
@property (nonatomic, copy) NSString *ParentId;
@property (nonatomic, copy) NSArray<NSString *> *RepoDigests;
@property (nonatomic, copy) NSArray<NSString *> *RepoTags;
@property (nonatomic, copy) NSString *RepoTag;
@property (nonatomic, assign) NSUInteger SharedSize;
@property (nonatomic, assign) NSUInteger Size;
@property (nonatomic, assign) NSUInteger VirtualSize;

@end


@interface ESDeviceInfoResultModel : NSObject

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *productModel;
@property (nonatomic, copy) NSString *deviceNameEn;
@property (nonatomic, copy) NSString *generationEn;
@property (nonatomic, copy) NSString *deviceLogoUrl;
@property (nonatomic, copy) NSString *snNumber;
@property (nonatomic, copy) NSString *spaceVersion;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSArray<ESServiceInfoResultModel *> *serviceVersion;
@property (nonatomic, copy) NSArray<ESServiceDetailResultModel *> *serviceDetail;

@end

NS_ASSUME_NONNULL_END
