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
//  ESLanguageManager.m
//  EulixSpace
//
//  Created by qu on 2023/1/2.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//
#import "ESLanguageManager.h"


static NSString *ESUserLanguageKey = @"UserLanguageKey";


@implementation ESLanguageManager

+ (void)setUserLanguage:(NSString *)userLanguage {
    //跟随手机系统
    if (!userLanguage.length) {
        [self resetSystemLanguage];
        return;
    }
    //用户自定义
    [[NSUserDefaults standardUserDefaults] setValue:userLanguage forKey:ESUserLanguageKey];
    [[NSUserDefaults standardUserDefaults] setValue:@[userLanguage] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userLanguage {
    return [[NSUserDefaults standardUserDefaults] valueForKey:ESUserLanguageKey];
}

/**
 重置系统语言
 */
+ (void)resetSystemLanguage {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ESUserLanguageKey];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)systemLanguage{
    
    NSNumber *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"language_setting"];
    if (language.intValue == ESLanguageType_System) {
        [ESLanguageManager setUserLanguage:nil];
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSArray  *array = [language componentsSeparatedByString:@"-"];
        NSString *currentLanguage = array[0];
        if (currentLanguage) {
            if( [currentLanguage isEqualToString:@"en"]){
                [ESLanguageManager setUserLanguage:@"en"];
            }else{
                [ESLanguageManager setUserLanguage:@"zh-Hans"];
            }
        }
    }
}
@end
