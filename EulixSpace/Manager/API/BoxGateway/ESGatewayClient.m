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
//  ESGatewayClient.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESGatewayClient.h"
#import "ESApiCode.h"
#import "ESBoxManager.h"
#import "ESGatewayManager.h"
#import "ESGatewayRouter.h"
#import "ESGlobalMacro.h"
#import "ESLocalNetworking.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESBoxManager.h"
#import "NSObject+ESAOP.h"
#import "ESDefaultConfiguration.h"
#import <YCEasyTool/YCProperty.h>
#import <YYModel/YYModel.h>
#import "ESNetworkRequestManager.h"
#import "ESApiClient+ESHost.h"

@interface ESBoxItem ()

@property (nonatomic, strong) ESTokenItem *pairToken;

@end

NSNotificationName const ESUserInvaliedNotification = @"ESUserInvaliedNotification";

@implementation ESApiClient (AOP)

+ (void)load {
    [self es_swizzleSEL:@selector(requestWithPath:method:pathParams:queryParams:formParams:files:body:headerParams:authSettings:requestContentType:responseContentType:responseType:completionBlock:) withSEL:@selector(es_requestWithPath:method:pathParams:queryParams:formParams:files:body:headerParams:authSettings:requestContentType:responseContentType:responseType:completionBlock:)];
    [self es_swizzleSEL:@selector(initWithBaseURL:sessionConfiguration:) withSEL:@selector(es_initWithBaseURL:sessionConfiguration:)];
}

/// 切面, 添加201-206的返回码支持
/// @param url 切面,透传
/// @param configuration 切面,透传
- (instancetype)es_initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    ESApiClient *api = [self es_initWithBaseURL:url sessionConfiguration:configuration];
    NSMutableIndexSet *indexSet = api.responseSerializer.acceptableStatusCodes.mutableCopy;
    [indexSet addIndexesInRange:NSMakeRange(201, 5)];
    api.responseSerializer.acceptableStatusCodes = indexSet;
    return api;
}

