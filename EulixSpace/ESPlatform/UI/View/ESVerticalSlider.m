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
//  ESVerticalSlider.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESVerticalSlider.h"

@implementation ESVerticalSlider

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self initVerticalSlider];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVerticalSlider];
    }
    return self;
}

- (void)initVerticalSlider
{
    CGRect rect = self.frame;
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.frame = rect;
    
    [self setMinimumValueImage:self.minimumValueImage];
    [self setMaximumValueImage:self.maximumValueImage];
    [self setThumbImage:[self thumbImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self setThumbImage:[self thumbImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [self setThumbImage:[self thumbImageForState:UIControlStateSelected] forState:UIControlStateSelected];
    [self setThumbImage:[self thumbImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
}

- (void)setMinimumValueImage:(UIImage *)image
{
    [super setMinimumValueImage:[self rotatedImage:image]];
}

- (void)setMaximumValueImage:(UIImage *)image
{
    [super setMaximumValueImage:[self rotatedImage:image]];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state
{
    [super setThumbImage:[self rotatedImage:image] forState:state];
}

- (UIImage *)rotatedImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.height, image.size.width), NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(context, M_PI_2);
    [image drawAtPoint:CGPointMake(0.0, -image.size.height)];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL isTracking = [super beginTrackingWithTouch:touch withEvent:event];
    if ( isTracking && self.trackingBlock) {
        self.trackingBlock();
    }
    return isTracking;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    BOOL isContinueTracing = [super continueTrackingWithTouch:touch withEvent:event];
    if (self.trackingBlock && isContinueTracing) {
        self.trackingBlock();
    }
    return isContinueTracing;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.endTrackingBlock) {
        self.endTrackingBlock();
    }
}

@end
