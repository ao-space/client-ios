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
//  ESNotifiResp.h
//  EulixSpace
//
//  Created by dazhou on 2022/7/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBaseResp.h"


NS_ASSUME_NONNULL_BEGIN

@interface ESNotifiSecurityTokenResp : NSObject
@property (nonatomic, strong) NSString * authClientUUid;
@property (nonatomic, strong) NSString * authDeviceInfo;
@property (nonatomic, assign) long authUserId;
@property (nonatomic, strong) NSString * requestId;

@property (nonatomic, strong) NSString * securityToken;
@property (nonatomic, strong) NSString * expiredAt;
@property (nonatomic, strong) NSString * applyId;
@end

@interface ESNotifiDetailModel : NSObject

@property (nonatomic, strong) NSString * clientUUID;
@property (nonatomic, strong) NSString * createAt;
@property (nonatomic, strong) NSString * messageId;
@property (nonatomic, strong) NSString * optType;
@property (nonatomic, strong) NSString * requestId;

@property (nonatomic, strong) NSString * data;

@end

@interface ESNotifiResp : ESBaseResp


@property (nonatomic, strong) ESNotifiDetailModel * results;


@end


@interface ESAuthApplyRsp : NSObject
@property (nonatomic, assign) BOOL accept;
@property (nonatomic, strong) NSString * applyId;
@property (nonatomic, strong) NSString * clientUuid;
@property (nonatomic, strong) NSString * msgType;
@property (nonatomic, strong) NSString * requestId;

@property (nonatomic, strong) NSString * securityToken;
@property (nonatomic, strong) NSString * expiredAt;
@end

NS_ASSUME_NONNULL_END
