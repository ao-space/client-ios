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
//  ESNetworkServiceUploadTask.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkServiceUploadTask.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"
#import "ESNetworkRequestTaskContext.h"
#import <JSONModel/JSONModel.h>
#import <YYModel/NSObject+YYModel.h>
#import "ESNetworkRequestServiceTask+ESLocalAccess.h"
#import "ESLocalNetworking.h"
#import "ESToast.h"
#import "ESLocalizableDefine.h"
#import "ESGatewayManager.h"
#import "ESAES.h"
#import "ESLocalPath.h"
#import "ESFileHandleManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "ESLogger.h"

@interface ESNetworkRequestManager ()

+ (instancetype)sharedInstance;
+ (NSURLSession *)shareSession;

- (void)appendRequest:(ESNetworkRequestServiceTask *)request;
- (void)removeRequest:(ESNetworkRequestServiceTask *)request;

@end

FOUNDATION_EXPORT NSString *const ESNetworkApiNameKey;
FOUNDATION_EXPORT NSString *const ESNetworkServiceNameKey;
FOUNDATION_EXPORT NSString *const ESNetworkApiVersionsKey;
static NSString *const ESNetworkRequestQueriesKey = @"queries";
static NSString *const ESNetworkRequestHeaderKey = @"headers";
static NSString *const ESNetworkRequestEntityKey = @"entity";

@interface ESNetworkServiceUploadTask ()

@property (nonatomic, strong) ESTokenItem *token;
@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@interface ESNetworkRequestServiceTask ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionWWanManager;


- (void)setQueryParams:(NSDictionary *)queryParams withUrlComponents:(NSURLComponents *)components;
- (void)addHeaderParams:(NSDictionary *)headerParams withRequest:(NSMutableURLRequest *)mRequest;
- (void)addCommonHeaderParams:(NSDictionary *)headerParams  withRequest:(NSMutableURLRequest *)mRequest;
- (void)addBodyParams:(NSDictionary *)bodyParams withRequest:(NSMutableURLRequest *)mRequest;

@end

@implementation ESNetworkServiceUploadTask

- (void)sendCallRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
               filePath:(NSString *)filePath {
    [self sendCallRequest:apiParams queryParams:queryParams header:headerParams body:bodyParams filePath:filePath data:nil];
}

- (void)sendCallRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
                   data:(NSData *)data {
    [self sendCallRequest:apiParams queryParams:queryParams header:headerParams body:bodyParams filePath:nil data:data];
}

static NSString * AFCreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}

- (void)sendCallRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
                   body:(NSDictionary *)bodyParams
               filePath:(NSString * _Nullable)filePath
                   data:(NSData * _Nullable)data {
    ESDLog(@"apiParams : %@  \n queryParams: %@ \n  headerParams: %@ \n bodyParams: %@ \n", apiParams, queryParams, headerParams, bodyParams);
    if (![apiParams.allKeys containsObject:ESNetworkApiNameKey] || ![apiParams.allKeys containsObject:ESNetworkApiNameKey]) {
        [self callbackFailWithRequestId:self.requestId response:nil error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                              code:NSNetworkErrorParams
                                                                                          userInfo:@{ESNetworkErrorUserInfoMessageKey : @"api 参数错误"}]];
        return;
    }
    ESBoxItem *boxItem = ESBoxManager.activeBox;
    self.boundary = AFCreateMultipartFormBoundary();
    NSDictionary *defaultHeaderParams = @{@"Request-Id" : NSUUID.UUID.UUIDString.lowercaseString,
                                   @"Accept" : @"*/*",
                                    @"Content-Type" : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary]
                                  };
    
    [ESGatewayManager token:boxItem
             defaultHeaders:headerParams
                   callback:^(ESTokenItem *token, NSError *error) {
        if (error) {
            [self callbackFailWithRequestId:self.requestId response:nil error:error];
            return;
        }
        
        self.token = token;
        NSMutableDictionary *headerTemp = [NSMutableDictionary dictionaryWithDictionary:headerParams ?: @{}];
        [headerTemp addEntriesFromDictionary:defaultHeaderParams];
        [self sendCallRequest:apiParams
                  queryParams:queryParams
                       header:[headerTemp copy]
                         body:bodyParams
                        token:token
                     filePath:filePath
                         data:data];
    }];
}

