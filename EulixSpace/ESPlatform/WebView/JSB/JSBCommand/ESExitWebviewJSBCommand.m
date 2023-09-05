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
//  ESExitWebviewJSBCommand.m
//  EulixSpace
//
//  Created by KongBo on 2023/5/11.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESExitWebviewJSBCommand.h"

@implementation ESExitWebviewJSBCommand

/**
{
   {titleName:'xxx',canGoBack:true|false}
}*/

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        [self.context.webVC.navigationController popViewControllerAnimated:YES];
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"onClickExit";
}
@end
