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
//  ESBoxItem.m
//  ESBoxItem
//
//  Created by Ye Tao on 2021/8/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxItem.h"
#import "ESApiClient.h"
#import <YYModel/YYModel.h>

@interface ESBoxItem ()

@property (nonatomic, assign) ESBoxType boxType;

@property (nonatomic, copy) NSString *boxUUID;

///授权盒子时获取的信息, 访问时用这里的数据
@property (nonatomic, strong) ESTokenItem *authToken;

///配对
///存放配对的盒子信息
@property (nonatomic, strong) ESPairingBoxInfo *info;

///后端获取的token原始数据
@property (nonatomic, strong) ESCreateTokenResult *tokenResult;

///配对的盒子获取的token
@property (nonatomic, strong) ESTokenItem *pairToken;

//是否在线
@property (nonatomic, assign) BOOL offline;

@property (nonatomic, copy) NSString *aoid;

@end

@implementation ESBoxItem

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"boxIPList" : [ESBoxIPModel class]
    };
}

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[
        @"pairToken",
        @"tokenResult",
        @"secretKey",
        @"apiClient",
        @"online",
    ];
}

+ (instancetype)fromPairing:(ESPairingBoxInfo *)info {
    ESBoxItem *box = [ESBoxItem new];
    box.boxType = ESBoxTypePairing;
    box.info = info;
    box.boxUUID = info.boxUuid;
    box.aoid = info.aoId ?: @"aoid-1";
    box.spaceName = info.spaceName;
    return box;
}

+ (instancetype)fromAuth:(NSDictionary *)data {
    ESBoxItem *box = [ESBoxItem new];
    box.boxType = ESBoxTypeAuth;
    ESTokenItem *token = [ESTokenItem tokenFromAuth:data];
    ESPairingBoxInfo *info = [ESPairingBoxInfo new];
    info.userDomain = data[@"domain"] ?: @"";
    info.boxName = data[@"boxName"] ?: @"";
    info.boxUuid = data[@"boxUUID"];
    NSParameterAssert(info.userDomain && info.boxUuid);
    if (!(info.userDomain && info.boxUuid)) {
        return nil;
    }
    box.authToken = token;
    box.info = info;
    box.boxUUID = info.boxUuid;
    box.aoid = data[@"aoid"];
    return box;
}

+ (instancetype)fromInviteMemberWithBoxUUID:(NSString *)boxUUID
                                    authKey:(NSString *)authKey
                                 userDomain:(NSString *)userDomain
                                       aoid:(NSString *)aoid {
    NSParameterAssert(userDomain && boxUUID && authKey);
    ESBoxItem *box = [ESBoxItem new];
    box.boxType = ESBoxTypeMember;
    ESPairingBoxInfo *info = [ESPairingBoxInfo new];
    info.userDomain = userDomain;
    info.boxName = @"";
    info.boxUuid = boxUUID;
    info.authKey = authKey;
    box.info = info;
    box.boxUUID = info.boxUuid;
    box.aoid = aoid;
    return box;
}

- (BOOL)auth {
    return self.authToken != nil;
}

- (NSString *)name {
    return _info.boxName;
}

- (NSString *)description {
    return self.info.description;
}

- (BOOL)isEqual:(ESBoxItem *)object {
    if (![object isKindOfClass:[ESBoxItem class]]) {
        return NO;
    }
    if ([self.authToken.accessToken isEqualToString:ESSafeString(object.authToken.accessToken)]) {
        return YES;
    }
    return self.boxType == object.boxType && [self.boxUUID isEqualToString:object.boxUUID ?: @"null"] && (!self.aoid || [self.aoid isEqualToString:object.aoid ?: @"null"]);
}
 
- (NSString *)prettyDomain {
    NSString *domain = self.info.userDomain;
    if (domain && ![domain hasPrefix:@"https://"] && ![domain hasPrefix:@"http://"]) {
        domain = [@"https://" stringByAppendingString:domain];
    }
    return domain;
}

- (ESApiClient *)apiClient {
    if (!_apiClient) {
        _apiClient = [ESApiClient sharedClient];
    }
    return _apiClient;
}

- (NSString *)uniqueKey {
    return [NSString stringWithFormat:@"%@-%zd%@", self.boxUUID,self.boxType,self.info.userDomain];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [ESBoxItem yy_modelWithJSON:[self yy_modelToJSONObject]];
}

- (NSString *)bindUserName {
    return _bindUserName.length > 0 ? _bindUserName : [self getPersonalName];
}

- (NSString *)bindUserHeadImagePath {
    if (_bindUserHeadImagePath.length > 0 && [self bindUserHeadImagePathVaild:(_bindUserHeadImagePath)]) {
        return _bindUserHeadImagePath;
    }
    NSString *prePlistCachePath = [self getHeaderImagePath];
    if (prePlistCachePath.length > 0 && [self bindUserHeadImagePathVaild:(prePlistCachePath)]) {
        return prePlistCachePath;
    }
    return nil;
}

- (BOOL)bindUserHeadImagePathVaild:(NSString *)path {
    return [ESSafeString(path) containsString: ESSafeString(_boxUUID)];
}

- (NSString *)getPersonalName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistName = [[NSString stringWithFormat:@"ESBoxItem"] stringByAppendingPathExtension:@"plist"];
    NSString *plistPath = [documentPath stringByAppendingPathComponent:plistName];
    NSDictionary *boxBindInfoMap = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *key = [NSString stringWithFormat:@"%@-%zd%@", self.boxUUID, self.boxType, self.info.userDomain];
    NSDictionary *boxBindInfo = boxBindInfoMap[key];
    return boxBindInfo[@"personalName"] ?: @"";
}

- (NSString *)getHeaderImagePath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistName = [[NSString stringWithFormat:@"ESBoxItem"] stringByAppendingPathExtension:@"plist"];
    NSString *plistPath = [documentPath stringByAppendingPathComponent:plistName];
    NSDictionary *boxBindInfoMap = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *key = [NSString stringWithFormat:@"%@-%zd%@", self.boxUUID, self.boxType, self.info.userDomain];
    NSDictionary *boxBindInfo = boxBindInfoMap[key];
    return boxBindInfo[@"imagePath"] ?: @"";
}

- (BOOL)hasInnerDiskSupport {
    if (self.bindInitResultModel) {
        return self.bindInitResultModel.deviceAbility.innerDiskSupport;
    }
    return NO;
}

- (void)setOffline:(BOOL)offline {
    _offline = offline;
}

@end
