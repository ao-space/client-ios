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
//  ESSapceWelcomeVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/29.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSapceWelcomeVC.h"
#import "ESLocalPath.h"
#import "ESImageDefine.h"
#import "ESBoxManager.h"
#import "ESAccountManager.h"
#import "ESHomeCoordinator.h"
#import "ESToast.h"

@interface ESSapceWelcomeVC ()

@property (nonatomic, strong) UILabel *welcomeLabel;
@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *spaceNameLabel;
@property (nonatomic, strong) UILabel *spaceUrlLabel;

@property (nonatomic, strong) UILabel *swipeHintLabel;
@property (nonatomic, strong) UIImageView *swipeHintIcon;

@end

@implementation ESSapceWelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBackBt = NO;
    self.view.backgroundColor = [ESColor systemBackgroundColor];

    [self setupViews];
    
    UISwipeGestureRecognizer * swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeGes.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGes];
    
    if (self.inviteModel) {
        [self reloadDataWithInviteModel];
        return;
    }
    [self reloadData];
}

- (void)swipeLeft:(id)ges {
    if (self.inviteModel) {
        [ESBoxManager.manager onActive:self.inviteModel.boxItem];
        [ESHomeCoordinator showHome];
        return;
    }
    [ESBoxManager.manager onActive:self.paringBoxItem];
    [ESHomeCoordinator showHome];
    
    if (self.paringBoxItem.boxType == ESBoxTypeMember) {
//        [ESToast toastSuccess:NSLocalizedString(@"Create_member_success", @"创建成员成功")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createMemberNSNotification" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loopUrlChangeNSNotification" object: self.paringBoxItem.prettyDomain];
        });
    }
}

- (void)reloadData {
    if (self.viewModel.spaceName.length > 0) {
        _spaceNameLabel.text =  self.viewModel.spaceName;
    } else if (self.paringBoxItem.name.length > 0) {
        _spaceNameLabel.text =  self.paringBoxItem.name;
    }
    _spaceUrlLabel.text = self.paringBoxItem.info.userDomain;
    _icon.image = IMAGE_ME_AVATAR_DEFAULT;
    
//    if (self.paringBoxItem.info.avatarUrl.length > 0) {
//       //优化取头像的速度
//    }
    weakfy(self)

    [[ESAccountManager manager] loadAvatarWithBox:self.paringBoxItem
                                          completion:^(NSString *path) {
                                              strongfy(self)
        ESDLog(@"[ESSapceWelcomeVC][loadAvatarWithBox] queries box aoid:%@ targetPath:%@", self.paringBoxItem.aoid, path);
                                              if (path.length > 0) {
                                                  self.paringBoxItem.bindUserHeadImagePath = path;
                                                  [ESBoxManager.manager saveBox:self.paringBoxItem];
                                                  UIImage *image = [UIImage imageWithContentsOfFile:path.shareCacheFullPath];
                                                  ESDLog(@"[ESSapceWelcomeVC][loadAvatarWithBox] queries image:%@", image);
                                                  if (image) {
                                                      self.icon.image = image;
                                                  }
                                              }
                                          }];
}

- (void)reloadDataWithInviteModel {
    _spaceNameLabel.text =  self.inviteModel.spaceName ?: self.inviteModel.boxItem.spaceName;
    _spaceUrlLabel.text = self.inviteModel.boxItem.info.userDomain;
    _icon.image = IMAGE_ME_AVATAR_DEFAULT;
    
    weakfy(self)
    [[ESAccountManager manager] loadAvatar:self.inviteModel.boxItem.aoid
                                          completion:^(NSString *path) {
                                              strongfy(self)
                                              if (path.length > 0) {
                                                  self.paringBoxItem.bindUserHeadImagePath = path;
                                                  [ESBoxManager.manager saveBox:self.inviteModel.boxItem];
                                                  UIImage *image = [UIImage imageWithContentsOfFile:self.inviteModel.boxItem.bindUserHeadImagePath.shareCacheFullPath];
                                                  if (image) {
                                                      self.icon.image = image;
                                                  }
                                              }
                                          }];
}

- (void)setupViews {
    [self.view addSubview:self.welcomeLabel];
    [self.welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).inset(150 + kStatusBarHeight);
    }];
    
    [self.view addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(50);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.welcomeLabel.mas_bottom).inset(60);
    }];
    
    [self.view addSubview:self.spaceNameLabel];
    [self.spaceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(25);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.icon.mas_bottom).inset(10);
    }];
    [self.view addSubview:self.spaceUrlLabel];
    [self.spaceUrlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.spaceNameLabel.mas_bottom).inset(10);
    }];
    
    [self.view addSubview:self.swipeHintLabel];
    [self.swipeHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(80 + kBottomHeight);
    }];
    
    [self.view addSubview:self.swipeHintIcon];
    [self.swipeHintIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(20);
        make.centerY.mas_equalTo(self.swipeHintLabel.mas_centerY);
        make.left.mas_equalTo(self.swipeHintLabel.mas_right).inset(4);
    }];
}

- (UILabel *)welcomeLabel {
    if (!_welcomeLabel) {
        _welcomeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _welcomeLabel.textColor = ESColor.labelColor;
        _welcomeLabel.font = ESFontPingFangMedium(24);
        _welcomeLabel.textAlignment = NSTextAlignmentCenter;
        _welcomeLabel.numberOfLines = 0;
        _welcomeLabel.text = NSLocalizedString(@"binding_welcome", @"欢迎使用傲空间");
    }
    return _welcomeLabel;
}

- (UILabel *)spaceNameLabel {
    if (!_spaceNameLabel) {
        _spaceNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _spaceNameLabel.textColor = ESColor.labelColor;
        _spaceNameLabel.font = ESFontPingFangMedium(18);
        _spaceNameLabel.textAlignment = NSTextAlignmentLeft;
//        _spaceNameLabel.text = @"喵喵的空间";
    }
    return _spaceNameLabel;
}

- (UILabel *)spaceUrlLabel {
    if (!_spaceUrlLabel) {
        _spaceUrlLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _spaceUrlLabel.textColor = ESColor.labelColor;
        _spaceUrlLabel.font = ESFontPingFangMedium(14);
        _spaceUrlLabel.textAlignment = NSTextAlignmentLeft;
//        _spaceUrlLabel.text = @"https://adasdads.ao.spac/aaa";
    }
    return _spaceUrlLabel;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
        _icon.image = [UIImage imageNamed:@"push_head"];
        _icon.layer.cornerRadius = 25;
        _icon.clipsToBounds = YES;
    }
    return _icon;
}

- (UILabel *)swipeHintLabel {
    if (!_swipeHintLabel) {
        _swipeHintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _swipeHintLabel.textColor = ESColor.labelColor;
        _swipeHintLabel.font = ESFontPingFangMedium(14);
        _swipeHintLabel.textAlignment = NSTextAlignmentLeft;
        _swipeHintLabel.text = NSLocalizedString(@"binding_start", @"向左滑动以开始");
    }
    return _swipeHintLabel;
}

- (UIImageView *)swipeHintIcon {
    if (!_swipeHintIcon) {
        _swipeHintIcon = [UIImageView new];
        _swipeHintIcon.image = [UIImage imageNamed:@"swip_arrow"];
    }
    return _swipeHintIcon;
}

@end
