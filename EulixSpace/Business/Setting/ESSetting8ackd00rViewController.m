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
//  ESSetting8ackd00rViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSetting8ackd00rViewController.h"

#ifdef ES8ackD00r
#import "ESBoxManager.h"
#import "ESCacheCleanTools.h"
#import "ESFormCell.h"
#import "ESSetting8ackd00rItem.h"
#import "ESThemeDefine.h"
#import "ESTransferManager.h"
#import "ESLogController.h"
#import "AppDelegate.h"
#import "ESToast.h"
//#import "ESTransferResultController.h"
//#import "ESInviteTrailMemberVC.h"
#import "ESDIDDocManager.h"

@interface ESBoxManager ()

+ (void)reset;

@end

@interface ESTransferManager ()

- (void)reset;

@end

@interface ESSetting8ackd00rItem ()

@property (nonatomic, assign) ESSettingEnvType envType; //App 连接的盒子环境

- (void)save;

@end

typedef NS_ENUM(NSUInteger, ESSettingSection) {
    ESSettingSectionDefault,
};

typedef NS_ENUM(NSUInteger, ESSettingCell) {
    ESSettingCellDefault = 0,
    ESSettingCellRCTOPEnv, //prod/main 环境 ,, eulix.top
    ESSettingCellRCXYZEnv, //eulix.xyz
    ESSettingCellDevEnv,   //dev 环境
    ESSettingCellTestEnv,  //test 环境
    ESSettingCellQAEnv,    //qa 环境
    ESSettingCellSitEnv,
    
    ESSettingCellLog, // 去显示本地的log功能
    ESSettingCellClearCache, // 清楚缓存
    ESSettingCellWebViewDebug, // 查看上传下载的结果
    ESSettingCellReset = 0xff,
};

@interface ESSetting8ackd00rViewController ()

@property (nonatomic, strong) ESSetting8ackd00rItem *data;

@end

@implementation ESSetting8ackd00rViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellClass = ESFormCell.class;
    self.navigationItem.title = @"诊断模式";
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.section = @[@(ESSettingSectionDefault)];
    self.data = [ESSetting8ackd00rItem current];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSMutableArray *cellArray = NSMutableArray.array;

#ifndef APPSTORE

    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellRCTOPEnv;
        item.title = @"rc.top";
        item.showSwitch = YES;
        item.selected = self.data.envType == ESSettingEnvTypeRCTOPEnv;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellRCXYZEnv;
        item.title = @"rc.xyz";
        item.showSwitch = YES;
        item.selected = self.data.envType == ESSettingEnvTypeRCXYZEnv;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellDevEnv;
        item.title = @"dev";
        item.showSwitch = YES;
        item.selected = self.data.envType == ESSettingEnvTypeDevEnv;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTestEnv;
        item.title = @"test";
        item.showSwitch = YES;
        item.selected = self.data.envType == ESSettingEnvTypeTestEnv;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellQAEnv;
        item.title = @"qa";
        item.showSwitch = YES;
        item.selected = self.data.envType == ESSettingEnvTypeQAEnv;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellSitEnv;
        item.title = @"sit";
        item.showSwitch = YES;
        item.selected = self.data.envType == ESSettingEnvTypeSitEnv;
        [cellArray addObject:item];
    }
    
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellLog;
        item.title = @"Log日志";
        [cellArray addObject:item];
    }
    
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellClearCache;
        item.title = @"清除缓存";
        [cellArray addObject:item];
    }
    
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellWebViewDebug;
        item.title = @"WebViewDebug";
        [cellArray addObject:item];
    }
    
#endif

    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellReset;
        item.title = @"重置APP所有数据";
        item.showSwitch = YES;
        [cellArray addObject:item];
    }

    self.dataSource[@(ESSettingSectionDefault)] = cellArray;
    [self.tableView reloadData];
}

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESFormItem *item = [self objectAtIndexPath:indexPath];
    if (item.row == ESSettingCellClearCache) {
        [ESCacheCleanTools clearCacheForTest];
        [ESToast toastSuccess:TEXT_ME_ALREADY_CLEARED_CACHE];
    }
    else if (item.row == ESSettingCellLog) {
        ESLogController * ctl = [[ESLogController alloc] init];
        [self dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;

            [appDelegate.window.rootViewController presentViewController:ctl
                                                         animated:YES
                                                       completion:^{
                
            }];
        }];
    } else if (item.row == ESSettingCellWebViewDebug) {
        
        return;
    }
    
    else if (item.row == ESSettingCellReset) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:item.title
                                                                       message:@"重置后所有数据都会丢失"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *join = [UIAlertAction actionWithTitle:TEXT_OK
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action) {
                                                         [self resetAll];
                                                     }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_CANCEL
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action){
                                                       }];

        [alert addAction:cancel];
        [alert addAction:join];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (item.row >= ESSettingCellRCTOPEnv && item.row <= ESSettingCellSitEnv) {
        item.selected = !item.selected;
        if (item.selected) {
            self.data.envType = item.row;
        } else {
            self.data.envType = ESSettingEnvTypeDefault;
        }

        [self.data save];
        [self loadData];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:item.title
                                                                       message:@"重启后生效"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *gotIt = [UIAlertAction actionWithTitle:TEXT_GOT_IT
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          exit(0);
                                                      }];
        [alert addAction:gotIt];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)resetAll {
    [ESTransferManager.manager reset];
    [ESCacheCleanTools reset];
    [ESBoxManager reset];
    
    BOOL result = [[ESDIDDocManager shareInstance] resetDIDDocInfo];
    ESDLog(@"[resetAll][resetDIDDocInfo] result: %d", result);
}

@end

#endif
