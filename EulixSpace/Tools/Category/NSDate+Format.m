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
//  NSDate+Format.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "NSDate+Format.h"

@interface SIDateFormatterTool : NSObject

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation SIDateFormatterTool

+ (instancetype)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _formatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

@end

@implementation NSDate (Format)

- (NSString *)stringFromFormat:(NSString *)format {
    NSDateFormatter *formatter = [SIDateFormatterTool sharedInstance].formatter;
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

@end

@implementation NSString (DateFormat)

- (NSDate *)dateFromFormat:(NSString *)format {
    NSDateFormatter *formatter = [SIDateFormatterTool sharedInstance].formatter;
    [formatter setDateFormat:format];
    return [formatter dateFromString:self];
}

@end
