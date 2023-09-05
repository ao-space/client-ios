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
//  ESAuthConfirmHeaderView.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthConfirmHeaderView.h"
#import <Masonry/Masonry.h>
#import "ESColor.h"
#import "ESCommonToolManager.h"
#import <SDWebImage/SDWebImage.h>

@interface ESAuthConfirmHeaderView ()

@property (nonatomic, strong) UIView *line;

@end

@implementation ESAuthConfirmHeaderView

- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setupViews {
    self.backgroundColor = ESColor.systemBackgroundColor;
   
    [self addSubview:self.appletIcon];
    
    [self.appletIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(15.0f);
        make.left.mas_equalTo(self.mas_left).offset(20.0f);
        make.height.width.mas_equalTo(26.0f);
    }];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.appletIcon.mas_right).offset(8.0f);
        make.right.mas_equalTo(self.mas_right).offset(-20.0f);
        make.centerY.mas_equalTo(self.appletIcon.mas_centerY);
    }];
    
    [self addSubview:self.desLabel];
    
    if([ESCommonToolManager isEnglish]){
        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(20.0f);
            make.right.mas_equalTo(self.mas_right).offset(-20.0f);
            make.top.mas_equalTo(self.appletIcon.mas_bottom).offset(10.0f);
        }];
    }else{
        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(20.0f);
            make.right.mas_equalTo(self.mas_right).offset(-20.0f);
            make.top.mas_equalTo(self.appletIcon.mas_bottom).offset(20.0f);
        }];
    }

    [self addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(20.0f);
        make.right.mas_equalTo(self.mas_right).offset(-20.0f);
        make.top.mas_equalTo(self.mas_bottom).offset(-1.0f);
        make.height.mas_equalTo(1.0f);
    }];
    
   
}

- (UIImageView *)appletIcon {
    if (!_appletIcon) {
        _appletIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _appletIcon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.font = ESFontPingFangMedium(14);
    }
    return _titleLabel;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _desLabel.textColor = ESColor.labelColor;
        _desLabel.numberOfLines = 0;
        _desLabel.font = ESFontPingFangMedium(16);
    }
    return _desLabel;
}


- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectZero];
        _line.backgroundColor = [ESColor colorWithHex:0xF7F7F9];
    }
    return _line;
}

- (CGFloat)contentHeight {
    return 100;
}

@end
