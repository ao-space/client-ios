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
//  ESAppletMoreOperateItemCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletMoreOperateItemCell.h"
#import <Masonry/Masonry.h>
#import "ESColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ESAppletMoreOperateViewModel.h"

@interface ESAppletMoreOperateItemCell ()

@property (nonatomic, strong) UIImageView *appletIcon;
@property (nonatomic, strong) UILabel *appletTitle;
@property (nonatomic, strong) UIImageView *redIcon;

@end

@implementation ESAppletMoreOperateItemCell

- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.appletIcon];
    
    [self.appletIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(-12.0f);
        make.height.width.mas_equalTo(50.0f);
    }];
    
    [self.contentView addSubview:self.redIcon];
    
    [self.redIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.appletIcon.mas_right);
        make.top.mas_equalTo(self.appletIcon.mas_top);
        make.height.width.mas_equalTo(8.0f);
    }];
    
    
    [self.contentView addSubview:self.appletTitle];
    
    [self.appletTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.appletIcon.mas_bottom).offset(4.0f);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
}

- (UIImageView *)appletIcon {
    if (!_appletIcon) {
        _appletIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _appletIcon;
}

- (UIImageView *)redIcon {
    if (!_redIcon) {
        _redIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _redIcon.backgroundColor = ESColor.redColor;
        _redIcon.layer.cornerRadius = 4;
        _redIcon.clipsToBounds = YES;
    }
    return _redIcon;
}


- (UILabel *)appletTitle {
    if (!_appletTitle) {
        _appletTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _appletTitle.textColor = ESColor.labelColor;
        _appletTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    }
    return _appletTitle;
}

- (void)bindViewModel:(ESAppletMoreOperateItemViewModel *)viewModel {
    self.appletIcon.image = [UIImage imageNamed:viewModel.icon];
    self.appletTitle.text = viewModel.name;
    
    if (viewModel.operateType == ESAppletOperateTypeUpdate) {
        self.redIcon.hidden = ![self haveNewVersion:viewModel];
    } else {
        self.redIcon.hidden = YES;
    }
}

- (BOOL)haveNewVersion:(ESAppletMoreOperateItemViewModel *)viewModel {
    if (viewModel.operateInfo[ESMoreOperationNewVersionKey] == nil) {
        return NO;
    }
    return [viewModel.operateInfo[ESMoreOperationNewVersionKey] boolValue];
}

@end
