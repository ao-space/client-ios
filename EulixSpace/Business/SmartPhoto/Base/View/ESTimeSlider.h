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
//  ESTimeSlider.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESTimeSliderShowStyle) {
    ESTimeSliderShowStyleHideen,
    ESTimeSliderShowStyleNormal,
    ESTimeSliderShowStyleTimeLine,
};

typedef void (^ESTimeSliderValueChangedBlock)(CGFloat value);

@interface ESTimeSlider : UIView

@property (nonatomic, assign) ESTimeSliderShowStyle showStyle;
@property (nonatomic, copy) ESTimeSliderValueChangedBlock valueChangedBlock;
@property (nonatomic, copy)dispatch_block_t trackingBlock;
@property (nonatomic, copy)dispatch_block_t endTrackingBlock;

- (void)updateTimeText:(NSString *)time;
- (void)setValue:(float)value;

@end

NS_ASSUME_NONNULL_END
