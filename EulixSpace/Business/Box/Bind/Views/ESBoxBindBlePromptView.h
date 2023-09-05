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
//  ESBoxBindBlePromptView.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxBindDefine.h"
#import <UIKit/UIKit.h>
#import <Lottie/LOTAnimationView.h>

@interface ESBoxBindBlePromptView : UIView <ESBoxBindPromptProtocol>

//@property (nonatomic, copy) void (^actionBlock)(id action);
@property (nonatomic, strong) LOTAnimationView *animation;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *title;

- (void)initUI;
- (void)reloadWithState:(ESBoxBindState)state;

@end
