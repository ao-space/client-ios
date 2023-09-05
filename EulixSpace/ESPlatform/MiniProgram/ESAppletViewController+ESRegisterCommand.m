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
//  ESAppletViewController+ESRegisterCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletViewController+ESRegisterCommand.h"
#import "ESWebViewJavascriptBridge.h"
#import "ESWebViewJSBBaseCommand.h"

@interface ESAppletViewController ()<WKNavigationDelegate>

@property ESWebViewJavascriptBridge* bridge;
@property (nonatomic, strong) ESAppletInfoModel* appletInfo;
@property (nonatomic, strong) ESNavigationBar *customNavigationBar;
@property (nonatomic, copy) NSString* url;

@end

@implementation ESAppletViewController (ESRegisterCommand)

- (void)registerMethods {
    NSArray *registerCommandClassList = [self registerCommandClassList];
    [registerCommandClassList enumerateObjectsUsingBlock:^(NSString *commandClassName, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![commandClassName isKindOfClass:[NSString class]]) {
            return;
        }
        
        if (commandClassName.length <= 0) {
            return;
        }
        
        Class commandClass = NSClassFromString(commandClassName);
        if (!commandClass) {
            return;
        }
        
        if (![commandClass isSubclassOfClass:[ESWebViewJSBBaseCommand class]]) {
            return;
        }
        
        ESWebViewJSBBaseCommand *commandObject = (ESWebViewJSBBaseCommand *)[commandClass new];
        commandObject.context.appletInfo = self.appletInfo;
        commandObject.context.customNavigationBar = self.customNavigationBar;
        commandObject.context.appletVC = self;
        commandObject.context.url = self.url;

        [self.bridge registerHandler:commandObject.commandName handler:commandObject.commandHander];
    }];
  
}

- (NSArray<NSString *> *)registerCommandClassList {
    return @[ @"ESJSBGetUserInfoCommand",
              @"ESCustomNavigationBarCommand",
              @"ESJSBGetAuthParamsCommand",
              @"ESJSBRequestAuthConfirmCommand",
              @"ESJSBSaveWebDataCommand",
              @"ESJSBGetWebDataCommand",
              @"ESJSBExportContactsCommand",
              @"ESJSBExitAppletCommand",
              @"ESJSBUploadFileCommand",
              @"ESJSBOpenContactSystemSettingCommand",
              @"ESJSBContactCountCommand",
              @"ESJSBOpenUrlWithSystemWebCommand",
              @"ESJBSendAppModelCommand",
    ];
}
@end
