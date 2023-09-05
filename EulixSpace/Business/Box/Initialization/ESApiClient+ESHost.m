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
//  ESApiClient+ESHost.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/18.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESApiClient+ESHost.h"
#import "NSObject+ESAOP.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ESLocalNetworking.h"

@implementation ESApiClient (ESHost)

+ (void)load {
    [self es_swizzleSEL:@selector(es_baseURL) withSEL:@selector(baseURL)];
}

- (NSURL *)es_baseURL {
    if (self.boxItem != nil &&
        self.boxItem.enableInternetAccess == NO &&
        self.boxItem.localHost.length > 0) {
        NSString *userDomain = self.boxItem.localHost;
        ESDLog(@"es_baseURL boxItem url  %@", userDomain);
        return [NSURL URLWithString:userDomain];
    }
    
    if (ESBoxManager.activeBox != nil &&
        ESBoxManager.activeBox.enableInternetAccess == NO &&
        (self.es_baseURL.absoluteString.length <= 0 || ([self.es_baseURL.absoluteString hasSuffix:ESSafeString(ESBoxManager.activeBox.prettyDomain)]))&&
        ESBoxManager.activeBox.localHost.length > 0) {
        NSString *userDomain = ESBoxManager.activeBox.localHost;
        ESDLog(@"es_baseURL activeBox url  %@", userDomain);
        return [NSURL URLWithString:userDomain];
    }
    ESDLog(@"es_baseURL url  %@", self.es_baseURL);
    return self.es_baseURL;
}

static void *gApiClientBindBox = &gApiClientBindBox;

- (ESBoxItem *)boxItem {
    return (ESBoxItem *)objc_getAssociatedObject(self, gApiClientBindBox);
}

- (void)setBoxItem:(ESBoxItem *)boxItem {
    objc_setAssociatedObject(self, gApiClientBindBox, boxItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
