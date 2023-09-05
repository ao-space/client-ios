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
//  ESMemoriesPicPlayer.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesPicPlayer.h"
#import "ESPicModel.h"
#import "ESBaseViewController+Status.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountInfoStorage.h"
#import "ESSmarPhotoCacheManager.h"
#import "ESToast.h"

@interface ESMemoriesPicPlayer ()

@end

@implementation ESMemoriesPicPlayer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self isPicReady]) {
        [self loadCompressData];
        [self showLoading:YES];
    }
}

- (BOOL)isPicReady {
    __block BOOL compressCacheAllReady = YES;
    [self.picList enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pic.compressUrl.length <= 0) {
            compressCacheAllReady = NO;
            *stop = YES;
        }
    }];
    
    return compressCacheAllReady;
}

- (void)loadCompressData {
    NSMutableArray *uuidList = [NSMutableArray array];
    [self.picList enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pic.compressUrl.length <= 0) {
            [uuidList addObject:pic.uuid];
        }
    }];
    
    if (uuidList.count <= 0) {
        return;
    }
    
    weakfy(self)
    
    NSString *picZipCachePath = [ESSmarPhotoCacheManager cacheZipPathWithAlbumId:self.albumModel.albumId];
    [ESNetworkRequestManager sendCallDownloadRequest:@{ @"serviceName" : @"eulixspace-file-service",
                                                                 @"apiName" : @"album_thumbs", }
                                                   queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId])
                                                                }
                                                     header:@{}
                                                       body:@{ @"uuids" : uuidList,
                                                               @"type" : @(1) // ESSmartPhotoThumbTypeCompress
                                                            }
                                                 targetPath:picZipCachePath
                                                     status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                                      }
                                               successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {
                strongfy(self)
                [ESSmarPhotoCacheManager unZipCompressPicCachePath:picZipCachePath picList:self.picList];
                ESPerformBlockOnMainThread(^{
                    strongfy(self)
                    [self showLoading:NO];

                    [self startPlay];
                });
             
        
           } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               strongfy(self)
               ESPerformBlockOnMainThread(^{
                   strongfy(self)
                   [self showLoading:NO];
                   [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
               });
           }];
}

- (NSString *)getUrlPathWith:(ESPicModel *)pic {
    if ([[NSFileManager defaultManager] fileExistsAtPath:pic.compressUrl]) {
        return pic.compressUrl;
    }
    
    return pic.cacheUrl;
}

- (NSString *)titleForLoading {
    return NSLocalizedString(@"memory_data_loading", @"影集生成中");
}

@end
