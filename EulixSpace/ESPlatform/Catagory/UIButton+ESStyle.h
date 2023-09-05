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
//  UIButton+ESStyle.h
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (ESStyle)

- (void)setLeftTextRightImageStyleOffset:(CGFloat)offset;

- (void)setTopTextBottomImageStyleOffset:(CGFloat)offset;

- (void)setBottomTextTopImageStyleOffset:(CGFloat)offset;
//正常使用该方法
- (void)setBottomTextTopImageStyle2Offset:(CGFloat)padding;

@end

NS_ASSUME_NONNULL_END
