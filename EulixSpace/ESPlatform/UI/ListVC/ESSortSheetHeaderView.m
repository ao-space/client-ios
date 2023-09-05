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
//  ESSortSheetHeaderView.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSortSheetHeaderView.h"
#import "UIButton+ESTouchArea.h"

@interface ESSortSheetHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelBt;

@end


@implementation ESSortSheetHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = ESColor.systemBackgroundColor;
    [self addSubview:self.cancelBt];
    [self addSubview:self.titleLabel];
    
    [self.cancelBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).inset(20.0f);
        make.top.mas_equalTo(self.mas_top).inset(20.0f);
        make.width.mas_equalTo(18.0f);
        make.height.mas_equalTo(18.0f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(20.0f);
        make.leading.mas_equalTo(self.mas_leading).inset(58.0f);
        make.trailing.mas_equalTo(self.mas_trailing).inset(58.0f);
        make.height.mas_equalTo(25.0f);
    }];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (UIButton *)cancelBt {
    if (!_cancelBt) {
        _cancelBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBt addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBt setBackgroundImage:[UIImage imageNamed:@"sort_menu_cancel"] forState:UIControlStateNormal];
        [_cancelBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _cancelBt;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = ESFontPingFangMedium(18);
    }
    return _titleLabel;
}

- (void)cancelAction:(id)sender {
    if (self.cancelActionBlock) {
        self.cancelActionBlock();
    }
}

@end
