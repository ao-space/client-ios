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
//  ESNewListCell1.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNewListCell1.h"

#import "ESColor.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import <Masonry/Masonry.h>
#import "NSString+ESTool.h"

@implementation ESNewsModel

@end

@interface ESNewListCell1 ()
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UIView * mContainView;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) UILabel *mContentLabel;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic, strong) UIImageView * arrowImageView;

@end

@implementation ESNewListCell1

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ESColor.newsListBg;
    }
    
    return self;
}

- (void)setModel1:(ESNewsModel *)model1 {
    _model1 = model1;
    self.timeLabel.text = model1.timeStr;
    self.typeLabel.text = model1.typeTitle;
    self.desLabel.text = model1.desTitle;
    self.mContentLabel.text = model1.content;
    
    self.detailsLabel.hidden = (model1.onClick == nil);
    self.arrowImageView.hidden = (model1.onClick == nil);
    self.line.hidden = (model1.onClick == nil);
    
    if (model1.onClick) {
        [self.detailsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mContainView).offset(14.0);
            make.top.mas_equalTo(self.line.mas_bottom).offset(10);
            make.bottom.mas_equalTo(self.mContainView).offset(-10);
        }];
        
        [self.mContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.desLabel.mas_bottom).offset(10.0f);
            make.left.mas_equalTo(self.mContainView).offset(14);
            make.right.mas_equalTo(self.mContainView).offset(-14.0);
        }];
    } else {
        [self.detailsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mContainView).offset(14.0);
            make.top.mas_equalTo(self.line.mas_bottom).offset(10);
        }];
        
        [self.mContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.desLabel.mas_bottom).offset(10.0f);
            make.left.mas_equalTo(self.mContainView).offset(14);
            make.right.mas_equalTo(self.mContainView).offset(-14.0);
            make.bottom.mas_equalTo(self.mContainView).offset(-10);
        }];
    }
}

- (void)initUI {
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    [self.mContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-10.0);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mContainView).offset(10.0f);
        make.left.mas_equalTo(self.mContainView).offset(14);
        make.right.mas_equalTo(self.mContainView).offset(-14.0);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.typeLabel.mas_bottom).offset(10.0f);
        make.left.mas_equalTo(self.mContainView).offset(14);
        make.right.mas_equalTo(self.mContainView).offset(-14.0);
    }];

    [self.mContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.desLabel.mas_bottom).offset(10.0f);
        make.left.mas_equalTo(self.mContainView).offset(14);
        make.right.mas_equalTo(self.mContainView).offset(-14.0);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mContentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.mContainView).offset(13.0f);
        make.right.mas_equalTo(self.mContainView).offset(-13.0f);
        make.height.mas_equalTo(1);
    }];

    [self.detailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mContainView).offset(14.0);
        make.top.mas_equalTo(self.line.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.mContainView).offset(-10);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.detailsLabel);
        make.height.mas_equalTo(16.0f);
        make.width.mas_equalTo(16.0f);
        make.right.mas_equalTo(self.mContainView).offset(-12.0);
    }];
}

#pragma mark - Lazy Load
- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.textColor = ESColor.labelColor;
        _typeLabel.numberOfLines = 0;
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        [self.mContainView addSubview:_typeLabel];
    }
    return _typeLabel;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = ESColor.labelColor;
        _desLabel.numberOfLines = 0;
        _desLabel.textAlignment = NSTextAlignmentLeft;
        _desLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.mContainView addSubview:_desLabel];
    }
    return _desLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = ESColor.newsListTimeColor;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = IMAGE_ME_ARROW;
        [self.mContainView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UILabel *)mContentLabel {
    if (!_mContentLabel) {
        _mContentLabel = [[UILabel alloc] init];
        _mContentLabel.textColor = ESColor.labelColor;
        _mContentLabel.textAlignment = NSTextAlignmentLeft;
        _mContentLabel.numberOfLines = 0;
        _mContentLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.mContainView addSubview:_mContentLabel];
    }
    return _mContentLabel;
}

- (UILabel *)detailsLabel {
    if (!_detailsLabel) {
        _detailsLabel = [[UILabel alloc] init];
        _detailsLabel.textColor = ESColor.labelColor;
        _detailsLabel.textAlignment = NSTextAlignmentLeft;
        _detailsLabel.numberOfLines = 0;
        _detailsLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _detailsLabel.text = NSLocalizedString(@"view_details", @"查看详情");
        [self.mContainView addSubview:_detailsLabel];
    }
    return _detailsLabel;
}

- (UIView *)bgView {
    if (!_bgView) {
        UIView * view = [[UIView alloc] init];
        [self.contentView addSubview:view];
        _bgView = view;
    }
    return _bgView;
}

- (UIView *)mContainView {
    if (!_mContainView) {
        _mContainView = [[UIView alloc] init];
        _mContainView.backgroundColor = ESColor.systemBackgroundColor;
        _mContainView.layer.cornerRadius = 10;
        _mContainView.layer.masksToBounds = YES;
        [self.contentView addSubview:_mContainView];
    }
    return _mContainView;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self.mContainView addSubview:_line];
    }
    return _line;
}

@end

