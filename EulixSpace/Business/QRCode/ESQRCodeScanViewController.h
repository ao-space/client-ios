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
//  ESQRCodeScanViewController.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/7.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <YCBase/YCViewController.h>

typedef NS_ENUM(NSUInteger, ESQRCodeScanAction) {
    ESQRCodeScanActionDefault = 1, //不限制扫描内容
    ESQRCodeScanActionLogin, // 授权登录
    ESQRCodeScanActionBoxUrl,
    ESQRCodeScanActionResetNetwork,
    ESQRCodeScanActionTrailBoxUrl,
};

@interface ESQRCodeScanViewController : YCViewController

@property (nonatomic, assign) ESQRCodeScanAction action;

//正则匹配，只在 action = ESQRCodeScanActionDefault 生效
@property (nonatomic, copy) NSString *regExpStr;

@property (nonatomic, copy) void (^callback)(NSString *value);

@end
