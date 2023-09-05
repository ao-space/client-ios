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
//  FLEXRuntime+Compare.m
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXRuntime+Compare.h"

@implementation FLEXProperty (Compare)

- (NSComparisonResult)compare:(FLEXProperty *)other {
    NSComparisonResult r = [self.name caseInsensitiveCompare:other.name];
    if (r == NSOrderedSame) {
        // TODO make sure empty image name sorts above an image name
        return [self.imageName ?: @"" compare:other.imageName];
    }

    return r;
}

@end

@implementation FLEXIvar (Compare)

- (NSComparisonResult)compare:(FLEXIvar *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end

@implementation FLEXMethodBase (Compare)

- (NSComparisonResult)compare:(FLEXMethodBase *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end

@implementation FLEXProtocol (Compare)

- (NSComparisonResult)compare:(FLEXProtocol *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end
