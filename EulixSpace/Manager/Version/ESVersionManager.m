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
//  ESVersionManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESVersionManager.h"
#import "ESHomeCoordinator.h"
#import "ESPlatformClient.h"
#import "ESResponseBasePackageCheckRes.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"

@implementation ESVersionManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


+ (void)checkAppVersion:(void (^)(ESPackageCheckRes *info))completion {
    ESSpaceGatewayVersionCheckingServiceApi *api = [ESSpaceGatewayVersionCheckingServiceApi new];
    NSString *bundleId = NSBundle.mainBundle.bundleIdentifier;
    NSString *version;
    //#ifdef DEBUG
    //    version = @"0.5.1";
    //#else
    version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    //#endif
    [api spaceV1ApiGatewayVersionAppGetWithAppName:bundleId
                                           appType:@"ios"
                                           version:version
                                 completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
                                     if (completion) {
                                         completion(output.results);
                                     }
                                 }];
}

+ (void)checkBoxVersion:(void (^)(ESPackageCheckRes *info))completion {
    ESSpaceGatewayVersionCheckingServiceApi *api = [ESSpaceGatewayVersionCheckingServiceApi new];
    NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    //#ifdef DEBUG
    //    version = @"0.5.1";
    //#endif
    [api spaceV1ApiGatewayVersionBoxGetWithAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
                                           appType:@"ios"
                                           version:version
                                 completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
                                     if (completion) {
                                         completion(output.results);
                                     }
                                 }];
}

///space/v1/api/gateway/version/compatible
+ (void)checkCompatibleAfterLaunch {
    ESSpaceGatewayVersionCheckingServiceApi *api = [ESSpaceGatewayVersionCheckingServiceApi new];
    NSString *bundleId = NSBundle.mainBundle.bundleIdentifier;
    NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
#ifdef DEBUG
    //version = @"0.4.1";
#endif
    [api spaceV1ApiGatewayVersionCompatibleGetWithAppName:bundleId
                                                  appType:@"ios"
                                                  version:version
                                        completionHandler:^(ESResponseBaseCompatibleCheckRes *output, NSError *error) {
                                            ESCompatibleCheckRes *info = output.results;
                                            //info.isAppForceUpdate = @(YES);
                                            //info.isBoxForceUpdate = @(YES);
                                            //info.lastestAppPkg = [ESPackageRes new];
                                            //info.lastestAppPkg.downloadUrl = @"https://apps.apple.com/cn/app/%E5%BE%AE%E4%BF%A1/id414478124";
                                            if (info.isAppForceUpdate.boolValue || info.isBoxForceUpdate.boolValue) {
                                                [ESHomeCoordinator showForceUpgrade:info];
                                            }
                                        }];
}

@end
