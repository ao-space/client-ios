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
//  ESBoxSearchingNotFoundView.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/19.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxSearchingNotFoundView.h"
#import "ESBoxBindDefine.h"
#import <Lottie/LOTAnimationView.h>
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>
#import "ESGradientButton.h"

@interface ESBoxSearchingNotFoundView ()

@property (nonatomic, strong) LOTAnimationView *animation;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *detailHintLabel;
@property (nonatomic, strong) UILabel *detailHint2Label;
@property (nonatomic, strong) ESGradientButton *enterSpace;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation ESBoxSearchingNotFoundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;

    [self.animation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(68);
        make.size.mas_equalTo(CGSizeMake(196, 196));
        make.centerX.mas_equalTo(self.contentView);
    }];

    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.animation.mas_bottom).inset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(25);
    }];

    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stateLabel.mas_bottom).inset(40);
        make.left.right.mas_equalTo(self.contentView).inset(40);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    
    [self.detailHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.hintLabel.mas_bottom).inset(19);
        make.left.mas_equalTo(self.contentView).inset(52);
        make.right.mas_equalTo(self.contentView).inset(40);
//        make.height.mas_greaterThanOrEqualTo(40);
    }];
    
    UIView *dot1 = [UIView new];
    dot1.backgroundColor = ESColor.primaryColor;
    dot1.layer.cornerRadius = 3.0f;

    [self addSubview:dot1];
    [dot1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailHintLabel.mas_top).inset(8);
        make.right.mas_equalTo(self.detailHintLabel.mas_left).inset(6);
        make.height.width.mas_equalTo(6);
    }];
    
    [self.detailHint2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailHintLabel.mas_bottom).inset(30);
        make.left.mas_equalTo(self.contentView).inset(52);
        make.right.mas_equalTo(self.contentView).inset(40);
//        make.height.mas_greaterThanOrEqualTo(40);
    }];
    
    UIView *dot2 = [UIView new];
    dot2.backgroundColor = ESColor.primaryColor;
    dot2.layer.cornerRadius = 3.0f;
    [self addSubview:dot2];
    [dot2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailHint2Label.mas_top).inset(8);
        make.right.mas_equalTo(self.detailHint2Label.mas_left).inset(6);
        make.height.width.mas_equalTo(6);
    }];
    [self addSubview:self.enterSpace];
    [_enterSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).inset(60);
    }];
}


#pragma mark - Lazy Load

- (LOTAnimationView *)animation {
    if (!_animation) {
        _animation = [LOTAnimationView animationNamed:@"scaning"];
        _animation.loopAnimation = YES;
        [self addSubview:_animation];
    }
    return _animation;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _contentView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.textColor = ESColor.labelColor;
        _stateLabel.font = ESFontPingFangMedium(18);
        _stateLabel.text = NSLocalizedString(@"box_bind_not_found", @"未发现设备");
        [self.contentView addSubview:_stateLabel];
    }
    return _stateLabel;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.textAlignment = NSTextAlignmentLeft;
        _hintLabel.textColor = ESColor.labelColor;
        _hintLabel.font = ESFontPingFangMedium(16);
        _hintLabel.text = NSLocalizedString(@"binding_checkBluetooth1", @"请检查：");
        [self.contentView addSubview:_hintLabel];
    }
    return _hintLabel;
}

- (UILabel *)detailHintLabel {
    if (!_detailHintLabel) {
        _detailHintLabel = [[UILabel alloc] init];
        _detailHintLabel.textColor = ESColor.labelColor;
        _detailHintLabel.textAlignment = NSTextAlignmentLeft;
        _detailHintLabel.font = ESFontPingFangMedium(14);
        _detailHintLabel.numberOfLines = 0;
        _detailHintLabel.text = NSLocalizedString(@"es_device_is_power_on", @"设备是否已接通电源");
        [self.contentView addSubview:_detailHintLabel];
    }
    return _detailHintLabel;
}

- (UILabel *)detailHint2Label {
    if (!_detailHint2Label) {
        _detailHint2Label = [[UILabel alloc] init];
        _detailHint2Label.textColor = ESColor.labelColor;
        _detailHint2Label.textAlignment = NSTextAlignmentLeft;
        _detailHint2Label.font = ESFontPingFangMedium(14);
        _detailHint2Label.numberOfLines = 0;
        _detailHint2Label.text = NSLocalizedString(@"es_iphone_device_are_same_net", @"手机与设备是否在同一局域网内");
        [self.contentView addSubview:_detailHint2Label];
    }
    return _detailHint2Label;
}

- (ESGradientButton *)enterSpace {
    if (!_enterSpace) {
        _enterSpace = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_enterSpace setCornerRadius:10];
        [_enterSpace setTitle:NSLocalizedString(@"Search Again", @"重新搜索") forState:UIControlStateNormal];
        _enterSpace.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_enterSpace setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_enterSpace setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [_enterSpace addTarget:self action:@selector(searchAgin) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterSpace;
}

- (void)searchAgin {
    if (self.searchAginBlock) {
        self.searchAginBlock();
    }
}
@end
