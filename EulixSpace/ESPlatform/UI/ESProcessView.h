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
//  ESProcessView.h
//  EulixSpace
//
//  Created by KongBo on 2023/4/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESProcessView : UIView

/// 0.0 .. 1.0, default is 0.0. values outside are pinned.
@property (nonatomic, assign) CGFloat progressValue;

/// The color shown for the portion of the progress bar that is filled.
//进度条渐变颜色数组，颜色个数>=2   默认是 @[kHuColor(#FDA249),kHuColor(#FF823C)]
@property (nonatomic, strong, nullable) NSArray *tintColorArray;

/// The color shown for the portion of the progress bar that is not filled.
//默认背景色kHuColor(#E8E8E8)
@property (nonatomic, strong, nullable) UIColor *trackTintColor;

@end

NS_ASSUME_NONNULL_END
