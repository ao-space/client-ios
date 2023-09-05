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
//  NSString+ObjcRuntime.m
//  FLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/1/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "NSString+ObjcRuntime.h"
#import "FLEXRuntimeUtility.h"

@implementation NSString (Utilities)

- (NSString *)stringbyDeletingCharacterAtIndex:(NSUInteger)idx {
    NSMutableString *string = self.mutableCopy;
    [string replaceCharactersInRange:NSMakeRange(idx, 1) withString:@""];
    return string;
}

/// See this link on how to construct a proper attributes string:
/// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
- (NSDictionary *)propertyAttributes {
    if (!self.length) return nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSArray *components = [self componentsSeparatedByString:@","];
    for (NSString *attribute in components) {
        FLEXPropertyAttribute c = (FLEXPropertyAttribute)[attribute characterAtIndex:0];
        switch (c) {
            case FLEXPropertyAttributeTypeEncoding:
                // Note: the type encoding here is not always correct. Radar: FB7499230
                attributes[kFLEXPropertyAttributeKeyTypeEncoding] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case FLEXPropertyAttributeBackingIvarName:
                attributes[kFLEXPropertyAttributeKeyBackingIvarName] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case FLEXPropertyAttributeCopy:
                attributes[kFLEXPropertyAttributeKeyCopy] = @YES;
                break;
            case FLEXPropertyAttributeCustomGetter:
                attributes[kFLEXPropertyAttributeKeyCustomGetter] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case FLEXPropertyAttributeCustomSetter:
                attributes[kFLEXPropertyAttributeKeyCustomSetter] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case FLEXPropertyAttributeDynamic:
                attributes[kFLEXPropertyAttributeKeyDynamic] = @YES;
                break;
            case FLEXPropertyAttributeGarbageCollectible:
                attributes[kFLEXPropertyAttributeKeyGarbageCollectable] = @YES;
                break;
            case FLEXPropertyAttributeNonAtomic:
                attributes[kFLEXPropertyAttributeKeyNonAtomic] = @YES;
                break;
            case FLEXPropertyAttributeOldTypeEncoding:
                attributes[kFLEXPropertyAttributeKeyOldStyleTypeEncoding] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case FLEXPropertyAttributeReadOnly:
                attributes[kFLEXPropertyAttributeKeyReadOnly] = @YES;
                break;
            case FLEXPropertyAttributeRetain:
                attributes[kFLEXPropertyAttributeKeyRetain] = @YES;
                break;
            case FLEXPropertyAttributeWeak:
                attributes[kFLEXPropertyAttributeKeyWeak] = @YES;
                break;
        }
    }

    return attributes;
}

@end
