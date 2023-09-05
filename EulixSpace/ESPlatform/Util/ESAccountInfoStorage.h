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
//  ESAccountInfoStorage.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESAccountType) {
    ESAccountTypeUnkown,
    ESAccountTypeAdmin,        //管理员原绑定
    ESAccountTypeAdminAuth,    //管理员授权
    ESAccountTypeMember,       //成员原绑定
    ESAccountTypeMemberAuth,   //成员原授权
};

@class ESBoxItem;
@interface ESAccountInfoStorage : NSObject

@property (nonatomic, readonly, class) NSString *userId; //原理解 通 boxUUID， 不能区分用户
@property (nonatomic, readonly, class) NSString *userUniqueId; //用户唯一标识 BoxUUID + bindType + aoId
@property (nonatomic, readonly, class) NSString *userUniqueKey;//用户唯一标识 BoxUUID + bindType + domain

@property (nonatomic, readonly, class) NSString *avatarPath;
@property (nonatomic, readonly, class) UIImage *avatarImage;

@property(nonatomic, readonly, class) NSString* personalName;
@property(nonatomic, readonly, class) NSString* personalSign;
@property(nonatomic, readonly, class) ESAccountType accountType;

+ (BOOL)isAdminOrAuthAccount;
//管理员账号登录
+ (BOOL)isAdminAccount;
+ (BOOL)isAdminAccount:(ESBoxItem *)box;
//授权账号
+ (BOOL)isAuthAccount;
+ (BOOL)isAuthAccount:(ESBoxItem *)box;
//成员账号
+ (BOOL)isMemberAccount;
+ (BOOL)isMemberAccount:(ESBoxItem *)box;

//账号具体类型
+ (ESAccountType)accountType:(ESBoxItem *)box;
//账号类型是 管理员原绑定|管理员授权
+ (BOOL)currentAccountIsAdminType;

@end

NS_ASSUME_NONNULL_END
