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
//  ESAppletScopesManager.h
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ESAppletAuthStatus)
{
    ESAppletAuthStatusNotDetermined = 0, //未确定授权状态
    ESAppletAuthStatusNoAuthorized, //没有该功能授权
    ESAppletAuthStatusAuthorized, //该功能已授权
};

typedef NS_ENUM(NSInteger, ESAppletAccessAuthType)
{
    ESAppletAccessAuthTypeContact = 0, //通讯录
    ESAppletAccessAuthTypeUnkown,
};

typedef void (^ESAppletAuthRequestCompeltionCallback)(BOOL granted, NSError * _Nullable error);

@interface ESAppletBaseInfo : NSObject

@property (nonatomic, copy) NSString *appletId;
@property (nonatomic, copy) NSString *appletSecret;
@property (nonatomic, copy) NSString *appletVersion;

@end


@interface ESAppletScopesManager : NSObject

+ (instancetype)shared;

- (void)requestAccessAuthWithType:(ESAppletAccessAuthType)accessAuthType
                       appletInfo:(ESAppletBaseInfo *)appletInfo
                completionHandler:(ESAppletAuthRequestCompeltionCallback)callback;

- (ESAppletAuthStatus)authorizationStatusForAccessType:(ESAppletAccessAuthType)accessAuthType
                                              appletId:(NSString *)appletId;

- (void)clearAuthStatusWithAppletId:(NSString *)appletId;

@end

NS_ASSUME_NONNULL_END
