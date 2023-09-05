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
//  ESDiskInfoCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskInfoCell.h"

@interface ESDiskInfoCell ()
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *switchBt;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UIView *hintView;

@property (nonatomic, strong) id<ESDiskInfoItemProtocol> cellModel;

@end

@implementation ESDiskInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    [self.contentView addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(48);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView).inset(0);
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.icon.mas_top);
        make.left.mas_equalTo(self.icon.mas_right).inset(16);
        make.right.mas_equalTo(self.contentView).inset(16);
    }];
    
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(4);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.right.mas_equalTo(self.contentView).inset(16);
    }];
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _icon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = ESFontPingFangMedium(16);
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = ESColor.secondaryLabelColor;
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = ESFontPingFangRegular(12);
    }
    return _detailLabel;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESDiskInfoCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(title)] &&
           [data respondsToSelector:@selector(detail)])) {
        ESDLog(@"[ESDiskInfoCell] [bindData] bindData data type error");
        return;
    }
    id<ESDiskInfoItemProtocol> cellModel = (id <ESDiskInfoItemProtocol>)data;
    self.cellModel = cellModel;
    
    self.titleLabel.text = cellModel.title;
    self.detailLabel.text = cellModel.detail;
    self.icon.image = [UIImage imageNamed:cellModel.iconName];
}

@end
