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
//  ESShareListCell.m
//  EulixSpace
//
//  Created by qu on 2022/7/4.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShareListCell.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import <Masonry/Masonry.h>
#import "UIImageView+ESThumb.h"
#import "ESFileDefine.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import "UIImageView+ESThumb.h"


@interface ESShareListCell ()

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *dataLabel;

@property (nonatomic, strong) UILabel *stutsLabel;

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation ESShareListCell

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

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26.0);
        make.height.width.mas_equalTo(40);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(19.0f);
        make.left.mas_equalTo(self.arrowImageView.mas_right).offset(20);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-50.0);
    }];

    [self.dataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6.0f);
        make.left.mas_equalTo(self.arrowImageView.mas_right).offset(20);
        make.height.mas_equalTo(14.0f);
        make.right.mas_equalTo(self.contentView.mas_right).inset(-50.0);
    }];

    [self.stutsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(29.0f);
        make.height.mas_equalTo(22.0f);
        make.width.mas_equalTo(48.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-52.0);
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

-(void)setModel:(ESFileInfoPub *)model{
    self.titleLabel.text = model.name;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.createdAt.integerValue / 1000];
    NSString *time = [date stringFromFormat:@"YYYY-MM-dd HH:mm"];
    self.dataLabel.text = time;
    if (!model.isDir.boolValue && model.mime) {
        UIImage *image = IconForFile(model);
        self.arrowImageView.image = image;
        if (IsMediaForFile(model)) {
            [self.arrowImageView es_setThumbImageWithFile:model placeholder:image];
        }
    } else {
        self.arrowImageView.image = IMAGE_FILE_FOLDER;
    }
}
@end
