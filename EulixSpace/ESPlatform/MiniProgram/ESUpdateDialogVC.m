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
//  ESUpdateDialogVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESUpdateDialogVC.h"

@interface ESUpdateDialogVC () <ESAlertVCCustomProtocol>

@property (nonatomic, strong) UIImageView *headerBackgroudImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *hintImageView;
@property (nonatomic, copy) NSString * iconImageUrl;

@property (nonatomic, strong) UIView *customHeaderView;

@end

@implementation ESUpdateDialogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionOrientationStyle = ESAlertActionOrientationStyleHorizontal;
}

- (UIView * _Nullable)headerView {
    if (!_customHeaderView) {
        _customHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _headerBackgroudImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_customHeaderView addSubview:self.headerBackgroudImageView];
        _headerBackgroudImageView.image = [UIImage imageNamed:@"gengxin-1"];
        [_headerBackgroudImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(97.0f);
            make.height.mas_equalTo(73.0f);
            make.centerX.equalTo(_customHeaderView.mas_centerX);
            make.top.equalTo(_customHeaderView.mas_top).offset(20.0f);
        }];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_headerBackgroudImageView addSubview:self.iconImageView];
        [_iconImageView es_setImageWithURL:_iconImageUrl placeholderImageName:nil];

        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60.0f);
            make.height.mas_equalTo(60.0f);
            make.centerX.equalTo(_headerBackgroudImageView.mas_centerX).offset(4.5f);
            make.bottom.equalTo(_headerBackgroudImageView.mas_bottom).offset(-7.0f);
        }];
        
        _hintImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_headerBackgroudImageView addSubview:_hintImageView];
        _hintImageView.image = [UIImage imageNamed:@"update_hint"];
        [_hintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(25.0f);
            make.height.mas_equalTo(25.0f);
            make.right.equalTo(_headerBackgroudImageView.mas_right).offset(-11.5f);
            make.bottom.equalTo(_headerBackgroudImageView.mas_bottom).offset(-1.0f);
        }];
    }
    
    return _customHeaderView;
}

- (void)settIconImageUrl:(NSString *)url {
    _iconImageUrl = url;
    [_iconImageView es_setImageWithURL:url placeholderImageName:nil];
}

- (CGFloat)headerViewHeight {
    return 93;
}

- (UIEdgeInsets)contentViewContentInsets {
    return UIEdgeInsetsMake(0, 12, 40, 12);
}

- (UIEdgeInsets)actionViewContentInsets {
    return UIEdgeInsetsMake(0, 35, 18, 35);
}

- (void)preAddAction {
    
}

@end