/// 请求切面
/// 从eulix.bundle的routers.json 查找是否需要走网关
/// @param path 切面,透传
/// @param method 切面,透传
/// @param pathParams 切面,透传
/// @param queryParams 切面,透传
/// @param formParams 切面,透传
/// @param files 切面,透传
/// @param body 切面,透传
/// @param headerParams 切面,透传
/// @param authSettings 切面,透传
/// @param requestContentType 切面,透传
/// @param responseContentType 切面,透传
/// @param responseType 切面,透传
/// @param completionBlock 切面,透传
- (NSURLSessionTask *)es_requestWithPath:(NSString *)path
                                  method:(NSString *)method
                              pathParams:(NSDictionary *)pathParams
                             queryParams:(NSDictionary *)queryParams
                              formParams:(NSDictionary *)formParams
                                   files:(NSDictionary *)files
                                    body:(id)body
                            headerParams:(NSDictionary *)headerParams
                            authSettings:(NSArray *)authSettings
                      requestContentType:(NSString *)requestContentType
                     responseContentType:(NSString *)responseContentType
                            responseType:(NSString *)responseType
                         completionBlock:(void (^)(id, NSError *))completionBlock {
    //eulix.bundle中的routers.json
    ESGatewayRouterItem *router = [ESGatewayRouter.manager routerForPath:path method:method];

    NSMutableDictionary *header = headerParams.mutableCopy ?: NSMutableDictionary.dictionary;
    NSString *originPath = header[@"Origin-Path"];
    if (!originPath) {
        originPath = path;
        header[@"Origin-Path"] = path;
    }
    //添加默认的 request-id 参数
    if (!headerParams[@"Request-Id"]) {
        header[@"Request-Id"] = NSUUID.UUID.UUIDString.lowercaseString;
    }
    headerParams = header;

    if ([requestContentType isEqualToString:@"text/plain"]) {
        requestContentType = @"application/json";
    }

    ///取出盒子信息
    __weak __typeof__(self) weak_self = self;
    ESBoxItem *box = self.yc_store(@"box", nil);
    box.apiClient = self;

    ///路由中没配置,直接访问,不走网关转发
    if (!router) {
        header[@"Origin-Path"] = nil;
        NSURL *localFiles = formParams[@"file"];
        if ([localFiles isKindOfClass:NSURL.class]) {
            files = @{@"file": localFiles};
            NSMutableDictionary *localFormParams = formParams.mutableCopy;
            localFormParams[@"file"] = nil;
            formParams = localFormParams;
        }

        ESDLog(@"directly call input\nhost:%@\npath:%@\nmethod:%@\nqueryParams:\n%@\nbody:\n%@\nheaderParams:%@\nRequest-Id:%@\n", self.baseURL, path, method, queryParams, body, headerParams, headerParams[@"Request-Id"]);
        return [self es_requestWithPath:path
                                 method:method
                             pathParams:pathParams
                            queryParams:queryParams
                             formParams:formParams
                                  files:files
                                   body:body
                           headerParams:headerParams
                           authSettings:authSettings
                     requestContentType:requestContentType
                    responseContentType:responseContentType
                           responseType:responseType
                        completionBlock:^(ESObject *output, NSError *error) {
                            ///用 ip 访问时出错, 则回退一次
//                            if ([self ipCannotAccess:error] && self.localAccess && !box.checkingLocalAcesss) {
//                                [ESLocalNetworking.shared restartMonitor];
//                                [self es_requestWithPath:path
//                                                  method:method
//                                              pathParams:pathParams
//                                             queryParams:queryParams
//                                              formParams:formParams
//                                                   files:files
//                                                    body:body
//                                            headerParams:headerParams
//                                            authSettings:authSettings
//                                      requestContentType:requestContentType
//                                     responseContentType:responseContentType
//                                            responseType:responseType
//                                         completionBlock:completionBlock];
//                                return;
//                            }
                            @try {
                                if ([self clientNotConnectedToInternet:error]) {
                                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
                                        ESToast.networkError(TEXT_ERROR_CLIENT_NOT_CONNECTED_TO_INTERNET).show();
                                    }
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(1)];
                                } else if ([self boxNotConnectedToInternet:error box:box] && ![self pathIngore:originPath]) {
                                    if (box && !box.offline) {
                                        ESToast.networkError(TEXT_ERROR_BOX_NOT_CONNECTED_TO_INTERNET).show();
                                        [box setOffline:YES];
                                    }
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(1)];
                                }else{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(0)];
                                }
                                if (error) {
                                    ESDLog(@"directly call error\nhost:%@\npath:%@\nmethod:%@\nRequest-Id:%@\nerror:%@\n", self.baseURL, path, method, headerParams[@"Request-Id"], error);
                                } else {
                                    ESDLog(@"directly call output\nhost:%@\npath:%@\nmethod:%@\nRequest-Id:%@\nresponse:\n%@\n", self.baseURL, path, method, headerParams[@"Request-Id"], output);
                                }
                            } @catch (NSException *exception) {
                            } @finally {
                            }
                            if (completionBlock) {
                                completionBlock(output, error);
                            }
                        }];
    }

    ESDLog(@"gateway call input\nhost:%@\npath:%@\nmethod:%@\nqueryParams:\n%@\nbody:\n%@\nheaderParams:%@\nRequest-Id:%@\n", self.baseURL, path, method, queryParams, body, headerParams, headerParams[@"Request-Id"]);

    ///routers.json 有配置
    /*"eulixspace-file-service": {//serviceName
    "list_folders": {//apiName
        "type": "call",
        "method": "GET",
        "protocol": "HTTP",
        "url": "http://eulixspace-fileapi:2001/space/v1/api/file/list"
    },*/

    ///封装网关需要的数据
    ESRealCallRequest *request = [ESRealCallRequest new];
    request.apiName = router.apiName;
    request.serviceName = router.serviceName;
    request.requestId = headerParams[@"Request-Id"];
    request.headers = [self paramSanitizer:headerParams];
    request.queries = queryParams;
    request.entity = [body yy_modelToJSONObject];
    if (request.entity.count == 0 && queryParams.count > 0) {
        request.entity = queryParams;
    }

    ///调用网关的 call 接口
    [ESGatewayManager call:box
                   request:request
                  callback:^(id output, NSError *error) {
                      ///用 ip 访问时出错, 则回退一次
//                      if (error && self.localAccess && !box.checkingLocalAcesss && self.baseURL) {
//                          ESDLog(@"serviceName:%@, apiName:%@", request.serviceName, request.apiName);
//                          [ESLocalNetworking.shared restartMonitor];
//                          [ESGatewayManager call:box
//                                         request:request
//                                        callback:completionBlock];
//                          return;
//                      }
                      if ([self clientNotConnectedToInternet:error]) {
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(1)];
                          if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
                              ESToast.networkError(TEXT_ERROR_CLIENT_NOT_CONNECTED_TO_INTERNET).show();
                          }
                      } else if ([self boxNotConnectedToInternet:error box:box] && ![self pathIngore:originPath]) {
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(1)];
                          if (box && !box.offline) {
                              ESToast.networkError(TEXT_ERROR_BOX_NOT_CONNECTED_TO_INTERNET).show();
                              [box setOffline:YES];
                          }
                      } else if ([self userMayInvalied:error]) {
                          ESDLog(@"userMayInvalied postNotificationName : ESUserInvaliedNotification");
                          [[NSNotificationCenter defaultCenter] postNotificationName:ESUserInvaliedNotification object:nil];
                      }
                      else{
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(0)];
                      }
                      NSError *serializationError;
                      id response = [weak_self.responseDeserializer deserialize:output class:responseType error:&serializationError];

                      if (!response && !error) {
                          error = serializationError;
                      }
                      if (error) {
                          ESDLog(@"gateway call error\nhost:%@\npath:%@\nRequest-Id:%@\nerror:%@\n", self.baseURL, path, headerParams[@"Request-Id"], error);
                      } else {
                          ESDLog(@"gateway call output\nhost:%@\npath:%@\nRequest-Id:%@\nresponse:\n%@\n", self.baseURL, path, headerParams[@"Request-Id"], [response yy_modelToJSONObject]);
                      }
                      if (completionBlock) {
                          completionBlock(response, error);
                      }
                  }];
    return nil;
}