- (void)sendCallRequest:(NSDictionary *)apiParams
               queryParams:(NSDictionary *)queryParams
                  header:(NSDictionary *)headerParams
                      body:(NSDictionary *)bodyParams
                     token:(ESTokenItem *)token
                   filePath:(NSString * _Nullable)filePath
                       data:(NSData * _Nullable)data {

    ESDLog(@"apiParams : %@  \n queryParams: %@ \n  headerParams: %@ \n bodyParams: %@ \n token: %@ \n ", apiParams, queryParams, headerParams, bodyParams, token);

    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithDictionary:apiParams];
    if (![requestDic.allKeys containsObject:ESNetworkApiVersionsKey]) {
        requestDic[ESNetworkApiVersionsKey] = @"v1";
    }
    
    if (headerParams.count > 0) {
        requestDic[ESNetworkRequestHeaderKey] = headerParams;
    }
    
    if (queryParams.count > 0) {
        requestDic[ESNetworkRequestQueriesKey] = queryParams;
    }
    
    if (bodyParams.count > 0) {
        requestDic[ESNetworkRequestEntityKey] = bodyParams;
    } else if (queryParams.count > 0) {
        requestDic[ESNetworkRequestEntityKey] = queryParams;
    }
    
    
    NSError *error;
    NSData *resultData = [NSJSONSerialization dataWithJSONObject:requestDic options:kNilOptions error:&error];
    NSString *json = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    NSString *encodeJson = [json aes_cbc_encryptWithKey:token.secretKey iv:token.secretIV];
    NSDictionary *callBody = @{ @"accessToken" : ESSafeString(token.accessToken),
                                @"body" : ESSafeString(encodeJson)
                              };
    [self sendRequest:@"/space/v1/api/gateway/upload"
               method:@"POST"
          queryParams:nil
               header:headerParams
                 body:callBody
                token:token
             filePath:filePath
                 data:data];
}

- (void)sendRequest:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams
              token:(ESTokenItem *)token
           filePath:(NSString * _Nullable)filePath
               data:(NSData * _Nullable)data {
    if (filePath.length <= 0 && data == nil) {
        [self callbackFailWithRequestId:self.requestId response:nil error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                              code:NSNetworkErrorParams
                                                                                          userInfo:@{ESNetworkErrorUserInfoMessageKey : @"data相关参数错误"}]];
        return;
    }

//    NSURLSession *shareSession = ESNetworkRequestManager.shareSession;
    
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *userDomain = dic[@"userDomain"];;
    if(userDomain.length < 1){
        userDomain = ESBoxManager.realdomain ?: ESBoxManager.activeBox.info.userDomain;;
    }
    
    NSString *url = [NSString stringWithFormat:@"https://%@/%@",userDomain, path];
    if ([path hasPrefix:@"/"]) {
        url = [NSString stringWithFormat:@"https://%@%@",userDomain,path];
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    if (!components) {
        return;
    }
    
    [self setQueryParams:queryParams withUrlComponents:components];
    
    __block NSInteger requestId;
    NSURLSessionUploadTask *uploadTask;
    if (filePath.length > 0) {
        NSString *encryptFilePath = [NSString stringWithFormat:@"%@.encrypt", filePath];
        UInt64 cipherTextLength = [ESFileHandleManager.manager encryptFile:filePath target:encryptFilePath key:token.secretKey iv:token.secretIV];
        if (cipherTextLength <= 0) {
            [filePath clearCachePath];
            [self callbackFailWithRequestId:self.requestId response:nil error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                  code:NSNetworkErrorParams
                                                                                              userInfo:@{ESNetworkErrorUserInfoMessageKey : @"加密文件错误"}]];
            return;
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:bodyParams options:NSJSONWritingPrettyPrinted error:nil];
        void (^constructingBodyWithBlock)(id<AFMultipartFormData> _Nonnull formData) = ^(id<AFMultipartFormData> _Nonnull formData) {
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            [formData appendPartWithHeaders:[self headerWithName:@"callRequest" type:@"application/json"] body:data];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:encryptFilePath] name:@"file" error:nil];
        };
        NSMutableURLRequest *mRequest = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                                      URLString:[components URL].absoluteString
                                                                                                     parameters:nil
                                                                                      constructingBodyWithBlock:constructingBodyWithBlock
                                                                                                        error:nil];
        
        [self addHeaderParams:headerParams withRequest:mRequest];
        uploadTask = [self.sessionManager uploadTaskWithStreamedRequest:mRequest
                                                                    progress:nil
                                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self handleResultData:responseObject response:response error:error];
        }];
        
    }
