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
//  ESDiskInitProgressPage.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskInitProgressPage.h"
#import "ESDiskInitProgressModule.h"
#import "ESToast.h"
#import "ESDiskMainStorageCell.h"
#import "UIViewController+ESTool.h"
#import "ESDiskInitSuccessPage.h"
#import "ESBoxListViewController.h"
#import "ESBoxManager.h"
#import "UIView+Status.h"

@interface ESDiskInitProgressPage ()

@property (nonatomic, strong) ESSpaceReadyCheckResultModel * spaceReadyCheckModel;
@property (nonatomic, strong) ESDiskImagesView * diskImageView;
// 初始化进度的视图
@property (nonatomic, strong) ESDiskInitProgressView * progressView;
// 初始化失败的视图
@property (nonatomic, strong) ESESDiskInitFailedView * failedView;
@property (nonatomic, strong) NSMutableArray * dataArr;

@end

@implementation ESDiskInitProgressPage

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBackBt = NO;
    
    self.viewModel.delegate = self;
    [self addBackgroudProcessBt];
    if (self.status == ESDeviceStartupStatusDiskIniting) {
        [self reqDiskInitProgress:0];
        return;
    }
    [self sendDiskInit];
    [self.listModule.listView reloadData];
}

- (void)sendDiskInit {
    [self readyDiskData];
    
    self.viewModel.diskInitializeReq.diskEncrypt = 1; //  self.encrySwitch.on ? 1 : 2;
    
    [self.view showLoading:YES];
    [self.viewModel sendDiskInitialize:self.viewModel.diskInitializeReq];
}

- (void)viewModelDiskInitialize:(ESBaseResp *)response {
    [self.view showLoading:NO];

    if ([response isOK]) {
        ESDLog(@"[系统启动] 请求初始化成功");
        [self reqDiskInitProgress:5];
    } else if ([response codeValue] == 462) {
        // 傲空间已绑定其他设备
        NSString * text = NSLocalizedString(@"Box bind by other device", @"");
        [self showAlert:text];
        if (self.viewModel.paringBoxItem) {
            [ESBoxManager revoke:self.viewModel.paringBoxItem];
        }
    } else {
        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        self.status = ESDeviceStartupStatusEncry;
    }
}

- (void)readyDiskData {
    if ([self.diskListModel hasDisk:ESDiskStorage_Disk1] && [self.diskListModel hasDisk:ESDiskStorage_Disk2]) {
        self.viewModel.diskInitializeReq.raidType = ESDiskStorageModeType_Raid;
    } else {
        self.viewModel.diskInitializeReq.raidType = ESDiskStorageModeType_Normal;
    }
    
    if ([self.diskListModel hasDisk:ESDiskStorage_SSD] ) {
        ESDiskInfoModel *mainDisk = [self.diskListModel getDiskInfo:ESDiskStorage_SSD];
        [self.viewModel.diskInitializeReq.primaryStorageHwIds addObject:mainDisk.hwId];
    }
    
    if (self.viewModel.diskInitializeReq.raidType == ESDiskStorageModeType_Raid) {
        ESDiskInfoModel *disk1 = [self.diskListModel getDiskInfo:ESDiskStorage_Disk1];
        ESDiskInfoModel *disk2 = [self.diskListModel getDiskInfo:ESDiskStorage_Disk2];

        [self.viewModel.diskInitializeReq.raidDiskHwIds addObject:disk1.hwId];
        [self.viewModel.diskInitializeReq.raidDiskHwIds addObject:disk2.hwId];
        
        [self.viewModel.diskInitializeReq.secondaryStorageHwIds addObject:disk1.hwId];
        [self.viewModel.diskInitializeReq.secondaryStorageHwIds addObject:disk2.hwId];
        return;
    }
    
    if ([self.diskListModel hasDisk:ESDiskStorage_Disk1]) {
        ESDiskInfoModel *disk1 = [self.diskListModel getDiskInfo:ESDiskStorage_Disk1];
        if (self.viewModel.diskInitializeReq.primaryStorageHwIds.count > 0) {
            [self.viewModel.diskInitializeReq.secondaryStorageHwIds addObject:disk1.hwId];
        } else {
            [self.viewModel.diskInitializeReq.primaryStorageHwIds addObject:disk1.hwId];
        }
        return;
    }
    
    if ([self.diskListModel hasDisk:ESDiskStorage_Disk2]) {
        ESDiskInfoModel *disk2 = [self.diskListModel getDiskInfo:ESDiskStorage_Disk2];

        if (self.viewModel.diskInitializeReq.primaryStorageHwIds.count > 0) {
            [self.viewModel.diskInitializeReq.secondaryStorageHwIds addObject:disk2.hwId];
        } else {
            [self.viewModel.diskInitializeReq.primaryStorageHwIds addObject:disk2.hwId];
        }
        return;
    }
}

- (void)reqDiskInitProgress:(long)delay {
    if (delay <= 0) {
        [self.viewModel sendDiskInitializeProgress];
    } else {
        weakfy(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weak_self.viewModel sendDiskInitializeProgress];
        });
    }
}

