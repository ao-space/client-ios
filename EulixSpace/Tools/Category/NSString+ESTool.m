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
//  NSString+ESSize.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/13.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "NSString+ESTool.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ESTool)

- (CGFloat)es_heightFitWidth:(CGFloat)width font:(UIFont *)font {
    CGFloat height = [self es_sizeFitWidth:width font:font].height;
    return ceil(height);
}

- (CGSize)es_sizeFitWidth:(CGFloat)width font:(UIFont *)font {
    if (self.length == 0) {
        return CGSizeZero;
    }
    CGSize size = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingTruncatesLastVisibleLine |
                                             NSStringDrawingUsesLineFragmentOrigin |
                                             NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName: font}
                                     context:NULL]
                      .size;
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

- (CGFloat)es_widthWithFont:(UIFont *)font {
    return [self es_sizeFitWidth:CGFLOAT_MAX font:font].width;
}

- (NSMutableAttributedString *)match:(NSString *)key
                       highlightAttr:(NSDictionary *)hightlightAttr
                         defaultAttr:(NSDictionary *)defaultAttr {
    NSMutableAttributedString *matchContent = [[NSMutableAttributedString alloc] initWithString:self attributes:defaultAttr];
    if (key.length > 0) {
        NSRange range = NSMakeRange(0, 0);
        while (range.location != NSNotFound) {
            range = [self rangeOfString:key options:NSCaseInsensitiveSearch range:NSMakeRange(NSMaxRange(range), self.length - NSMaxRange(range))];
            if (range.location != NSNotFound) {
                [matchContent setAttributes:hightlightAttr range:range];
            }
        }
    }
    return matchContent;
}

- (NSArray *)resultForMatch:(NSString *)match {
    NSString *string = self;
    NSError *regexError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:match options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (results.count == 0) {
        return nil;
    }
    NSTextCheckingResult *result = results.firstObject;
    if (results.count == 0) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (int index = 1; index < result.numberOfRanges; index++) {
        NSRange range = [result rangeAtIndex:index];
        if (range.length == 0 || range.location > string.length || NSMaxRange(range) > string.length) {
            break;
        }
        NSString *capture = [string substringWithRange:range];
        if (capture) {
            [array addObject:capture];
        }
    }
    return array;
}

- (NSMutableAttributedString *)es_toAttr:(NSDictionary *)attr {
    return [[NSMutableAttributedString alloc] initWithString:self attributes:attr];
}

- (NSString *)defaultPadding:(NSInteger)length {
    if (length <= 0) {
        return @"";
    }
    NSMutableString *padding = [NSMutableString stringWithCapacity:length];
    for (NSInteger index = 0; index < length; index++) {
        [padding appendString:kESDefaultPadding];
    }
    return padding;
}

//UUID
//https://ao.space/?btid=0a399348a545b2f9
//0a399348a545b2f9 => 0A399348-A545-B2F9-0000-000000000000
- (NSString *)uuidFrombtid {
    NSString *btid = self;
    //8-4-4-4-12
    NSArray *numberArray = @[@(8), @(4), @(4), @(4), @(12)];
    __block NSInteger offset = 0;
    NSMutableString *uuid = [NSMutableString stringWithCapacity:32 + 4];
    [numberArray enumerateObjectsUsingBlock:^(NSNumber *_Nonnull obj,
                                              NSUInteger idx,
                                              BOOL *_Nonnull stop) {
        NSInteger length = obj.integerValue;
        ///btid不够用了,用默认填充
        if (offset > btid.length) {
            [uuid appendString:[self defaultPadding:length]];
        } else {
            NSInteger total = offset + length;
            ///当前够用, 直接去取字符串填充
            if (total <= btid.length) {
                NSString *sub = [btid substringWithRange:NSMakeRange(offset, length)];
                [uuid appendString:sub];
                offset = total;
            } else {
                ///部分够用
                ///取到最后一个
                NSString *sub = [btid substringFromIndex:offset];
                [uuid appendString:sub];
                offset = total;
                [uuid appendString:[self defaultPadding:total - btid.length]];
            }
        }
        if (idx != numberArray.count - 1) {
            [uuid appendString:kESDefaultSeparator];
        }
    }];
    return uuid.uppercaseString;
}

