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
//  ESAppletViewController+ESOperate.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletViewController+ESOperate.h"
#import "ESUninstallDialogVC.h"
#import "ESUpdateDialogVC.h"
#import "ESGradientUtil.h"
#import "ESToast.h"
#import "ESAppletManager.h"
#import "UIViewController+ESPresent.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESAppletManager+ESCache.h"
#import "ESOperateFailDialogVC.h"
#import "ESNetworkRequestManager.h"
#import "ESWebDataManager.h"
#import "ESCommonToolManager.h"
#import "ESAppStoreModel.h"
#import "ESCache.h"

@interface ESAppletViewController ()

@property (nonatomic, strong) ESAppletInfoModel* appletInfo;

@property (nonatomic, strong) ESAppStoreModel* appStoreModel;

@property (nonatomic, assign) BOOL isNewVersion;
@property (nonatomic, assign) BOOL isUnInstall;

@property (nonatomic, weak) ESAppletMoreOperateVC *moreOperateVC;
@property (nonatomic, strong) WKWebView *webView;

- (void)closeApplet;

- (void)settingApplet;

- (void)closeAppletAndPostNotificationInfoChanged;

@end

@implementation ESAppletViewController (ESOperate)

- (void)tryShowUpdateDialog {
    if ([self needShowUpdateDialog]) {
        [self showUpdateDiaglog];
        self.appletInfo.context.shownedUpdateDialog = YES;
    }
}

- (BOOL)needShowUpdateDialog {
    if (self.appletInfo.isForceUpdate) {
        return [self.appletInfo hasNewVersion];
    }
    
    return [self.appletInfo hasNewVersion] && !self.appletInfo.context.shownedUpdateDialog;
}

- (void)moreOperateVC:(ESAppletMoreOperateVC *)vc  operateType:(ESAppletOperateType)operateType {
    if (self.moreOperateVC) {
        [self.moreOperateVC es_dismissViewControllerAnimated:YES completion:nil];
        self.moreOperateVC = nil;
    }
    
    if (operateType == ESAppletOperateTypeUpdate) {
        if (![self.appletInfo hasNewVersion]) {
            [ESToast toastInDarkStyleInfo:NSLocalizedString(@"already_the_latest_version", @"已经是最新版本")];
            return;
        }
        [self showUpdateDiaglog];
        return;
    }
    
    if (operateType == ESAppletOperateTypeUninstall) {
        [self showUninstallDialog];
        return;
    }
    
    if (operateType == ESAppletOperateTypeClose) {
        [self closeApplet];
        return;
    }
    
    if (operateType == ESAppletOperateTypeSetting) {
        [self settingApplet];
        return;
    }
}

- (void)showUpdateDiaglog {
    ESUpdateDialogVC *alertVC = [ESUpdateDialogVC alertControllerWithTitle:NSLocalizedString(@"applet_update_dialog_update_title", @"发现新版本")
                                                                   message:NSLocalizedString(@"applet_update_dialog_update_des", @"发现新版本，是否更新应用？")];
    alertVC.actionOrientationStyle = ESAlertActionOrientationStyleHorizontal;
    [alertVC settIconImageUrl:self.appletInfo.iconUrl];
 
    __weak typeof(self) weakSelf = self;
    ESAlertAction *updateAction = [ESAlertAction actionWithTitle:NSLocalizedString(@"applet_update_dialog_update_bt_title", @"立即更新") handler:^(ESAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        [self closeApplet];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"applet_update_dialog_update" object:self.appletInfo.appletId userInfo:nil];
     //   [self updateApplet];
    }];
    updateAction.textColor = ESColor.primaryColor;
    updateAction.backgroudImage = self.gradientImage;
    [alertVC addAction:updateAction];

    
    if (self.appletInfo.isForceUpdate) {
        ESAlertAction *cancelAction = [ESAlertAction actionWithTitle: NSLocalizedString(@"applet_update_dialog_goback", @"退出")  handler:^(ESAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) self = weakSelf;
            [self closeApplet];
        }];
        cancelAction.textColor = ESColor.secondaryLabelColor;
        [alertVC addAction:cancelAction];
    } else {
        ESAlertAction *cancelAction = [ESAlertAction actionWithTitle:NSLocalizedString(@"applet_update_dialog_update_late", @"以后再说") handler:^(ESAlertAction * _Nonnull action) {
        }];
        cancelAction.textColor = ESColor.primaryColor;
        [alertVC addAction:cancelAction];
    }
    [alertVC show];
}

- (void)showUpdateFailDiaglog {
    ESOperateFailDialogVC *alertVC = [ESOperateFailDialogVC alertControllerWithTitle:NSLocalizedString(@"applet_dialog_fail_update_title", @"更新失败")
                                                                   message:NSLocalizedString(@"applet_dialog_fail_message", @"原因：傲空间系统版本过低")];
    alertVC.actionOrientationStyle = ESAlertActionOrientationStyleVertical;
    [alertVC settIconImageUrl:self.appletInfo.iconUrl];
 
    ESAlertAction *okAction = [ESAlertAction actionWithTitle:NSLocalizedString(@"applet_update_dialog_fail_bt_title", @"确定") handler:^(ESAlertAction * _Nonnull action) {
    }];
    okAction.textColor = ESColor.lightTextColor;
    okAction.backgroudImage = self.gradientImage;
    [alertVC addAction:okAction];
    [alertVC show];
}

