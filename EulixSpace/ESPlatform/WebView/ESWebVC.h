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
//  ESWebVC.h
//  EulixSpace
//
//  Created by KongBo on 2023/3/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ESWebVCShowStyle_CustomNavigationBar,
    ESWebVCShowStyle_FullScreen,
    ESWebVCShowStyle_Translucent,
} ESWebVCShowStyle;

@interface ESWebVC : UIViewController

@property (nonatomic, assign) ESWebVCShowStyle style;
@property (nonatomic, strong) UIColor *statusBarBackgroudColor;

- (void)loadWithURL:(NSString *)url;

- (void)registerMethods;
- (NSArray<NSString *> *)registerCommandClassList;

- (NSArray *)canOpenSchemeWhiteList;

- (void)layoutWebViewIfNeed;

- (BOOL)useCustomNavigationBar;

@end

NS_ASSUME_NONNULL_END
