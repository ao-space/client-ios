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
//  ESMimiProgramInfoModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/5/31.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletInfoModule.h"
#import "ESApiClient.h"
#import "ESAppletServiceApi.h"
#import "ESGatewayManager.h"
#import "ESAppletService.h"
#import "ESUserDefaults.h"
#import "ESAppletManager+ESCache.h"
#import "ESNetworkRequestManager.h"

@interface ESAppletInfoModel (Network)

- (instancetype)initWithAppletInfo:(ESAppletInfoRes *)appletInfo;

@end

@implementation ESAppletInfoModel (Network)

- (instancetype)initWithAppletInfo:(ESAppletInfoRes *)appletInfo {
    if (self = [super init]) {
        self.appletId = appletInfo.appletId;
        self.appletVersion = appletInfo.appletVersion;
        self.iconUrl = appletInfo.iconUrl;
        self.isForceUpdate = [appletInfo.isForceUpdate boolValue];
        self.md5 = appletInfo.md5;
        self.name = appletInfo.name;
        self.nameEn = appletInfo.nameEn;
        self.installable = [appletInfo.state integerValue] != 1;
        self.updateAt = appletInfo.updateAt;
        self.updateDesc = appletInfo.updateDesc;
    }
    return self;
}

@end

@interface ESAppletInfoModule ()

@property (nonatomic, copy) NSArray<ESAppletInfoModel *> *appletInfoList;
@property (nonatomic, strong) NSMutableArray<NSString *> *installedAppletIdList;

@property (nonatomic, strong) NSMutableDictionary<NSString *, ESAppletInfoModel *> *appInfoMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ESAppletInfoModel *> *installedAppletInfoMap;

@end

@implementation ESAppletInfoModule

- (void)getAppletInfoListWithCompletionBlock:(ESMPInfoModuleGetAppletInfosCompletionBlock)block {
    [self getAppletAllInfoWithCompletion:block];
}

- (void)getAppletAllInfoWithCompletion:(ESMPInfoModuleGetAppletInfosCompletionBlock)block {
    _appInfoMap = nil;
    _installedAppletIdList = nil;
    
    __weak typeof(self) weakSelf = self;
    [self getAppletInfoListFromNetworkWithCompletionBlock:^(NSArray<ESAppletInfoModel *> * _Nullable infoList, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if(infoList.count > 0) {
            self.appletInfoList = infoList;
            self.appInfoMap = [NSMutableDictionary dictionary];
            
            [self.appletInfoList enumerateObjectsUsingBlock:^(ESAppletInfoModel * _Nonnull infoModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if (infoModel && infoModel.appletId.length > 0) {
                    self.appInfoMap[infoModel.appletId] = infoModel;
                }
            }];
            [self tryMergeAppletInfoWithCompletion:block];
        } else {
            if (block) {
                block(nil, error);
            }
        }
    }];
    
    [self getAppletInstalledListWithCompletionBlock:^(NSArray<ESAppletInfoModel *> * _Nullable infoList, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (error == nil) {
            self.installedAppletIdList = [NSMutableArray array];
            self.installedAppletInfoMap = [NSMutableDictionary dictionary];
            [infoList enumerateObjectsUsingBlock:^(ESAppletInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && obj.appletId.length > 0) {
                    self.installedAppletInfoMap[obj.appletId] = obj;
                    [self.installedAppletIdList addObject:obj.appletId];
                }
            }];
            [self tryMergeAppletInfoWithCompletion:block];
        } else {
            if (block) {
                block(nil, error);
            }
        }
    }];
}

- (void)tryMergeAppletInfoWithCompletion:(ESMPInfoModuleGetAppletInfosCompletionBlock)block {
    if (self.appInfoMap.count > 0 && self.installedAppletIdList != nil) {
        [self.installedAppletIdList enumerateObjectsUsingBlock:^(NSString * _Nonnull appletId, NSUInteger idx, BOOL * _Nonnull stop) {
            ESAppletInfoModel *infoModel = self.appInfoMap[appletId];
            ESAppletInfoModel *currentInfoModel = self.installedAppletInfoMap[appletId];
            if (infoModel) {
                infoModel.context.isInstalled = YES;
                infoModel.installedAppletVersion = currentInfoModel.appletVersion;
                infoModel.memPermission = currentInfoModel.memPermission;
            }
        }];
        if (block) {
            block(self.appletInfoList, nil);
        }
    }
}

- (void)getAppletInfoListFromNetworkWithCompletionBlock:(ESMPInfoModuleGetAppletInfosCompletionBlock)block {
    ESAppletService *api = [ESAppletService new];
    [api spaceV1ApiGatewayAppletInfoGetWithCompletionHandler:^(ESAppletResponseBaseListAppletInfoRes *output, NSError *error) {
        if (block) {
            NSMutableArray *tempList = [NSMutableArray array];
            [output.results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ESAppletInfoModel *infoModel = [[ESAppletInfoModel alloc] initWithAppletInfo:obj];
                [tempList addObject:infoModel];
            }];
            block(tempList, error);
        }
    }];
}

- (void)getAppletInstalledListWithCompletionBlock:(ESMPInfoModuleGetAppletInfosCompletionBlock)block {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                  apiName:@"installed_applet_info"
                                              queryParams:@{}
                                                   header:@{}
                                                     body:@{}
                                                modelName:@"ESAppletResponseBaseListAppletInfoRes"
                                             successBlock:^(NSInteger requestId, ESAppletResponseBaseListAppletInfoRes * _Nullable response) {
        if (block) {
            block(response.results, nil);
        }
      } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          if (block) {
              block(nil, error);
          }
      }];
}

@end
