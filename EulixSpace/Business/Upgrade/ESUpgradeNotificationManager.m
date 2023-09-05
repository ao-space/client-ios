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
//  ESUpgradeNotificationManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESUpgradeNotificationManager.h"
#import "ESAppUpdatingNotificationVC.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"
#import "ESSapceUpgradeInfoModel.h"
#import "ESFileDefine.h"
#import "ESAppUpdateDialogVC.h"
#import "ESToast.h"

@implementation ESUpgradeNotificationManager

+ (BOOL)isUpgradNotiticationInfo:(NSDictionary *)info {
    return  ([info[@"optType"] isEqual:@"upgrade_installing"] ||
             [info[@"optType"] isEqual:@"upgrade_success"] ||
             [info[@"optType"] isEqual:@"upgrade_download_success"]) ;
}

+ (void)handlerRemoteNotificationInfo:(NSDictionary *)info {
    if ([info[@"optType"] isEqual:@"upgrade_installing"]) {
        [ESAppUpdatingNotificationVC showNotification];
        return;
    }
    
    if ([info[@"optType"] isEqual:@"upgrade_download_success"]) {
        [self checkVersionServiceApi];
        return;
    }
}

+ (void)checkVersionServiceApi {
    static NSInteger retryCount = 3;
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
                                                     retryCount = 3;
                                                     ESPackageRes *res = output.results.latestBoxPkg;

                                                     ESSapceUpgradeInfoModel *upgradeInfo = [ESSapceUpgradeInfoModel new];
                                                     NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                     upgradeInfo.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                                                     upgradeInfo.pkgSize = FileSizeString(res.pkgSize.floatValue, YES);
                                                     upgradeInfo.packName = res.pkgName;
                                                     upgradeInfo.pckVersion = res.pkgVersion;
                                                     upgradeInfo.isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     upgradeInfo.desc = res.updateDesc;
                                                     if (upgradeInfo.isVarNewVersionExist) {
                                                         [ESAppUpdateDialogVC showDialogIfNeedWithInfo:upgradeInfo];
                                                     }
                                                     return;
                                                 }
                                                    retryCount--;
                                                    if (retryCount > 0) {
                                                        [self checkVersionServiceApi];
                                                    }
                                             }];
}
@end
