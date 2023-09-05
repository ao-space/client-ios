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
//  FLEXRuntimeSafety.m
//  FLEX
//
//  Created by Tanner on 3/25/17.
//

#import "FLEXRuntimeSafety.h"

NSUInteger const kFLEXKnownUnsafeClassCount = 19;
Class * _UnsafeClasses = NULL;
CFSetRef FLEXKnownUnsafeClasses = nil;
CFSetRef FLEXKnownUnsafeIvars = nil;

#define FLEXClassPointerOrCFNull(name) \
    (NSClassFromString(name) ?: (__bridge id)kCFNull)

#define FLEXIvarOrCFNull(cls, name) \
    (class_getInstanceVariable([cls class], name) ?: (void *)kCFNull)

__attribute__((constructor))
static void FLEXRuntimeSafteyInit() {
    FLEXKnownUnsafeClasses = CFSetCreate(
        kCFAllocatorDefault,
        (const void **)(uintptr_t)FLEXKnownUnsafeClassList(),
        kFLEXKnownUnsafeClassCount,
        nil
    );

    Ivar unsafeIvars[] = {
        FLEXIvarOrCFNull(NSURL, "_urlString"),
        FLEXIvarOrCFNull(NSURL, "_baseURL"),
    };
    FLEXKnownUnsafeIvars = CFSetCreate(
        kCFAllocatorDefault,
        (const void **)unsafeIvars,
        sizeof(unsafeIvars),
        nil
    );
}

const Class * FLEXKnownUnsafeClassList() {
    if (!_UnsafeClasses) {
        const Class ignored[] = {
            FLEXClassPointerOrCFNull(@"__ARCLite__"),
            FLEXClassPointerOrCFNull(@"__NSCFCalendar"),
            FLEXClassPointerOrCFNull(@"__NSCFTimer"),
            FLEXClassPointerOrCFNull(@"NSCFTimer"),
            FLEXClassPointerOrCFNull(@"__NSGenericDeallocHandler"),
            FLEXClassPointerOrCFNull(@"NSAutoreleasePool"),
            FLEXClassPointerOrCFNull(@"NSPlaceholderNumber"),
            FLEXClassPointerOrCFNull(@"NSPlaceholderString"),
            FLEXClassPointerOrCFNull(@"NSPlaceholderValue"),
            FLEXClassPointerOrCFNull(@"Object"),
            FLEXClassPointerOrCFNull(@"VMUArchitecture"),
            FLEXClassPointerOrCFNull(@"JSExport"),
            FLEXClassPointerOrCFNull(@"__NSAtom"),
            FLEXClassPointerOrCFNull(@"_NSZombie_"),
            FLEXClassPointerOrCFNull(@"_CNZombie_"),
            FLEXClassPointerOrCFNull(@"__NSMessage"),
            FLEXClassPointerOrCFNull(@"__NSMessageBuilder"),
            FLEXClassPointerOrCFNull(@"FigIrisAutoTrimmerMotionSampleExport"),
            // Temporary until we have our own type encoding parser;
            // setVectors: has an invalid type encoding and crashes NSMethodSignature
            FLEXClassPointerOrCFNull(@"_UIPointVector"),
        };
        
        assert((sizeof(ignored) / sizeof(Class)) == kFLEXKnownUnsafeClassCount);

        _UnsafeClasses = (Class *)malloc(sizeof(ignored));
        memcpy(_UnsafeClasses, ignored, sizeof(ignored));
    }

    return _UnsafeClasses;
}

NSSet * FLEXKnownUnsafeClassNames() {
    static NSSet *set = nil;
    if (!set) {
        NSArray *ignored = @[
            @"__ARCLite__",
            @"__NSCFCalendar",
            @"__NSCFTimer",
            @"NSCFTimer",
            @"__NSGenericDeallocHandler",
            @"NSAutoreleasePool",
            @"NSPlaceholderNumber",
            @"NSPlaceholderString",
            @"NSPlaceholderValue",
            @"Object",
            @"VMUArchitecture",
            @"JSExport",
            @"__NSAtom",
            @"_NSZombie_",
            @"_CNZombie_",
            @"__NSMessage",
            @"__NSMessageBuilder",
            @"FigIrisAutoTrimmerMotionSampleExport",
            @"_UIPointVector",
        ];

        set = [NSSet setWithArray:ignored];
        assert(set.count == kFLEXKnownUnsafeClassCount);
    }

    return set;
}
