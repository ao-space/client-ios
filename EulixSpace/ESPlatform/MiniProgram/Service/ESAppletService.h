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
//  ESAppletService.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESApiClient.h"
#import "ESAppletResponseBase.h"
#import "ESAppletResponseBaseListAppletInfoRes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESAppletService : NSObject

extern NSString* kESAppletServiceErrorDomain;
extern NSInteger kESAppletServiceMissingParamErrorCode;
//
/// 请求安装小应用
///
/// @param appletId applet_id (optional)
///
///  code:200 message:"OK"
///
/// @return ESResponseBase1*
-(NSURLSessionTask*) spaceV1ApiAppletInstallPostWithAppletId: (NSString*) appletId
    completionHandler: (void (^)(ESAppletResponseBase* output, NSError* error)) handler;


///
/// 获取已安装小应用信息
///
///
///  code:200 message:"OK"
///
/// @return ESResponseBaseListAppletInfoRes*
-(NSURLSessionTask*) spaceV1ApiAppletInstalledInfoGetWithCompletionHandler:
    (void (^)(ESAppletResponseBaseListAppletInfoRes* output, NSError* error)) handler;


///
/// 卸载已安装小应用
///
/// @param appletId applet_id
///
///  code:200 message:"OK"
///
/// @return ESResponseBase1*
-(NSURLSessionTask*) spaceV1ApiAppletUninstallPostWithAppletId: (NSString*) appletId
    completionHandler: (void (^)(ESAppletResponseBase* output, NSError* error)) handler;


///
/// 请求更新小应用
///
/// @param appletId applet_id
///
///  code:200 message:"OK"
///
/// @return ESResponseBase1*
-(NSURLSessionTask*) spaceV1ApiAppletUpdatePutWithAppletId: (NSString*) appletId
    completionHandler: (void (^)(ESAppletResponseBase* output, NSError* error)) handler;

///
/// 获取所有小应用信息
///
///
///  code:200 message:"OK"
///
/// @return ESResponseBaseListAppletInfoRes*
-(NSURLSessionTask*) spaceV1ApiGatewayAppletInfoGetWithCompletionHandler:
    (void (^)(ESAppletResponseBaseListAppletInfoRes* output, NSError* error)) handler;


@end

NS_ASSUME_NONNULL_END
