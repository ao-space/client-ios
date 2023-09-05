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
//  NSError+ESTool.m
//  EulixSpace
//
//  Created by dazhou on 2022/7/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "NSError+ESTool.h"

@implementation NSError (ESTool)

- (NSString *)errorDescription {
    return  [self.userInfo objectForKey:NSLocalizedDescriptionKey];
}

- (long)errorCode {
    NSString * codeStr = [self.userInfo objectForKey:@"code"];
    if (!codeStr) {
        return -1;
    }
    NSArray * list = [codeStr componentsSeparatedByString:@"-"];
    NSString * code = [list lastObject];
    if (!code) {
        return -1;
    }
    
    return code.integerValue;
}

- (NSString *)codeString {
    NSString * codeStr = [self.userInfo objectForKey:@"code"];
    return codeStr;
}

- (NSString *)errorMessage {
    NSString * result = [self.userInfo objectForKey:@"message"];
    if (result) {
        return result;
    }
    
    return [self errorDescription];
}

@end
