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
//  ESBoxBindInfoCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/14.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxBindInfoCell.h"
#import "ESBCResult.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>
#import "ESBoxManager.h"

@interface ESBoxBindInfoCell ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *snLabel;

@property (nonatomic, strong) UILabel *desc;

@property (nonatomic, strong) ESGradientButton *bindBox;

@property (nonatomic, strong) UIImageView *boxIcon;

@end

@implementation ESBoxBindInfoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.contentView.backgroundColor = ESColor.tertiarySystemBackgroundColor;
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).inset(30);
        make.height.mas_equalTo(22);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];
    
    [self.snLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(20);
        make.height.mas_equalTo(18);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];
    
    [self.boxIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.snLabel.mas_bottom).inset(20);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(110);
    }];

    [self.desc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.boxIcon.mas_bottom).inset(10);
        make.height.mas_equalTo(40);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];

    [self.bindBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).inset(30);
        make.centerX.mas_equalTo(self.contentView);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(244);
    }];
}

- (void)reloadWithData:(ESBindInitResultModel *)model {
    self.title.text = model.deviceAbility != nil ? [model.deviceAbility boxName] : model.boxName;

    self.desc.text = nil;
    if (!model.unpaired && model.deviceAbility.openSource) {
        self.desc.text = TEXT_BOX_ALREADY_BINDED_PROMPT;
    }
    
    [self.bindBox stopLoading: NSLocalizedString(@"bind_box_bt_title", @"绑定") ];
    self.bindBox.enabled = YES;
    // 产品型号数字(内部使用, 1xx: 树莓派, 2xx: 二代, ...)
    self.boxIcon.image = model.deviceAbility != nil ? [model.deviceAbility boxIcon] : [UIImage imageNamed:@"box_info_v2_logo"];
}

- (void)setCannotBind {
    [self.bindBox stopLoading: NSLocalizedString(@"es_cannot_bind", @"无法绑定") ];
    self.bindBox.enabled = NO;
    self.desc.text = nil;
}

- (void)reloadSN:(NSString *)sn {
    self.snLabel.text = sn.length > 0 ? [NSString stringWithFormat:@"SN: %@", sn] : @"";
}

- (void)action:(UIButton *)sender {
    if (sender == self.bindBox) {
        //[self.bindBox startLoading:TEXT_BOX_BIND_ONGOING];
    }
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

#pragma mark - Lazy Load

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.numberOfLines = 0;
        _title.font = ESFontPingFangMedium(18);
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)snLabel {
    if (!_snLabel) {
        _snLabel = [[UILabel alloc] init];
        _snLabel.textColor = ESColor.labelColor;
        _snLabel.textAlignment = NSTextAlignmentCenter;
        _snLabel.font = ESFontPingFangRegular(14);
        _snLabel.numberOfLines = 0;
        [self.contentView addSubview:_snLabel];
    }
    return _snLabel;
}

- (UIImageView *)boxIcon {
    if (!_boxIcon) {
        _boxIcon = [UIImageView new];
        _boxIcon.image = [UIImage imageNamed:@"box_info_v1_logo"];
        [self.contentView addSubview:_boxIcon];
    }
    return _boxIcon;
}

- (UILabel *)desc {
    if (!_desc) {
        _desc = [[UILabel alloc] init];
        _desc.textColor = ESColor.primaryColor;
        _desc.textAlignment = NSTextAlignmentLeft;
        _desc.font = ESFontPingFangRegular(12);
        _desc.numberOfLines = 0;
        [self.contentView addSubview:_desc];
    }
    return _desc;
}

- (ESGradientButton *)bindBox {
    if (!_bindBox) {
        _bindBox = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 244, 44)];
        [_bindBox setCornerRadius:10];
        _bindBox.tag = ESBoxBindActionConfirm;
        [_bindBox setTitle:TEXT_BOX_BIND_CONFIRM forState:UIControlStateNormal];
        _bindBox.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_bindBox setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.contentView addSubview:_bindBox];
        [_bindBox addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindBox;
}

@end
