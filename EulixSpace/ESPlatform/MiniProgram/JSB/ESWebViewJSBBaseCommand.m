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
//  ESWebViewJSBBaseCommand.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESWebViewJSBBaseCommand.h"

@implementation ESWebViewJSBContext

@end

@implementation ESWebViewJSBBaseCommand

- (instancetype)init {
    if (self = [super init]) {
        _context = [[ESWebViewJSBContext alloc] init];
    }
    return self;
}

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"";
}

- (BOOL)checkResponseData:(id)data callback:(ESJBResponseCallback _Nullable) responseCallback {
    if (![data isKindOfClass:[NSDictionary class]]) {
        responseCallback(@{ @"code" : @(-1),
                            @"data" : @{},
                            @"msg" : @"参数错误"
                         });
        return NO;
    }
    
    NSDictionary *params = (NSDictionary *)data;
    NSArray *needCheckParams = [self needCheckParams];
    __block BOOL checkOK = YES;
    [needCheckParams enumerateObjectsUsingBlock:^(NSString * param, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![params.allKeys containsObject:param]) {
            checkOK = NO;
            *stop = YES;
        }
    }];
    
    if (!checkOK) {
        responseCallback(@{ @"code" : @(-1),
                            @"data" : @{},
                            @"msg" : @"参数错误"
                         });
        return NO;
    }
    
    return YES;
    
}


- (NSArray<NSString *> *)needCheckParams {
    return @[];
}

@end
