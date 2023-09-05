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
//  ESTerminalListCell.m
//  EulixSpace
//
//  Created by qu on 2022/5/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTerminalListCell.h"
#import "ESTryListCell.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import "ESBoxManager.h"
#import "ESCommonToolManager.h"
#import <Masonry/Masonry.h>
#import "ESTerminalAutorizationServiceApi.h"
#import "ESAccountServiceApi.h"

#import "ESCommonToolManager.h"

@interface ESTerminalListCell ()

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *dataLabel;

@property (nonatomic, strong) UILabel *stutsLabel;

@property (nonatomic, strong) UIButton *iconImageView;

@property (nonatomic, strong) UIButton *downline;


@end

@implementation ESTerminalListCell

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
        make.top.mas_equalTo(self.contentView).inset(36.0);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26.0);
        make.height.width.mas_equalTo(30);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(76);
        make.height.mas_equalTo(25.0f);
       // make.width.mas_equalTo(140.0f);
    }];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY).offset(0.0f);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(6.0);
        make.height.mas_equalTo(16);
    }];

    [self.dataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(76);
        make.height.mas_equalTo(14.0f);
        make.right.mas_equalTo(self.contentView.mas_right).inset(-105.0);
    }];

    [self.stutsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dataLabel.mas_bottom).offset(6.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(76);
        make.height.mas_equalTo(14.0f);
        make.right.mas_equalTo(self.contentView.mas_right).inset(-105.0);
    }];
    
    [self.downline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(39.0f);
        make.height.mas_equalTo(36.0f);
        make.width.mas_equalTo(100);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26.0f);
    }];
}

#pragma mark - Lazy Load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
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

- (UIButton *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIButton alloc] init];
        [_iconImageView setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        _iconImageView.hidden = YES;
        _iconImageView.layer.cornerRadius = 8;
        _iconImageView.layer.borderWidth = 1;
        _iconImageView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        _iconImageView.layer.borderColor = ESColor.primaryColor.CGColor;
        [_iconImageView sizeToFit];
        _iconImageView.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
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
        _stutsLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        [self.contentView addSubview:_stutsLabel];
    }
    return _stutsLabel;
}


- (UIButton *)downline {
    if (nil == _downline) {
        _downline = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downline.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_downline addTarget:self action:@selector(downlineClick) forControlEvents:UIControlEventTouchUpInside];
        [_downline setTitle:NSLocalizedString(@"Offline", @"下线") forState:UIControlStateNormal];
        _downline.backgroundColor = [ESColor.secondarySystemBackgroundColor colorWithAlphaComponent:1];
       // [_downline setBackgroundColor:ESColor.secondarySystemBackgroundColor forState:UIControlStateNormal];
        [_downline setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [self.contentView addSubview:_downline];
        [_downline.layer setCornerRadius:10.0]; //设置矩圆角半径
        _downline.layer.masksToBounds = YES;
        _downline.hidden = NO;
    }
    return _downline;
}

#pragma mark - Set方法
- (void)setModel:(ESAuthorizedTerminalResult *)model {
    _model = model;
    
    if([model.terminalType isEqual:@"ios"] || [model.terminalType isEqual:@"iOS"]){
        if([model.terminalModel containsString:@","]){
            NSString *titleStr =  [ESCommonToolManager judgeIphoneType:model.terminalModel];
            if(titleStr.length > 0){
                self.titleLabel.text = titleStr;
            }else{
                self.titleLabel.text = model.terminalModel;
            }
        }else{
            self.titleLabel.text = model.terminalModel;
        }
    }else{
        self.titleLabel.text = model.terminalModel;
    }
    
    self.dataLabel.text = model.terminalType;
    NSArray *array = [model.address componentsSeparatedByString:@"|"];
    NSString *city;
    for (NSString *str in array) {
        if([str containsString :@"市"]){
            city = str;
        }
    }

    if (city.length < 1) {
        city = NSLocalizedString(@"Unknown Location", @"未知地点");
    }
    self.stutsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Login_p", @"登录%@"),[self getTimeToStr:model.loginTime]];
    
    if([model.terminalType isEqual:@"web"] || [model.terminalType isEqual:@"web"]){
        self.arrowImageView.image = IMAGE_LOGIN_LIULANQI;
        self.dataLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Web", @"网页版.%@"),city];
    }else if([model.terminalType isEqual:@"ios"] || [model.terminalType isEqual:@"iOS"] ||[model.terminalModel containsString:@"iPhone"]) {
        self.arrowImageView.image = IMAGE_LOGIN_IOS;
        self.dataLabel.text = [NSString stringWithFormat:NSLocalizedString(@"iOS", @"iOS客户端.%@"),city];
    }else if([model.terminalType isEqual:@"android"] || [model.terminalType isEqual:@"Android"]){
        self.dataLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Android", @"Android客户端.%@"),city];
        self.arrowImageView.image = IMAGE_LOGIN_ANDROID;
    }else {
        self.dataLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unknown Device", @"未知设备.%@"),city];
        self.arrowImageView.image = IMAGE_LOGIN_UNKNOW;
    }

    if([model.uuid isEqual:ESBoxManager.clientUUID]){
        self.iconImageView.hidden = NO;
        [self.iconImageView setTitle:NSLocalizedString(@"Me", @"当前终端") forState:UIControlStateNormal];
        [self.iconImageView setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];

    }else{
        if([self.uuid isEqual:model.uuid]){
            self.iconImageView.hidden = NO;
            [self.iconImageView setTitle:NSLocalizedString(@"Bound Device", @"绑定设备") forState:UIControlStateNormal];
        }else{
            self.iconImageView.hidden = YES;
        }
    }
    
    if([self.uuid isEqual:model.uuid] || [model.uuid isEqual:ESBoxManager.clientUUID]){
        self.downline.hidden = YES;
    }else{
        self.downline.hidden = NO;
    }
    if( [self.type isEqual:@"head"]){
        if(ESBoxManager.activeBox.boxType == ESBoxTypeAuth){
            self.downline.hidden = YES;
        }else{
            self.downline.hidden = NO;
        }

        [self.downline setTitle:NSLocalizedString(@"box_unbind", @"解绑设备") forState:UIControlStateNormal];
        [self.downline setTitleColor:ESColor.systemBackgroundColor forState:UIControlStateNormal];
        _downline.backgroundColor = [ESColor.primaryColor colorWithAlphaComponent:1];
        self.iconImageView.hidden = YES;
    }
}

-(void)downlineClick{
    if(self.actionBlock){
        self.actionBlock(self.model);
    }
}


- (NSString *)getTimeToStr:(NSDate *)dateFormatted {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    // 这里设置自己想要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *locationTimeString=[dateFormatter stringFromDate:dateFormatted];
    return locationTimeString;
}

@end
