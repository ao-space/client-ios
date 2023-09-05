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
//  ESAccountInfoStorage.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAccountInfoStorage.h"
#import "ESBoxManager.h"
#import "ESAccountManager.h"
#import "ESImageDefine.h"

@implementation ESAccountInfoStorage

+ (BOOL)isAdminOrAuthAccount {
    return [self isAdminAccount] || [self isAuthAccount];
}
+ (BOOL)isAdminAccount {
    NSDictionary *boxInfo = [ESBoxManager cacheInfoForBox:ESBoxManager.activeBox];
    return (boxInfo[@"isAdmin"] ? [boxInfo[@"isAdmin"] boolValue] : NO ) && ![self isAuthAccount] && ![self isMemberAccount];
}

+ (BOOL)isAdminAccount:(ESBoxItem *)box {
    NSDictionary *boxInfo = [ESBoxManager cacheInfoForBox:box];
    return (boxInfo[@"isAdmin"] ? [boxInfo[@"isAdmin"] boolValue] : NO ) && ![self isAuthAccount:box] && ![self isMemberAccount:box];
}

+ (BOOL)isAuthAccount {
    return ESBoxManager.activeBox.boxType == ESBoxTypeAuth;
}

+ (BOOL)isAuthAccount:(ESBoxItem *)box {
    return box.boxType == ESBoxTypeAuth;
}

+ (BOOL)isMemberAccount {
    return ESBoxManager.activeBox.boxType == ESBoxTypeMember;
}

+ (BOOL)isMemberAccount:(ESBoxItem *)box {
    return box.boxType == ESBoxTypeMember;
}

+ (NSString *)userId {
    return [ESAccountManager.manager currentAccount].userId;
}

+ (NSString *)userUniqueId {
    return [NSString stringWithFormat:@"%@-%lu-%@", ESBoxManager.activeBox.boxUUID, (unsigned long)ESBoxManager.activeBox.boxType, ESBoxManager.activeBox.aoid];
}

+ (NSString *)userUniqueKey {
    return [ESBoxManager.activeBox uniqueKey];
}

+ (NSString *)avatarPath {
    return ESAccountManager.manager.avatarPath;
}

+ (NSString *)personalName {
    return ESAccountManager.manager.userInfo.personalName;
}

+ (NSString *)personalSign {
    return ESAccountManager.manager.userInfo.personalSign;
}

+ (UIImage *)avatarImage {
    return [UIImage imageWithContentsOfFile:ESAccountManager.manager.avatarPath] ?:IMAGE_ME_AVATAR_DEFAULT;
}

+ (ESAccountType)accountType {
    return [self accountType:ESBoxManager.activeBox];
}

+ (ESAccountType)accountType:(ESBoxItem *)box {
    if ([box.aoid isEqualToString:@"aoid-1"] && box.boxType == ESBoxTypePairing) {
        return ESAccountTypeAdmin;
    }
    if ([box.aoid isEqualToString:@"aoid-1"] && box.boxType == ESBoxTypeAuth) {
        return ESAccountTypeAdminAuth;
    }
    
    if (![box.aoid isEqualToString:@"aoid-1"] && box.boxType == ESBoxTypeAuth) {
        return ESAccountTypeMemberAuth;
    }
    
    if (box.boxType == ESBoxTypeMember) {
        return ESAccountTypeMember;
    }
    return ESAccountTypeUnkown;
}

+ (BOOL)currentAccountIsAdminType {
    return self.accountType == ESAccountTypeAdmin || self.accountType == ESAccountTypeAdminAuth;
}
@end


 
