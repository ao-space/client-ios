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
//  ESWebViewJSBCommand.h
//  EulixSpace
//
//  Created by KongBo on 2023/3/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESWebViewJavascriptBridge.h"
#import "ESWebVC.h"
#import "ESWebNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ESWebViewJSBCommandProtocol <NSObject>

- (NSArray<NSString *> *)needCheckParams;

@end

@interface ESWebVCJSBContext : NSObject

@property (nonatomic, weak) ESWebVC *webVC;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, weak) ESWebNavigationBar *customNavigationBar;

@end

@interface ESWebViewJSBCommand : NSObject <ESWebViewJSBCommandProtocol>

@property (nonatomic, readonly) NSString *commandName;
@property (nonatomic, readonly) ESJBHandler commandHander;
@property (nonatomic, strong) ESWebVCJSBContext *context;

- (BOOL)checkResponseData:(id)data callback:(ESJBResponseCallback _Nullable) responseCallback;

@end

NS_ASSUME_NONNULL_END
