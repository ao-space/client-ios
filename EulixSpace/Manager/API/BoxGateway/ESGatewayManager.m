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
//  ESGatewayManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESGatewayManager.h"
#import "ESAES.h"
#import "ESToast.h"
#import "ESBoxManager.h"
#import "ESRSACenter.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "ESApiClient.h"
#import "ESSpaceGatewayAdminAuthingServiceApi.h"
#import "ESSpaceGatewayGenericCallServiceApi.h"
#import "ESSpaceGatewayMemberAuthingServiceApi.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "ESApiClient+ESHost.h"
#import "ESLocalNetworking.h"
#import "ESLoopPollManager.h"
#import "NSError+ESTool.h"

@interface ESBoxItem ()

@property (nonatomic, strong) ESCreateTokenResult *tokenResult;

@property (nonatomic, strong) ESTokenItem *pairToken;

@property (nonatomic, copy) NSString *clientUUID;

@end

@interface ESGatewayManager ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

@implementation ESGatewayManager {
    dispatch_semaphore_t _lock;
}

+ (BOOL)shouldUseLanHost:(NSString *)lanHost
            reachableBox:(ESBoxItem *)reachableBox
               activeBox:(ESBoxItem *)activeBox {
    if (lanHost.length == 0 || !reachableBox || !activeBox) {
        return NO;
    }
    if (reachableBox.boxUUID.length > 0 && activeBox.boxUUID.length > 0) {
        return [reachableBox.boxUUID isEqualToString:activeBox.boxUUID];
    }
    return [reachableBox isEqual:activeBox];
}

