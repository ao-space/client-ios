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
//  ESCommunication.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCommunication.h"
#import "ESAccountManager.h"
#import "ESGatewayManager.h"
#import "ESNetworking.h"
#import "ESUploadEntity.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "ESSpaceGatewayGenericCallServiceApi.h"

@interface ESCommunication ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) AFHTTPSessionManager *sessionWWanManager;
@property (nonatomic, strong) AFHTTPSessionManager *sessionWWanManager4Lan;

@end

@implementation ESCommunication

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (AFHTTPSessionManager *)getSessionManager {
    return self.sessionManager;
}

- (AFHTTPSessionManager *)getSessionWWanManager {
    return self.sessionWWanManager;
}

- (AFHTTPSessionManager *)getSessionWWanManager4Lan {
    return self.sessionWWanManager4Lan;
}

- (NSURLSessionUploadTask *)uploadFile:(NSString *)path
                             serverUrl:(NSString *)serverUrl
                                entity:(ESUploadEntity *)entity
                           realRequest:(ESRealCallRequest *)realRequest
                           callRequest:(ESCallRequest *)callRequest
                        sessionManager:(AFHTTPSessionManager *)sessionManager
                     completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    //multipart/form-data
    void (^constructingBodyWithBlock)(id<AFMultipartFormData> _Nonnull formData) = ^(id<AFMultipartFormData> _Nonnull formData) {
        [formData appendPartWithHeaders:[self headerWithName:@"callRequest" type:@"application/json"] body:[callRequest toJSONData]];
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" error:nil];
    };

    NSMutableURLRequest *urlRequest = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                                  URLString:serverUrl
                                                                                                 parameters:nil
                                                                                  constructingBodyWithBlock:constructingBodyWithBlock
                                                                                                      error:nil];

    urlRequest.allHTTPHeaderFields = realRequest.headers;
    NSURLSessionUploadTask *uploadTask = [sessionManager uploadTaskWithStreamedRequest:urlRequest
                                                                              progress:nil
                                                                     completionHandler:completionHandler];
    return uploadTask;
}

- (NSDictionary *)headerWithName:(NSString *)name type:(NSString *)type {
    NSParameterAssert(name);
    NSParameterAssert(type);
    return @{
        @"Content-Disposition": [NSString stringWithFormat:@"form-data; name=\"%@\"", name],
        @"Content-Type": type,
    };
}

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.allowsCellularAccess = NO;
        configuration.HTTPMaximumConnectionsPerHost = kNetworkingSessionMaximumConnectionsPerHost;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        configuration.timeoutIntervalForRequest = 60 * 60;
        configuration.timeoutIntervalForResource = 60 * 60;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _sessionManager;
}

- (AFHTTPSessionManager *)sessionWWanManager {
    if (!_sessionWWanManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.allowsCellularAccess = YES;
        configuration.HTTPMaximumConnectionsPerHost = kNetworkingSessionMaximumConnectionsPerHost;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        configuration.timeoutIntervalForRequest = 60 * 60;
        configuration.timeoutIntervalForResource = 60 * 60;
        _sessionWWanManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _sessionWWanManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _sessionWWanManager;
}

- (AFHTTPSessionManager *)sessionWWanManager4Lan {
    if (!_sessionWWanManager4Lan) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.allowsCellularAccess = YES;
        configuration.HTTPMaximumConnectionsPerHost = kNetworkingSessionMaximumConnectionsPerHostForLan;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        configuration.timeoutIntervalForRequest = 60 * 60;
        configuration.timeoutIntervalForResource = 60 * 60;
        _sessionWWanManager4Lan = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _sessionWWanManager4Lan.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _sessionWWanManager4Lan;
}


@end
