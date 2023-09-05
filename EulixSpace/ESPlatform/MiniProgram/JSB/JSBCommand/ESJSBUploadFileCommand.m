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
//  ESJSBExportContactsCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/18.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBUploadFileCommand.h"
#import "ESNetworkRequestManager.h"


#import "ESContactManager.h"
#import "ESAppletManager.h"
#import "ESAppletManager+ESCache.h"
#import "ESApplicationConfigStorage.h"
#import "ESWXFileShareManager.h"

@interface ESJSBUploadFileCommand ()

@property (nonatomic, strong) ESContactManager *contactManager;

@end

@implementation ESJSBUploadFileCommand

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        ESDLog(@"[ESJSBUploadFileCommand] invoke commandHander data: %@", data);

        if (![data isKindOfClass:[NSDictionary class]]) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        NSDictionary *params = (NSDictionary *)data;
        if (![params.allKeys containsObject:@"sourcePath"]) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        
        [self uploadFileWithFileParams:params responseCallback:responseCallback];
    };
    return _commandHander;
}


- (void)uploadFileWithFileParams:(NSDictionary *)params responseCallback:(ESJBResponseCallback)responseCallback {
    NSString *appletId =  params[@"appletId"] ?: self.context.appletInfo.appletId;
    NSString *targetPath =  params[@"targetPath"];
    NSString *sourcePath =  params[@"sourcePath"];
    
    ESDLog(@"[ESJSBUploadFileCommand] [uploadFileWithFileParams] appletId: %@ \n targetPath: %@\n sourcePath: %@\n", appletId, targetPath, sourcePath);

    [ESNetworkRequestManager sendCallUploadRequest:@{ @"serviceName" : @"eulixspace-applet-service",
                                                      @"apiName" : @"file_upload",
                                                      @"apiVersion" : @"v1"
                                                   }
                                       queryParams:@{
                                                     @"path" : targetPath ?: ESSafeString(@""),
                                                     @"file" : ESSafeString([NSURL fileURLWithPath:sourcePath].lastPathComponent),
                                                     @"applet_id" : ESSafeString(appletId)
                                                   }
                                            header:@{}
                                              body:@{
                                                     @"mediaType":@"application/octet-stream",
                                                     @"filename":ESSafeString([NSURL fileURLWithPath:sourcePath].lastPathComponent)
                                                   }
                                          filePath:sourcePath
                                      successBlock:^(NSInteger requestId, id  _Nullable response) {
        NSDictionary *result = (NSDictionary *)response;
        ESDLog(@"[ESJSBUploadFileCommand] [sendCallUploadRequest] result: %@ \n", result);

        if (![result isKindOfClass:[NSDictionary class]] ||
            !([result.allKeys containsObject:@"filepath"] ||
              [result.allKeys containsObject:@"filePath"]) ) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : ESSafeString(@"后台返回数据格式错误")
                             });
            return;
        }
        
        NSString *filePath = result[@"filePath"]  ?: result[@"filepath"];
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{@"filePath" : ESSafeString(filePath),
                                        @"context" : @{
                                            @"platform" : @"iOS",
                                            @"appVersion" : ESApplicationConfigStorage.applicationVersion
                                        }
                            },
                            @"msg" : @""
                         });
        
            }
                                 failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         responseCallback(@{ @"code" : @(-1),
                             @"data" : @{},
                             @"msg" : ESSafeString(error.description)
                          });
     }];
}

- (NSString *)commandName {
    return @"uploadFile";
}

- (ESContactManager *)contactManager {
    if (!_contactManager) {
        _contactManager = [ESContactManager new];
    }
    return _contactManager;
}

@end