+ (BOOL)isActiveBoxRequest:(ESBoxItem *)requestBox
                 activeBox:(ESBoxItem *)activeBox {
    // If there is no active box yet, do not block request startup.
    if (!requestBox || !activeBox) {
        return YES;
    }
    if (requestBox.boxUUID.length > 0 && activeBox.boxUUID.length > 0) {
        return requestBox.boxType == activeBox.boxType &&
               [requestBox.boxUUID isEqualToString:activeBox.boxUUID];
    }
    return [requestBox isEqual:activeBox];
}

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        _queue = dispatch_queue_create("xyz.eulix.space.gateway", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (ESTokenItem *)onGetToken:(ESCreateTokenResult *)output box:(ESBoxItem *)activeBox {
    activeBox.tokenResult = output;
    activeBox.pairToken = [ESTokenItem tokenFrom:output];
    return activeBox.pairToken;
}

- (ESTokenItem *)onGetToken:(ESCreateTokenResult *)output box:(ESBoxItem *)activeBox tmpAesKey:(NSString *)tmpAesKey {
    activeBox.tokenResult = output;
    activeBox.pairToken = [ESTokenItem tokenFrom:output tmpAesKey:tmpAesKey];
    return activeBox.pairToken;
}

+ (void)token:(ESGatewayManageOnToken)callback {
    [self token:ESBoxManager.activeBox defaultHeaders:nil callback:callback];
}

+ (void)token:(ESBoxItem *)activeBox defaultHeaders:(NSDictionary *)defaultHeaders callback:(ESGatewayManageOnToken)callback {
    [ESGatewayManager.manager token:activeBox defaultHeaders:defaultHeaders callback:callback];
}

- (void)token:(ESBoxItem *)activeBox defaultHeaders:(NSDictionary *)defaultHeaders callback:(ESGatewayManageOnToken)callback {
    activeBox = activeBox ?: ESBoxManager.activeBox;
    dispatch_async(self.queue, ^{
        Lock();
        if (![ESGatewayManager isActiveBoxRequest:activeBox activeBox:ESBoxManager.activeBox]) {
            ESDLog(@"[ESGatewayManager] skip stale box token request request:%@ active:%@",
                   ESSafeString(activeBox.boxUUID),
                   ESSafeString(ESBoxManager.activeBox.boxUUID));
            NSError *staleError = [NSError errorWithDomain:NSURLErrorDomain
                                                      code:NSURLErrorCancelled
                                                  userInfo:@{NSLocalizedDescriptionKey : @"stale box token request cancelled"}];
            [self callback:callback token:nil error:staleError];
            Unlock();
            return;
        }
        ///授权的盒子
        if (activeBox.auth) {
            if (activeBox.authToken.valid) {
                [self callback:callback token:activeBox.authToken error:nil];
                Unlock();
            } else {
              //  刷新token
                [self refreshToken:activeBox
                          callback:^(ESTokenItem *token, NSError *error) {
                              [self callback:callback token:token error:error];
                              Unlock();
                          }];
           }
            return;
        }
        /// 当前获取的token 是可以用的
        /// 配对的和成员的token 存在同一个对象里
        if (activeBox.tokenResult.valid) {
            [self callback:callback token:activeBox.pairToken error:nil];
            Unlock();
            return;
        }
        ///调用成员获取token的方法
        NSDictionary *dic = [ESBoxManager cacheInfoForBox:activeBox];
        NSString *userDomain = dic[@"userDomain"];;
        NSString *baseUrl = [NSString stringWithFormat:@"https://%@",userDomain];
        
        if (activeBox.enableInternetAccess == NO && activeBox.localHost.length > 0) {
            baseUrl = activeBox.localHost;
            ESDLog(@"[activeBox.localHost] lanHost:%@", baseUrl);
        }
        
        ESBoxItem *reachableBox = [ESLocalNetworking shared].reachableBox;
        NSString *lanHost = [[ESLocalNetworking shared] getLanHost];
        if ([ESGatewayManager shouldUseLanHost:lanHost reachableBox:reachableBox activeBox:activeBox]) {
            baseUrl = lanHost;
            ESDLog(@"[ESLocalNetworking] lanHost:%@", baseUrl);
        } else if (reachableBox && lanHost.length > 0) {
            ESDLog(@"[ESLocalNetworking] skip lanHost override due to box mismatch, reachable:%@ active:%@ host:%@",
                   ESSafeString(reachableBox.boxUUID),
                   ESSafeString(activeBox.boxUUID),
                   lanHost);
        }
        
        if (activeBox.boxType == ESBoxTypeMember) {
            ESCreateMemberTokenInfo *info = [ESCreateMemberTokenInfo new];
            ESRSAPair *pair = [ESRSACenter boxPair:activeBox.boxUUID];
            if (!pair.publicKey) {
                [self callback:callback token:nil error:nil];
                Unlock();
                return;
            }
            info.encryptedClientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
            info.encryptedAuthKey = [pair publicEncrypt:activeBox.info.authKey];
            NSString *tmpAesKey = [NSString randomKeyWithLength:16];
            info.tempEncryptedSecret = [pair publicEncrypt:tmpAesKey];
            
            [ESNetworkRequestManager sendRequest:baseUrl
                                           path:@"/space/v1/api/gateway/auth/token/create/member"
                                          method:@"POST"
                                     queryParams:@{}
                                          header: defaultHeaders ?:@{}
                                            body:@{ @"encryptedAuthKey" : ESSafeString(info.encryptedAuthKey),
                                                    @"encryptedClientUUID" : ESSafeString(info.encryptedClientUUID),
                                                    @"tempEncryptedSecret" : ESSafeString(info.tempEncryptedSecret),
                                                 }
                                       modelName:@"ESCreateTokenResult"
                                    successBlock:^(NSInteger requestId, ESCreateTokenResult  * _Nullable output) {
                [self callback:callback token:[self onGetToken:output box:activeBox tmpAesKey:tmpAesKey] error:nil];
                Unlock();
            } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                [self callback:callback token:nil error:error];
                ESDLog(@"Failed to create token!");
                Unlock();
            }];
            return;
        }
        ///调用配对盒子获取token的方法
        if (activeBox.boxType == ESBoxTypePairing) {
            ///管理员的获取token
            ESCreateTokenInfo *body = [ESCreateTokenInfo new];
            ESRSAPair *pair = [ESRSACenter boxPair:activeBox.boxUUID];
            if (!pair.publicKey) {
                [self callback:callback token:nil error:nil];
                Unlock();
                return;
            }
            body.encryptedClientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
            body.encryptedAuthKey = [pair publicEncrypt:activeBox.info.authKey];
            
            [ESNetworkRequestManager sendRequest:baseUrl
                                            path:@"/space/v1/api/gateway/auth/token/create"
                                          method:@"POST"
                                     queryParams:@{}
                                          header:defaultHeaders ?:@{}
                                            body:@{ @"encryptedClientUUID" : ESSafeString(body.encryptedClientUUID),
                                                    @"encryptedAuthKey" : ESSafeString(body.encryptedAuthKey),
                                                 }
                                       modelName:@"ESCreateTokenResult"
                                    successBlock:^(NSInteger requestId, ESCreateTokenResult  * _Nullable output) {
                [self callback:callback token:[self onGetToken:output box:activeBox] error:nil];
                Unlock();
            } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                [self callback:callback token:nil error:error];
                if ([[error codeString] isEqualToString:@"GW-4012"]) {
                    [[ESLoopPollManager Instance] processRevoke];
                }
                 ESDLog(@"Failed to create token!");
                Unlock();
            }];
        }
    });
}

