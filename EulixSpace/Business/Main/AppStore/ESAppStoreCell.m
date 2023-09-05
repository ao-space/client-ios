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
//  ESAppStoreCell.m
//  EulixSpace
//
//  Created by qu on 2022/11/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAppStoreCell.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import "ESAppStoreModel.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface ESAppStoreCell ()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, assign) ESAppInstallStuts installStuts;

@property (nonatomic, assign) ESAppBtnTextStuts btnStutsType;

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UIImageView *headImageViewBg;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *pointOutLabel;

@property (nonatomic, strong) UIButton *stutsBtn;

@property (nonatomic, strong) UILabel *stutsLabel;


@property (nonatomic, strong) UIImageView *installingImageView;
@end

@implementation ESAppStoreCell

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
    self.backgroundColor = ESColor.secondarySystemBackgroundColor;
    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(5.0);
        make.left.mas_equalTo(self.contentView.mas_left).offset(10.0);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-10.0);
        make.height.mas_equalTo(80.0f);
    }];
    
    
    [self.headImageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(20.0);
        make.left.mas_equalTo(self.programView.mas_left).offset(20);
        make.height.width.mas_equalTo(40);
    }];

    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headImageViewBg.mas_top).offset(0.0);
        make.left.mas_equalTo(self.headImageViewBg.mas_left).offset(0);
        make.height.width.mas_equalTo(40);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(20.0f);
        make.left.mas_equalTo(self.programView.mas_left).offset(68);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.programView.mas_right).offset(-50.0);
    }];
    
    [self.pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2.0f);
        make.left.mas_equalTo(self.programView.mas_left).offset(68);
        make.height.mas_equalTo(22.0f);
        make.right.mas_equalTo(self.programView.mas_right).offset(-90.0);
    }];
    
    [self.stutsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(22.0f);
        make.right.mas_equalTo(self.programView.mas_right).offset(-20);
        make.height.mas_equalTo(36.0f);
        make.width.mas_equalTo(70.0f);
    }];
    
    [self.stutsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(32.0f);
        make.right.mas_equalTo(self.programView.mas_right).offset(-20);
        make.height.mas_equalTo(17.0f);
        make.width.mas_equalTo(48.0f);
    }];
    
    [self.installingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(32.0f);
        make.right.mas_equalTo(self.stutsLabel.mas_left).offset(-6);
        make.height.mas_equalTo(16.0f);
        make.width.mas_equalTo(16.0f);
    }];
    
}

#pragma mark - Lazy Load

-(UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] init];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        _programView.layer.cornerRadius = 10.0;
        _programView.layer.masksToBounds = YES;
        [self.contentView addSubview:_programView];
    }
    return _programView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [[UILabel alloc] init];
        _pointOutLabel.textColor = ESColor.secondaryLabelColor;
        _pointOutLabel.textAlignment = NSTextAlignmentLeft;
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.programView addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}

- (UILabel *)stutsLabel {
    if (!_stutsLabel) {
        _stutsLabel = [[UILabel alloc] init];
        _stutsLabel.textColor = ESColor.primaryColor;
        _stutsLabel.textAlignment = NSTextAlignmentLeft;
        _stutsLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [self.programView addSubview:_stutsLabel];
    }
    return _stutsLabel;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.image = [UIImage imageNamed:@"app_store_def"];
        [self.headImageViewBg addSubview:_headImageView];
    }
    return _headImageView;
}


- (UIImageView *)headImageViewBg {
    if (!_headImageViewBg) {
        _headImageViewBg = [[UIImageView alloc] init];
        _headImageViewBg.backgroundColor = ESColor.iconBg;
        _headImageViewBg.layer.cornerRadius = 6.0;
        _headImageViewBg.layer.masksToBounds = YES;
        [self.programView addSubview:_headImageViewBg];
    }
    return _headImageViewBg;
}

- (UIImageView *)installingImageView {
    if (!_installingImageView) {
        _installingImageView = [[UIImageView alloc] init];
        _installingImageView.image = [UIImage imageNamed:@"app_gengxin"];
        [self.programView addSubview:_installingImageView];
    }
    return _installingImageView;
}

- (UIButton *)stutsBtn {
    if (!_stutsBtn) {
        _stutsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 36)];
        _stutsBtn.layer.cornerRadius = 10;
        _stutsBtn.layer.masksToBounds = YES;
        _stutsBtn.backgroundColor = ESColor.tertiarySystemBackgroundColor;
        _stutsBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_stutsBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_stutsBtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self.programView addSubview:_stutsBtn];
    }
    return _stutsBtn;
}

