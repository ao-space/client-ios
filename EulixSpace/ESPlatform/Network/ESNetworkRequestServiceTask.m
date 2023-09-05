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
//  ESNetworkRequestServiceTask.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkRequestServiceTask.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"
#import "ESNetworkRequestTaskContext.h"
#import <JSONModel/JSONModel.h>
#import <YYModel/NSObject+YYModel.h>
#import "ESNetworkRequestServiceTask+ESLocalAccess.h"
#import "ESLocalNetworking.h"
#import "ESToast.h"
#import "ESLocalizableDefine.h"

@interface ESBoxItem ()

@property (nonatomic, strong) ESTokenItem *pairToken;

@end

FOUNDATION_EXTERN NSString * const AFNetworkingOperationFailingURLResponseErrorKey;
FOUNDATION_EXTERN NSNotificationName const ESUserInvaliedNotification;

NSErrorDomain const ESNetWorkErrorDomain = @"ESNetWorkErrorDomain";
NSNetworkErrorCode const NSNetworkErrorParams = 10001;
NSNetworkErrorCode const NSNetworkErrorResponseStructure = 10008;
NSNetworkErrorCode const NSNetworkErrorResponseBusiness = 10009;
NSNetworkErrorCode const NSNetworkErrorResponseParse = 10020;

NSString *const ESNetworkErrorUserInfoMessageKey = @"message";
NSString *const ESNetworkErrorUserInfoResposeCodeKey = @"code";
NSString *const ESNetworkErrorUserInfoResposeResultKey = @"result";

NSString *const ESNetworkErrorSystemNeedUpdateCode = @"GW-511";

@interface ESNetworkRequestManager ()

+ (instancetype)sharedInstance;
+ (NSURLSession *)shareSession;

- (void)appendRequest:(ESNetworkRequestServiceTask *)request;
- (void)removeRequest:(ESNetworkRequestServiceTask *)request;

@end

@interface ESNetworkRequestServiceTask ()

@end

@implementation ESNetworkRequestServiceTask

- (void)sendRequest:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams {
    /*
    NSURLSession *shareSession = ESNetworkRequestManager.shareSession;
    
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
    
    NSString * lanHost = [[ESLocalNetworking shared] getLanHost];
    if ([ESLocalNetworking shared].reachableBox && lanHost) {
        if ([path hasPrefix:@"/"]) {
            url = [NSString stringWithFormat:@"%@%@",lanHost, path];
        } else {
            url = [NSString stringWithFormat:@"%@/%@",lanHost, path];
        }
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    if (!components) {
        return;
    }
    
    [self setQueryParams:queryParams withUrlComponents:components];
    
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[components URL]];
    [self addHeaderParams:headerParams withRequest:mRequest];
    [self addBodyParams:bodyParams withRequest:mRequest];
    
    [mRequest setHTTPMethod: ESSafeString(method)];


    __block NSInteger requestId;
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForResource = 60.0;


    NSURLSessionDataTask *dataTask = [shareSession dataTaskWithRequest:mRequest
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!self.successBlock || !self.failBlock) {
            return;
        }
        
        if (error) {
            [self retryRequestByEror:error
                                path:path
                        method:method
                   queryParams:queryParams
                        header:headerParams
                         body:bodyParams];
           
            return;
        }
        
        [self parseResponseData:data reponse:response];
                           
    }];
    
    requestId = dataTask.taskIdentifier;
    self.taskContext = [[ESNetworkRequestTaskContext alloc] initWithTaskId:requestId];
    self.taskContext.requestId = requestId;
    self.taskContext.method = method;
    self.taskContext.queryParams = queryParams;
    self.taskContext.headerParams = headerParams;
    self.taskContext.bodyParams = bodyParams;

    self.requestId = requestId;
    self.taskId = requestId;
    self.sessionTask = dataTask;
    
    self.status = ESNetworkRequestServiceStatus_Running;
    [dataTask resume];
     */
    
    
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *userDomain = dic[@"userDomain"];;
    if(userDomain.length < 1){
        userDomain = ESBoxManager.realdomain ?: ESBoxManager.activeBox.info.userDomain;;
    }
    
    NSString *baseUrl = [NSString stringWithFormat:@"https://%@",userDomain];
    if ([path hasPrefix:@"/"]) {
        baseUrl = [NSString stringWithFormat:@"https://%@",userDomain];
    }
    
    if (ESBoxManager.activeBox != nil &&
        ESBoxManager.activeBox.localHost.length > 0 &&
        ESBoxManager.activeBox.enableInternetAccess == NO) {
        baseUrl = ESBoxManager.activeBox.localHost;
        ESDLog(@"[activeBox.localHost] lanHost:%@", baseUrl);
    }
    
    NSString * lanHost = [[ESLocalNetworking shared] getLanHost];
    if ([ESLocalNetworking shared].reachableBox && lanHost.length > 0) {
        baseUrl = lanHost;
        ESDLog(@"[ESLocalNetworking] lanHost:%@", baseUrl);

//        if (![ESBoxManager.activeBox.localHost isEqualToString:lanHost]) {
//            ESBoxManager.activeBox.localHost = lanHost;
//            [ESBoxManager.manager saveBox:ESBoxManager.activeBox];
//        }
    }
    ESDLog(@"[sendRequest] baseUrl: %@ path: %@ method:%@ queryParams:%@ header:%@ bodyParams:%@", baseUrl, path, method, queryParams, headerParams, bodyParams);
    [self sendRequest:baseUrl path:path method:method queryParams:queryParams header:headerParams body:bodyParams];
}

