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
//  ESGradientUtil.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESGradientUtil.h"

@implementation ESGradientUtil

+ (UIImage *)gradientImageWithCGColors:(NSArray *)cgColors rect:(CGRect)rect {

    CAGradientLayer *gradientLayer = [self gradientLayerWithCGColors:cgColors rect:rect];
    if (!gradientLayer) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, gradientLayer.opaque, 0);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (CAGradientLayer *)gradientLayerWithCGColors:(NSArray <UIColor *> *)cgColors rect:(CGRect)rect {
    if (cgColors.count == 0 || CGRectEqualToRect(rect, CGRectZero)) {
        return nil;
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = rect;
    gradientLayer.colors = cgColors.copy;
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0,@1];
    return gradientLayer;
}

@end
