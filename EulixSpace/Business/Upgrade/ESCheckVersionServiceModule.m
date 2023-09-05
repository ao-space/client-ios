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
//  ESCheckVersionServiceModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCheckVersionServiceModule.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"
#import "ESAccountInfoStorage.h"
#import "ESFileDefine.h"
#import "ESToast.h"

@implementation ESCheckVersionServiceModule

+ (void)checkVersionWithCompletionBlock:(ESCheckVersionServiceCompletionBlock)block {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
    [clientResultApi spaceV1ApiGatewayVersionBoxGetWithAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
                                                       appType:@"ios"
                                                       version:appVersion
                                             completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
        
                                                 if (!error) {
                                                     if ([output.code isEqualToString:@"GW-5006"]) {
                                                         [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
                                                         return;
                                                     }
                                                     ESPackageRes *res = output.results.latestBoxPkg;
                                                     
                                                     ESSapceUpgradeInfoModel *upgradeInfo = [ESSapceUpgradeInfoModel new];
                                                     NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                     upgradeInfo.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                                                     upgradeInfo.pkgSize = FileSizeString(res.pkgSize.floatValue, YES);
                                                     upgradeInfo.packName = res.pkgName;
                                                     upgradeInfo.pckVersion = res.pkgVersion;
                                                     upgradeInfo.isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     upgradeInfo.desc = res.updateDesc;
                                        
                                                     BOOL isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     if (block) {
                                                         block(isVarNewVersionExist, upgradeInfo, nil);
                                                     }
                                                     return;
                                                 }
                                                    if (block) {
                                                        block(NO, nil, error);
                                                    }
                                                    return;
                                             }];
}

@end
