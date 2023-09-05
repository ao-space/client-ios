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
//  ESDebugMacro.h
//  ESDebugMacro
//
//  Created by Ye Tao on 2021/8/23.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESDebugMacro_h
#define ESDebugMacro_h

#import <Foundation/Foundation.h>

///注释掉下面这行, 就没有后门了
#define ES8ackD00r 1

///Websocket
static NSString *const kESSessionClientHost = @"wss://services.eulix.xyz/platform/";

static NSString *const kESSentryDns = @"https://2b5431322e5f436db4f2f801593a9029@sentry.eulix.xyz/2";

#define BLE_KEY @"51ff2e5142f133621052dcadb804b059"

#define BLE_IV @"v3/QEXuw06ZVbMbiCYu4Hw=="

static NSString *const kESAgreementformClientHost = @"https://dev-services.eulix.xyz/";
#endif /* ESDebugMacro_h */
