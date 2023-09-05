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
//  ESAppStoreModel.h
//  EulixSpace
//
//  Created by qu on 2022/11/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+YYModel.h"

@interface ESAppInstalledModel : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, assign) NSInteger appSize;
@property (nonatomic, copy) NSString *bundle;
@property (nonatomic, assign) NSInteger downloadCount;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *packageId;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *shortDesc;
@property (nonatomic, copy) NSNumber *state;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *appletId;
@property (nonatomic, copy) NSString *appletVersion;
@property (nonatomic, copy) NSString *deployMode;
@property (nonatomic, copy) NSString *containerWebUrl;
@property (nonatomic, copy) NSString *curVersion;
@property (nonatomic, copy) NSString *installSource;

@property (nonatomic, copy) NSNumber *uninstallType;

@property (nonatomic, copy) NSNumber *stateCode;


@property (nonatomic, copy) NSString *webUrl;
@end