#pragma mark - Set方法
- (void)setAppStoreModel:(ESAppStoreModel *)model {
    _appStoreModel = model;
    self.installingImageView.hidden =YES;
    self.stutsLabel.hidden =YES;
    self.stutsBtn.hidden =NO;
    if(model.stateCode == ESUNINSTALL){
        [_stutsBtn setTitle:NSLocalizedString(@"Install", @"安装") forState:UIControlStateNormal];
        self.btnStutsType = Install;
    }else if(model.stateCode == ESINSTALLED){
        if([model.curVersion isEqual:model.version]){
            [_stutsBtn setTitle:NSLocalizedString(@"Open", @"打开") forState:UIControlStateNormal];
            self.btnStutsType = Open;
        }else{
            [_stutsBtn setTitle:NSLocalizedString(@"me_upgrade", @"更新") forState:UIControlStateNormal];
            self.btnStutsType = Update;
        }
    }else if(model.stateCode == ESINSTALLING){
        _stutsBtn.hidden  = YES;
        self.installingImageView.hidden = NO;
        self.stutsLabel.hidden = NO;
        self.stutsLabel.text = NSLocalizedString(@"appstore_state_installing", @"安装中…");
        self.btnStutsType = Installing;
        [self loopBasicAnimation];
    }else if(model.stateCode == ESUPDATING){
        _stutsBtn.hidden  = YES;
        self.installingImageView.hidden = NO;
        self.stutsLabel.hidden = NO;
        self.stutsLabel.text = NSLocalizedString(@"appstore_state_updating", @"更新中…");
        self.btnStutsType = Updating;
        [self loopBasicAnimation];
    }else if(model.stateCode == ESINSTALLFAIL){
        [_stutsBtn setTitle:NSLocalizedString(@"Install", @"安装") forState:UIControlStateNormal];
        self.btnStutsType = Install;
    }else if(model.stateCode == ESUPDATEFAIL){
        [_stutsBtn setTitle:NSLocalizedString(@"me_upgrade", @"更新") forState:UIControlStateNormal];
        self.btnStutsType = Update;
    }else if(model.stateCode == ESUPGRADE){
        [_stutsBtn setTitle:NSLocalizedString(@"me_upgrade", @"更新") forState:UIControlStateNormal];
        self.btnStutsType = Update;
    }
    
    self.titleLabel.text = model.name;
    self.pointOutLabel.text = model.shortDesc;
    NSURL *imageurl = [NSURL URLWithString:model.iconUrl];
    NSData *imagedata = [NSData dataWithContentsOfURL:imageurl];
    self.headImageView.image = [UIImage imageWithData:imagedata];
}

-(void)action:(UIButton *)btn{
    if(self.appStoreModel.stateCode == ESUNINSTALL  || self.appStoreModel.stateCode == ESINSTALLFAIL){
        _stutsBtn.hidden  = YES;
        self.installingImageView.hidden = NO;
        self.stutsLabel.hidden = NO;
        self.stutsLabel.text = NSLocalizedString(@"appstore_state_installing", @"安装中…");
        self.btnStutsType = Installing;
        [self loopBasicAnimation];
    }else if([btn.titleLabel.text isEqual:NSLocalizedString(@"me_upgrade", @"更新")] ){
        _stutsBtn.hidden  = YES;
        self.installingImageView.hidden = NO;
        self.stutsLabel.hidden = NO;
        self.stutsLabel.text = NSLocalizedString(@"appstore_state_updating", @"更新中…");
        self.btnStutsType = Updating;
        [self loopBasicAnimation];
    }else if(self.appStoreModel.stateCode == ESUPDATEFAIL ){
        _stutsBtn.hidden  = YES;
        self.installingImageView.hidden = NO;
        self.stutsLabel.hidden = NO;
        self.stutsLabel.text = NSLocalizedString(@"appstore_state_updating", @"更新中…");
        self.btnStutsType = Updating;
        [self loopBasicAnimation];
    }
   
    if(_stutsBtn.hidden == NO){
        self.actionBlock(self.appStoreModel,self.stutsBtn.titleLabel.text,self.btnStutsType);
    }else{
        self.actionBlock(self.appStoreModel, self.stutsLabel.text,self.btnStutsType);
    }
}


- (void)loopBasicAnimation
{
    CABasicAnimation* rotationAnimation;

    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];

    rotationAnimation.duration = 0.8;

    rotationAnimation.cumulative = YES;

    rotationAnimation.repeatCount = ULLONG_MAX;
    
    [self.installingImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
