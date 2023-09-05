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
//  UIFont+FLEX.m
//  FLEX
//
//  Created by Tanner Bennett on 12/20/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "UIFont+FLEX.h"

#define kFLEXDefaultCellFontSize 12.0

@implementation UIFont (FLEX)

+ (UIFont *)flex_defaultTableCellFont {
    static UIFont *defaultTableCellFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultTableCellFont = [UIFont systemFontOfSize:kFLEXDefaultCellFontSize];
    });

    return defaultTableCellFont;
}

+ (UIFont *)flex_codeFont {
    // Actually only available in iOS 13, the SDK headers are wrong
    if (@available(iOS 13, *)) {
        return [self monospacedSystemFontOfSize:kFLEXDefaultCellFontSize weight:UIFontWeightRegular];
    } else {
        return [self fontWithName:@"Menlo-Regular" size:kFLEXDefaultCellFontSize];
    }
}

+ (UIFont *)flex_smallCodeFont {
        // Actually only available in iOS 13, the SDK headers are wrong
    if (@available(iOS 13, *)) {
        return [self monospacedSystemFontOfSize:self.smallSystemFontSize weight:UIFontWeightRegular];
    } else {
        return [self fontWithName:@"Menlo-Regular" size:self.smallSystemFontSize];
    }
}

@end
