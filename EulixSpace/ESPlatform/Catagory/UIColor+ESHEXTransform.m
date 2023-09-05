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
//  UIColor+ESHEXTransform.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UIColor+ESHEXTransform.h"

@implementation UIColor (ESHEXTransform)

+ (nullable instancetype)es_colorWithHexString:(NSString *)hex {
    return [self componentsWithHexExpression:hex];
}

+ (nullable instancetype)componentsWithHexExpression:(NSString *)expression {
    NSDictionary *patterns = @{ @"#[A-Fa-f0-9]{3}$" : NSStringFromSelector(@selector(componentsWithRGBString:)),
                                @"#[A-Fa-f0-9]{4}$" : NSStringFromSelector(@selector(componentsWithRGBAString:)),
                                @"#[A-Fa-f0-9]{6}$" : NSStringFromSelector(@selector(componentsWithRRGGBBString:)),
                                @"#[A-Fa-f0-9]{8}$" : NSStringFromSelector(@selector(componentsWithRRGGBBAAString:)) };
    for (NSString *pattern in patterns.allKeys) {
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
        NSRange range = [regular rangeOfFirstMatchInString:expression options:0 range:NSMakeRange(0, expression.length)];
        if (range.location != NSNotFound) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [self performSelector:NSSelectorFromString(patterns[pattern]) withObject:[expression substringFromIndex:1]];
#pragma clang diagnostic pop
        }
    }
    return nil;
}

+ (nullable instancetype)componentsWithRGBString:(NSString *)rgb {
    return [self componentsWithRGBAString:[rgb stringByAppendingString:@"F"]];
}

+ (nullable instancetype)componentsWithRGBAString:(NSString *)rgba {
    NSMutableString *aarrggbb = [NSMutableString string];
    for (NSUInteger i = 0; i < rgba.length; i++) {
        [aarrggbb appendFormat:@"%@", [rgba substringWithRange:NSMakeRange(i, 1)]];
        [aarrggbb appendFormat:@"%@", [rgba substringWithRange:NSMakeRange(i, 1)]];
    }
    return [self componentsWithRRGGBBAAString:[aarrggbb copy]];
}

+ (nullable instancetype)componentsWithRRGGBBString:(NSString *)rrggbb {
    return [self componentsWithRRGGBBAAString:[rrggbb stringByAppendingString:@"FF"]];
}

+ (nullable instancetype)componentsWithRRGGBBAAString:(NSString *)aarrggbb {
    return [self initWithAARRGGBBString:aarrggbb];
}

+ (nullable instancetype)initWithAARRGGBBString:(NSString *)aarrggbb {
    static NSInteger const numberOfColorComponents = 4;
    static CGFloat const divisor = 255.0;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[A-Fa-f0-9]{2}"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil];
    NSArray<NSTextCheckingResult *> *checkingResults = [regular matchesInString:aarrggbb options:0 range:NSMakeRange(0, aarrggbb.length)];
    NSParameterAssert(checkingResults.count == numberOfColorComponents);
    if (checkingResults.count != numberOfColorComponents) {
        return nil;
    }

    unsigned int colorComponents[numberOfColorComponents] = {0, 0, 0, 0};
    for (NSInteger i = 0; i < checkingResults.count; i++) {
        NSTextCheckingResult *checkingResult = checkingResults[i];
        [[NSScanner scannerWithString:[aarrggbb substringWithRange:checkingResult.range]] scanHexInt:&colorComponents[i]];
    }

    CGFloat red = colorComponents[0] / divisor;
    CGFloat green = colorComponents[1] / divisor;
    CGFloat blue = colorComponents[2] / divisor;
    CGFloat alpha = colorComponents[3] / divisor;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
