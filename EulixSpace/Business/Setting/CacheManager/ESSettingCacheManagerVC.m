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
//  ESSettingCacheManagerVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSettingCacheManagerVC.h"
#import "ESUniversalSelectCell.h"
#import "ESTitleDetailCell.h"
#import "ESCacheManagerListModule.h"
#import "ESCacheCleanTools+ESBusiness.h"
#import "ESToast.h"

@interface ESSettingCacheManagerVC ()

@end

@implementation ESSettingCacheManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"setting_clear_manager", @"缓存管理");;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"clear_cache_data_clear", @"清理")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(clearCache)];
    self.navigationItem.rightBarButtonItem.tintColor = ESColor.disableTextColor;
    [self setupListModule];
 
    [self loadCacheData:YES];
}

- (void)setupListModule {
    weakfy(self)
    ESCacheManagerListModule *listModule = (ESCacheManagerListModule *)self.listModule;
    listModule.selectedUpdateBlock = ^() {
        strongfy(self)
        self.navigationItem.rightBarButtonItem.tintColor = listModule.selectedCount == 0 ? ESColor.disableTextColor : ESColor.primaryColor;
    };
    
    listModule.cleanFinishBlock = ^() {
        strongfy(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadCacheData:NO];
        });
    };
}

- (void)loadCacheData:(BOOL)first {
    if (first) {
        [self showEmptyLoading:YES];
    }
    weakfy(self)
    [ESCacheCleanTools businessCacheSizeWithCompletion:^(NSString * _Nonnull totalSize, NSArray<ESBusinessCacheInfoItem *> * _Nonnull cacheInfoList) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            strongfy(self)
            [self showEmptyLoading:NO];
            [(ESCacheManagerListModule *)self.listModule loadCacheData:cacheInfoList totalSize:totalSize];
        });
    }];
}

- (Class)listModuleClass {
    return [ESCacheManagerListModule class];
}

- (void)clearCache {
    if ([(ESCacheManagerListModule *)self.listModule selectedCount] == 0) {
        return;
    }

    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"clear_cache_data_notice", @"预计可释放%@空间，清理缓存可能需要一点时间，请耐心等待"),
                         [(ESCacheManagerListModule *)self.listModule canCleanCacheSize]];
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attMessage = [[NSMutableAttributedString alloc]initWithString:message
                                                                                  attributes:@{NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                                                                                               NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                               NSParagraphStyleAttributeName : paraStyle,
                                                                                             }];
    [actionSheetController setValue:attMessage forKey:@"attributedMessage"];
    
    UIAlertAction *cleanAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showLoading:YES];
            [(ESCacheManagerListModule *)self.listModule cleanSelectedCache:^(NSString * _Nonnull cleanSize) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [ESToast toastSuccess:[NSString stringWithFormat:NSLocalizedString(@"clear_cache_data_clear_short", @"已清理并释放%@空间"),cleanSize.length > 0 ? cleanSize : @"0"]];
                });
            }];
    }];
    [cleanAction setValue:ESColor.redColor forKey:@"titleTextColor"];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];

    [actionSheetController addAction:cleanAction];
    [actionSheetController addAction:cancelAction];
        
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (NSString *)emptyLoadingMessage {
    return NSLocalizedString(@"cache_calculate_loading_notice", @"正在计算缓存大小，可能需要较长时间，请稍等");
}

@end
