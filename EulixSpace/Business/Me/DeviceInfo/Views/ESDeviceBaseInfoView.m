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
//  ESDeviceBaseInfoView.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeviceBaseInfoView.h"
#import "UIButton+ESStyle.h"
#import "UIImageView+ESWebImageView.h"
#import "ESBoxManager.h"
#import "ESCommonToolManager.h"
#import "NSString+ESTool.h"

@interface ESDeviceBaseInfoView ()

@property (nonatomic, strong) UIImageView *boxIcon;
@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UILabel *boxName;
@property (nonatomic, strong) UILabel *deviceBaseInfoLabel; //产品型号
@property (nonatomic, strong) UIButton *moreInfoBt;

@end

@implementation ESDeviceBaseInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self setupUI];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setupUI {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    
    [self addSubview:self.boxIcon];
    [self.boxIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(130.0f, 110.0f));
        make.left.mas_equalTo(self).inset(10.0f);
    }];
    
    [self addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.height.mas_equalTo(106);
        make.width.mas_equalTo(213);
    }];

    [self addSubview:self.boxName];
    [self.boxName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(22.0f);
        make.height.mas_equalTo(24);
        make.leading.mas_equalTo(self.boxIcon.mas_trailing).inset(19.0f);
        make.trailing.mas_equalTo(self.mas_trailing).inset(24.0f);
    }];

    [self addSubview:self.deviceBaseInfoLabel];
    [self.deviceBaseInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.boxName.mas_bottom).offset(10.0f);
        make.leading.mas_equalTo(self.boxName.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing).inset(24.0f);
    }];
    
    [self addSubview:self.moreInfoBt];
    [self.moreInfoBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deviceBaseInfoLabel.mas_bottom).offset(10.0f);
        make.height.mas_equalTo(20.0f);
        make.leading.mas_equalTo(self.boxName.mas_leading);
    }];
    
    [self layoutIfNeeded];
    [_moreInfoBt setLeftTextRightImageStyleOffset:4.0f];
}

- (void)setCornerRadius:(float)radius {
    self.layer.cornerRadius = radius;
}

- (void)loadWithDeviceInfo:(ESDeviceInfoModel *)deviceInfo {
    self.deviceBaseInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"device_base_info_detail", @"SN号：%@ \n系统版本：%@"),
//                                     ESSafeString(deviceInfo.productModel) ,
                                     ESSafeString(deviceInfo.snNumber),
                                     ESSafeString(deviceInfo.systemInfo.spaceVersion)];
    ESBoxItem *activeBox = ESBoxManager.activeBox;
    self.boxName.text = [activeBox.deviceAbilityModel boxName] ?: deviceInfo.deviceName;
    CGFloat height = [self.boxName.text es_heightFitWidth:self.boxName.frame.size.width font:self.boxName.font];
    [self.boxName mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    // 产品型号数字(内部使用, 1xx: 树莓派, 2xx: 二代, ...)
    // deviceModelNumber 不能正常返回 为一代
    if (activeBox != nil && activeBox.deviceAbilityModel == nil) {
        [ESBoxManager.manager reqDeviceAbility:^(ESDeviceAbilityModel *model) {
            if (model != nil) {
                if (activeBox.deviceAbilityModel == nil) {
                    activeBox.deviceAbilityModel = model;
                }
                [ESBoxManager.manager saveBox:activeBox];
                [self updateBoxInfo];
            }
        } fail:^(NSError *error) {
            
            //接口调用不成功， 是一代盒子
//            if (error.code == 10009) {
                activeBox.deviceAbilityModel = [ESDeviceAbilityModel new];
                activeBox.deviceAbilityModel.deviceModelNumber = 100;
                [self updateBoxInfo];
//            }
        }];
        return;
    }
       
    [self updateBoxInfo];
}

- (void)updateBoxInfo {
    ESBoxItem *activeBox = ESBoxManager.activeBox;
    self.boxName.text = [activeBox.deviceAbilityModel boxName];
    self.boxIcon.image = [activeBox.deviceAbilityModel boxIcon];
}

- (UIImageView *)boxIcon {
    if (!_boxIcon) {
        _boxIcon = [UIImageView new];
    }
    return _boxIcon;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.image = [UIImage imageNamed:@"box_space_size_bg"];
    }
    return _bgImageView;
}

- (UILabel *)boxName {
    if (!_boxName) {
        _boxName = [[UILabel alloc] init];
        _boxName.textColor = ESColor.labelColor;
        _boxName.textAlignment = NSTextAlignmentLeft;
        _boxName.lineBreakMode = NSLineBreakByCharWrapping;
        _boxName.numberOfLines = 0;
        _boxName.font = ESFontPingFangMedium(18);
    }
    return _boxName;
}

- (UILabel *)deviceBaseInfoLabel {
    if (!_deviceBaseInfoLabel) {
        _deviceBaseInfoLabel = [[UILabel alloc] init];
        _deviceBaseInfoLabel.textColor = ESColor.secondaryLabelColor;
        _deviceBaseInfoLabel.textAlignment = NSTextAlignmentLeft;
        _deviceBaseInfoLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        _deviceBaseInfoLabel.lineBreakStrategy = NSLineBreakStrategyNone;
        _deviceBaseInfoLabel.numberOfLines = 0;
        _deviceBaseInfoLabel.font = ESFontPingFangRegular(14);
    }
    return _deviceBaseInfoLabel;
}

- (UIButton *)moreInfoBt {
    if (!_moreInfoBt) {
        _moreInfoBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreInfoBt.titleLabel setFont:ESFontPingFangRegular(12)];
        [_moreInfoBt setTitleColor: ESColor.primaryColor
                     forState:UIControlStateNormal];
        [_moreInfoBt setTitle:NSLocalizedString(@"device_base_info_more_bt_title", @"更多信息")  forState:UIControlStateNormal];
        [_moreInfoBt setImage:[UIImage imageNamed:@"device_more_info"] forState:UIControlStateNormal];
        [_moreInfoBt addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _moreInfoBt;
}

- (void)clickAction:(id)sender {
    if (_moreInfoActionBlock) {
        _moreInfoActionBlock();
    }
}

@end
