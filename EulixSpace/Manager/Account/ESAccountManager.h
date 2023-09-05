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
// Created by Ye Tao on 2021/9/17.
// Copyright (c) 2021 eulix.xyz. All rights reserved.
//

#import "ESAccount.h"
#import "ESDeviceInfoResult.h"
#import "ESFileInfoPub.h"
#import "ESPersonalInfoResult.h"
#import "ESResponseBaseArrayListAccountInfoResult.h"
#import "ESResponseBaseMemberNameUpdateInfo.h"
#import "ESSyncFolderRsp.h"
#import <Foundation/Foundation.h>

@class ESBoxItem;

@interface ESAccountManager : NSObject

@property (nonatomic, strong, readonly) ESPersonalInfoResult *userInfo;

@property (nonatomic, copy, readonly) NSString *avatarPath;

+ (instancetype)manager;

- (void)loadInfo:(void (^)(ESPersonalInfoResult *info))completion;

- (void)updateName:(NSString *)name completion:(void (^)(ESResponseBaseArrayListAccountInfoResult *output))completion;

- (void)updateMemberName:(NSString *)name aoId:(NSString *)aoid completion:(void (^)(ESResponseBaseMemberNameUpdateInfo *info))completion;

- (void)updateSign:(NSString *)sign aoid:(NSString *)aoid completion:(void (^)(ESPersonalInfoResult *info))completion;
- (void)updateAvatar:(NSString *)path completion:(void (^)(void))completion;

- (void)loadAvatar:(void (^)(NSString *imagePath))completion;

- (void)loadAvatar:(NSString *)aoid completion:(void (^)(NSString *path))completion;

//非登入状态下获取box user icon
- (void)loadAvatarWithBox:(ESBoxItem *)box completion:(void (^)(NSString *path))completion;

@property (nonatomic, strong, readonly) ESDeviceInfoResult *deviceInfo;

- (void)loadDeviceStorage:(void (^)(ESDeviceInfoResult *deviceInfo))completion;

@property (nonatomic, readonly) NSUInteger memberCount;

- (void)loadMemberCount:(void (^)(NSInteger count))completion;

- (void)loadNetworkInfo:(void (^)(NSString *linkName))completion;

#pragma mark - Account

- (ESAccount *)currentAccount;

- (void)saveAccount:(ESAccount *)account;

- (void)loadAccountAutoUploadPath:(void (^)(ESSyncFolderRsp *folder))completion;

- (void)createAutoUploadPath:(ESAccount *)account completion:(void (^)(ESSyncFolderRsp *folder))completion;


- (NSString *)defaultAvatarPath:(NSString *)clientUUID aoid:(NSString *)aoid;
@end
