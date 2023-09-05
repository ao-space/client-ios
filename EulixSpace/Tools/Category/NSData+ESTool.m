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
//  NSData+ESTool.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/11.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "NSData+ESTool.h"

@implementation NSData (ESTool)

- (uint8_t)uint8FromBytes {
    NSAssert(self.length == 1, @"uint8FromBytes: (data length != 1)");
    NSData *data = self;
    uint8_t val = 0;
    [data getBytes:&val length:1];
    return val;
}

/// 0x12 34 56 78
/// 1)大端模式：
/// 低地址 -----------------> 高地址
/// 0x12  |  0x34  |  0x56  |  0x78
/// 2)小端模式：
/// 低地址 ------------------> 高地址
/// 0x78  |  0x56  |  0x34  |  0x12

- (uint16_t)uint16FromBytes {
    NSAssert(self.length == 2, @"uint16FromBytes: (data length != 2)");
    NSData *data = self;
    uint16_t val0 = 0;
    uint16_t val1 = 0;
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];

    uint16_t dstVal = ((val0 << 8) & 0xff00) + (val1 & 0xff);
    return dstVal;
}

+ (NSData *)byteFromUInt8:(uint8_t)val {
    NSMutableData *valData = [[NSMutableData alloc] init];
    unsigned char valChar[1];
    valChar[0] = 0xff & val;
    [valData appendBytes:valChar length:1];
    return valData;
}

/// 0x12 34 56 78
/// 1)大端模式：
/// 低地址 -----------------> 高地址
/// 0x12  |  0x34  |  0x56  |  0x78
/// 2)小端模式：
/// 低地址 ------------------> 高地址
/// 0x78  |  0x56  |  0x34  |  0x12
/// @param val 2个字节的数字
+ (NSData *)bytesFromUInt16:(uint16_t)val {
    NSMutableData *valData = [[NSMutableData alloc] init];

    unsigned char valChar[2];
    //高位在前面
    valChar[0] = (0xff00 & val) >> 8;
    valChar[1] = 0xff & val;
    [valData appendBytes:valChar length:2];
    return valData;
}

- (NSData *)dataWithReverse {
    NSData *srcData = self;
    NSUInteger byteCount = srcData.length;
    NSMutableData *dstData = [[NSMutableData alloc] initWithData:srcData];
    NSUInteger halfLength = byteCount / 2;
    for (NSUInteger i = 0; i < halfLength; i++) {
        NSRange begin = NSMakeRange(i, 1);
        NSRange end = NSMakeRange(byteCount - i - 1, 1);
        NSData *beginData = [srcData subdataWithRange:begin];
        NSData *endData = [srcData subdataWithRange:end];
        [dstData replaceBytesInRange:begin withBytes:endData.bytes];
        [dstData replaceBytesInRange:end withBytes:beginData.bytes];
    } //for

    return dstData;
}

@end

extern BOOL IsBigEndian(void) {
    int a = 0x1234;
    char b = *(char *)&a; //通过将int强制类型转换成char单字节，通过判断起始存储位置。即等于 取b等于a的低地址部分
    if (b == 0x12) {
        return YES;
    }
    return NO;
}
