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
//  ESJSBExitAppletCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/7.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESJSBExitAppletCommand.h"

@interface ESAppletViewController ()

- (void)closeApplet;

@end


@implementation ESJSBExitAppletCommand

- (ESJBHandler)commandHander {
    __weak typeof(self) weakSelf = self;
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.context.appletVC closeApplet];
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"exitApplet";
}

@end