- (void)refreshToken:(ESBoxItem *)activeBox callback:(ESGatewayManageOnToken)callback {
    ESSpaceGatewayAdminAuthingServiceApi *api = [[ESSpaceGatewayAdminAuthingServiceApi alloc] initWithApiClient:activeBox.apiClient];
    api.apiClient.boxItem = activeBox;
    ESRefreshTokenInfo *body = [ESRefreshTokenInfo new];
    body.refreshToken = activeBox.authToken.refreshToken;
    [api spaceV1ApiGatewayAuthTokenRefreshPostWithBody:body
                                     completionHandler:^(ESCreateTokenResult *output, NSError *error) {
                                         if (output) {
                                             if (callback) {
                                                 callback([ESGatewayManager.manager onGetToken:output box:activeBox], error);
                                             }
                                         } else {
                                             if (callback) {
                                                 callback(nil, error);
                                             }
                                             ESDLog(@"Failed to create token!");
                                         }
                                     }];
}

+ (void)call:(ESRealCallRequest *)request callback:(void (^)(id output, NSError *error))callback {
    [self call:ESBoxManager.activeBox request:request callback:callback];
}

+ (void)call:(ESBoxItem *)activeBox
     request:(ESRealCallRequest *)request
    callback:(void (^)(id output, NSError *error))callback {
    activeBox = activeBox ?: ESBoxManager.activeBox;
    [self token:activeBox
        defaultHeaders:request.headers
              callback:^(ESTokenItem *token, NSError *error) {
                  if (!token) {
                      if (callback) {
                          callback(nil, error);
                      }
                      return;
                  }
                  ESSpaceGatewayGenericCallServiceApi *api = [[ESSpaceGatewayGenericCallServiceApi alloc] initWithApiClient:activeBox.apiClient];
                  api.apiClient.boxItem = activeBox;
        
                  ESCallRequest *callRequest = [ESCallRequest new];
                  callRequest.accessToken = token.accessToken;

                  ESDLog(@"[GatewayCall][input] service:%@ api:%@ requestId:%@ payloadLen:%lu",
                         request.serviceName,
                         request.apiName,
                         request.requestId,
                         (unsigned long)request.json.length);
                  callRequest.body = [request.json aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
                  [api spaceV1ApiGatewayCallPostWithBody:callRequest
                                       completionHandler:^(ESRealCallResult *output, NSError *error) {
                                           NSString *plainBody = [output.body aes_cbc_decryptWithKey:token.secretKey iv:token.secretIV];
                                           if (error) {
                                               ESDLog(@"[GatewayCall][error] service:%@ api:%@ requestId:%@ error:%@",
                                                      request.serviceName,
                                                      request.apiName,
                                                      request.requestId,
                                                      error.localizedDescription);
                                           } else {
                                               ESDLog(@"[GatewayCall][output] service:%@ api:%@ requestId:%@ payloadLen:%lu",
                                                      request.serviceName,
                                                      request.apiName,
                                                      request.requestId,
                                                      (unsigned long)plainBody.length);
                                           }
                                           if (callback) {
                                               callback([plainBody toJson] ?: plainBody, error);
                                           }
                                       }];
              }];
}

- (void)callback:(ESGatewayManageOnToken)callback token:(ESTokenItem *)token error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callback) {
            callback(token, error);
        }
    });
}

@end
