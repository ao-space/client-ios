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
//  ESJSBImportVCardContactsCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBImportVCardContactsCommand.h"
#import "ESContactManager.h"
#import "ESAppletManager.h"
#import "ESAppletManager+ESCache.h"
#import "ESApplicationConfigStorage.h"
#import "ESWXFileShareManager.h"
#import "ESNetworkRequestManager.h"

@interface ESJSBImportVCardContactsCommand ()

@property (nonatomic, strong) ESContactManager *contactManager;

@end

@implementation ESJSBImportVCardContactsCommand

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

        if (![params.allKeys containsObject:@"strategy"]) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        
        NSString *appletId = self.context.appletInfo.appletId;
        NSString *fileDir = [ESAppletManager.shared getCacheAppletIndexPageDirWithAppletId:appletId];
        [self.contactManager fetchContactVCardFileWithCustomCacheFileDir:fileDir
                                                       completionHandler:^(BOOL success, NSString * _Nullable vCardFilePath, NSUInteger count, NSError * _Nullable error) {
            if (success && count > 0 && vCardFilePath.length > 0) {
                [self fetchContactListWithParams:params
                                   vCardFilePath:vCardFilePath
                                           count:count
                                responseCallback:responseCallback];
                return;
             }
            responseCallback(@{ @"code" : @(-1),
                               @"data" : @{},
                               @"msg" : @"vCard文件导出失败"
                            });
        }];
    };
    return _commandHander;
}

- (void)fetchContactListWithParams:(NSDictionary *)params
                     vCardFilePath:(NSString *)vCardFilePath
                            count:(NSUInteger) count
                  responseCallback:(ESJBResponseCallback _Nullable) responseCallback {
    [ESNetworkRequestManager sendCallRequest:@{ @"serviceName" : @"eulixspace-addressbook-service",
                                                @"apiName" : @"list_contacts",
                                                }
                                 queryParams:nil
                                      header:nil
                                        body:nil
                                   modelName:nil
                                successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self importContactWithParams:params
                        vCardFilePath:vCardFilePath
                                count:count
                     responseCallback:responseCallback];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        responseCallback(@{ @"code" : @(-1),
                            @"data" : @{},
                            @"msg" : ESSafeString(error.description)
                         });
    }];
}
    
- (void)importContactWithParams:(NSDictionary *)params
                       vCardFilePath:(NSString *)vCardFilePath
                              count:(NSUInteger)count
                    responseCallback:(ESJBResponseCallback _Nullable) responseCallback {
                NSString *strategy = params[@"strategy"];
        [ESNetworkRequestManager sendCallUploadRequest:@{ @"serviceName" : @"eulixspace-addressbook-service",
                                                          @"apiName" : @"import_contacts",
                                                          @"apiVersion" : @"v1.0"
                                                       }
                                           queryParams:@{
                                                         @"strategy" : ESSafeString(strategy),
                                                         @"name" : ESSafeString([NSURL fileURLWithPath:vCardFilePath].lastPathComponent)
                                                       } // merge-合并, cover-覆盖
                                                header:@{}
                                                  body:@{
                                                         @"mediaType":@"application/octet-stream",
                                                         @"filename":ESSafeString([NSURL fileURLWithPath:vCardFilePath].lastPathComponent)
                                                       }
                                              filePath:vCardFilePath
                                          successBlock:^(NSInteger requestId, id  _Nullable response) {
            NSDictionary *result = (NSDictionary *)response;
            if (![result isKindOfClass:[NSDictionary class]] ||
                ![result.allKeys containsObject:@"success"] ||
                ![result.allKeys containsObject:@"fail"] ||
                ![result.allKeys containsObject:@"total"]) {
                responseCallback(@{ @"code" : @(-1),
                                    @"data" : @{},
                                    @"msg" : ESSafeString(@"后台返回数据格式错误")
                                 });
                return;
            }
            
            NSUInteger successCount = [result[@"success"] intValue];
            NSUInteger failCount = [result[@"fail"] intValue];
            NSUInteger totalCount = [result[@"total"] intValue];
            
            responseCallback(@{ @"code" : @(200),
                                @"data" : @{@"success" : @(successCount),
                                            @"fail" : @(failCount),
                                            @"total" : @(totalCount),
                                            @"context" : @{
                                                @"platform" : @"iOS",
                                                @"appVersion" : ESApplicationConfigStorage.applicationVersion
                                            }
                                },
                                @"msg" : @""
                             });
            
                    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        responseCallback(@{ @"code" : @(-1),
                                            @"data" : @{},
                                            @"msg" : ESSafeString(error.description)
                                         });
                    }];
}

- (NSString *)commandName {
    return @"importVCardContacts";
}

- (ESContactManager *)contactManager {
    if (!_contactManager) {
        _contactManager = [ESContactManager new];
    }
    return _contactManager;
}

@end
