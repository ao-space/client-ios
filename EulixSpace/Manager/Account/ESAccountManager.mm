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
// Created by Ye Tao on 2021/9/17.
// Copyright (c) 2021 eulix.xyz. All rights reserved.
//

#import "ESAccountManager.h"
#import "ESAccount+WCTTableCoding.h"
#import "ESApiCode.h"
#import "ESToast.h"
#import "ESBCResult.h"
#import "ESBoxManager.h"
#import "ESCache.h"
#import "ESDatabaseManager+CURD.h"
#import "ESLocalPath.h"
#import "ESLocalizableDefine.h"
#import "ESRealCallRequest.h"
#import "ESTransferManager.h"
#import "ESAccountServiceApi.h"
#import "ESDeviceApi.h"
#import "ESDeviceStorageServiceApi.h"
#import "ESSyncApi.h"
#import <YYModel/YYModel.h>
#import "ESMemberManageServiceApi.h"

static NSString *const kESAccountManagerCacheKey = @"kESAccountManagerCacheKey";

@interface ESAccountManager ()

@property (nonatomic, strong) ESPersonalInfoResult *userInfo;

@property (nonatomic, copy) NSString *avatarPath;

///

@property (nonatomic, strong) ESDeviceInfoResult *deviceInfo;

@property (nonatomic, assign) NSUInteger memberCount;

@property (nonatomic, strong) ESAccount *currentAccount;

@end

@implementation ESAccountManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadCache];
        [self currentAccount]; //load current account 线程安全
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadCache) name:kESBoxActiveMessage object:nil];
    }
    return self;
}

- (void)loadCache {
    if (!ESBoxManager.clientUUID) {
        return;
    }
    NSString *tmp = [self defaultAvatarPath:ESBoxManager.activeBox.boxUUID aoid:ESBoxManager.activeBox.aoid];
    if ([NSFileManager.defaultManager fileExistsAtPath:tmp]) {
        _avatarPath = tmp;
    }
    NSString *key = [NSString stringWithFormat:@"%@-%@", kESAccountManagerCacheKey, ESBoxManager.activeBox.boxUUID];
    NSString *json = [ESCache.defaultCache objectForKey:key];
    if (json) {
        _userInfo = [[ESPersonalInfoResult alloc] initWithString:json error:nil];
    }
    self.deviceInfo = [self getLocalDeviceInfo];
    self.memberCount = [self getLocalMemberCount];
}

- (void)setUserInfo:(ESPersonalInfoResult *)userInfo {
    _userInfo = userInfo;
    [self saveUserInfo];
}

- (void)saveUserInfo {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kESAccountManagerCacheKey, ESBoxManager.activeBox.boxUUID];
    [ESCache.defaultCache setObject:_userInfo.toJSONString forKey:key];
}

- (void)saveDeviceInfo {
    NSString *key = [NSString stringWithFormat:@"%@-%@", @"ESDeviceInfoKey", ESBoxManager.activeBox.boxUUID];
    [ESCache.defaultCache setObject:[self.deviceInfo yy_modelToJSONString] forKey:key];
}

- (ESDeviceInfoResult *)getLocalDeviceInfo {
    NSString *key = [NSString stringWithFormat:@"%@-%@", @"ESDeviceInfoKey", ESBoxManager.activeBox.boxUUID];
    NSString *json = [ESCache.defaultCache objectForKey:key];
    ESDeviceInfoResult * model = [ESDeviceInfoResult.class yy_modelWithJSON:json];
    return model;
}

- (void)saveMemberCount {
    NSString *key = [NSString stringWithFormat:@"%@-%@", @"ESMemberCountKey", ESBoxManager.activeBox.boxUUID];
    [ESCache.defaultCache setObject:@(self.memberCount) forKey:key];
}

- (NSUInteger)getLocalMemberCount {
    NSString *key = [NSString stringWithFormat:@"%@-%@", @"ESMemberCountKey", ESBoxManager.activeBox.boxUUID];
    NSString *json = [ESCache.defaultCache objectForKey:key];
    if (json) {
        return [json integerValue];
    }
    return 0;
}

