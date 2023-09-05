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
//  NSArray+ESTool.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "NSArray+ESTool.h"

@implementation NSArray (ESTool)


+ (BOOL)isEmpty:(NSArray *)arr {
    if (arr != nil && arr.count > 0) {
        return NO;
    }
    return YES;
}

+ (BOOL)isNotEmpty:(NSArray *)arr {
    return ![[self class] isEmpty:arr];
}

- (id)getObject:(long)index {
    if (index < 0 || index >= self.count) {
        return nil;
    }
//    return [self objectAtIndex:index];
    return self[index];
}

@end
