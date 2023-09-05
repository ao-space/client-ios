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
//  ESDeviceStorageInfoView.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeviceStorageInfoView.h"
#import "ESCircleProgressView.h"
#import "ESFileDefine.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"


@interface ESDeviceStorageInfoView ()


@property (nonatomic, strong) ESCircleProgressView *progressView;
@property (nonatomic, strong) UILabel *usageLabel;
@property (nonatomic, strong) UILabel *usageSizeLabel;

@property (nonatomic, strong) UILabel *freeLabel;
@property (nonatomic, strong) UILabel *freeSizeLabel;


@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *totalSizeLabel;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView * horizontalLineView;
@property (nonatomic, strong) UILabel * memManageTitleLabel;

@property (nonatomic, strong) UIImageView * bgImageView;
@end

@implementation ESDeviceStorageInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self setupUI];
    return self;
}

- (void)hiddenStorageViewTitle {
    [self.memManageTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(0);
    }];
}

- (void)setCornerRadius:(float)radius {
    self.layer.cornerRadius = radius;
}

- (void)hiddenCPUMemView {
    self.horizontalLineView.hidden = YES;
    
    [self.memManageTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(16);
        make.top.mas_equalTo(self).offset(19);
    }];
}

- (void)setupUI {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    self.backgroundColor = [UIColor es_colorWithHexString:@"#F8FAFF"];
    
    UIView * lineView = [[UIView alloc] init];
    self.horizontalLineView = lineView;
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#EAEDF5"];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(self);
    }];
    
    UILabel * titleLabel = [UILabel createLabel:NSLocalizedString(@"HW_Storage_Manage", @"存储管理")
                                           font:ESFontPingFangMedium(16)
                                          color:@"#333333"];
    self.memManageTitleLabel = titleLabel;
    [self addSubview:titleLabel];
    [self.memManageTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(16);
        make.top.mas_equalTo(lineView.mas_bottom).offset(19);
    }];
    
    [self addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.mas_centerY);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(16);
        make.size.mas_equalTo(CGSizeMake(70.0f, 70.0f));
        make.left.mas_equalTo(self).inset(38.0f);
    }];
    
    [self.progressView addSubview:self.totalLabel];
    self.totalLabel.text = NSLocalizedString(@"device_storage_info_total_title", @"总容量");
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.progressView.mas_centerX);
        make.top.mas_equalTo(self.progressView.mas_top).offset(17.0f);
        make.size.mas_equalTo(CGSizeMake(30.0f, 16.0f));
    }];
    
    
    [self.progressView addSubview:self.totalSizeLabel];
    [self.totalSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.progressView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(60.0f, 20.0f));
        make.top.mas_equalTo(self.totalLabel.mas_bottom);
    }];
    
    self.freeLabel = [self newTitleLabel];
    self.freeLabel.text = NSLocalizedString(@"device_storage_info_free_title", @"未使用");
    [self addSubview:self.freeLabel];
    [self.freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.memManageTitleLabel.mas_bottom).offset(30);
        make.height.mas_equalTo(20);
        make.trailing.mas_equalTo(self.mas_trailing).inset(54.0f);
    }];

    self.freeSizeLabel = [self newSizeLabel];
    [self addSubview:self.freeSizeLabel];
    [self.freeSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.freeLabel.mas_bottom).offset(4.0f);
        make.left.mas_equalTo(self.freeLabel.mas_left);
        make.height.mas_equalTo(22.0f);
    }];
    
    
    self.usageLabel = [self newTitleLabel];
    self.usageLabel.text = NSLocalizedString(@"device_storage_info_usage_title", @"已使用");
    [self addSubview:self.usageLabel];
    [self.usageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.memManageTitleLabel.mas_bottom).offset(30);
        make.height.mas_equalTo(20);
        make.trailing.mas_equalTo(self.freeLabel.mas_leading).inset(69.0f);
    }];

    self.usageSizeLabel = [self newSizeLabel];
    [self addSubview:self.usageSizeLabel];
    [self.usageSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.usageLabel.mas_bottom).offset(4.0f);
        make.height.mas_equalTo(22.0f);
        make.leading.mas_equalTo(self.usageLabel.mas_leading);

    }];
    
    [self addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.usageLabel.mas_top).offset(4.0f);
        make.leading.mas_equalTo(self.usageLabel.mas_trailing).inset(39.0f);
        make.height.mas_equalTo(38.0f);
        make.width.mas_equalTo(1.0f);
    }];
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_storage_bg"]];
        [self addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.mas_equalTo(self);
        }];
        iv.hidden = YES;
        _bgImageView = iv;
    }
    return _bgImageView;
}

- (UILabel *)newTitleLabel {
    UILabel *newTitleLabel = [[UILabel alloc] init];
    newTitleLabel.textColor = ESColor.secondaryLabelColor;
    newTitleLabel.textAlignment = NSTextAlignmentLeft;
    newTitleLabel.font = ESFontPingFangRegular(12);
    
    return newTitleLabel;
}

- (UILabel *)newSizeLabel {
    UILabel *newSizeLabel = [[UILabel alloc] init];
    newSizeLabel.textColor = ESColor.labelColor;
    newSizeLabel.textAlignment = NSTextAlignmentLeft;
    newSizeLabel.font = ESFontPingFangMedium(18);
    
    return newSizeLabel;
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.textColor = ESColor.labelColor;
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        _totalLabel.font = ESFontPingFangMedium(10);
    }
    return _totalLabel;
}

- (UILabel *)totalSizeLabel {
    if (!_totalSizeLabel) {
        _totalSizeLabel = [[UILabel alloc] init];
        _totalSizeLabel.textColor = ESColor.labelColor;
        _totalSizeLabel.textAlignment = NSTextAlignmentCenter;
        _totalSizeLabel.font = ESFontPingFangMedium(14);
    }
    return _totalSizeLabel;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UILabel alloc] init];
        _line.backgroundColor = [ESColor colorWithHex:0xE6E8ED];
    }
    return _line;
}

- (void)loadWithDeviceInfo:(ESDeviceInfoModel *)deviceInfo {
    [self.progressView reloadWithProgress:deviceInfo.storageInfo.usageProcess];
    self.totalSizeLabel.text = FileSizeString(deviceInfo.storageInfo.totalSize, YES);
    self.usageSizeLabel.text = FileSizeString(deviceInfo.storageInfo.usagedSize, YES);
    self.freeSizeLabel.text = FileSizeString(deviceInfo.storageInfo.freeSize, YES);
    if (deviceInfo.storageInfo.title.length > 0) {
        self.memManageTitleLabel.text = deviceInfo.storageInfo.title;
    }
    self.bgImageView.hidden = !deviceInfo.storageInfo.showBgImage;
}

- (ESCircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[ESCircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
    }
    return _progressView;
}


@end