///TODO
- (void)loadInfo:(void (^)(ESPersonalInfoResult *info))completion {
    ESAccountServiceApi *api = [ESAccountServiceApi new];
    [api spaceV1ApiPersonalInfoGetWithCompletionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
        if (output == nil || output == nil || ![output.code isEqualToString:@"ACC-200"]) {
            return;
        }
        self.userInfo = output.results.firstObject;
        if (completion) {
            completion(self.userInfo);
        }
    }];
}

- (void)updateName:(NSString *)name completion:(void (^)(ESResponseBaseArrayListAccountInfoResult *output))completion {
    ESAccountServiceApi *api = [ESAccountServiceApi new];
    ESPersonalInfoResult *body = [ESPersonalInfoResult new];
    body.personalName = name;
    [api spaceV1ApiPersonalInfoUpdatePostWithBody:body
                                completionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
            if (error) {
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
            if (output.code.justErrorCode >= ESApiCodeOk && output.code.justErrorCode <= ESApiCodeOKMax) {
                self.userInfo.personalName = name;
                [self saveUserInfo];
            }
            if (completion) {
                completion(output);
            }
         }];
}

- (void)updateMemberName:(NSString *)name aoId:(NSString *)aoid completion:(void (^)(ESResponseBaseMemberNameUpdateInfo *info))completion {
    ESAccountServiceApi *api = [ESAccountServiceApi new];
    ESMemberNameUpdateInfo *body = [ESMemberNameUpdateInfo new];
    body.aoId = aoid;
    body.nickName = name;
    [api spaceV1ApiMemberNameUpdatePostWithBody:body
                              completionHandler:^(ESResponseBaseMemberNameUpdateInfo *output, NSError *error) {
        if (error){
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
        if (completion) {
            completion(output);
        }
    }];
}

- (void)updateSign:(NSString *)sign aoid:(NSString *)aoid completion:(void (^)(ESPersonalInfoResult *info))completion {
    ESAccountServiceApi *api = [ESAccountServiceApi new];
    ESPersonalInfoResult *body = [ESPersonalInfoResult new];
    body.personalSign = sign;
    [api spaceV1ApiPersonalInfoUpdatePostWithBody:body
                                completionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
   
            if (error){
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
 
            if (output) {
                self.userInfo.personalSign = sign;
                [self saveUserInfo];
            }
            if (completion) {
                completion(error == nil ? self.userInfo : nil);
            }
    }];
}

- (void)updateAvatar:(NSString *)path completion:(void (^)(void))completion {
    ESRealCallRequest *request = [ESRealCallRequest new];
    request.serviceName = @"eulixspace-account-service";
    request.apiName = @"image_update";
    [ESNetworking.shared uploadFile:path
        dir:nil
        request:request
        progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {

        }
        callback:^(ESRspUploadRspBody *result, NSError *error) {
            if (!error) {
                self.avatarPath = [self defaultAvatarPath:ESBoxManager.activeBox.boxUUID aoid:ESBoxManager.activeBox.aoid];
                [NSFileManager.defaultManager removeItemAtPath:self.avatarPath error:nil];
                [NSFileManager.defaultManager moveItemAtPath:path toPath:self.avatarPath error:nil];
                if (completion) {
                    completion();
                }
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
}

/// /path/to/sanbox/Documents/clientUUID/avatar.png
/// @param boxUUID 
- (NSString *)defaultAvatarPath:(NSString *)boxUUID aoid:(NSString *)aoid {
    NSString *dir = [[NSString alloc] initWithFormat:@"%@/%@", boxUUID, aoid ?: @"aoid-1"];
    NSString *fullPath = [[NSString cacheLocationWithDir:dir] stringByAppendingString:@"avatar.png"].fullCachePath;
    UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
    if (image) {
        return fullPath;
    }
    return [[NSString cacheLocationWithDir:dir] stringByAppendingString:@"avatar.png"].shareCacheFullPath;
}

- (NSString *)shortAvatarPath:(NSString *)boxUUID aoid:(NSString *)aoid {
    NSString *dir = [[NSString alloc] initWithFormat:@"%@/%@", boxUUID, aoid ?: @"aoid-1"];
    return [[NSString cacheLocationWithDir:dir] stringByAppendingString:@"avatar.png"];
}

- (void)loadAvatar:(void (^)(NSString *imagePath))completion {
    [self loadAvatar:ESBoxManager.activeBox.aoid
          completion:^(NSString *path) {
              if (completion) {
                  completion(path);
              }
          }];
}

- (void)loadAvatar:(NSString *)aoid completion:(void (^)(NSString *path))completion {
    ESRealCallRequest *request = [ESRealCallRequest new];
    request.serviceName = @"eulixspace-account-service";
    request.apiName = @"image_show";
    if (aoid) {
        request.queries = @{@"aoid": aoid};
    }
    NSString *boxUUID = ESBoxManager.activeBox.boxUUID;
    NSString *targetPath = [self shortAvatarPath:boxUUID aoid:aoid];
    [ESNetworking.shared downloadRequest:request
        targetPath:targetPath.fullCachePath
        progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {

        }
        callback:^(NSURL *output, NSError *error) {
            if (output) {
                if ([ESSafeString(aoid) isEqualToString:ESBoxManager.activeBox.aoid] &&
                    [boxUUID isEqualToString: ESSafeString(ESBoxManager.activeBox.boxUUID)]) {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath.shareCacheFullPath]) {
                        [[NSFileManager defaultManager] removeItemAtPath:targetPath.shareCacheFullPath error:nil];
                    }
                    [[NSFileManager defaultManager] copyItemAtPath:targetPath.fullCachePath toPath:targetPath.shareCacheFullPath error:&error];
                    self.avatarPath = targetPath.shareCacheFullPath;
                }
                if (completion) {
                    completion(targetPath);
                }
            } else {
                if (error && [error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
                                                 NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                                                 if (response.statusCode == 405) {
                                                     // Handle the 405 error here
                                                      [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                                 }
                }
                if (completion) {
                    completion(nil);
                }
            }
        }];
}

- (void)loadAvatarWithBox:(ESBoxItem *)box completion:(void (^)(NSString *path))completion {
    ESRealCallRequest *request = [ESRealCallRequest new];
    request.serviceName = @"eulixspace-account-service";
    request.apiName = @"image_show";
    if (box.aoid) {
        request.queries = @{@"aoid": box.aoid};
    }
    NSString *boxUUID = box.boxUUID;
    NSString *targetPath = [self shortAvatarPath:boxUUID aoid:box.aoid];
    [ESNetworking.shared downloadRequest:request
               box:box
        targetPath:targetPath.fullCachePath
        progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {

        }
        callback:^(NSURL *output, NSError *error) {
            if (output) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath.shareCacheFullPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:targetPath.shareCacheFullPath error:nil];
                }
                [[NSFileManager defaultManager] copyItemAtPath:targetPath.fullCachePath toPath:targetPath.shareCacheFullPath error:&error];
                self.avatarPath = targetPath.shareCacheFullPath;
                if (completion) {
                    completion(targetPath);
                }
            } else {
                if (error && [error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
                                                 NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                                                 if (response.statusCode == 405) {
                                                     // Handle the 405 error here
                                                      [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                                 }
                }
                if (completion) {
                    completion(nil);
                }
            }
        }];
}

- (void)loadDeviceStorage:(void (^)(ESDeviceInfoResult *))completion {
    //在线试用盒子的容量单独处理
    if ([ESBoxManager.activeBox.deviceAbilityModel isOnlineTrialBox]) {
        ESMemberManageServiceApi *api = [ESMemberManageServiceApi new];
            [api spaceV1ApiMemberUsedStorageGetWithAoid:ESBoxManager.activeBox.aoid
                                      completionHandler:^(ESMemberUsedStorageResult *output, NSError *error) {
                if (error || output == nil || ![output.results isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                NSDictionary *dic = output.results;
                NSString *userStorage = dic[@"userStorage"];
                NSString *userTotalStorage = dic[@"totalStorage"];

                ESDeviceInfoResult *deviceInfoResult = [ESDeviceInfoResult new];
                deviceInfoResult.spaceSizeUsed = userStorage;
                deviceInfoResult.spaceSizeTotal = userTotalStorage;
                self.deviceInfo = deviceInfoResult;
                [self saveDeviceInfo];
                if (completion) {
                    completion(self.deviceInfo);
                }
        }];
        return;
    }
    ESDeviceStorageServiceApi *api = [ESDeviceStorageServiceApi new];
    [api spaceV1ApiDeviceStorageInfoGetWithClientUUID:ESBoxManager.clientUUID
                                    completionHandler:^(ESDeviceInfoResult *output, NSError *error) {
        if (error || output == nil) {
            return;
        }
        self.deviceInfo = output;
        [self saveDeviceInfo];
        if (completion) {
            completion(output);
        }
    }];
}

- (void)loadMemberCount:(void (^)(NSInteger count))completion {
    ESAccountServiceApi *api = [ESAccountServiceApi new];
    [api spaceV1ApiMemberListGetWithCompletionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
        if (error || output == nil || ![output.code isEqualToString:@"ACC-200"]) {
            return;
        }
        if (completion) {
            self.memberCount = output.results.count;
            [self saveMemberCount];
            completion(output.results.count);
        }
    }];
}

- (void)loadNetworkInfo:(void (^)(NSString *linkName))completion {
    ESDeviceApi *api = [ESDeviceApi new];
    [api pairNetLocalIpsDeviceWithCompletionHandler:^(ESRspNetwork *output, NSError *error) {
        if (output.code.justErrorCode != 200) {
            if (completion) {
                completion(@"");
            }
            return;
        }
        ESInitResult *info = [ESInitResult new];
        __block ESNetwork *first = output.results.firstObject;
        [output.results enumerateObjectsUsingBlock:^(ESNetwork *_Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL *_Nonnull stop) {
            if (!obj.wire.boolValue) {
                first = obj;
            }
        }];
        if (!first) {
            if (completion) {
                completion(@"");
            }
            return;
        }
        info.network = output.results;
        if (first.wire.boolValue) {
            info.connected = @(ESBCConnectStatusLocalNetwork);
        } else {
            info.connected = @(ESBCConnectStatusWifi);
        }
        if (completion) {
            completion(info.linkName);
        }
    }];
}

- (ESAccount *)currentAccount {
    if (!ESBoxManager.activeBox) {
        return nil;
    }
    if (![ESDatabaseManager.manager isReady]) {
        return nil;
    }
    
    if (_currentAccount == nil) {
        WCTSelect *select = [ESDatabaseManager.manager select:ESAccount.class];
        [select where:ESAccount.boxUUID == ESBoxManager.activeBox.boxUUID];
        ESAccount *account = select.allObjects.firstObject;
        if (!account) {
            account = [ESAccount new];
            account.boxUUID = ESBoxManager.activeBox.boxUUID;
            [self saveAccount:account];
        }
        _currentAccount = account;
    }

    return _currentAccount;
}

- (void)saveAccount:(ESAccount *)account {
    if (!account.boxUUID) {
        return;
    }
    [ESDatabaseManager.manager save:@[account]];
}

- (void)loadAccountAutoUploadPath:(void (^)(ESSyncFolderRsp *))completion {
    ESSyncFolderRsp *mock = [ESSyncFolderRsp new];
    NSString *directoryName = [NSString stringWithFormat:TEXT_SYNC_DIRECTORY_NAME_FORAMT, UIDevice.currentDevice.name];
    directoryName = [directoryName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    mock.path = [NSString stringWithFormat:@"/%@/", directoryName];
    completion(mock);
}

- (void)createAutoUploadPath:(ESAccount *)account completion:(void (^)(ESSyncFolderRsp *folder))completion {
    ESSyncApi *api = [ESSyncApi new];
    ESSyncDeviceReq *req = [ESSyncDeviceReq new];
    req.deviceId = ESBoxManager.deviceId;
    req.deviceName = UIDevice.currentDevice.name;
    [api spaceV1ApiSyncCreatePostWithSyncDeviceReq:req
                                 completionHandler:^(ESRspSyncFolderRsp *output, NSError *error) {
                                     account.autoUploadPath = nil;
                                     if (output.results) {
                                         account.autoUploadPath = [NSString stringWithFormat:@"%@%@/", output.results.path, output.results.name];
                                     }
                                     [account save];
                                     if (completion) {
                                         completion(output.results);
                                     }
                                 }];
}



@end
