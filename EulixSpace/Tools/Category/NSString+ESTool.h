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
//  NSString+ESTool.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/13.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kESDefaultPadding = @"0";

static NSString *const kESDefaultSeparator = @"-";

@interface NSString (ESTool)

- (CGFloat)es_heightFitWidth:(CGFloat)width font:(UIFont *)font;

- (CGSize)es_sizeFitWidth:(CGFloat)width font:(UIFont *)font;

- (CGFloat)es_widthWithFont:(UIFont *)font;

- (NSMutableAttributedString *)match:(NSString *)key
                       highlightAttr:(NSDictionary *)hightlightAttr
                         defaultAttr:(NSDictionary *)defaultAttr;

- (NSArray *)resultForMatch:(NSString *)match;

- (NSMutableAttributedString *)es_toAttr:(NSDictionary *)attr;

//UUID
//https://ao.space/?btid=0a399348a545b2f9
//0a399348a545b2f9 => 0A399348-A545-B2F9-0000-000000000000
- (NSString *)uuidFrombtid;

- (void)matchRegex:(NSString *)regexString
         onCapture:(void (^)(NSRange range, NSString *capture))onCapture;

- (BOOL)ifMatchRegex:(NSString *)regexString;

- (NSInteger)justErrorCode;

- (NSString *)SHA256;

- (NSString *)md5;
- (NSString *)md5Uppercase;

- (BOOL)es_validateEmail;
- (BOOL)es_validateIPV4Format;

+ (NSString *)randomKeyWithLength:(NSUInteger)length;

- (NSString *)toHexString;

@end

@interface NSMutableAttributedString (ESSize)

- (CGSize)es_sizeForWidth:(CGFloat)width height:(CGFloat)height;

- (void)matchRegex:(NSString *)regexString
           replace:(NSString * (^)(NSRange range, NSString *capture))replace
     highlightAttr:(NSDictionary *)hightlightAttr;

- (void)matchRegex:(NSString *)regexString
           replace:(NSAttributedString * (^)(NSRange range, NSString *capture))replace;

- (void)matchString:(NSString *)pattern
            replace:(NSAttributedString * (^)(NSRange range, NSString *capture))replace;

- (void)matchPattern:(NSString *)pattern
       highlightAttr:(NSDictionary *)hightlightAttr;

- (void)matchPattern:(NSString *)pattern
               matchRang:(NSRange)matchRang
       highlightAttr:(NSDictionary *)hightlightAttr;
@end

@interface NSString (ESJson)

- (id)toJson;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString *)convertToJsonData:(NSDictionary *)dict;
@end

@interface NSObject (ESErrorCode)

- (NSInteger)justErrorCode;

@end
