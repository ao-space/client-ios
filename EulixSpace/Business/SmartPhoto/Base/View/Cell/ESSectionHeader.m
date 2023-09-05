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
//  ESSectionHeader.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSectionHeader.h"
#import "UIButton+ESTouchArea.h"

@interface ESSectionHeader ()

@end

@implementation ESSectionHeader

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        self.backgroundColor = ESColor.systemBackgroundColor;
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(14.0f);
        make.right.mas_equalTo(self).offset(-14.0f);
        make.top.mas_equalTo(self).offset(20.0f);
        make.height.mas_equalTo(22.0f);
    }];
    
    [self addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(14.0f);
        make.right.mas_equalTo(self).offset(-14.0f);
        make.bottom.mas_equalTo(self).offset(- 16.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self addSubview:self.selectdBt];
    [self.selectdBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10.0f);
        make.centerY.mas_equalTo(self.subtitleLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22.0, 22.0f));
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [ESColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.font = ESFontPingFangMedium(16);
    }
    return _titleLabel;
}

- (UIButton *)selectdBt {
    if (!_selectdBt) {
        _selectdBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_selectdBt addTarget:self action:@selector(sectionSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        [_selectdBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _selectdBt;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.backgroundColor = [ESColor clearColor];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.textColor = ESColor.labelColor;
        _subtitleLabel.font = ESFontPingFangMedium(14);
    }
    return _subtitleLabel;
}

- (void)sectionSelectAction:(id)sender {
    if (self.selectBlock) {
        self.selectBlock();
    }
}

- (void)setShowStyle:(ESSectionHeaderShowStyle)showStyle {
    _showStyle = showStyle;
    switch (showStyle) {
        case ESSectionHeaderShowStyleUnSelecte: {
                [_selectdBt setImage:[UIImage imageNamed:@"pic_unselected"] forState:UIControlStateNormal];
                [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(42.0f);
                }];
                [self.subtitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(42.0f);
                }];
            _selectdBt.hidden = self.subtitleLabel.text.length <= 0;
            }
            break;
        case ESSectionHeaderShowStyleSelected: {
                [_selectdBt setImage:[UIImage imageNamed:@"pic_selected"] forState:UIControlStateNormal];
                [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(42.0f);
                }];
                [self.subtitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(42.0f);
                }];
            _selectdBt.hidden = self.subtitleLabel.text.length <= 0;
            }
            break;
        case ESSectionHeaderShowStyleNormal: {
                [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(14.0f);
                }];
                [self.subtitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(14.0f);
                }];
                _selectdBt.hidden = YES;
            }
            break;
        default:
            break;
    }
}

- (BOOL)isSelected {
    return _showStyle == ESSectionHeaderShowStyleSelected;
}
@end
