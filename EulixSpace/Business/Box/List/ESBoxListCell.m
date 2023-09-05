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
//  ESBoxListCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxListCell.h"
#import "ESAccountManager.h"
#import "ESBoxManager.h"
#import "ESLocalPath.h"
#import "ESMemberManager.h"
#import "ESAccountManager.h"
#import "NSDate+Format.h"
#import "ESGatewayManager.h"
#import "ESAccountServiceApi.h"
#import "UIButton+ESTouchArea.h"
#import "ESCommonToolManager.h"
#import "UIImage+ESTool.h"


@interface ESBoxListCell ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIImageView *adminImageView;
@property (nonatomic, strong) UIImageView *cellBgImageView;
@property (nonatomic, strong) UIImageView *cellFlagImageView;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *userDomain;
@property (nonatomic, strong) UILabel *pointOutLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIView *stateView;
@property (nonatomic, strong) UIButton *mySelfBtn;
@property (nonatomic, strong) UIButton *deviceStatusBtn;
@property (nonatomic, strong) UIImageView * diskUnInitIv;

@end

@implementation ESBoxListCell

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
    self.backView.backgroundColor = ESColor.tertiarySystemBackgroundColor;
    self.backView.layer.cornerRadius = 10;
    self.backView.layer.masksToBounds = YES;

    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(0.0);
        make.right.mas_equalTo(self.mas_right).offset(0.0);
        make.top.mas_equalTo(self.contentView.mas_top).offset(0.0);
        make.height.width.mas_equalTo(100);
    }];

    self.iconImageView.layer.cornerRadius = 25;
    self.iconImageView.layer.masksToBounds = YES;

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView).inset(15.0);
        make.top.mas_equalTo(self.backView.mas_top).inset(25.0);
        make.height.width.mas_equalTo(50);
    }];

    [self.cellBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.backView.mas_right).offset(0.0);
        make.top.mas_equalTo(self.backView.mas_top).offset(0.0);
        make.height.mas_equalTo(120);
        make.width.mas_equalTo(140);
    }];
    
    [self.cellFlagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.backView.mas_right).offset(-20.0);
        make.top.mas_equalTo(self.backView.mas_top).offset(10.0);
        make.height.mas_equalTo(34.0f);
        make.width.mas_equalTo(84.0f);
    }];
    
    [self.stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.right.mas_equalTo(self.backView.mas_right).offset(-56);
        make.width.height.mas_equalTo(8);
    }];

    if (self.mySelfBtn.hidden) {
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(27);
            make.left.mas_equalTo(self.iconImageView.mas_right).offset(20);
            make.right.mas_equalTo(self.stateView.mas_left).offset(-16);
            make.height.mas_equalTo(25);
        }];
    } else {
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(20);
            make.left.mas_equalTo(self.iconImageView.mas_right).offset(20);
            make.height.mas_equalTo(25);
        }];

        [self.mySelfBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.name.mas_centerY);
            make.left.mas_equalTo(self.name.mas_right).offset(6);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(30);
        }];
    }
    /*
      优化项：显示userDomain 存在于成员列表和登陆列表
     */
    [self.userDomain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name.mas_bottom).inset(4);
        make.left.mas_equalTo(self.name.mas_left);
        make.right.mas_equalTo(self.name.mas_right);
        make.height.mas_equalTo(17);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26.0);
        make.height.width.mas_equalTo(16);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.left.mas_equalTo(self.stateView.mas_right).offset(6);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self.backView.mas_right).offset(5);
    }];
    
    [self.adminImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.iconImageView.mas_bottom).offset(-2);
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(-12);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];
}
/// 登录列表
- (void)reloadWithData:(ESBoxListItem *)model {
    _cellFlagImageView.hidden = NO;
    self.adminImageView.hidden = YES;
    
    BOOL showDiskUnInitIv = model.data.diskInitStatus != ESDiskInitStatusNormal && model.data.boxType == ESBoxTypePairing && [model.data hasInnerDiskSupport];
    self.diskUnInitIv.hidden = !showDiskUnInitIv;
    
    if (![model.category isEqual:TEXT_LOGIN_TITLE]) {
        return;
    }
    self.mySelfBtn.hidden = YES;
    self.backView.backgroundColor = model.online ? ESColor.tertiarySystemBackgroundColor : ESColor.secondarySystemBackgroundColor;
    
    self.name.text = model.data.bindUserName.length > 0 ? model.data.bindUserName : model.data.spaceName;
    self.userDomain.text = model.data.info.userDomain.length > 0 &&
    (model.data.supportNewBindProcess == NO || (model.data.supportNewBindProcess && model.data.enableInternetAccess)) ? [NSString stringWithFormat:@"https://%@/", model.data.info.userDomain] : @"";
    
    UIImage *image =  [UIImage imageWithContentsOfFile:model.data.bindUserHeadImagePath.shareCacheFullPath];
    if (image == nil) {
        image =  [UIImage imageWithContentsOfFile:model.data.bindUserHeadImagePath.fullCachePath];
    }
    self.iconImageView.image = image ?: IMAGE_ME_AVATAR_DEFAULT;
    self.arrowImageView.hidden = YES;
    self.stateLabel.hidden = NO;
    self.stateView.hidden = NO;
    
    
    if ([ESCommonToolManager isEnglish]) {
        self.cellFlagImageView.image = (model.data.boxType == ESBoxTypeAuth) ? [UIImage imageNamed:@"shouquan_en"] : [UIImage imageNamed:@"bangding_en"];
    }else{
        self.cellFlagImageView.image = (model.data.boxType == ESBoxTypeAuth) ? IMAGE_LOGIN_EMPOWER : IMAGE_LOGIN_BIND_ICON;
    }
    
    //在线
    self.name.textColor = model.online ? ESColor.labelColor : ESColor.disableTextColor;
    self.userDomain.textColor = model.online ? ESColor.labelColor : ESColor.placeholderTextColor;

    if (model.inuse) {
        self.stateLabel.text = TEXT_BOX_IN_USE;
        self.stateView.backgroundColor = ESColor.greenColor;
        return;
    }
    
    //不在线
    if (!model.online) {
        self.stateLabel.text = TEXT_BOX_OFFLINE;
        self.name.textColor = ESColor.disableTextColor;
        self.stateView.backgroundColor = ESColor.placeholderTextColor;
        self.userDomain.textColor = ESColor.placeholderTextColor;
        
        return;
    }

    //no inuse
    self.stateLabel.text = NSLocalizedString(@"To be Used", @"待使用");
    self.stateView.backgroundColor = ESColor.grayColor;
    self.stateLabel.hidden = YES;
    self.stateView.hidden = YES;
}

