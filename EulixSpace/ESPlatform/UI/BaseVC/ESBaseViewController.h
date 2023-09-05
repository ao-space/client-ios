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
//  ESBaseViewController.h
//  EulixSpace
//
//  Created by KongBo on 2022/8/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESDefaultEmptyView.h"
#import "ESEmptyLoadingView.h"
#import <YCBase/YCViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESBaseViewController : UIViewController {
    ESDefaultEmptyView *_emptyView;
    UIView *_maskView;
    ESEmptyLoadingView *_emptyLoadingView;
}

@property (nonatomic, assign, readonly) BOOL hasEnterBackground;
@property (nonatomic, assign) BOOL isViewVisible;
@property (nonatomic, assign) BOOL showBackBt;

- (void)enterForground:(id _Nullable)sender;
- (void)enterBackground:(id _Nullable)sender;
- (void)willResignActive:(id _Nullable)sender;
- (void)didBecomeActive:(id _Nullable)sender;

- (BOOL)es_needShowNavigationBar;

- (UIColor *)customeNavigationBarBackgroudColor;

@end

NS_ASSUME_NONNULL_END
