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
//  ESNetworkCallRequestServiceTask.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkCallRequestServiceTask.h"
#import "ESGatewayManager.h"
#import "ESBoxManager.h"
#import "ESAES.h"

NSString *const ESNetworkApiNameKey = @"apiName";
NSString *const ESNetworkServiceNameKey = @"serviceName";
NSString *const ESNetworkApiVersionsKey = @"apiVersion";

static NSString *const ESNetworkRequestQueriesKey = @"queries";
static NSString *const ESNetworkRequestHeaderKey = @"headers";
static NSString *const ESNetworkRequestEntityKey = @"entity";

@interface ESNetworkCallRequestServiceTask ()

@property (nonatomic, strong) ESTokenItem *token;

@end


@implementation ESNetworkCallRequestServiceTask

- (void)sendCallRequest:(NSDictionary *)apiParams
        queryParams:(NSDictionary *)queryParams
           header:(NSDictionary *)headerParams
               body:(NSDictionary *)bodyParams {
    ESDLog(@"apiParams : %@  \n queryParams: %@ \n  headerParams: %@ \n bodyParams: %@ \n", apiParams, queryParams, headerParams, bodyParams);
    if (![apiParams.allKeys containsObject:ESNetworkApiNameKey] || ![apiParams.allKeys containsObject:ESNetworkApiNameKey]) {
        [self callbackFailWithRequestId:self.requestId response:nil error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                              code:NSNetworkErrorParams
                                                                                          userInfo:@{ESNetworkErrorUserInfoMessageKey : @"api 参数错误"}]];
        return;
    }
    ESBoxItem *boxItem = ESBoxManager.activeBox;
   
    NSDictionary *defaultHeaderParams = @{@"Request-Id" : NSUUID.UUID.UUIDString.lowercaseString,
                                   @"Accept" : @"*/*",
                                   @"Content-Type" : @"application/json"
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
                        token:token];
    }];
}

- (void)sendCallRequest:(NSDictionary *)apiParams
               queryParams:(NSDictionary *)queryParams
                  header:(NSDictionary *)headerParams
                      body:(NSDictionary *)bodyParams
                     token:(ESTokenItem *)token {
    ESDLog(@"apiParams : %@  \n queryParams: %@ \n  headerParams: %@ \n bodyParams: %@ \n token: %@ \n ", apiParams, queryParams, headerParams, bodyParams, token);

    NSDictionary *callBody = [self makeCallBodyWithApiParams:apiParams queryParams:queryParams header:headerParams body:bodyParams token:token];
    [self sendRequest:@"/space/v1/api/gateway/call"
               method:@"POST"
          queryParams:nil
               header:nil
                 body:callBody];
}

- (NSDictionary *)makeCallBodyWithApiParams:(NSDictionary *)apiParams
                       queryParams:(NSDictionary *)queryParams
                          header:(NSDictionary *)headerParams
                              body:(NSDictionary *)bodyParams
                                      token:(ESTokenItem *)token {
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
    NSDictionary *callBody = @{@"accessToken" : ESSafeString(token.accessToken),
                           @"body" : ESSafeString(encodeJson)
                           };
    return callBody;
}

- (void)parseResponseData:(NSData *)data reponse:(NSURLResponse * _Nullable)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        ESDLog(@"[数据返回结构出错] %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
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

@end
