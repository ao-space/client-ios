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
//  ESBoxIPModel.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxIPModel.h"
#import <YYModel/YYModel.h>
#import "ESBoxItem.h"

@implementation ESBoxIPResp

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"results" : [ESBoxIPModel class] };
}

- (void)resetCheckState {
    [self.results enumerateObjectsUsingBlock:^(ESBoxIPModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.ipChecked = NO;
        obj.ipConnected = NO;
    }];
}

- (BOOL)hasBoxIp {
    return self.results.count > 0;
}

- (ESBoxIPModel *)getConnectedBoxIP {
    __block ESBoxIPModel * result = nil;
    [self.results enumerateObjectsUsingBlock:^(ESBoxIPModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.ipConnected) {
            result = obj;
            * stop = YES;
        }
    }];
    return result;
}

- (NSString *)toString {
    NSMutableString * mStr = [[NSMutableString alloc] init];
    [self.results enumerateObjectsUsingBlock:^(ESBoxIPModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mStr appendString:[obj getIPDomain]];
        [mStr appendString:@"\n"];
    }];
    return mStr;
}

@end


@implementation ESBoxIPModel

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[
        @"ipConnected",
        @"ipChecked",
    ];
}

- (NSString *)getIPDomain {
    if (self.port > 0) {
        return [NSString stringWithFormat:@"http://%@:%ld", self.ip, self.port];
    }
    return  [NSString stringWithFormat:@"http://%@", self.ip];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        ESBoxIPModel *another = (ESBoxIPModel *)object;
        return [self.ip isEqualToString:another.ip] && self.port == another.port;
    }

    return NO;
}

@end