- (void)viewModelDiskInitializeProgress:(ESDiskInitializeProgressResp *)response {
    if ([response isOK]) {
        ESDiskInitializeProgressModel * model = response.results;
        ESDLog(@"[系统启动] 请求初始化进度成功: %@", [model toString]);

        if (model.initialCode == ESDiskInitStatusNormal) {
            ESDLog(@"[viewModelDiskInitializeProgress] self.viewModel.paringBoxItem %@", self.viewModel.paringBoxItem);

            if (self.viewModel.paringBoxItem) {
                ESBoxItem * box = self.viewModel.paringBoxItem;
                box.diskInitStatus = ESDiskInitStatusNormal;
                [[ESBoxManager manager] saveBox:box];
                ESDLog(@"[viewModelDiskInitializeProgress] 缓存初始化状态");
            }
            
            ESDiskInitSuccessPage * ctl = [[ESDiskInitSuccessPage alloc] init];
            ctl.diskListModel = self.diskListModel;
            ctl.viewModel = self.viewModel;
            [self.navigationController pushViewController:ctl animated:NO];
            return;
        }
        
        if (model.initialCode == ESDiskInitStatusFormatting
            || model.initialCode == ESDiskInitStatusSynchronizingData) {
            [self updateProgess:model];
        } else if (model.initialCode >= ESDiskInitStatusError) {
            [self upDateDiskInitFailed:model.initialCode];
        }
    } else {
        ESDLog(@"[系统启动] 请求初始化进度失败 %@, %@", response.code, response.message);
        [self reqDiskInitProgress:5];
    }
}

- (void)updateProgess:(ESDiskInitializeProgressModel *)model {
    weakfy(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        strongfy(self);
        if (self.status != ESDeviceStartupStatusDiskIniting) {
            [self.listModule.listView reloadData];
        }
        self.status = ESDeviceStartupStatusDiskIniting;
        
        NSString * text;
        if (model.initialCode == ESDiskInitStatusFormatting) {
            text = NSLocalizedString(@"Disk initialing", @"正在进行磁盘初始化…");
        } else if (model.initialCode == ESDiskInitStatusSynchronizingData) {
            text = NSLocalizedString(@"Disk data sync", @"正在同步必要数据…");
        }
        [self.progressView setHintString:text];
        [self.progressView setProgress:(model.initialProgress / 100.0)];
        [self reqDiskInitProgress:5];
    });
}

- (void)upDateDiskInitFailed:(ESDiskInitStatus)status {
    weakfy(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        strongfy(self);
        
        self.status = ESDeviceStartupStatusDiskFailed;
                
        NSString * title;
        NSString * content;
        if (status == ESDiskInitStatusFormatError) {
            title = NSLocalizedString(@"Disk may be faulty", @"您的磁盘可能存在故障");
            // 建议您检查磁盘状况，您也可以在关机后更换新的磁盘进行磁盘初始化
            content = NSLocalizedString(@"Disk may be faulty hint", @"");
        } else if (status > ESDiskInitStatusFormatError) {
            title = NSLocalizedString(@"Disk init error", @"磁盘初始化过程发生错误");
            content = [NSString stringWithFormat:@"%@: %lu",NSLocalizedString(@"Error Num", @"错误编号"), status]; ;
        } else {
            title = NSLocalizedString(@"Disk init unknown error", @"磁盘初始化过程发生未知错误");
        }
        [self.failedView setTitle:title content:content];
        
        [self.diskListModel.diskInfos enumerateObjectsUsingBlock:^(ESDiskInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.diskInitStatus = status;
        }];
        [self.listModule.listView reloadData];
    });
}


- (Class)listModuleClass {
    return [ESDiskInitProgressModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(0, 26, kBottomHeight, 26);
}

- (void)addBackgroudProcessBt {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"binding_minimization", @"最小化")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(processBackgroud:)];
  
    [rightBarItem setTintColor:ESColor.primaryColor];
    rightBarItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)processBackgroud:(id)sender {
    [self goback2BoxlistVC];
    ESPerformBlockOnMainThreadAfterDelay(1, ^{
        [ESToast toastInfo:NSLocalizedString(@"binding_executedbackground", @"在登录页点击空间即可恢\n复此进度")];
    });
}

- (void)goback2BoxlistVC {
    __block UIViewController *vc;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ESBoxListViewController class]]) {
            vc = obj;
            *stop = YES;
        }
    }];
    if (vc != nil) {
        [self.navigationController popToViewController:vc animated:YES];
    }
}

- (ESDiskImagesView *)diskImageView {
    if (!_diskImageView) {
        ESDiskImagesView * view = [[ESDiskImagesView alloc] init];
        _diskImageView = view;
    }
    return _diskImageView;
}
- (ESDiskInitProgressView *)progressView {
    if (!_progressView) {
        ESDiskInitProgressView * view = [[ESDiskInitProgressView alloc] init];
        _progressView = view;
    }
    return _progressView;
}

- (ESESDiskInitFailedView *)failedView {
    if (!_failedView) {
        ESESDiskInitFailedView * view = [[ESESDiskInitFailedView alloc] init];
        _failedView = view;
    }
    return _failedView;
}

@end
