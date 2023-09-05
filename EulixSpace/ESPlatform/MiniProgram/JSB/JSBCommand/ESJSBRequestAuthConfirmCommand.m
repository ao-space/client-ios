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
//  ESJSBRequestAuthConfirmCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBRequestAuthConfirmCommand.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"
#import "ESAuthConfirmVC.h"
#import "UIViewController+ESPresent.h"
#import "ESAuthParseManager.h"
#import "ESToast.h"
#import "ESLocalizableDefine.h"

@interface ESJSBRequestAuthConfirmCommand ()

@property (nonatomic, strong) ESAuthConfirmVC *authConfirmVC;

@end


@implementation ESJSBRequestAuthConfirmCommand

/*
 请求参数:
{
    "appletId": "小应用id",
    "appletSecret": "小应用secret",
    "appletVersion": "小应用版本号"
}
 返回参数：
{
    "authCode": "小程序认证code"
}
*/


- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        if (![data isKindOfClass:[NSDictionary class]]) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        NSDictionary *params = (NSDictionary *)data;

        if (![params.allKeys containsObject:@"appletId"] ||
            ![params.allKeys containsObject:@"appletSecret"] ||
            ![params.allKeys containsObject:@"appletVersion"] ) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        
        NSString *appletId = params[@"appletId"];
        NSString *appletSecret = params[@"appletSecret"];
        NSString *appletVersion = params[@"appletVersion"];

//        NSString *appletId = @"eb640ee6450b6742";
//        NSString *appletSecret = @"PC5FKBq03SaKn3K7ahZTj5lE9czRdNKBZsoxg3x7vQ0ryV0MkPgwsLkpywNvteZg";
//        NSString *appletVersion = @"1";
        [self getAuthScopesWithInfo:appletId
                       appletSecret:appletSecret
                      appletVersion:appletVersion
                   responseCallback:responseCallback];
    };
    return _commandHander;
}
    
- (void)getAuthScopesWithInfo:(NSString *)appletId
                appletSecret:(NSString *)appletSecret
                appletVersion:(NSString *)appletVersion
             responseCallback:(ESJBResponseCallback _Nullable) responseCallback {
    
    ESToast.showLoading(TEXT_WAIT, self.context.appletVC.view);

    [ESNetworkRequestManager sendCallRequest:@{@"serviceName" : @"eulixspace-openapi-service",
                                               @"apiName" : @"get_auth_scopes"
                                              }
                              queryParams:@{@"applet_id": ESSafeString(appletId),
                                            @"applet_secret" : ESSafeString(appletSecret),
                                            @"applet_version" : ESSafeString(appletVersion ?: self.context.appletInfo.installedAppletVersion)
                                          }
                                   header:nil
                                     body:nil
                                modelName:nil
                             successBlock:^(NSInteger requestId, NSDictionary *_Nullable response) {
        [ESToast dismiss];
     if (![response isKindOfClass:[NSDictionary class]] ||
         ![response.allKeys containsObject:@"categories"]) {
         responseCallback(@{ @"code" : @(-1),
                             @"data" : @{},
                             @"msg" : @"后台返回数据错误"
                          });
         return;
     }
         
     
     NSDictionary *responseMap = (NSDictionary *)response;
     NSDictionary *categories = responseMap[@"categories"];
     
     NSString *authTitle = [ESAuthParseManager parseTitleAuthWithAuthCategories:categories];
     [self.authConfirmVC setAuthTitle:authTitle];
     
     NSString *autDetail = [ESAuthParseManager parseAuthDetailWithAuthCategories:categories];
     [self.authConfirmVC setAuthDetail:autDetail];

     __weak typeof(self) weakSelf = self;
     self.authConfirmVC.operateBlock = ^(ESAuthOperateType type) {
         __strong typeof(weakSelf) self = weakSelf;
         if (type == ESAuthOperateTypeConfirm) {
             [self.authConfirmVC es_dismissViewControllerAnimated:YES completion:nil];
             [self getAuthCodeWithInfo:appletId
                          appletSecret:appletSecret
                         appletVersion:appletVersion
                      responseCallback:responseCallback];
         }
     };
     [self.context.appletVC es_presentViewController:self.authConfirmVC animated:YES completion:^{
     }];
    }
                                failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     [ESToast dismiss];
     responseCallback(@{ @"code" : @(-1),
                         @"data" : @{},
                         @"msg" : ESSafeString(error.userInfo[ESNetworkErrorUserInfoMessageKey] ?: error.description)
                      });
    }];
}

- (ESAuthConfirmVC *)authConfirmVC {
    if (!_authConfirmVC) {
        _authConfirmVC = [[ESAuthConfirmVC alloc] initWithAppletInfo:self.context.appletInfo];
        _authConfirmVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return _authConfirmVC;
}

- (void)getAuthCodeWithInfo:(NSString *)appletId
                appletSecret:(NSString *)appletSecret
                appletVersion:(NSString *)appletVersion
                                responseCallback:(ESJBResponseCallback _Nullable) responseCallback {
    NSString *aoId = ESBoxManager.activeBox.aoid;

    ESToast.showLoading(TEXT_WAIT, self.context.appletVC.view);
     __weak typeof(self) weakSelf = self;
    [ESNetworkRequestManager sendCallRequest:@{@"serviceName" : @"eulixspace-openapi-service",
                                               @"apiName" : @"get_auth_confirm"
                                             }
                                 queryParams:@{@"applet_id": ESSafeString(appletId),
                                               @"applet_secret" : ESSafeString(appletSecret),
                                               @"aoid" : ESSafeString(aoId),
                                               @"applet_version" : ESSafeString( appletVersion ?: self.context.appletInfo.installedAppletVersion)
                                             }
                                      header:nil
                                        body:nil
                                   modelName:nil
                                successBlock:^(NSInteger requestId, id  _Nullable response) {
        [ESToast dismiss];
        __strong typeof(weakSelf) self = weakSelf;
        if ([response isKindOfClass:[NSDictionary class]] &&
            [[(NSDictionary *)response allKeys] containsObject: @"authCode"]) {
            NSDictionary *responseMap = (NSDictionary *)response;
            NSString *authCode = responseMap[@"authCode"];
            NSString *authTicket = responseMap[@"authTicket"];

            responseCallback(@{ @"code" : @(200),
                                @"data" : @{@"authCode" : ESSafeString(authCode),
                                            @"authTicket" : ESSafeString(authTicket)
                                },
                                @"msg" : @"",
                                @"context" : @{
                                    @"platform" : @"iOS",
                                    @"appVersion" : ESApplicationConfigStorage.applicationVersion
                                }
                             });
        } else {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"后台返回数据错误"
                             });
        }
       }
                                   failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
        responseCallback(@{ @"code" : @(-1),
                            @"data" : @{},
                            @"msg" : ESSafeString(error.userInfo[ESNetworkErrorUserInfoMessageKey] ?: error.description)
                         });
    }];
}

- (NSString *)commandName {
    return @"requestAuthConfirm";
}

@end