- (void)sendRequest:(NSString *)baseUrl
               path:(NSString *)path
             method:(NSString *)method
        queryParams:(NSDictionary * _Nullable)queryParams
           header:(NSDictionary * _Nullable)headerParams
               body:(NSDictionary * _Nullable)bodyParams {
    NSURLSession *shareSession = ESNetworkRequestManager.shareSession;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",baseUrl, path];
    if ([path hasPrefix:@"/"]) {
        url = [NSString stringWithFormat:@"%@%@",baseUrl,path];
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    if (!components) {
        return;
    }
    
    [self setQueryParams:queryParams withUrlComponents:components];
    
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[components URL]];
//    [mRequest setHTTPShouldHandleCookies:NO];
    [self addHeaderParams:headerParams withRequest:mRequest];
    if([path isEqual:@"/agent/v1/api/switch"]){
      // NSString *json = [bodyParams yy_modelToJSONString];
      //  mRequest.HTTPBody = [bodyParams dataUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSJSONSerialization dataWithJSONObject:bodyParams options:NSJSONWritingPrettyPrinted error:nil];
        mRequest.HTTPBody = data;
    }else{
        [self addBodyParams:bodyParams withRequest:mRequest];
    }

    
    [mRequest setHTTPMethod: ESSafeString(method)];
 
    __block NSInteger requestId;
    NSURLSessionDataTask *dataTask = [shareSession dataTaskWithRequest:mRequest
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!self.successBlock || !self.failBlock) {
            return;
        }
        
        if (error) {
            [self retryRequestByEror:error
                                path:path
                        method:method
                   queryParams:queryParams
                        header:headerParams
                         body:bodyParams
                            response:response];
           
            return;
        }
        
        [self parseResponseData:data reponse:response];
                           
    }];
    
    requestId = dataTask.taskIdentifier;
    self.taskContext = [[ESNetworkRequestTaskContext alloc] initWithTaskId:requestId];
    self.taskContext.requestId = requestId;
    self.taskContext.method = method;
    self.taskContext.queryParams = queryParams;
    self.taskContext.headerParams = headerParams;
    self.taskContext.bodyParams = bodyParams;

    self.requestId = requestId;
    self.taskId = requestId;
    self.sessionTask = dataTask;
    
    self.status = ESNetworkRequestServiceStatus_Running;
    [dataTask resume];
}

