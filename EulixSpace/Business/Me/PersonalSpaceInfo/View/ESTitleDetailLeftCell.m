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
//  ESTitleDetailLeftCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESTitleDetailLeftCell.h"

@implementation ESTitleDetailItem

@end

@interface ESTitleDetailLeftCell ()
@property (nonatomic, strong) UIImageView *nextIcon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;


@property (nonatomic, strong) id<ESTitleDetailItemProtocol> cellModel;

@end

@implementation ESTitleDetailLeftCell

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
    [self.contentView addSubview:self.nextIcon];
    [self.nextIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView).inset(26);
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.contentView.mas_top).inset(19);
        make.left.mas_equalTo(self.contentView).inset(26);
        make.right.mas_equalTo(self.contentView).inset(58);
    }];
    
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(6);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.right.mas_equalTo(self.contentView).inset(58);
    }];
}

- (UIImageView *)nextIcon {
    if (!_nextIcon) {
        _nextIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _nextIcon.image = [UIImage imageNamed:@"file_copyback"];
    }
    return _nextIcon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = ESFontPingFangRegular(16);
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = ESColor.secondaryLabelColor;
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = ESFontPingFangRegular(16);
    }
    return _detailLabel;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESTitleDetailLeftCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(title)] &&
           [data respondsToSelector:@selector(detail)])) {
        ESDLog(@"[ESTitleDetailLeftCell] [bindData] bindData data type error");
        return;
    }
    id<ESTitleDetailItemProtocol> cellModel = (id <ESTitleDetailItemProtocol>)data;
    self.cellModel = cellModel;
    
    self.titleLabel.text = cellModel.title;
    self.detailLabel.text = cellModel.detail;
    self.nextIcon.hidden = !cellModel.hasNextStep;
}

@end
