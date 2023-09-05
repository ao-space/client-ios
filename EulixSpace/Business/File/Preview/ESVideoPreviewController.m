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
//  ESVideoPreviewController.m
//  EulixSpace
//
//  Created by KongBo on 2022/12/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESVideoPreviewController.h"
#import "ESVideoPreviewController+ESM3U8.h"
#import "ESPlayerVC.h"
#import "ESGCDWebServerManager.h"
#import "ESLocalNetworking.h"
#import "ESBaseViewController+Status.h"

@interface ESVideoPreviewController () 


@end

@implementation ESVideoPreviewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.tabBarController.tabBar.hidden = YES;
  
    [self showLoading:YES];
    weakfy(self)
    [self checkVODSupportWithUuid:self.previewUuid
                  compeltionBlock:^(NSString * _Nonnull uuid, BOOL support, NSError * _Nullable error) {
        strongfy(self)
        if (support) {
            [self fetchM3U8FilesWithUuid:self.previewUuid];
            return;
        }
        if (self.supportBlock) {
            [self showLoading:NO];
            self.supportBlock (self.previewUuid, NO, nil);
            [self.navigationController popViewControllerAnimated:NO];
        }
    }];
    
}

- (void)fetchM3U8FilesWithUuid:(NSString *)uuid {
    weakfy(self)
    [self fetchM3U8FilesWithUuid:self.previewUuid
                       retyCount: 3
                 compeltionBlock:^(NSString * _Nonnull uuid,
                                   NSString * _Nullable lanM3u8Path,
                                   NSString * _Nullable wanM3u8Path,
                                   NSError * _Nullable error) {
        strongfy(self)
        if (error != nil) {
            if (self.supportBlock) {
                [self showLoading:NO];
                self.supportBlock (self.previewUuid, NO, nil);
                [self.navigationController popViewControllerAnimated:NO];
            }
            return;
        }
        
        if (lanM3u8Path.length <= 0 || wanM3u8Path.length <= 0) {
            if (self.supportBlock) {
                [self showLoading:NO];
                self.supportBlock (self.previewUuid, NO, nil);
                [self.navigationController popViewControllerAnimated:NO];
            }
            return;
        }
        
        [ESGCDWebServerManager startSeviceWithFilePathList:@[ESSafeString(lanM3u8Path) , ESSafeString(wanM3u8Path)]];

        ESPlayerModel *playerModel = [ESPlayerModel new];
        playerModel.uuid = self.previewUuid;
        NSString *wanFileName = [wanM3u8Path lastPathComponent];
        playerModel.wanM3U8Url = [NSString stringWithFormat:@"http://localhost:8080/%@", wanFileName];
        NSString *lanFileName = [lanM3u8Path lastPathComponent];
        playerModel.lanM3U8Url = [NSString stringWithFormat:@"http://localhost:8080/%@", lanFileName];
        
        if (self.supportBlock) {
            [self showLoading:NO];
            [self.navigationController popViewControllerAnimated:NO];
            self.supportBlock (self.previewUuid, YES, playerModel);
        }
    }];
}

@end
