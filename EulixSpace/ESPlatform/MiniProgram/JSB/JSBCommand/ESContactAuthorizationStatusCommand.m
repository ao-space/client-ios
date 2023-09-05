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
//  ESContactAuthorizationStatusCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESContactAuthorizationStatusCommand.h"
#import <Contacts/Contacts.h>

@interface ESContactAuthorizationStatusCommand ()

@property (nonatomic, copy) ESJBResponseCallback responseCallback;

@end

@implementation ESContactAuthorizationStatusCommand

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined)
        {
            CNContactStore *store = [CNContactStore new];
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted)
                {
                    responseCallback(@{ @"code" : @(200),
                                        @"data" : @{},
                                        @"msg" : @""
                                     });
                }
                else
                {
                    responseCallback(@{ @"code" : @(-1),
                                        @"data" : @{},
                                        @"msg" : @"授权失败"
                                     });
                }
            }];
     }
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"getContactAuthorizationStatus";
}

@end
