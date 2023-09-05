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
//  ESMiniProgramManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/5/31.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletManager.h"
#import "ESAppletInfoModule.h"
#import "ESAppletBaseOperateModule.h"
#import "ESUserDefaults.h"
#import "ESNetworkRequestManager.h"

@interface ESAppletManager ()

@property (nonatomic, strong) ESAppletInfoModule *infoModule;
@property (nonatomic, copy) ESGetAppletInfosCompletionBlock getAppletInfosCompletionBlock;
@property (nonatomic, strong) ESAppletBaseOperateModule *baseOperateModule;

@end

@implementation ESAppletManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)getAppletInfoListWithCompletionBlock:(ESGetAppletInfosCompletionBlock)block {
    [self.infoModule getAppletInfoListWithCompletionBlock:block];
}

- (void)getAppletUpdateInfoListWithCompletionBlock:(ESGetAppletInfosCompletionBlock)block {
    [self.infoModule getAppletInfoListFromNetworkWithCompletionBlock:block];
}

- (void)installAppletWithId:(NSString *)appletId completionBlock:(ESAppletOperateCompletionBlock)block {
    [self.baseOperateModule installAppletWithId:appletId completionBlock:^(BOOL success, NSError * _Nullable error) {
        if (!block) {
            return;
        }
        if (error != nil) {
            block(NO, ESAppletOperateTypeInstall, error);
            return;
        }
        block(YES, ESAppletOperateTypeInstall, nil);
    }];
}

- (void)downAppletWithId:(NSString *)appletId
           appletVersion:(NSString *)appletVersion
         completionBlock:(ESAppletOperateCompletionBlock)block {
    [self.baseOperateModule downAppletWithId:appletId
                               appletVersion:appletVersion
                             completionBlock:^(BOOL success, id  _Nonnull data, NSError * _Nullable error) {
        if (!block) {
            return;
        }
        if (error != nil) {
            block(NO, ESAppletOperateTypeDown, error);
            return;
        }
        block(YES, ESAppletOperateTypeDown, nil);
    }];
}

- (void)uninstallAppletWithId:(NSString *)appletId completionBlock:(ESAppletOperateCompletionBlock)block {
    [self.baseOperateModule unintallAppletWithId:appletId completionBlock:^(BOOL success, NSError * _Nullable error) {
        if (!block) {
            return;
        }
        block(error == nil, ESAppletOperateTypeUninstall, error);
    }];
}

- (void)updateAppletWithId:(NSString *)appletId packageId:(NSString *)packageId completionBlock:(ESAppletOperateCompletionBlock)block {
    [self.baseOperateModule updateAppletWithId:appletId packageId:packageId completionBlock:^(BOOL success, NSError * _Nullable error) {
        if (!block) {
            return;
        }
        block(error == nil, ESAppletOperateTypeUpdate, error);
    }];
}


- (ESAppletInfoModule *)infoModule {
    if (!_infoModule) {
        _infoModule = [[ESAppletInfoModule alloc] init];
    }
    return _infoModule;
}

- (ESAppletBaseOperateModule *)baseOperateModule {
    if (!_baseOperateModule) {
        _baseOperateModule = [[ESAppletBaseOperateModule alloc] init];
    }
    return _baseOperateModule;
}
@end



