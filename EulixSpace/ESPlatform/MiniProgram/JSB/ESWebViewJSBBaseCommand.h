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
//  ESWebViewJSBBaseCommand.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESWebViewJavascriptBridge.h"
#import "ESAppletInfoModel.h"
#import "ESAppletViewController.h"
#import "ESNavigationBar.h"
#import "ESApplicationConfigStorage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ESWebViewJSBBaseCommandProtocol <NSObject>

- (NSArray<NSString *> *)needCheckParams;

@end

@interface ESWebViewJSBContext : NSObject

@property (nonatomic, weak) ESAppletViewController *appletVC;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, weak) ESNavigationBar *customNavigationBar;
@property (nonatomic, weak) ESAppletInfoModel *appletInfo;

@end

@interface ESWebViewJSBBaseCommand : NSObject <ESWebViewJSBBaseCommandProtocol>

@property (nonatomic, readonly) NSString *commandName;
@property (nonatomic, readonly) ESJBHandler commandHander;
@property (nonatomic, strong) ESWebViewJSBContext *context;

- (BOOL)checkResponseData:(id)data callback:(ESJBResponseCallback _Nullable) responseCallback;

@end

NS_ASSUME_NONNULL_END