- (void)showUninstallDialog {
    __weak typeof(self) weakSelf = self;
    ESUninstallDialogVC * alertVC = [ESUninstallDialogVC alertControllerWithTitle:[NSString        stringWithFormat:NSLocalizedString(@"applet_uninstall_dialog_title",@"是否卸载%@？"), self.appletInfo.name]
                                                                          message: [NSString stringWithFormat:  NSLocalizedString(@"applet_uninstall_dialog_des", @"卸载“%@”，其数据不会被清除"), self.appletInfo.name]];
    [alertVC settIconImageUrl:self.appletInfo.iconUrl];
    
    [alertVC addAction:[ESAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消") handler:^(ESAlertAction * _Nonnull action) {
    }]];
    

    ESAlertAction *uninstallAction = [ESAlertAction actionWithTitle:NSLocalizedString(@"applet_uninstall_bt_title", @"卸载")  handler:^(ESAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        [self uninstallApplet];
    }];
    uninstallAction.textColor = ESColor.primaryColor;
    [alertVC addAction:uninstallAction];
    [alertVC show];
}


- (UIImage *)gradientImage {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id)([ESColor colorWithHex:0x337AFF].CGColor)];
    [array addObject:(id)([ESColor colorWithHex:0x16B9FF].CGColor)];
    return [ESGradientUtil gradientImageWithCGColors:array rect:CGRectMake(0, 0, 200, 44)];
}

- (void)updateApplet {
    ESToast.waiting(NSLocalizedString(@"waiting_operate", @"请稍后")).delay(60).showFrom(UIWindow.keyWindow);
    __weak typeof(self) weakSelf = self;
    [ESAppletManager.shared updateAppletWithId:self.appletInfo.appletId
                                     packageId:self.appletInfo.packageId
                               completionBlock:^(BOOL success, ESAppletOperateType operateTyp ,NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        [ESToast dismiss];
        if (error) {
            if ([error.userInfo[ESNetworkErrorUserInfoResposeCodeKey] isEqual:ESNetworkErrorSystemNeedUpdateCode]) {
                [self showUpdateFailDiaglog];
                return;
            }
            [ESToast toastError:NSLocalizedString(@"applet_update_fail" ,@"更新失败")];
            return;
        }
        [ESToast toastSuccess:NSLocalizedString(@"applet_update_success",@"更新成功")];
        self.appletInfo.installedAppletVersion = self.appletInfo.appletVersion;
        [ESAppletManager.shared removeAppletCacheWithId:self.appletInfo.appletId];
        
        [ESAppletManager.shared downAppletWithId:self.appletInfo.appletId
                                   appletVersion:self.appletInfo.installedAppletVersion
                                 completionBlock:^(BOOL success, ESAppletOperateType operateTyp, NSError * _Nullable error) {
            if (success) {
                [self loadWithAppletInfo:self.appletInfo];
                return;
            }
            [ESToast toastError:NSLocalizedString(@"applet_load_fail", @"加载失败")];
            return;
        }];
        [self closeAppletAndPostNotificationInfoChanged];
        
    }];
}
- (void)uninstallApplet {
    ESToast.waiting(NSLocalizedString(@"waiting_operate", @"请稍后")).delay(60).showFrom(UIWindow.keyWindow);
    
    __weak typeof(self) weakSelf = self;
    [ESAppletManager.shared uninstallAppletWithId:self.appletInfo.appletId
                                  completionBlock:^(BOOL success, ESAppletOperateType operateTyp ,NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        [ESToast dismiss];
        if (error) {
            [ESToast toastError:NSLocalizedString(@"applet_uninstall_fail", @"卸载失败")];
        } else {
            [ESToast toastSuccess:NSLocalizedString(@"applet_uninstall_success", @"卸载成功")];
            self.appletInfo.context.isInstalled = NO;
            [ESAppletManager.shared removeAppletCacheWithId:self.appletInfo.appletId];
            
            NSDictionary *dicApp = [[ESCache defaultCache] objectForKey:@"v2_app_sel_status"];
            NSMutableDictionary *dicMutable = [NSMutableDictionary dictionaryWithDictionary:dicApp];
            NSString *key = [ESCommonToolManager miniAppKey:self.appletInfo.appletId];
            [dicMutable setObject:@"NO" forKey:key];
            [[ESCache defaultCache] setObject:dicMutable forKey:@"v2_app_sel_status"];
        
            NSString *jsClearStorage = @"localStorage.clear()";
            [self.webView evaluateJavaScript:jsClearStorage completionHandler:^(id _Nullable re, NSError * _Nullable error) {
                self.appletInfo.isUnInstalled = YES;
                [self closeAppletAndPostNotificationInfoChanged];
            }];

        }
    }];
}

@end