//    else if (data != nil) {
//         uploadTask = [shareSession uploadTaskWithRequest:mRequest
//                                                 fromData:data
//                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                       [self handleResultData:data response:response error:error];
//         }];
//    }
    
    requestId = uploadTask.taskIdentifier;
    self.taskContext = [[ESNetworkRequestTaskContext alloc] initWithTaskId:requestId];
    self.taskContext.requestId = requestId;
    self.taskContext.method = method;
    self.taskContext.queryParams = queryParams;
    self.taskContext.headerParams = headerParams;
    self.taskContext.bodyParams = bodyParams;

    self.requestId = requestId;
    self.taskId = requestId;
    self.sessionTask = uploadTask;
    
    self.status = ESNetworkRequestServiceStatus_Running;
    [uploadTask resume];
}

- (NSDictionary *)headerWithName:(NSString *)name type:(NSString *)type {
    NSParameterAssert(name);
    NSParameterAssert(type);
    return @{
        @"Content-Disposition": [NSString stringWithFormat:@"form-data; name=\"%@\"", name],
        @"Content-Type": type,
    };
}

- (void)handleResultData:(NSData *)data response:(NSURLResponse *)response error:(NSError * _Nullable)error {
    if (!self.successBlock || !self.failBlock) {
        return;
    }
    if (error) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        [self callbackFailWithRequestId:self.requestId response:response error:error];
        return;
    }
    [self parseResponseData:data reponse:response];
}

- (void)parseResponseData:(NSData *)data reponse:(NSURLResponse * _Nullable)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                   code:NSNetworkErrorResponseStructure
                                                                                               userInfo:@{ESNetworkErrorUserInfoMessageKey : @"数据返回结构出错"}]];
        return;
    }
    if ( ![self returnCodeIsSuccess:dict[@"code"]] || !dict[@"body"]) {
        [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                   code:NSNetworkErrorResponseBusiness
                                                                                               userInfo:@{ESNetworkErrorUserInfoMessageKey : (dict[@"message"] ?: @"业务返回错误")}]];
        return;
    }
    
    NSString *responseStr = [(NSString *)dict[@"body"] aes_cbc_decryptWithKey:self.token.secretKey iv:self.token.secretIV];
    NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [super parseResponseData:responseData reponse:response];
}

- (void)callbackSuccessWithRequestId:(NSInteger)reuqestId
                            response:(id)response {
    ESDLog(@"requestTaskContext: %@  \n callbackSuccessWithRequestId: %ld \n response: %@ \n", self.taskContext, (long)reuqestId, response);
    self.status = ESNetworkRequestServiceStatus_Finish;
    ESPerformBlockAsynOnMainThread(^{
        self.successBlock(reuqestId, response);
        [ESNetworkRequestManager.sharedInstance removeRequest:self];
    });
}

- (void)callbackFailWithRequestId:(NSInteger)requestId
                         response:(NSURLResponse * _Nullable)response
                            error:(NSError *_Nullable)error {
    ESDLog(@"requestTaskContext: %@  \n callbackFailWithRequestId: %ld  \n  response: %@ \n error: %@  \n", self.taskContext, (long)requestId, response, error);

    self.status = ESNetworkRequestServiceStatus_Finish;
    ESPerformBlockAsynOnMainThread(^{
        self.failBlock(requestId, response, error);
        [ESNetworkRequestManager.sharedInstance removeRequest:self];
    });
}

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.allowsCellularAccess = NO;
        configuration.HTTPMaximumConnectionsPerHost = 1;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        configuration.timeoutIntervalForRequest = 60 * 60;
        configuration.timeoutIntervalForResource = 60 * 60;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _sessionManager;
}

- (void)cancel {
    
}
@end
