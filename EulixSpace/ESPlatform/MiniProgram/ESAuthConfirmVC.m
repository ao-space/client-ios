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
//  ESAuthConfirmVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthConfirmVC.h"
#import "ESAppletInfoModel.h"
#import "ESAuthConfirmHeaderView.h"
#import "ESAuthConfirmFooterView.h"
#import "ESAuthConfirmContentView.h"
#import <Masonry/Masonry.h>
#import "ESColor.h"
#import "UIImageView+ESWebImageView.h"
#import "UIViewController+ESPresent.h"
#import "ESDeviceConfigStorage.h"
#import "ESAccountInfoStorage.h"

@interface ESAuthConfirmVC ()

@property (nonatomic, strong) ESAuthConfirmHeaderView *headerView;
@property (nonatomic, strong) ESAuthConfirmContentView *contentView;
@property (nonatomic, strong) ESAuthConfirmFooterView *footerView;

@property (nonatomic, strong) ESAppletInfoModel *appletInfo;

@end

@implementation ESAuthConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupListView];
}

- (instancetype)initWithAppletInfo:(ESAppletInfoModel *)appletInfo
                    {
    if (self = [super init]) {
        _appletInfo = appletInfo;
    }
    return self;
}

- (void)setupListView {
    [self.view addSubview:self.headerView];
    
    CGFloat allContentHeight = [self.headerView contentHeight] + [self.contentView contentHeight] + [self.footerView contentHeight];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_bottom).offset(-allContentHeight);
        make.height.mas_equalTo([self.headerView contentHeight]);
    }];
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.height.mas_equalTo([self.contentView contentHeight]);
    }];
    
    [self.view addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.contentView.mas_bottom);
    }];
}

- (ESAuthConfirmContentView *)contentView {
    if (!_contentView) {
        _contentView = [[ESAuthConfirmContentView alloc] initWithFrame:CGRectZero];
        _contentView.userIcon.image = ESAccountInfoStorage.avatarImage;
        _contentView.nameLabel.text = ESAccountInfoStorage.personalName;
        _contentView.domainLabel.text = ESDeviceConfigStorage.userDomain;
    }
    return _contentView;
}


- (ESAuthConfirmHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ESAuthConfirmHeaderView alloc] initWithFrame:CGRectZero];
        _headerView.titleLabel.text = [NSString stringWithFormat:@"%@  %@", self.appletInfo.name, NSLocalizedString(@"applet_auth_confirm_dialog_title_endstring", @"申请") ];
        [_headerView.appletIcon es_setImageWithURL:self.appletInfo.iconUrl placeholderImageName:@"applet_default"];
        if (self.appletInfo.iconUrl.length > 0) {
            [self.headerView.appletIcon es_setImageWithURL:self.appletInfo.iconUrl placeholderImageName:nil];
        }
    }
    return _headerView;
}

- (void)setAuthTitle:(NSString *)authTitile {
    if (authTitile.length > 0) {
        self.headerView.desLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"applet_auth_confirm_dialog_des_prestring", @"获取你的"), authTitile];
    }
}

- (void)setAuthDetail:(NSString *)authDetail {
    self.footerView.titleLabel.text = authDetail;
}

- (ESAuthConfirmFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[ESAuthConfirmFooterView alloc] initWithFrame:CGRectZero];
        
        __weak typeof(self) weakSelf = self;
        _footerView.refuseBlock = ^(void) {
            __strong typeof(weakSelf) self = weakSelf;
            if (self.operateBlock) {
                self.operateBlock(ESAuthOperateTypeRefuse);
            }
            [self es_dismissViewControllerAnimated:YES completion:^{
            }];
        };
        
        _footerView.confirmBlock = ^(void) {
            __strong typeof(weakSelf) self = weakSelf;
            if (self.operateBlock) {
                self.operateBlock(ESAuthOperateTypeConfirm);
            }
        };
    }
    return _footerView;
}

@end

