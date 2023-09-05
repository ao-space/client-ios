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
//  ESCommentCreateFolder.m
//  EulixSpace
//
//  Created by qu on 2021/9/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCommentCreateFolder.h"

@implementation ESCommentCreateFolder

- (NSString *)checkCreateFolder:(NSString *)name {
    if (name.length > 10) {
        return NSLocalizedString(@"The file name is too long and cannot exceed 10 characters", @"文件名过长，不得超过10个字符");
    }
    if (name.length < 1) {
        return NSLocalizedString(@"Please enter a folder name", @"请设置文件夹名称");
    }
    if ([self stringContainsEmoji:name]) {
        return NSLocalizedString(@"Only Chinese and English, numbers and underscores are supported", @"仅支持中英文、数字和下划线");
    }

    if ([self judgeTheillegalCharacter:name]) {
        return NSLocalizedString(@"Only Chinese and English, numbers and underscores are supported", @"仅支持中英文、数字和下划线");
    }
    return @"";
}

- (NSString *)checkReNameFolder:(NSString *)name {
    if (name.length < 1) {
        return @"请设置名称";
    }
    if ([self stringContainsEmoji:name]) {
        return NSLocalizedString(@"Only Chinese and English, numbers and underscores are supported", @"仅支持中英文、数字和下划线");
    }

    if ([self judgeTheillegalCharacter:name]) {
        return NSLocalizedString(@"Only Chinese and English, numbers and underscores are supported", @"仅支持中英文、数字和下划线");
    }
    return @"";
}

- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

- (BOOL)judgeTheillegalCharacter:(NSString *)content {
    //提示 标签不能输入特殊字符

    NSString *str = @"^[a-zA-Z0-9\\_\u4e00-\u9fa5]+$";

    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];

    if ([emailTest evaluateWithObject:content]) {
        return NO;
    }

    return YES;
}
@end
