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
//  ESTokenItem.m
//  ESTokenItem
//
//  Created by Ye Tao on 2021/8/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTokenItem.h"
#import "ESAES.h"
#import "ESRSACenter.h"
#import "ESThemeDefine.h"
#import <ISO8601/ISO8601.h>
#import <YYModel/YYModel.h>

@interface ESTokenItem ()

@property (nonatomic, copy) NSString *accessToken;

@property (nonatomic, copy) NSString *refreshToken;

@property (nonatomic, copy) NSString *secretKey;

@property (nonatomic, copy) NSString *secretIV;

@property (nonatomic, copy) NSString *expiresAt;

@property (nonatomic, copy) NSString *domain;

+ (instancetype)tokenFrom:(ESCreateTokenResult *)output;

@end

@implementation ESTokenItem

- (NSString *)secretIV {
    if (_secretIV.length == 0) {
        NSMutableString *ivString = NSMutableString.string;
        for (NSUInteger index = 0; index < self.secretKey.length; index++) {
            [ivString appendFormat:@"%C", 0];
        }
        _secretIV = ivString;
    }
    return _secretIV;
}

+ (instancetype)tokenFrom:(ESCreateTokenResult *)output {
    return [self tokenFrom:output tmpAesKey:nil];
}

+ (instancetype)tokenFrom:(ESCreateTokenResult *)output tmpAesKey:(NSString *)tmpAesKey {
    if (!output) {
        return nil;
    }
    ESTokenItem *item = [ESTokenItem new];
    NSString *secretKey;
    if (tmpAesKey) {
        secretKey = [output.encryptedSecret aes_cbc_decryptWithKey:tmpAesKey iv:output.algorithmConfig.transportation.initializationVector];
    } else {
        ESRSAPair *client = ESRSACenter.defaultPair;
        secretKey = [client privateDecrypt:output.encryptedSecret];
    }
    ESDLog(@"secretKey: [%@]", secretKey);
    item.secretKey = secretKey;
    item.accessToken = output.accessToken;
    item.refreshToken = output.refreshToken;
    item.expiresAt = output.expiresAt;
    item.secretIV = output.algorithmConfig.transportation.initializationVector;
    return item;
}

+ (instancetype)tokenFromAuth:(NSDictionary *)data {
    ESTokenItem *item = [ESTokenItem yy_modelWithJSON:data];
    ESDLog(@"secretKey: [%@]", item.secretKey);
    NSDictionary *algorithmConfig = data[@"algorithmConfig"];
    if ([algorithmConfig isKindOfClass:[NSDictionary class]]) {
        NSString *initializationVector = [algorithmConfig valueForKeyPath:@"transportation.initializationVector"];
        ESDLog(@"initializationVector: [%@]", initializationVector);
        if (initializationVector) {
            item.secretIV = initializationVector;
        }
    }
    return item;
}

- (BOOL)valid {
    return [NSDate dateWithISO8601String:self.expiresAt].timeIntervalSince1970 - NSDate.date.timeIntervalSince1970 > 2 * 60;
}

@end

@implementation ESCreateTokenResult (ESTool)

- (BOOL)valid {
    return [NSDate dateWithISO8601String:self.expiresAt].timeIntervalSince1970 - NSDate.date.timeIntervalSince1970 > 2 * 60;
}

@end