- (void)retryRequestByEror:(NSError *)error
                      path:(NSString *)path
        method:(NSString *)method
   queryParams:(NSDictionary * _Nullable)queryParams
      header:(NSDictionary * _Nullable)headerParams
          body:(NSDictionary * _Nullable)bodyParams
                  response:(NSURLResponse * _Nullable) response {
//    if (error && [self localAccess] && ![self boxCheckingLocalAcesss]) {
//       [ESLocalNetworking.shared restartMonitor];
//       [self sendRequest:path
//                  method:method
//             queryParams:queryParams
//                  header:headerParams
//                    body:bodyParams];
//       return;
//     }
    ESDLog(@"retryRequestByEror path:%@ \n queryParams: %@\n headerParams:%@/n bodyParams:%@/n response: %@/n  error:%@/n",  path,  queryParams, headerParams, bodyParams, response, error );
    if ([self clientNotConnectedToInternet:error]) {
       [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(1)];
       if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
           ESToast.networkError(TEXT_ERROR_CLIENT_NOT_CONNECTED_TO_INTERNET).show();
       }
    } else if ([self boxNotConnectedToInternet:error] && ![self pathIngore:path]) {
       [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(1)];
       ESToast.networkError(TEXT_ERROR_BOX_NOT_CONNECTED_TO_INTERNET).show();
    } else if ([self userMayInvalied:error] || [self userMayInvaliedResponse:(NSHTTPURLResponse *)response]) {
        ESDLog(@"postNotificationName ESUserInvaliedNotification");
        [[NSNotificationCenter defaultCenter] postNotificationName:ESUserInvaliedNotification object:nil];
    }
      
    [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotificationCenter" object:@(0)];
    [self callbackFailWithRequestId:self.requestId response:nil error:error];
}

- (BOOL)userMayInvalied:(NSError *)error {
    ESDLog(@"userMayInvaliedResponse error: %@",  error);
    NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    if ([response isKindOfClass:NSHTTPURLResponse.class] && response.statusCode == 461) { //Method Not Allowed
        return YES;
    }
    return NO;
}

- (BOOL)userMayInvaliedResponse:(NSHTTPURLResponse *)response {
    ESDLog(@"userMayInvaliedResponse response: %@",  response);
    if ([response isKindOfClass:NSHTTPURLResponse.class] && response.statusCode == 461) { //Method Not Allowed
        return YES;
    }
    return NO;
}

#pragma mark - Request Params
- (void)setQueryParams:(NSDictionary *)queryParams withUrlComponents:(NSURLComponents *)components {
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [key isKindOfClass:[NSString class]]) {
            NSURLQueryItem * newQueryItem = [[NSURLQueryItem alloc] initWithName:key value:obj];
            [queryItems addObject:newQueryItem];
        }
    }];
    if (queryItems.count > 0) {
        [components setQueryItems:[queryItems copy]];
    }
}

- (void)addHeaderParams:(NSDictionary *)headerParams withRequest:(NSMutableURLRequest *)mRequest {
    [headerParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]] &&
            [obj isKindOfClass:[NSString class]] &&
            ![mRequest.allHTTPHeaderFields.allKeys containsObject:key]) {
            [mRequest addValue:obj forHTTPHeaderField:key];
        }
    }];
    [self addCommonHeaderParams:headerParams withRequest:mRequest];
}

- (void)addCommonHeaderParams:(NSDictionary *)headerParams  withRequest:(NSMutableURLRequest *)mRequest  {
    if (![headerParams.allKeys containsObject:@"Request-Id"] && ![mRequest.allHTTPHeaderFields.allKeys containsObject:@"Request-Id"]) {
        [mRequest addValue:NSUUID.UUID.UUIDString.lowercaseString  forHTTPHeaderField:@"Request-Id"];
    }
   
    if (![headerParams.allKeys containsObject:@"Accept"] && ![mRequest.allHTTPHeaderFields.allKeys containsObject:@"Accept"]) {
        [mRequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    }
    
    if (![headerParams.allKeys containsObject:@"Content-Type"] && ![mRequest.allHTTPHeaderFields.allKeys containsObject:@"Content-Type"]) {
        [mRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
}

- (void)addBodyParams:(NSDictionary *)bodyParams withRequest:(NSMutableURLRequest *)mRequest {
    if (bodyParams != nil && bodyParams.count > 0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:bodyParams options:NSJSONWritingPrettyPrinted error:nil];
        mRequest.HTTPBody = data;

    }
}

#pragma mark - Parse
- (void)parseResponseData:(NSData *)data reponse:(NSURLResponse * _Nullable)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                   code:NSNetworkErrorResponseStructure
                                                                                               userInfo:@{ESNetworkErrorUserInfoMessageKey : dataStr ?: @"数据返回结构出错"}]];
        return;
    }

    //对旧接口做兼容处理 - 返回data数据表示成功, 新接口需做code判断
    if ([self isNewApi:dict]&&
        ![self returnCodeIsSuccess:dict[@"code"]]) {
        [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                   code:NSNetworkErrorResponseBusiness
                                                                                               userInfo:@{
            ESNetworkErrorUserInfoMessageKey : (dict[@"message"] ?: @"业务返回错误"),
            ESNetworkErrorUserInfoResposeCodeKey : ESSafeString(dict[@"code"]),
            ESNetworkErrorUserInfoResposeResultKey : dict ?: @"",
        }]];
        return;
    }

    if (self.modelName.length <= 0) {
        [self callbackWithDic:dict];
        return;
    }
    
    [self tryParseAsModelWithData:data parseDic:dict reponse:response];
}


