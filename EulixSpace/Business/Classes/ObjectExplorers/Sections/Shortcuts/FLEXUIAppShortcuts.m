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
//  FLEXUIAppShortcuts.m
//  FLEX
//
//  Created by Tanner on 5/25/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXUIAppShortcuts.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXShortcut.h"
#import "FLEXAlert.h"

@implementation FLEXUIAppShortcuts

#pragma mark - Overrides

+ (instancetype)forObject:(UIApplication *)application {
    return [self forObject:application additionalRows:@[
        [FLEXActionShortcut title:@"Open URL…"
            subtitle:^NSString *(UIViewController *controller) {
                return nil;
            }
            selectionHandler:^void(UIViewController *host, UIApplication *app) {
                [FLEXAlert makeAlert:^(FLEXAlert *make) {
                    make.title(@"Open URL");
                    make.message(
                        @"This will call openURL: or openURL:options:completion: "
                         "with the string below. 'Open if Universal' will only open "
                         "the URL if it is a registered Universal Link."
                    );
                    
                    make.textField(@"twitter://user?id=12345");
                    make.button(@"Open").handler(^(NSArray<NSString *> *strings) {
                        [self openURL:strings[0] inApp:app onlyIfUniveral:NO host:host];
                    });
                    make.button(@"Open if Universal").handler(^(NSArray<NSString *> *strings) {
                        [self openURL:strings[0] inApp:app onlyIfUniveral:YES host:host];
                    });
                    make.button(@"Cancel").cancelStyle();
                } showFrom:host];
            }
            accessoryType:^UITableViewCellAccessoryType(UIViewController *controller) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ]
    ]];
}

+ (void)openURL:(NSString *)urlString
          inApp:(UIApplication *)app
 onlyIfUniveral:(BOOL)universalOnly
           host:(UIViewController *)host {
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        if (@available(iOS 10, *)) {
            [app openURL:url options:@{
                UIApplicationOpenURLOptionUniversalLinksOnly: @(universalOnly)
            } completionHandler:^(BOOL success) {
                if (!success) {
                    [FLEXAlert showAlert:@"No Universal Link Handler"
                        message:@"No installed application is registered to handle this link."
                        from:host
                    ];
                }
            }];
        } else {
            [app openURL:url];
        }
    } else {
        [FLEXAlert showAlert:@"Error" message:@"Invalid URL" from:host];
    }
}

@end

