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
//  NSData+ESTool.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/11.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL IsBigEndian(void);

@interface NSData (ESTool)

- (uint8_t)uint8FromBytes;

- (uint16_t)uint16FromBytes;

+ (NSData *)byteFromUInt8:(uint8_t)val;

+ (NSData *)bytesFromUInt16:(uint16_t)val;

- (NSData *)dataWithReverse;

@end
