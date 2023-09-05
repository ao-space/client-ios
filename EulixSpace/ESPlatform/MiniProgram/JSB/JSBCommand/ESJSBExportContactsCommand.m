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
//  ESJSBRequestContactVCardFileCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/4.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBExportContactsCommand.h"
#import "ESContactManager.h"
#import "ESAppletManager.h"
#import "ESAppletManager+ESCache.h"
#import "ESApplicationConfigStorage.h"
#import "ESWXFileShareManager.h"
#import "ESAppletScopesManager.h"

@interface ESJSBExportContactsCommand ()

@property (nonatomic, strong) ESContactManager *contactManager;

@end

@implementation ESJSBExportContactsCommand

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        if (![self checkResponseData:data callback:responseCallback]) {
            return;
        }
        
        NSDictionary *params = (NSDictionary *)data;
        ESAppletBaseInfo *appletInfo = [ESAppletBaseInfo new];
        appletInfo.appletId = self.context.appletInfo.appletId;
        appletInfo.appletSecret = ESSafeString(params[@"appletSecret"]);
        appletInfo.appletVersion = params[@"appletVersion"] ?: self.context.appletInfo.appletVersion;
        
        [ESAppletScopesManager.shared requestAccessAuthWithType:ESAppletAccessAuthTypeContact appletInfo:appletInfo completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [self fetchContactWithResponseCallback:responseCallback];
                return;
            }
            
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : error ? ESSafeString(error.description) : @"没有权限"
                             });
        }];
    };
    return _commandHander;
}

- (void)fetchContactWithResponseCallback:(ESJBResponseCallback)responseCallback {
    NSString *fileDir = [ESAppletManager.shared getCacheAppletIndexPageDirWithAppletId:ESSafeString(self.context.appletInfo.appletId)];
    ESDLog(@"[ESJSBExportContactsCommand] fetchContactVCardFileWithCustomCacheFileDir: %@", fileDir);

    [self.contactManager fetchContactVCardFileWithCustomCacheFileDir:fileDir
                                                   completionHandler:^(BOOL success, NSString * _Nullable vCardFilePath, NSUInteger count,  NSError * _Nullable error) {
        ESDLog(@"[ESJSBExportContactsCommand] fetchContactVCardFileWithCustomCacheFileDir result: %d  vCardFilePath: %@ count: %lu  error: %@", success,
                                                                                                                                               vCardFilePath,
                                                                                                                                               (unsigned long)count,
                                                                                                                                               error);

        if (success) {
            responseCallback(@{ @"code" : @(200),
                                @"data" : @{@"filePath" : ESSafeString(vCardFilePath),
                                            @"contactCount" : @(count),
                                            @"context" : @{
                                                @"platform" : @"iOS",
                                                @"appVersion" : ESApplicationConfigStorage.applicationVersion
                                            }
                                },
                                @"msg" : @""
                             });
            return;
        }
        
        responseCallback(@{ @"code" : @(-1),
                            @"data" : @{},
                            @"msg" : ESSafeString(error.description)
                         });
    }];
}

- (NSArray<NSString *> *)needCheckParams {
    return @[@"appletSecret"];
}

- (NSString *)commandName {
    return @"exportContacts";
}

- (ESContactManager *)contactManager {
    if (!_contactManager) {
        _contactManager = [ESContactManager new];
    }
    return _contactManager;
}

@end
