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
//  ESAppletScopesManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletScopesManager.h"
#import "ESNetworkRequestManager.h"
#import "ESAuthParseManager.h"

@implementation ESAppletBaseInfo

@end

@interface ESAppletScopesInfo : NSObject

@property (nonatomic, assign) ESAppletAuthStatus authStatus;
@property (nonatomic, copy) NSString *authCode;
@property (nonatomic, copy) NSDictionary *categories;

@end

@implementation ESAppletScopesInfo

@end

@interface ESAppletScopesManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, ESAppletScopesInfo *> *socpesInfo;

@end

@implementation ESAppletScopesManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)requestAccessAuthWithType:(ESAppletAccessAuthType)accessAuthType
                       appletInfo:(ESAppletBaseInfo *)appletInfo
                completionHandler:(ESAppletAuthRequestCompeltionCallback)callback {
    
    if ([self.socpesInfo.allKeys containsObject:ESSafeString(appletInfo.appletId)]) {
        ESAppletAuthStatus authStatus = [self authorizationStatusForAccessType:accessAuthType appletId:ESSafeString(appletInfo.appletId)];
        if (authStatus != ESAppletAuthStatusNotDetermined) {
            callback(authStatus == ESAppletAuthStatusAuthorized, nil);
            return;
        }
    }
    
    [ESNetworkRequestManager sendCallRequest:@{@"serviceName" : @"eulixspace-openapi-service",
                                               @"apiName" : @"get_auth_scopes"
                                              }
                              queryParams:@{@"applet_id": ESSafeString(appletInfo.appletId),
                                            @"applet_secret" : ESSafeString(appletInfo.appletSecret),
                                            @"applet_version" : ESSafeString(appletInfo.appletVersion)
                                          }
                                   header:nil
                                     body:nil
                                modelName:nil
                             successBlock:^(NSInteger requestId, NSDictionary *_Nullable response) {
     if (![response isKindOfClass:[NSDictionary class]] ||
         ![response.allKeys containsObject:@"categories"]) {
         callback(NO, [NSError errorWithDomain:@"JSB Error"
                                          code: -1000
                                      userInfo:@{ESNetworkErrorUserInfoMessageKey : @"Auth scopes response error"}]);
         return;
     }
        NSDictionary *responseMap = (NSDictionary *)response;
        NSDictionary *categories = responseMap[@"categories"];
        NSString *authCode = responseMap[@"authCode"];

        BOOL contain = [self parseContainAuthWithType:accessAuthType scopesInfo:categories];
        
        [self addAuthStatusWithAppletId:appletInfo.appletId authCode:authCode categories:categories contain:contain];
        callback(contain, nil);
    }
                                   failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                   callback(NO, error);
       }];
}

- (ESAppletAuthStatus)authorizationStatusForAccessType:(ESAppletAccessAuthType)accessAuthType
                                              appletId:(NSString *)appletId {
    if (![self.socpesInfo.allKeys containsObject:ESSafeString(appletId)]) {
        return ESAppletAuthStatusNotDetermined;
    }
    ESAppletScopesInfo *scopesInfo = self.socpesInfo[ESSafeString(appletId)];
    //先取是否有该权限的定义
    if (![self parseContainAuthWithType:accessAuthType scopesInfo:scopesInfo.categories]) {
        return ESAppletAuthStatusNoAuthorized;
    }
    
    return (scopesInfo.authStatus == ESAppletAuthStatusAuthorized) ? ESAppletAuthStatusAuthorized : ESAppletAuthStatusNoAuthorized;
}

- (BOOL)parseContainAuthWithType:(ESAppletAccessAuthType)accessAuthType scopesInfo:(NSDictionary *)scopesInfo  {
    if (accessAuthType == ESAppletAccessAuthTypeContact) {
        return [ESAuthParseManager parseContainContactAuth:scopesInfo];
    }
   
    return ESAppletAuthStatusNoAuthorized;
}

- (void)addAuthStatusWithAppletId:(NSString *)appletId
                       authCode:(NSString *)authCode
                       categories:(NSDictionary *)categories
                          contain:(BOOL)contain {
    ESAppletScopesInfo *scopesInfo = [ESAppletScopesInfo new];
    scopesInfo.authStatus = contain ? ESAppletAuthStatusAuthorized : ESAppletAuthStatusNoAuthorized;
    scopesInfo.authCode = authCode;
    scopesInfo.categories = categories;
    self.socpesInfo[ESSafeString(appletId)] = scopesInfo;
}

- (void)clearAuthStatusWithAppletId:(NSString *)appletId {
    if ([self.socpesInfo.allKeys containsObject:ESSafeString(appletId)]) {
        [self.socpesInfo removeObjectForKey:ESSafeString(appletId)];
    }
}


- (NSMutableDictionary<NSString *, ESAppletScopesInfo *> *)socpesInfo {
    if (!_socpesInfo) {
        _socpesInfo = [NSMutableDictionary<NSString *, ESAppletScopesInfo *> new];
    }
    return _socpesInfo;
}


@end
