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
//  ESTryListCell.m
//  EulixSpace
//
//  Created by qu on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTryListCell.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import <Masonry/Masonry.h>

@interface ESTryListCell ()

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *dataLabel;

@property (nonatomic, strong) UILabel *stutsLabel;

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation ESTryListCell

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

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(19.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-50.0);
    }];

    [self.dataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26);
        make.height.mas_equalTo(14.0f);
        make.right.mas_equalTo(self.contentView.mas_right).inset(-50.0);
    }];

    [self.stutsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(29.0f);
        make.height.mas_equalTo(22.0f);
        make.width.mas_equalTo(48.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-52.0);
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
        _dataLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
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

- (UILabel *)stutsLabel {
    if (!_stutsLabel) {
        _stutsLabel = [[UILabel alloc] init];
        _stutsLabel.textColor = ESColor.secondaryLabelColor;
        _stutsLabel.textAlignment = NSTextAlignmentLeft;
        _stutsLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.contentView addSubview:_stutsLabel];
    }
    return _stutsLabel;
}
#pragma mark - Set方法
- (void)setModel:(ESQuestionnaireRes *)model {
    _model = model;
    self.titleLabel.text = model.title;
    NSString *endAt = [model.endAt stringFromFormat:@"YYYY-MM-dd"];
    NSString *startTime = [model.startAt stringFromFormat:@"YYYY-MM-dd"];
    self.arrowImageView.hidden = NO;
    self.dataLabel.text = [NSString stringWithFormat:@"请%@至%@填写", startTime, endAt];
    //completed, not_start, in_process, has_end
    if ([model.state isEqual:@"completed"]) {
        self.stutsLabel.text = @"已反馈";
        self.arrowImageView.hidden = YES;
        self.stutsLabel.textColor = ESColor.primaryColor;
    } else if ([model.state isEqual:@"not_start"]) {
        self.stutsLabel.text = @"未开始";
        self.arrowImageView.hidden = YES;
        self.stutsLabel.textColor = ESColor.disableTextColor;
    } else if ([model.state isEqual:@"in_process"]) {
        self.stutsLabel.text = @"待反馈";
        self.stutsLabel.textColor = ESColor.redColor;
    } else if ([model.state isEqual:@"has_end"]) {
        self.stutsLabel.text = @"已结束";
    } else {
        self.stutsLabel.text = @"";
    }
}

@end
