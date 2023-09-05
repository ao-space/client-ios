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
//  ESAutoErrorView.m
//  EulixSpace
//
//  Created by qu on 2022/6/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAutoErrorView.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>
#import "ESAutoErrorView.h"
#import "ESGradientButton.h"
#import "ESShareApi.h"

@interface ESAutoErrorView()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *goLoginLabel;

@property (nonatomic, strong) ESGradientButton *compleBtn;

@property (nonatomic, strong) UIButton *hyalineLabelBtn;


@end

@implementation ESAutoErrorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.programView.hidden = hidden;
}

///  返回
- (void)returnBtnClick:(UIButton *)returnBtn {
    self.hidden = YES;
}


- (void)initUI {
    
    self.programView.contentMode = UIViewContentModeScaleAspectFit;
    self.programView.layer.cornerRadius = 10;
    self.programView.layer.masksToBounds = YES;
    
    self.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
    [self.programView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@(270));
        make.height.equalTo(@(356));
    }];

    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(20.0f);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(97.0f);
        make.height.mas_equalTo(73.0f);
    }];
    
    [self.goLoginLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.equalTo(self.programView.mas_top).offset(105.0f);
        make.width.equalTo(@(72.0f));
        make.height.equalTo(@(25.0f));
    }];

    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.programView.mas_right).offset(-20.0f);
        make.top.equalTo(self.programView.mas_top).offset(146.0f);
        make.width.equalTo(@(212.0f));
        make.height.equalTo(@(64.0f));
    }];
    
    
    [self.compleBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.equalTo(self.programView.mas_top).offset(284.0f);
        make.width.equalTo(@(200.0f));
        make.height.equalTo(@(44.0f));
    }];
    
    [self.hyalineLabelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.programView.mas_right).offset(-35.0f);
        make.top.equalTo(self.programView.mas_top).offset(146.0 + 20.0);
        make.width.equalTo(@(115.0f));
        make.height.equalTo(@(44.0f));
    }];

}

-(void)titleTapShre{
   // self.promptImageView.hidden = NO;
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 400, ScreenWidth, 300 + 100)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_programView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _programView.bounds;
        maskLayer.path = maskPath.CGPath;
        _programView.layer.mask = maskLayer;
        [self addSubview:_programView];
    }
    return _programView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 3;
   
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        NSString *part1 = NSLocalizedString(@"login_expire_content_part_1", @"您的登录已失效，此空间将不再允许访问。您可点击");
        NSString *part2 = NSLocalizedString(@"login_expire_content_part_2", @"再次进行扫码登录。");
        NSString *part3 = NSLocalizedString(@"login_expire_content_part_3", @"请在绑定手机上确定登");
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@%@%@",part1,part2,part3]];
           //2.1修改富文本中的不同文字的样式1

        [attributedString addAttribute:NSForegroundColorAttributeName value:[ESColor primaryColor] range:NSMakeRange(part1.length, part2.length)];//字体颜色
        _titleLabel.attributedText = attributedString;
    
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)goLoginLabel {
    if (!_goLoginLabel) {
        _goLoginLabel = [[UILabel alloc] init];
        _goLoginLabel.textColor = ESColor.labelColor;
        _goLoginLabel.textAlignment = NSTextAlignmentCenter;
        _goLoginLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _goLoginLabel.text = NSLocalizedString(@"login_expire", @"登录失效");
        [self.programView addSubview:_goLoginLabel];
    }
    return _goLoginLabel;
}


-(void)compleBtnClick{
    if (self.actionCompleBlock) {
        self.actionCompleBlock(self.item);
    }
    self.hidden = YES;
}


- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        [self.programView addSubview:_headImageView];
        _headImageView.image = IMAGE_LOGIN_EFFICACY;
    }
    return _headImageView;
}


- (ESGradientButton *)compleBtn {
    if (!_compleBtn) {
        _compleBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_compleBtn setCornerRadius:10];
        [_compleBtn setTitle:TEXT_OK forState:UIControlStateNormal];
        _compleBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_compleBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.programView addSubview:_compleBtn];
        [_compleBtn addTarget:self action:@selector(compleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _compleBtn;
}

- (UIButton *)hyalineLabelBtn {
    if (!_hyalineLabelBtn) {
        _hyalineLabelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
        [self.programView addSubview:_hyalineLabelBtn];
        [_hyalineLabelBtn addTarget:self action:@selector(hyalineLabelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hyalineLabelBtn;
}


-(void)hyalineLabelBtnClick{
    if (self.actionBlock) {
        self.actionBlock(self.item);
    }
    self.hidden = YES;
}

@end





