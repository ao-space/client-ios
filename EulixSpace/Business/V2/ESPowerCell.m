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
//  ESPowerCell.m
//  EulixSpace
//
//  Created by qu on 2022/12/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPowerCell.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import <Masonry/Masonry.h>

@interface ESPowerCell ()


@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *dataLabel;

@property (nonatomic, strong) UILabel *stutsLabel;

@property (nonatomic, strong) UIImageView *iconImageView;
@end

@implementation ESPowerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;


    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(19.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26);
        make.height.width.mas_equalTo(16.0f);
     
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(16.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(52);
        make.right.mas_equalTo(self.contentView.mas_right).inset(-50.0);
    }];

    [self.dataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(52);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-50.0);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(32.0);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26.0);
        make.height.width.mas_equalTo(16);
    }];
}

#pragma mark - Lazy Load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)dataLabel {
    if (!_dataLabel) {
        _dataLabel = [[UILabel alloc] init];
        _dataLabel.textColor = ESColor.secondaryLabelColor;
        _dataLabel.textAlignment = NSTextAlignmentLeft;
        _dataLabel.numberOfLines = 0;
        _dataLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:_dataLabel];
    }
    return _dataLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = IMAGE_ME_ARROW;
        [self.contentView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}


#pragma mark - Set方法
- (void)setModel:(ESCellModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    self.iconImageView.image = [UIImage imageNamed:model.imageName];
    self.dataLabel.text = model.placeholderValue;
}

@end