- (void)matchRegex:(NSString *)regexString
         onCapture:(void (^)(NSRange range, NSString *capture))onCapture {
    NSError *regexError;
    NSString *string = self;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (results.count == 0) {
        return;
    }
    for (NSTextCheckingResult *result in results.reverseObjectEnumerator) {
        NSInteger numberOfRanges = result.numberOfRanges;
        for (NSUInteger idx = numberOfRanges - 1; idx >= 1; --idx) {
            NSRange range = [result rangeAtIndex:idx];
            if (range.length == 0) {
                continue;
            }
            NSString *capture = [self substringWithRange:range];
            if (onCapture) {
                onCapture(range, capture);
            }
        }
    }
}

- (BOOL)ifMatchRegex:(NSString *)regexString {
    NSError *regexError;
    NSString *string = self;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    return results.count > 0;
}

- (NSInteger)justErrorCode {
    return [self componentsSeparatedByString:@"-"].lastObject.integerValue;
}

- (NSString *)SHA256 {
    const char *s = [self cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];

    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *SHA256Data = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSMutableString *hex = [NSMutableString new];
    const unsigned char *bytes = (const unsigned char *)SHA256Data.bytes;
    for (NSInteger i = 0; i < SHA256Data.length; i++) {
        [hex appendFormat:@"%02x", bytes[i]];
    }
    return [hex copy];
}

