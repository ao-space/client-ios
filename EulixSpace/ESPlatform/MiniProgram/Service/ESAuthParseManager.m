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
//  ESAuthParseManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/1.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthParseManager.h"

static NSString * const ESUserInfoAuthKey = @"userinfo-readonly";
@implementation ESAuthParseManager

+ (NSString * _Nullable)parseTitleAuthWithAuthCategories:(NSDictionary *)categories {
    if (![categories isKindOfClass:[NSDictionary class]] ||  categories.count <= 0) {
        return nil;
    }
    __block NSString *authString = @"";
    if ([categories.allKeys containsObject:ESUserInfoAuthKey]) {
        NSString *userAuth = [self parseAuthWithCategoryName:ESUserInfoAuthKey];
        if (userAuth.length > 0) {
            authString = [authString stringByAppendingString:userAuth];
        }
    }
    [categories.allKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull categoryName, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![categoryName isEqualToString:ESUserInfoAuthKey]) {
            NSString *auth = [self parseAuthWithCategoryName:categoryName];
            authString = [authString stringByAppendingString:[NSString stringWithFormat:@"、%@",auth]];
        }
    }];
    
    return authString;
}

+ (NSString * _Nullable)parseAuthDetailWithAuthCategories:(NSDictionary *)categories {
    if (![categories isKindOfClass:[NSDictionary class]] ||  categories.count <= 0) {
        return nil;
    }
    __block NSString *authString = @"";
    [categories.allValues enumerateObjectsUsingBlock:^(NSArray *_Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![category isKindOfClass:[NSArray class]]) {
            return;
        }
        [category enumerateObjectsUsingBlock:^(NSString  *_Nonnull authDetailName, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![authDetailName isKindOfClass:[NSString class]]) {
                return;
            }
            NSString *auth = [self parseAuthWithAuthDetailName:authDetailName];
            if (auth.length <= 0) {
                return;
            }
            
            if (authString.length > 0) {
                authString = [authString stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"applet_and", @"和%@"),auth]];
            } else {
                authString = [authString stringByAppendingString:auth];
            }
        }];
    }];
    
    return authString;
}

+ (BOOL)parseContainContactAuth:(NSDictionary *)categories {
    __block BOOL contain = NO;
    [categories.allKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull categoryName, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([categoryName isEqualToString:@"addressbook"]) {
            contain = YES;
            *stop = YES;
        }
    }];
    return contain;
}

+ (NSString * _Nullable)parseAuthWithCategoryName:(NSString *)category {
    if (category.length <= 0) {
        return nil;
    }
    return ESAuthParseManager.categoryName2AuthMap[category];
}

+ (NSString * _Nullable)parseAuthWithAuthDetailName:(NSString *)authDetail {
    if (authDetail.length <= 0) {
        return nil;
    }
    return ESAuthParseManager.authItemName2AuthMap[authDetail];
}

+ (NSDictionary *)categoryName2AuthMap {
    return  @{
              @"addressbook" : NSLocalizedString(@"contacts", @"通讯录"),
              @"userinfo-readonly" : NSLocalizedString(@"applet_auth_scope_userinfo", @"头像、昵称、域名"),
             };
}

+ (NSDictionary *)authItemName2AuthMap {
    return  @{
              @"addressbook_write" : NSLocalizedString(@"applet_auth_scope_desc_contact", @"新建/修改/删除联系人"),
              @"addressbook_read" : NSLocalizedString(@"applet_auth_scope_desc_read", @"读取联系人"),
             };
}

@end
