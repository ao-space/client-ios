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
//  ESNotifiManager.h
//  EulixSpace
//
//  Created by dazhou on 2022/7/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESOptTypeHeader.h"
#import "ESDiskRecognitionResp.h"

NS_ASSUME_NONNULL_BEGIN


@interface ESNotifiModel : NSObject

@property (nonatomic, strong) NSString * optType;
@property (nonatomic, strong) NSString * messageId;
@property (nonatomic, strong) NSString * subdomain;
@property (nonatomic, strong) NSString * d;
@property (nonatomic, assign) int p;

@property (nonatomic, strong) NSString * alertTitle;
@property (nonatomic, strong) NSString * alertBody;

@property (nonatomic, strong) NSString * applyId;

@end

@interface ESNotiHardwareModel : NSObject
@property (nonatomic, assign) ESDiskStorageEnum busNumber;
@property (nonatomic, assign) long eventTime;
@property (nonatomic, assign) long battery;
- (NSString *)getTimeString;
@end


@interface ESNotifiManager : NSObject

+ (BOOL)processNotifi:(NSDictionary *)userInfo;
+ (BOOL)needShowAlertWhenPresentNotification:(NSDictionary *)userInfo;

//做兼容，特殊推送没走后台推送，
+ (BOOL)needProcessAlertWhenPresentNotification:(NSDictionary *)userInfo;
@end

NS_ASSUME_NONNULL_END
