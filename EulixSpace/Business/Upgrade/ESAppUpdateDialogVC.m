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
//  ESAppUpdateDialogVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/18.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppUpdateDialogVC.h"
#import "ESUpgradeVC.h"
#import "UIWindow+ESVisibleVC.h"

@interface ESAlertViewController ()

@property (nonatomic, strong) NSMutableArray<ESAlertAction *> *actions;

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *actionView;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, copy) NSString *message;

- (void)addMessageLabel;
- (UIButton *)buttonOfAction:(ESAlertAction *)action;
- (CGSize)sizeOfMessage:(NSString *)subtitle;

@end


@interface ESAppUpdateDialogVC ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *customHeaderView;

@end

static CGFloat const gActionHeight = 60.0;

@implementation ESAppUpdateDialogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionOrientationStyle = ESAlertActionOrientationStyleVertical;
}

- (UIView * _Nullable)headerView {
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"update_dialog_icon"];
        [_customHeaderView addSubview:_iconImageView];
        
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(97.0f);
            make.height.mas_equalTo(73.0f);
            make.centerX.equalTo(_customHeaderView.mas_centerX);
            make.top.equalTo(_customHeaderView.mas_top).offset(20.0f);
        }];
    }
    
    return _customHeaderView;
}

- (CGFloat)headerViewHeight {
    return 107;
}

- (UIEdgeInsets)contentViewContentInsets {
    return UIEdgeInsetsMake(15, 35, 11, 35);
}

- (UIEdgeInsets)actionViewContentInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)contentViewHeight {
    CGSize size = [self sizeOfMessage:self.message];
    return self.contentViewContentInsets.top  + self.contentViewContentInsets.bottom
           + 25 + 20 + size.height;
}

- (CGFloat)actionViewHeight {
    NSInteger count = self.actions.count;
    return count * gActionHeight + 1 * (count - 1) + self.actionViewContentInsets.top + self.actionViewContentInsets.bottom;
}

- (void)preAddAction {
    
}

- (void)addMessageLabel {
    [super addMessageLabel];
    CGSize size = [self sizeOfMessage:self.message];
    
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.centerX.equalTo(self.contentView);
        if (self.titleLabel) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(20.0f);
        } else {
            make.top.equalTo(self.contentView.mas_top).offset(20.0f);
        }
    }];
}

- (void)addActionButtonsWithVerticalStyle {
    UIEdgeInsets contentInsets = [self actionViewContentInsets];
    [self.actions enumerateObjectsUsingBlock:^(ESAlertAction * _Nonnull action, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= 3) {
            *stop = YES;
            return;
        }
        UIButton *button = [super buttonOfAction:action];
        button.backgroundColor = [UIColor clearColor];
        [button.titleLabel setFont:(ESFontPingFangMedium(16))];
        
        [self.actionView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.height.mas_equalTo(gActionHeight);
                 make.left.mas_equalTo(self.actionView.mas_left).offset(contentInsets.left);
                 make.right.mas_equalTo(self.actionView.mas_right).offset(- contentInsets.right);
                 make.top.mas_equalTo(self.actionView.mas_top).offset(contentInsets.top +  idx * (gActionHeight + 1) );
             }];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
        line.backgroundColor = ESColor.separatorColor;
        [self.actionView addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.height.mas_equalTo(1.0f);
                 make.left.right.mas_equalTo(self.actionView);
                 make.top.mas_equalTo(button.mas_bottom);
             }];
       }];
}


+ (void)showDialogIfNeedWithInfo:(ESSapceUpgradeInfoModel * _Nullable)info {
    if (info == nil) {
        return;
    }
    UIViewController *topVisibelVC = [UIWindow visibleViewController];
    if ([topVisibelVC isKindOfClass:[ESUpgradeVC class]]) {
        //触发安装
        if (info) {
            [(ESUpgradeVC *)topVisibelVC loadWithUpgradeInfo:info];
        }
        [(ESUpgradeVC *)topVisibelVC autoInstallSpaceSystem];
        return;
    }
    
    ESAppUpdateDialogVC *updateDialog = [ESAppUpdateDialogVC alertControllerWithTitle:NSLocalizedString(@"update_dialog_title", @"系统升级")
                                message: [NSString stringWithFormat:NSLocalizedString(@"update_dialog_detail", @"“傲空间 %@”可用于您的设备，是否现在安装？"), info.pckVersion]];
   
    updateDialog.actionOrientationStyle = ESAlertActionOrientationStyleVertical;
    
    __weak typeof(self) weakSelf = self;
    ESAlertAction *installNowAction = [ESAlertAction actionWithTitle:NSLocalizedString(@"update_dialog_bt_install_now", @"现在安装")  handler:^(ESAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        [self showSystemUpdatePage:YES upgradeInfo:info];
    }];
    installNowAction.textColor = ESColor.primaryColor;
    [updateDialog addAction:installNowAction];
    
    
    ESAlertAction *cancelAction = [ESAlertAction actionWithTitle:NSLocalizedString(@"update_dialog_bt_later", @"稍后")  handler:^(ESAlertAction * _Nonnull action) {
    }];
    cancelAction.textColor = ESColor.primaryColor;
    [updateDialog addAction:cancelAction];
    
    
    ESAlertAction *detailInfoAction = [ESAlertAction actionWithTitle:NSLocalizedString(@"update_dialog_bt_detail_info", @"详细信息")  handler:^(ESAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) self = weakSelf;
        [self showSystemUpdatePage:NO upgradeInfo:info];
    }];
    detailInfoAction.textColor = ESColor.primaryColor;
    [updateDialog addAction:detailInfoAction];
    
    [updateDialog show];
}

+ (void)showSystemUpdatePage:(BOOL)install upgradeInfo:(ESSapceUpgradeInfoModel *)info {
    ESUpgradeVC *vc = [ESUpgradeVC new];
    if (info) {
        [vc loadWithUpgradeInfo:info];
    }
    
    UIViewController *topVisibelVC = [UIWindow visibleViewController];
    if (topVisibelVC.navigationController != nil) {
        if (install) {
            [vc autoInstallSpaceSystem];
        }
        [topVisibelVC.navigationController pushViewController:vc animated:YES];
        return;
    }
    [topVisibelVC presentViewController:vc animated:YES completion:nil];
}


@end