//新接口的判断，是否按照规范的格式进行返回： 包含 code code": "string","message": "string",  "requestId"
- (BOOL)isNewApi:(NSDictionary *)dic {
    return ([dic.allKeys containsObject:@"code"] && [dic.allKeys containsObject:@"message"]  && [dic.allKeys containsObject:@"requestId"]);
}

- (BOOL)returnCodeIsSuccess:(id)code {
    if ([code isKindOfClass:[NSString class]]) {
        NSArray *codes = [(NSString *)code componentsSeparatedByString:@"-"];
        if (codes.count > 0) {
            return [codes[codes.count -1] isEqualToString:@"200"];
        }
    }
    
    if ([code isKindOfClass:[NSNumber class]] && [code intValue] == 200) {
        return YES;
    }
    return NO;
}

- (void)callbackWithDic:(NSDictionary *)dic {
    NSDictionary *resultDic = dic;
    if (dic[@"results"] && ![dic[@"results"] isKindOfClass:[NSNull class]]) {
        resultDic = dic[@"results"];
    }
    [self callbackSuccessWithRequestId:self.requestId response:(resultDic)];
}

- (void)tryParseAsModelWithData:(NSData *)data
                       parseDic:(NSDictionary *)dict
                        reponse:(NSURLResponse * _Nullable)response {
    Class modelClass = NSClassFromString(self.modelName);
    if (!modelClass) {
        [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                   code:NSNetworkErrorResponseParse
                                                                                               userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model设置错误"}]];
        return;
    }
    if ([modelClass isSubclassOfClass:[JSONModel class]]){
        [self tryParseAsJSModelClass:modelClass
                                data:data
                            parseDic:dict
                             reponse:response];
        return;
    }
    
    if ([modelClass isSubclassOfClass:[NSObject class]]){
        [self tryParseAsYYModelWithClass:modelClass
                                data:data
                            parseDic:dict
                             reponse:response];
        return;
    }
    
    [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                               code:NSNetworkErrorResponseParse
                                                                                           userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析错误"}]];
    return;
}


- (void)tryParseAsJSModelClass:(Class)modelClass
                          data:(NSData *)data
                      parseDic:(NSDictionary *)dict
                       reponse:(NSURLResponse * _Nullable)response {
    NSError *error;
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    id modelObject = [[modelClass alloc] initWithString:json error:&error];
    if (!error) {
        [self callbackSuccessWithRequestId:self.requestId response:modelObject];
        return;
    }
    [self tryParseFromResultSourceAsJSModelClass:modelClass
                                        parseDic:dict
                                         reponse:response];
    
}

- (void)tryParseFromResultSourceAsJSModelClass:(Class)modelClass
                      parseDic:(NSDictionary *)dict
                       reponse:(NSURLResponse * _Nullable)response {
    id results = dict[@"results"];
    if ([results isKindOfClass:[NSArray class]] ||
        [results isKindOfClass:[NSMutableArray class]] ||
        [results isKindOfClass:[NSDictionary class]] ||
        [results isKindOfClass:[NSMutableDictionary class]]) {
        NSError *error;
        NSData *resultData = [NSJSONSerialization dataWithJSONObject:results options:kNilOptions error:&error];
        if (error != nil) {
            [self callbackFailWithRequestId:self.requestId response:response error: [NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                        code:NSNetworkErrorResponseParse
                                                                                                    userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析失败"}]];
            return;
        }
        NSString *json = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        id modelObject = [[modelClass alloc] initWithString:json error:&error];
        if (!error) {
            [self callbackSuccessWithRequestId:self.requestId response:modelObject];
            return;
        }
        
        [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                   code:NSNetworkErrorResponseParse
                                                                                               userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析失败"}]];
        return;
    }
    
    [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                               code:NSNetworkErrorResponseParse
                                                                                           userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析失败"}]];
    return;
}

- (void)tryParseAsYYModelWithClass:(Class)modelClass
                          data:(NSData *)data
                      parseDic:(NSDictionary *)dict
                       reponse:(NSURLResponse * _Nullable)response {
    
    if ([self classNameIsResponseModel:modelClass]) {
        id modelObject = [modelClass yy_modelWithDictionary:dict];
        if (modelObject) {
            [self callbackSuccessWithRequestId:self.requestId response:modelObject];
        } else {
            [self callbackFailWithRequestId:self.requestId response:response error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                                                                       code:NSNetworkErrorResponseParse
                                                                                                   userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析失败"}]];
        }
        return;
    }

    [self tryParseFromResultSourceAsYYModelClass:modelClass parseDic:dict reponse:response];
}

- (BOOL)classNameIsResponseModel:(Class)modelClass {
    id classObject = [[modelClass alloc] init];
    if ([classObject respondsToSelector: NSSelectorFromString(@"code")] &&
        [classObject respondsToSelector:NSSelectorFromString(@"message")] &&
        [classObject respondsToSelector:NSSelectorFromString(@"results")]) {
        return YES;
    }
    return NO;
}

- (void)tryParseFromResultSourceAsYYModelClass:(Class)modelClass
                      parseDic:(NSDictionary *)dict
                       reponse:(NSURLResponse * _Nullable)response {
    id results = dict[@"results"];
    if ([results isKindOfClass:[NSDictionary class]] ||
        [results isKindOfClass:[NSMutableDictionary class]]) {
        
        id modelObject = [modelClass yy_modelWithDictionary:results];
        if (modelObject) {
            [self callbackSuccessWithRequestId:self.requestId response:modelObject];
            return;
        }
        
        [self callbackFailWithRequestId:self.requestId
                               response:response
                                  error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                           code:NSNetworkErrorResponseParse
                                                       userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析失败"}]];
        return;
        
    }
    
    if ( ([results isKindOfClass:[NSArray class]] ||
        [results isKindOfClass:[NSMutableArray class]]) &&
        [modelClass respondsToSelector:@selector(modelContainerPropertyGenericClass)] ) {
        NSDictionary *varMap = [modelClass modelContainerPropertyGenericClass];
        if (varMap.allKeys.count == 1) {
            results = @{ESSafeString(varMap.allKeys.firstObject) : results};
        }
        
        id modelObject = [modelClass yy_modelWithJSON:results];
        if (modelObject) {
            [self callbackSuccessWithRequestId:self.requestId response:modelObject];
            return;
        }
        
        [self callbackFailWithRequestId:self.requestId
                               response:response
                                  error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                           code:NSNetworkErrorResponseParse
                                                       userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析失败"}]];
        return;
    }
    
    [self callbackFailWithRequestId:self.requestId
                           response:response
                              error:[NSError errorWithDomain:ESNetWorkErrorDomain
                                                       code:NSNetworkErrorResponseParse
                                                   userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Model解析失败"}]];
    return;
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
    ESDLog(@"requestTaskContext: %@\n callbackFailWithRequestId: %ld\n response: %@\n error: %@\n", self.taskContext,
                                                                                                           (long)requestId,
                                                                                                           response,
                                                                                                           error);
    if ([self userMayInvalied:error] || [self userMayInvaliedResponse:(NSHTTPURLResponse *)response]) {
       ESDLog(@"[callbackFailWithRequestId] postNotificationName ESUserInvaliedNotification");
       [[NSNotificationCenter defaultCenter] postNotificationName:ESUserInvaliedNotification object:nil];
   }
    self.status = ESNetworkRequestServiceStatus_Finish;
    ESPerformBlockAsynOnMainThread(^{
        self.failBlock(requestId, response, error);
        [ESNetworkRequestManager.sharedInstance removeRequest:self];
    });
}

- (void)cancel {
    if (self.sessionTask.state == NSURLSessionTaskStateRunning) {
        [self.sessionTask cancel];
    }

    self.status = ESNetworkRequestServiceStatus_Cancel;
}

@end

