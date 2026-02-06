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

static BOOL ESHostIsLoopbackURL(NSURL *url) {
    NSString *host = url.host.lowercaseString;
    return [host isEqualToString:@"localhost"] || [host isEqualToString:@"127.0.0.1"];
}

static BOOL ESHostIsUsableHTTPURL(NSString *value) {
    if (value.length == 0) {
        return NO;
    }
    NSURL *url = [NSURL URLWithString:value];
    if (url == nil || url.scheme.length == 0 || url.host.length == 0) {
        return NO;
    }
    NSString *scheme = url.scheme.lowercaseString;
    return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
}

+ (void)load {
    [self es_swizzleSEL:@selector(es_baseURL) withSEL:@selector(baseURL)];
}

- (NSURL *)es_baseURL {
    ESBoxItem *activeBox = ESBoxManager.activeBox;
    NSString *activeLocalHost = @"";
    if (activeBox != nil &&
        activeBox.enableInternetAccess == NO &&
        ESHostIsUsableHTTPURL(activeBox.localHost)) {
        activeLocalHost = activeBox.localHost;
    }

    if (self.boxItem != nil &&
        self.boxItem.enableInternetAccess == NO &&
        ESHostIsUsableHTTPURL(self.boxItem.localHost)) {
        // If this client is accidentally bound to a stale box, force active LAN host.
        if (activeLocalHost.length > 0 &&
            activeBox != nil &&
            self.boxItem.boxUUID.length > 0 &&
            ![self.boxItem.boxUUID isEqualToString:activeBox.boxUUID]) {
            ESDLog(@"es_baseURL activeBox(stale-box override) url  %@", activeLocalHost);
            return [NSURL URLWithString:activeLocalHost];
        }
        NSString *userDomain = self.boxItem.localHost;
        ESDLog(@"es_baseURL boxItem url  %@", userDomain);
        return [NSURL URLWithString:userDomain];
    }

    NSURL *rawBaseURL = self.es_baseURL;
    NSString *rawBaseURLString = ESSafeString(rawBaseURL.absoluteString);
    if (activeLocalHost.length > 0 &&
        (rawBaseURLString.length <= 0 ||
         ESHostIsLoopbackURL(rawBaseURL) ||
         [rawBaseURLString hasSuffix:ESSafeString(activeBox.prettyDomain)])) {
        NSString *userDomain = activeLocalHost;
        ESDLog(@"es_baseURL activeBox url  %@", userDomain);
        return [NSURL URLWithString:userDomain];
    }
    return rawBaseURL;
}

static void *gApiClientBindBox = &gApiClientBindBox;

- (ESBoxItem *)boxItem {
    return (ESBoxItem *)objc_getAssociatedObject(self, gApiClientBindBox);
}

- (void)setBoxItem:(ESBoxItem *)boxItem {
    objc_setAssociatedObject(self, gApiClientBindBox, boxItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