- (NSString *)md5 {
    const char *s = [self cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];

    uint8_t digest[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *md5Data = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    NSMutableString *hex = [NSMutableString new];
    const unsigned char *bytes = (const unsigned char *)md5Data.bytes;
    for (NSInteger i = 0; i < md5Data.length; i++) {
        [hex appendFormat:@"%02x", bytes[i]];
    }
    return [hex copy];
}

- (NSString *)md5Uppercase {
    if(self.length < 1){
        return @"";
    }
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (BOOL)es_validateEmail {
//    NSString * regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString * regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z0-9]+";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)es_validateIPV4Format {
    NSString * regex = @"^(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3}$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

+ (NSString *)randomKeyWithLength:(NSUInteger)length {
    //30(48)-39(57) -> 10  60(97)-7a(122) -> 26 == 36
    NSUInteger count = length;
    NSMutableString *result = [NSMutableString stringWithCapacity:count];
    for (NSUInteger index = 0; index < count; index++) {
        NSInteger random = arc4random() % 36;
        if (random <= 9) {
            [result appendFormat:@"%c", (unichar)(random + 48)];
        } else {
            [result appendFormat:@"%c", (unichar)(random + 97 - 10)];
        }
    }
    return result;
}


- (NSString *)toHexString {
    NSData * myD = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    NSString * hexStr = @"";
    for(int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
        if ([newHexStr length] == 1) {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}
@end

@implementation NSMutableAttributedString (ESSize)

- (CGSize)es_sizeForWidth:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeZero;
    NSMutableAttributedString *atrString = self.mutableCopy;
    NSRange range = NSMakeRange(0, atrString.length);
    //获取指定位置上的属性信息，并返回与指定位置属性相同并且连续的字符串的范围信息。
    NSDictionary *dic = [atrString attributesAtIndex:0 effectiveRange:&range];
    //不存在段落属性，则存入默认值
    NSMutableParagraphStyle *paragraphStyle = dic[NSParagraphStyleAttributeName];
    if (!paragraphStyle) {
        paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineSpacing = 0.0;               //增加行高
        paragraphStyle.headIndent = 0;                  //头部缩进，相当于左padding
        paragraphStyle.tailIndent = 0;                  //相当于右padding
        paragraphStyle.lineHeightMultiple = 0;          //行间距是多少倍
        paragraphStyle.alignment = NSTextAlignmentLeft; //对齐方式
        paragraphStyle.firstLineHeadIndent = 0;         //首行头缩进
        paragraphStyle.paragraphSpacing = 0;            //段落后面的间距
        paragraphStyle.paragraphSpacingBefore = 0;      //段落之前的间距
        [atrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }

    CGSize strSize = [atrString boundingRectWithSize:CGSizeMake(width, height)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             context:nil]
                         .size;

    size = CGSizeMake(ceilf(strSize.width), ceilf(strSize.height));
    return size;
}

- (void)matchRegex:(NSString *)regexString
           replace:(NSString * (^)(NSRange range, NSString *capture))replace
     highlightAttr:(NSDictionary *)hightlightAttr {
    [self matchRegex:regexString
             replace:^NSAttributedString *(NSRange range, NSString *capture) {
                 NSString *replacement = capture;
                 if (replace) {
                     replacement = replace(range, capture);
                 }
                 if (replacement) {
                     NSAttributedString *replacementAttributedString = [[NSAttributedString alloc] initWithString:replacement attributes:hightlightAttr];
                     return replacementAttributedString;
                 }
                 return nil;
             }];
}

- (void)matchRegex:(NSString *)regexString
           replace:(NSAttributedString * (^)(NSRange range, NSString *capture))replace {
    NSError *regexError;
    NSString *string = self.string;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableAttributedString *one = self;
    if (results.count == 0) {
        return;
    }
    for (NSTextCheckingResult *result in results.reverseObjectEnumerator) {
        NSInteger numberOfRanges = result.numberOfRanges;
        for (NSUInteger idx = numberOfRanges - 1; idx >= 1; --idx) {
            NSRange range = [result rangeAtIndex:idx];
            if (range.length == 0) {
                continue;
            }
            NSAttributedString *capture = [one attributedSubstringFromRange:range];
            NSAttributedString *replacement = capture;
            if (replace) {
                replacement = replace(range, capture.string) ?: replacement;
            }
            if (replacement) {
                [one replaceCharactersInRange:range withAttributedString:replacement];
            }
        }
    }
}

- (void)matchString:(NSString *)pattern
            replace:(NSAttributedString * (^)(NSRange range, NSString *capture))replace {
    NSString *string = self.string;
    NSMutableAttributedString *one = self;
    NSRange range = [string rangeOfString:pattern options:NSLiteralSearch range:NSMakeRange(0, string.length)];
    while (range.location != NSNotFound) {
        NSAttributedString *capture = [one attributedSubstringFromRange:range];
        NSAttributedString *replacement = capture;
        if (replace) {
            replacement = replace(range, capture.string) ?: replacement;
        }
        if (replacement) {
            [self replaceCharactersInRange:range withAttributedString:replacement];
        }
        NSInteger postion = range.location + range.length;
        if (postion < string.length) {
            range = [string rangeOfString:pattern options:NSLiteralSearch range:NSMakeRange(postion, string.length - postion)];
        } else {
            break;
        }
    }
}

- (void)matchPattern:(NSString *)pattern
       highlightAttr:(NSDictionary *)hightlightAttr {
    NSString *string = self.string;
    NSMutableAttributedString *one = self;
    NSRange range = [string rangeOfString:pattern options:NSLiteralSearch range:NSMakeRange(0, string.length)];
    while (range.location != NSNotFound) {
        [one setAttributes:hightlightAttr range:range];
        NSInteger postion = range.location + range.length;
        if (postion < string.length) {
            range = [string rangeOfString:pattern options:NSLiteralSearch range:NSMakeRange(postion, string.length - postion)];
        } else {
            break;
        }
    }
}

- (void)matchPattern:(NSString *)pattern
               matchRang:(NSRange)matchRang
       highlightAttr:(NSDictionary *)hightlightAttr {
    NSString *string = self.string;
    NSMutableAttributedString *one = self;
    NSRange range = [string rangeOfString:pattern options:NSLiteralSearch range:matchRang];
    while (range.location != NSNotFound) {
        [one setAttributes:hightlightAttr range:range];
        NSInteger postion = range.location + range.length;
        if (postion < string.length) {
            range = [string rangeOfString:pattern options:NSLiteralSearch range:NSMakeRange(postion, string.length - postion)];
        } else {
            break;
        }
    }
}

@end

@implementation NSString (ESJson)

- (id)toJson {
    if (self.length == 0) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error) {
        return nil;
    }
    return object;
}

// 16进制转NSData
+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }

    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];

        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict

{
    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@", error);

    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0, jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0, mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"json解析失败：%@", err);
        return nil;
    }
    return dic;
}

@end

@implementation NSObject (ESErrorCode)

- (NSInteger)justErrorCode {
    if ([self isKindOfClass:[NSString class]]) {
        return [(NSString *)self componentsSeparatedByString:@"-"].lastObject.integerValue;
    }
    if ([self isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)self integerValue];
    }
    return NSNotFound;
}

@end
