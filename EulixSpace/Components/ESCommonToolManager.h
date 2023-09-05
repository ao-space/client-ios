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
//  ESCommonToolManager.h
//  EulixSpace
//
//  Created by qu on 2021/10/20.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+LocalAuthentication.h"
#import "ESFormItem.h"

NS_ASSUME_NONNULL_BEGIN
#define FeedbackVersionH5 @"2.0.3"
@interface ESCommonToolManager : NSObject

+ (instancetype)manager;

+ (NSString *)judgeIphoneType:(NSString *)phoneType;

+ (NSString *)arcRandom16Str;

+(void)isBackupInComple;

+(void)isRecoverComple;


+ (BOOL)isEnglish;

- (void)lockCheck:(void (^)(BOOL success, NSError * __nullable error))reply boxUUID:(NSString *)boxUUID;

- (void)savelockSwitchOpenLock:(NSString *)openLockStr;

- (NSString *)getLockSwitchOpenLock:(NSString *)boxUUID;

- (NSString *)miniAppKey:(ESFormItem *)item;

+(BOOL)isShowMsgTime:(NSString *) beginTime endTime:(NSString *) endTime;

+ (NSInteger)compareVersion:(NSString *)version1 withVersion:(NSString *)version2;
+ (NSString *)getCurrentTime;
- (void)toWebFeedbackWithImage:(nullable UIImage *)screenshotImage;

+ (NSString *)miniAppKey:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