/*
<NSHTTPURLResponse: 0x283e1a360> { URL: https://mo182jvj.eulix.xyz/space/v1/api/gateway/auth/token/create } { Status Code: 405, Headers {
    "Content-Length" =     (
                            157
                            );
    "Content-Type" =     (
                          "text/html"
                          );
    Date =     (
                "Mon, 27 Dec 2021 02:40:32 GMT"
                );
} }*/
- (BOOL)boxNotConnectedToInternet:(NSError *)error box:(ESBoxItem *)box {
    if (![box isEqual:ESBoxManager.activeBox]) {
        return NO;
    }
    NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    if ([response isKindOfClass:NSHTTPURLResponse.class] && response.statusCode == 405) { //Method Not Allowed
        return YES;
    }
    return NO;
}

- (BOOL)userMayInvalied:(NSError *)error {
    ESDLog(@"[ESGatewayManager] userMayInvalied error: %@", error);
    NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    if ([response isKindOfClass:NSHTTPURLResponse.class] && response.statusCode == 461) { //Method Not Allowed
        return YES;
    }
    return NO;
}

- (BOOL)pathIngore:(NSString *)path {
    static NSSet *_set = nil;
    if (!_set) {
        _set = [NSSet setWithArray:@[
            @"/agent/v1/api/device/localips", ///agent/v1/api/device/localips
        ]];
    }
    return path && [_set containsObject:path];
}

