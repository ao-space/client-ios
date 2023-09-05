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
//  ESJSBOpenContactSystemSettingCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBOpenContactSystemSettingCommand.h"

@implementation ESJSBOpenContactSystemSettingCommand

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        if (@available(iOS 11.0, *)) {
            [self tryOpenContactSystemSettingOverSystemVersion11WithResopnseCallback:responseCallback];
            return;
        }
        
        [self tryOpenContactSystemSettingOverSystemVersion10WithResopnseCallback:responseCallback];
        return;
    };
    return _commandHander;
}

- (void)tryOpenContactSystemSettingOverSystemVersion11WithResopnseCallback:(ESJBResponseCallback)responseCallback {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{},
                            @"msg" : @""
                         });
        return;
    }
    
    responseCallback(@{ @"code" : @(-1),
                        @"data" : @{},
                        @"msg" : @""
                     });
    
}

- (void)tryOpenContactSystemSettingOverSystemVersion10WithResopnseCallback:(ESJBResponseCallback)responseCallback {
    NSURL *url = [NSURL URLWithString:@"Prefs:root=Privacy&path=CONTACTS"];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{},
                            @"msg" : @""
                         });
        return;
    }
    
    responseCallback(@{ @"code" : @(-1),
                        @"data" : @{},
                        @"msg" : @""
                     });
    
}

- (NSString *)commandName {
    return @"openContactSystemSetting";
}

@end


