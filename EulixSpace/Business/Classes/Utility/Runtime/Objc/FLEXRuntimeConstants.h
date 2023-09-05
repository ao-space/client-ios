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
//  FLEXRuntimeConstants.h
//  FLEX
//
//  Created by Tanner on 3/11/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define FLEXEncodeClass(class) ("@\"" #class "\"")
#define FLEXEncodeObject(obj) (obj ? [NSString stringWithFormat:@"@\"%@\"", [obj class]].UTF8String : @encode(id))

// Arguments 0 and 1 are self and _cmd always
extern const unsigned int kFLEXNumberOfImplicitArgs;

// See https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
extern NSString *const kFLEXPropertyAttributeKeyTypeEncoding;
extern NSString *const kFLEXPropertyAttributeKeyBackingIvarName;
extern NSString *const kFLEXPropertyAttributeKeyReadOnly;
extern NSString *const kFLEXPropertyAttributeKeyCopy;
extern NSString *const kFLEXPropertyAttributeKeyRetain;
extern NSString *const kFLEXPropertyAttributeKeyNonAtomic;
extern NSString *const kFLEXPropertyAttributeKeyCustomGetter;
extern NSString *const kFLEXPropertyAttributeKeyCustomSetter;
extern NSString *const kFLEXPropertyAttributeKeyDynamic;
extern NSString *const kFLEXPropertyAttributeKeyWeak;
extern NSString *const kFLEXPropertyAttributeKeyGarbageCollectable;
extern NSString *const kFLEXPropertyAttributeKeyOldStyleTypeEncoding;

typedef NS_ENUM(NSUInteger, FLEXPropertyAttribute) {
    FLEXPropertyAttributeTypeEncoding       = 'T',
    FLEXPropertyAttributeBackingIvarName    = 'V',
    FLEXPropertyAttributeCopy               = 'C',
    FLEXPropertyAttributeCustomGetter       = 'G',
    FLEXPropertyAttributeCustomSetter       = 'S',
    FLEXPropertyAttributeDynamic            = 'D',
    FLEXPropertyAttributeGarbageCollectible = 'P',
    FLEXPropertyAttributeNonAtomic          = 'N',
    FLEXPropertyAttributeOldTypeEncoding    = 't',
    FLEXPropertyAttributeReadOnly           = 'R',
    FLEXPropertyAttributeRetain             = '&',
    FLEXPropertyAttributeWeak               = 'W'
}; //NS_SWIFT_NAME(FLEX.PropertyAttribute);

typedef NS_ENUM(char, FLEXTypeEncoding) {
    FLEXTypeEncodingNull             = '\0',
    FLEXTypeEncodingUnknown          = '?',
    FLEXTypeEncodingChar             = 'c',
    FLEXTypeEncodingInt              = 'i',
    FLEXTypeEncodingShort            = 's',
    FLEXTypeEncodingLong             = 'l',
    FLEXTypeEncodingLongLong         = 'q',
    FLEXTypeEncodingUnsignedChar     = 'C',
    FLEXTypeEncodingUnsignedInt      = 'I',
    FLEXTypeEncodingUnsignedShort    = 'S',
    FLEXTypeEncodingUnsignedLong     = 'L',
    FLEXTypeEncodingUnsignedLongLong = 'Q',
    FLEXTypeEncodingFloat            = 'f',
    FLEXTypeEncodingDouble           = 'd',
    FLEXTypeEncodingLongDouble       = 'D',
    FLEXTypeEncodingCBool            = 'B',
    FLEXTypeEncodingVoid             = 'v',
    FLEXTypeEncodingCString          = '*',
    FLEXTypeEncodingObjcObject       = '@',
    FLEXTypeEncodingObjcClass        = '#',
    FLEXTypeEncodingSelector         = ':',
    FLEXTypeEncodingArrayBegin       = '[',
    FLEXTypeEncodingArrayEnd         = ']',
    FLEXTypeEncodingStructBegin      = '{',
    FLEXTypeEncodingStructEnd        = '}',
    FLEXTypeEncodingUnionBegin       = '(',
    FLEXTypeEncodingUnionEnd         = ')',
    FLEXTypeEncodingQuote            = '\"',
    FLEXTypeEncodingBitField         = 'b',
    FLEXTypeEncodingPointer          = '^',
    FLEXTypeEncodingConst            = 'r'
}; //NS_SWIFT_NAME(FLEX.TypeEncoding);
