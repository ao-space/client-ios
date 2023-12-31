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
//  ESBaseResp.m
//  EulixSpace
//
//  Created by dazhou on 2022/7/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseResp.h"

@implementation ESBaseResp


- (BOOL)isOK {
    return [self codeValue] == 200;
}

- (long)codeValue {
    NSArray * arr = [self.code componentsSeparatedByString:@"-"];
    NSString * sCode = [arr lastObject];
    if (sCode) {
        return sCode.integerValue;
    }
    return -1;
}




@end