#pragma mark - Lazy Load
//
- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.textColor = ESColor.labelColor;
        _name.textAlignment = NSTextAlignmentLeft;
        _name.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.contentView addSubview:_name];
    }
    return _name;
}

#pragma mark - Set方法

- (UILabel *)userDomain {
    if (!_userDomain) {
        _userDomain = [[UILabel alloc] init];
        _userDomain.textColor = ESColor.labelColor;
        _userDomain.textAlignment = NSTextAlignmentLeft;
        _userDomain.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [self.contentView addSubview:_userDomain];
    }
    return _userDomain;
}

- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [[UILabel alloc] init];
        _pointOutLabel.textColor = ESColor.secondaryLabelColor;
        _pointOutLabel.textAlignment = NSTextAlignmentLeft;
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = ESColor.secondaryLabelColor;
        _stateLabel.textAlignment = NSTextAlignmentLeft;
        _stateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:_stateLabel];
    }
    return _stateLabel;
}

- (UIView *)stateView {
    if (!_stateView) {
        _stateView = [[UIView alloc] init];
        _stateView.backgroundColor = ESColor.greenColor;
        _stateView.layer.masksToBounds = YES;
        _stateView.layer.cornerRadius = 4;
        [self.backView addSubview:_stateView];
    }
    return _stateView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = IMAGE_APP_LOGO;
        [self.backView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)cellFlagImageView {
    if (!_cellFlagImageView) {
       _cellFlagImageView = [[UIImageView alloc] init];
      //  _cellFlagImageView.image = IMAGE_APP_LOGO;
        _cellFlagImageView.hidden = YES;
        [self.backView addSubview:_cellFlagImageView];
    }
    return _cellFlagImageView;
}


- (UIImageView *)adminImageView {
    if (!_adminImageView) {
        _adminImageView = [[UIImageView alloc] init];
        _adminImageView.image = IMAGE_ME_FAMILY_ADMIN;
        [self.backView addSubview:_adminImageView];
    }
    return _adminImageView;
}

- (UIImageView *)cellBgImageView {
    if (!_cellBgImageView) {
        _cellBgImageView = [[UIImageView alloc] init];
        _cellBgImageView.image = IMAGE_ME_FAMILY_CELL_BG;
        [self.backView addSubview:_cellBgImageView];
    }
    return _cellBgImageView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = IMAGE_ME_ARROW;
        [self.backView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIImageView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(action)];
        [_backView addGestureRecognizer:tap];
        [self.contentView addSubview:_backView];
    }
    return _backView;
}

- (UIButton *)mySelfBtn {
    if (!_mySelfBtn) {
        _mySelfBtn = [UIButton new];
        [_mySelfBtn setImage:IMAGE_ME_FAMILY_MYSELF forState:UIControlStateNormal];
        _mySelfBtn.hidden = YES;
        [self.backView addSubview:_mySelfBtn];
    }
    return _mySelfBtn;
}

- (UIButton *)deviceStatusBtn {
    if (!_deviceStatusBtn) {
        _deviceStatusBtn = [UIButton new];
        [_deviceStatusBtn setImage:IMAGE_ME_FAMILY_MYSELF forState:UIControlStateNormal];
        [self.backView addSubview:_deviceStatusBtn];
    }
    return _deviceStatusBtn;
}

- (void)setItem:(ESAccountInfoResult *)item {
    self.name.text = item.personalName;
    self.userDomain.text = item.userDomain.length > 0  ? [NSString stringWithFormat:@"https://%@/", item.userDomain] : @"";

    self.mySelfBtn.hidden = ![ESBoxManager.activeBox.aoid isEqual:item.aoId];
    self.adminImageView.hidden = ![item.role isEqual:@"ADMINISTRATOR"];
    self.arrowImageView.hidden = !([ESMemberManager isAdmin]);
    
    self.iconImageView.image = [UIImage imageWithContentsOfFile:item.headImagePath];
    
    self.stateView.hidden = YES;
    self.stateLabel.hidden = YES;
}

- (UIImageView *)diskUnInitIv {
    if (!_diskUnInitIv) {
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage es_imageNamed: ([ESCommonToolManager isEnglish] ? @"disk_unInit_en": @"disk_unInit")]];
        iv.hidden = YES;
        [self.backView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.backView);
            make.top.mas_equalTo(self.backView);
        }];
        _diskUnInitIv = iv;
    }
    return _diskUnInitIv;
}
@end
