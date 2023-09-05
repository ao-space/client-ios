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
//  ESAppStoreManage.m
//  EulixSpace
//
//  Created by qu on 2022/11/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppStoreManage.h"
#import "ESAppletManager.h"
#import "ESAppletViewController.h"
#import "ESAppStoreModel.h"
#import "ESSmarPhotoCacheManager.h"
#import "ESAppletManager+ESCache.h"
#import "ESNetworkRequestManager.h"
#import "ESToast.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation ESAppStoreManage

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)down:(ESFormItem *)item completionBlock:(nonnull ESAppStoreManageCompletionBlock)block {
    if(!item.version){
        item.version =@"";
    }

    NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:item.appId];
    NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
    NSFileManager *file = [NSFileManager new];
    if([file fileExistsAtPath:path]){
        ESAppletViewController *appletVC = [[ESAppletViewController alloc] init];
        ESAppletInfoModel *viewModel =  [ESAppletInfoModel new];
        viewModel.name = item.title;
        viewModel.appletId = item.appId;
        viewModel.appletVersion = item.version;
        viewModel.installedAppletVersion = item.installedAppletVersion;
        viewModel.iconUrl = item.iconUrl;
        viewModel.packageId = item.packageId;
        viewModel.source = item.source;
        viewModel.deployMode = item.deployMode;
        viewModel.hasNewVersion = item.isNewVersion;
        NSString *unzipPath = [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:item.appId];
        NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
        viewModel.localCacheUrl = path;
        [appletVC loadWithAppletInfo:viewModel];
        block(YES,nil);
       }
    else{
        
        NSString *picZipCachePath = [ESSmarPhotoCacheManager cacheZipPathWithDate:@"12"];
        [ESNetworkRequestManager sendCallDownloadRequest:@{ @"serviceName" : @"eulixspace-appstore-service",
                                                              @"apiName" : @"appstore_down"}
                                                queryParams:@{@"appid" : item.appId
                                                             }
                                                  header:@{}
                                                    body:@{}
                                              targetPath:picZipCachePath
                                                  status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                                   }
                                            successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {

            BOOL unZipSuccess = [ESAppletManager.shared addAppletCacheWithId:item.appId
                                                                appletVerion:item.version
                                                            downloadFilePath:picZipCachePath];
            if(unZipSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:item.appId];
                    NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
                    NSFileManager *file = [NSFileManager new];
                    if([file fileExistsAtPath:path]){
                        [self down:item completionBlock:^(BOOL success, NSError * _Nullable error) {
                            block(YES,nil);
                        }];
                        
                    }else{
                        [ESToast dismiss];
                       [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                      //  block(YES,nil);
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ESToast dismiss];
                   [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                   // block(YES,nil);
                });
            }
           // [SVProgressHUD dismiss];
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ESToast dismiss];
               [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
               // [SVProgressHUD dismiss];
            });
        }];
    }
}

@end
