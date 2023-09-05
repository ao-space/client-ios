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
//  NSObject+ESAOP.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/5.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "NSObject+ESAOP.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation NSObject (ESAOP)

+ (void)es_swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL {
    [self es_swizzleClass:NSStringFromClass([self class]) originalSEL:originalSEL withSEL:swizzledSEL];
}

+ (void)es_swizzleClass:(NSString *)className originalSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL {
    Class class = NSClassFromString(className);
    if (!class || !originalSEL || !swizzledSEL) {
        return;
    }
    Method originalMethod = class_getInstanceMethod(class, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);

    BOOL didAddMethod =
        class_addMethod(class,
                        originalSEL,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

@interface UINavigationController (ESAOP)

@end

@implementation UINavigationController (ESAOP)

+ (void)load {
    [self es_swizzleSEL:@selector(setNavigationBarHidden:) withSEL:@selector(es_setNavigationBarHidden:)];
}

- (void)es_setNavigationBarHidden:(BOOL)navigationBarHidden {
    [self es_setNavigationBarHidden:navigationBarHidden];
}

@end
