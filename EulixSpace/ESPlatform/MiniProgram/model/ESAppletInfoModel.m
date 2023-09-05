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
//  ESAppletInfoModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletInfoModel.h"
#import "ESAppletManager+ESCache.h"
#import "ESUserDefaults.h"

static ESUserDefaultsKey const ESShownedUpdateDialogAppleVersionKey = @"ESShownedUpdateDialogAppleVersionKey";
static ESUserDefaultsKey const ESShownedNewActionAppleVersionKey = @"ESShownedNewActionAppleVersionKey";

@interface ESAppletContext ()

@property (nonatomic, copy) NSString  *appletVersion;

@end

@implementation ESAppletContext

- (instancetype)initWithAppletVersion:(NSString *)appletVersion {
    if (self = [super init]) {
        _appletVersion = appletVersion;
    }
    return self;
}
- (BOOL)shownedUpdateDialog {
    NSString *shownedUpdateDialogAppletVersion = [[ESUserDefaults standardUserDefaults] objectForKey:ESShownedUpdateDialogAppleVersionKey];
    return [shownedUpdateDialogAppletVersion isEqualToString:self.appletVersion];
}

- (void)setShownedUpdateDialog:(BOOL)shownedUpdateDialog {
    if (shownedUpdateDialog) {
        [[ESUserDefaults standardUserDefaults] setObject:self.appletVersion forKey:ESShownedUpdateDialogAppleVersionKey];
    }
}

- (BOOL)shownedNewAction {
    NSString *shownedNewActionAppletVersion = [[ESUserDefaults standardUserDefaults] objectForKey:ESShownedNewActionAppleVersionKey];
    return [shownedNewActionAppletVersion isEqualToString:self.appletVersion];
}

- (void)setShownedNewAction:(BOOL)shownedNewAction {
    if (shownedNewAction) {
        [[ESUserDefaults standardUserDefaults] setObject:self.appletVersion forKey:ESShownedNewActionAppleVersionKey];
    }
}

@end

@implementation ESAppletInfoModel

//- (BOOL)hasNewVersion {    
//    if (self.installedAppletVersion.length <= 0 || self.appletVersion.length <= 0) {
//        return NO;
//    }
//    
//    if ([self.installedAppletVersion isEqualToString:self.appletVersion]) {
//        return NO;
//    }
//    return YES;
//}

- (NSString *)localCacheUrl {
    NSString *localFilePath = [ESAppletManager.shared getCacheAppletIndexPageWithAppletId:self.appletId];
    return localFilePath;
}

- (BOOL)downloaded {
    NSString *localFilePath = [ESAppletManager.shared getCacheAppletIndexPageWithAppletId:self.appletId];
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
}

- (ESAppletContext *)context {
    if (!_context) {
        _context = [[ESAppletContext alloc] initWithAppletVersion:self.appletVersion];
    }
    return _context;
}

@end