- (NSDictionary *)paramSanitizer:(NSDictionary *)dict {
    NSMutableDictionary *result = dict.mutableCopy ?: NSMutableDictionary.dictionary;
    result[@"Origin-Path"] = nil;
    return result;
}

- (BOOL)clientNotConnectedToInternet:(NSError *)error {
    return error.code == kCFURLErrorNotConnectedToInternet;
}

/// 简单判断，走http 是局域网连接
- (BOOL)localAccess {
    return ![self.baseURL.absoluteString containsString:@"https"];
}

/// 判断是否是因为网络不同导致的 ip 无法连接
/// @param error 接口返回的 error
- (BOOL)ipCannotAccess:(NSError *)error {
    return error.code == kCFURLErrorTimedOut ||
           error.code == kCFURLErrorBadURL ||
           error.code == kCFURLErrorTimedOut ||
           error.code == kCFURLErrorCannotConnectToHost ||
           error.code == kCFURLErrorNetworkConnectionLost ||
           error.code == kCFURLErrorNotConnectedToInternet;
}
//
//+ (instancetype)es_box:(ESBoxItem *)box {
//    ESDefaultConfiguration *config = [ESDefaultConfiguration new];
//    config.host = box.prettyDomain;
//
//    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
//
//    NSString *userDomain = dic[@"userDomain"];
//    NSNumber *boolNum = dic[@"isAdmin"];
//    BOOL isAdmin = [boolNum boolValue];
//
//    if(userDomain.length > 0 && isAdmin){
//        if (userDomain && ![userDomain hasPrefix:@"https://"] && ![userDomain hasPrefix:@"http://"]) {
//            userDomain = [@"https://" stringByAppendingString:userDomain];
//        }
//        config.host = userDomain;
//    }else{
//        config.host = box.prettyDomain;
//    }
//
//    ESApiClient *apiClient = [[self alloc] initWithConfiguration:config];
//    apiClient.yc_store(@"box", box);
//    apiClient.timeoutInterval = 10;
//    box.apiClient = apiClient;
//    return apiClient;
//}

+ (instancetype)es_box:(ESBoxItem *)box {
    ESDefaultConfiguration *config = [ESDefaultConfiguration new];
    config.host = box.prettyDomain;
    if (box.supportNewBindProcess && !box.enableInternetAccess && box.localHost.length > 0) {
        config.host = box.localHost;
    }
    ESApiClient *apiClient = [[self alloc] initWithConfiguration:config];
    apiClient.boxItem = box;
    apiClient.yc_store(@"box", box);
    apiClient.timeoutInterval = 60;// zdz todo change to 60s ??
    box.apiClient = apiClient;
    return apiClient;
}

@end

@interface ESSanitizer (AOP)

@end

@implementation ESSanitizer (AOP)

+ (void)load {
    [self es_swizzleSEL:@selector(sanitizeForSerialization:) withSEL:@selector(es_sanitizeForSerialization:)];
}

/// 数据校验的切面, 默认的不支持NSURL,
/// @param object 需要 校验  的数据
- (id)es_sanitizeForSerialization:(id)object {
    if ([object isKindOfClass:NSURL.class]) {
        return object;
    }
    return [self es_sanitizeForSerialization:object];
}

@end

@interface ESResponseDeserializer (AOP)

@end

@implementation ESResponseDeserializer (AOP)

+ (void)load {
    [self es_swizzleSEL:@selector(deserialize:class:error:) withSEL:@selector(es_deserialize:class:error:)];
}

- (id)es_deserialize:(id)data class:(NSString *)className error:(NSError *__autoreleasing *)error {
    ESBeforeParseJson aop = self.yc_store(ESBeforeParseJsonKey, nil);
    if (aop) {
        data = aop(data);
    }
    return [self es_deserialize:data class:className error:error];
}

@end
