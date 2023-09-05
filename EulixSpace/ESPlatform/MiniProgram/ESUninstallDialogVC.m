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
//  ESUninstallAlertVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESUninstallDialogVC.h"

@interface ESUninstallDialogVC () <ESAlertVCCustomProtocol>

@property (nonatomic, strong) UIImageView *headerBackgroudImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *hintImageView;

@property (nonatomic, strong) UIView *customHeaderView;
@property (nonatomic, copy) NSString * iconImageUrl;
@end

@implementation ESUninstallDialogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionOrientationStyle = ESAlertActionOrientationStyleHorizontal;
}

- (UIView * _Nullable)headerView {
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
 
        _headerBackgroudImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_customHeaderView addSubview:self.headerBackgroudImageView];
//        _headerBackgroudImageView.image = [UIImage imageNamed:@"xiezai-1"];
        _headerBackgroudImageView.backgroundColor = ESColor.iconBg;
        _headerBackgroudImageView.layer.masksToBounds = YES;
        _headerBackgroudImageView.layer.cornerRadius = 6;
        [_headerBackgroudImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(70.0f);
            make.height.mas_equalTo(70.0f);
            make.centerX.equalTo(_customHeaderView.mas_centerX);
            make.top.equalTo(_customHeaderView.mas_top).offset(50.0f);
        }];
        
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_headerBackgroudImageView addSubview:self.iconImageView];
        [_iconImageView es_setImageWithURL:_iconImageUrl placeholderImageName:nil];

        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(70.0f);
            make.height.mas_equalTo(70.0f);
            make.centerY.equalTo(_headerBackgroudImageView.mas_centerY);
            make.centerX.equalTo(_headerBackgroudImageView.mas_centerX);
        }];
        
        _hintImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_headerBackgroudImageView addSubview:_hintImageView];
        _hintImageView.image = [UIImage imageNamed:@"app_xiezai"];
        [_hintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(20.0f);
            make.height.mas_equalTo(20.0f);
            make.right.equalTo(_headerBackgroudImageView.mas_right).offset(-5.0f);
            make.bottom.equalTo(_headerBackgroudImageView.mas_bottom).offset(-5.0f);
        }];
    }
    
    return _customHeaderView;
}

- (void)settIconImageUrl:(NSString *)url {
    _iconImageUrl = url;
    [_iconImageView es_setImageWithURL:url placeholderImageName:nil];
}

- (CGFloat)headerViewHeight {
    return 141;
}

- (UIEdgeInsets)contentViewContentInsets {
    return UIEdgeInsetsMake(12, 12, 39, 12);
}

- (UIEdgeInsets)actionViewContentInsets {
    return UIEdgeInsetsMake(0, 0, 18, 0);
}

- (void)preAddAction {
    
}

@end
