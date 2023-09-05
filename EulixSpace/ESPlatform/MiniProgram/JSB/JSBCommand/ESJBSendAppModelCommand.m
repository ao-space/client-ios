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
//  ESJBSendAppModelCommand.m
//  EulixSpace
//
//  Created by qu on 2023/7/28.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESJBSendAppModelCommand.h"
#import "ESJSBUploadFileCommand.h"
#import "ESNetworkRequestManager.h"


#import "ESContactManager.h"
#import "ESAppletManager.h"
#import "ESWebDataManager.h"

#import "ESAppletManager+ESCache.h"
#import "ESApplicationConfigStorage.h"
#import "ESWXFileShareManager.h"

@implementation ESJBSendAppModelCommand


- (NSString *)commandName {
    return @"SendAppModel";
}

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        //           "uuid": "client_uuid",
        //           "userId": "ao_id",
        //           "avatarPath": "头像资源本地路径",
        //           "nickName": "昵称",
        //           "userDomain": "用户域名"
        
        NSNumber *uninstallType;
        if(self.context.appletInfo.isUnInstalled){
            uninstallType = @(1);
        }else{
            uninstallType = @(0);
        }
  
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{@"appId" : ESSafeString(self.context.appletInfo.appletId),
                                        @"containerWebUrl" : ESSafeString(self.context.appletInfo.originUrl),
                                        @"curVersion" : ESSafeString(self.context.appletInfo.appletVersion),
                                        @"iconUrl" : ESSafeString(self.context.appletInfo.iconUrl),
                                        @"name" : ESSafeString(self.context.appletInfo.name),
                                        @"packageId" : ESSafeString(self.context.appletInfo.packageId),
                                        @"uninstallType" : ESSafeString(uninstallType),
                            },
                            @"msg" : @"",
                            @"context" : @{
                                @"platform" : @"iOS",
                                @"appVersion" : ESApplicationConfigStorage.applicationVersion
                            }
                         });
    };
    return _commandHander;
}


@end

