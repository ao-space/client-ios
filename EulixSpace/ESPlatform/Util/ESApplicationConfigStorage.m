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
//  ESApplicationConfigStorage.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESApplicationConfigStorage.h"

static NSInteger const ESApplicationVersionSegmentsNumber = 3;

@implementation ESApplicationConfigStorage

+ (NSString *)applicationVersion {
    static NSString *v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSMutableArray *component = [NSMutableArray arrayWithArray:[v componentsSeparatedByString:@"."]];
        while (component.count < ESApplicationVersionSegmentsNumber) {
            [component addObject:@"0"];
        }
        while (component.count > ESApplicationVersionSegmentsNumber) {
            [component removeLastObject];
        }
        v = [component componentsJoinedByString:@"."];
    });
    
    return v;
}

+ (NSString *)applicationBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)applicationFullVersion {
    static NSString *fv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fv = [self applicationVersion];
        fv = [fv stringByAppendingFormat:@".%@", [self applicationBuildVersion]];
    });
    return fv;
}

- (NSString *)applicationBundleDisplayName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

@end
