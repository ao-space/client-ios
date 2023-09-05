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
//  ESJoinSpaceController.h
//  EulixSpace
//
//  Created by dazhou on 2023/4/3.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"
#import "ESBoxItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESInviteInfoManage : NSObject
+ (ESInviteInfoManage *)Instance;
@property (nonatomic, strong) NSString * inviteUrl;
@end

@interface ESMemberInviteModel : NSObject
// 格式：/member/accept?subdomain=sl9rspr5.dev-space.eulix.xyz
@property (nonatomic, strong) NSString * inviteparam;
@property (nonatomic, strong) NSString * invitecode;
@property (nonatomic, strong) NSString * keyfingerprint;
@property (nonatomic, strong) NSString * account;
@property (nonatomic, strong) NSString * member;
@property (nonatomic, strong) NSString * aoid;

@property (nonatomic, strong) NSString * spaceName;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) ESBoxItem *boxItem;
// 单位：毫秒
@property (nonatomic, assign) NSTimeInterval create;
// 单位：毫秒
@property (nonatomic, assign) NSTimeInterval expire;

- (NSString *)getSubdomain;
@end

NS_ASSUME_NONNULL_END
