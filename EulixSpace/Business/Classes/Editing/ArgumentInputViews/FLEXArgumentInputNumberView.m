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
//  FLEXArgumentInputNumberView.m
//  Flipboard
//
//  Created by Ryan Olson on 6/15/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXArgumentInputNumberView.h"
#import "FLEXRuntimeUtility.h"

@implementation FLEXArgumentInputNumberView

- (instancetype)initWithArgumentTypeEncoding:(const char *)typeEncoding {
    self = [super initWithArgumentTypeEncoding:typeEncoding];
    if (self) {
        self.inputTextView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.targetSize = FLEXArgumentInputViewSizeSmall;
    }
    
    return self;
}

- (void)setInputValue:(id)inputValue {
    if ([inputValue respondsToSelector:@selector(stringValue)]) {
        self.inputTextView.text = [inputValue stringValue];
    }
}

- (id)inputValue {
    return [FLEXRuntimeUtility valueForNumberWithObjCType:self.typeEncoding.UTF8String fromInputString:self.inputTextView.text];
}

+ (BOOL)supportsObjCType:(const char *)type withCurrentValue:(id)value {
    NSParameterAssert(type);
    
    static NSArray<NSString *> *supportedTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supportedTypes = @[
            @FLEXEncodeClass(NSNumber),
            @FLEXEncodeClass(NSDecimalNumber),
            @(@encode(char)),
            @(@encode(int)),
            @(@encode(short)),
            @(@encode(long)),
            @(@encode(long long)),
            @(@encode(unsigned char)),
            @(@encode(unsigned int)),
            @(@encode(unsigned short)),
            @(@encode(unsigned long)),
            @(@encode(unsigned long long)),
            @(@encode(float)),
            @(@encode(double)),
            @(@encode(long double))
        ];
    });
    
    return type && [supportedTypes containsObject:@(type)];
}

@end
