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
//  ESGlobalMacro.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/7.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESGlobalMacro_h
#define ESGlobalMacro_h

#pragma mark - weakfy & strongfy

#ifndef weakfy
#define weakfy(object) __weak __typeof__(object) weak##_##object = object;
#endif
#ifndef strongfy
#define strongfy(object) __typeof__(object) object = weak##_##object;
#endif

#pragma mark - debug log

#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const unsigned long ddLogLevel = DDLogLevelAll;
#else
static const unsigned long ddLogLevel = DDLogLevelInfo;
#endif

#ifdef DEBUG
#define ESDLog(fmt, ...) DDLogDebug_2(@"< %@:(%d) > %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(fmt), ##__VA_ARGS__])
#else
#define ESDLog(...)
#endif

#define LOG_MAYBE_2(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define DDLogDebug_2(frmt, ...)   LOG_MAYBE_2(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#pragma mark - Screen

#import <UIKit/UIKit.h>

static inline BOOL IS_IPHONE_X() {
    return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||

            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)) ||

            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(844, 390)) ||
            
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(430, 932)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(932, 430)) ||
            
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(393, 852)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(852, 393)) ||
            
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(844, 390)) ||

            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(926, 428)));
}

//定义屏幕的宽-高
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

#define kBottomHeight (IS_IPHONE_X() ? 34 : 0)

#endif /* ESGlobalMacro_h */
