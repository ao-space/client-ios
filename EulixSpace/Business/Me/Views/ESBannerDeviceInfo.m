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
//  ESBannerDeviceInfo.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBannerDeviceInfo.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESMemberManager.h"
#import "ESCommonToolManager.h"
#import "ESTransferProgressView.h"
#import <Masonry/Masonry.h>


@interface ESBannerDeviceInfo ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) ESTransferProgressView *progress;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UILabel *badge;

@end

@implementation ESBannerDeviceInfo

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(14);
        make.width.height.mas_equalTo(20);
        make.left.mas_equalTo(self.contentView).inset(16);
    }];
    
    if ([ESCommonToolManager isEnglish]) {
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.avatar).offset(-2);
            make.height.mas_equalTo(22);
            make.left.mas_equalTo(self.avatar.mas_right).inset(8);
            make.right.mas_equalTo(self.contentView).inset(24);
        }];
    }else{
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.avatar).offset(-2);
            make.height.mas_equalTo(22);
            make.left.mas_equalTo(self.avatar.mas_right).inset(8);
            make.right.mas_equalTo(self.contentView).inset(24);
        }];
    }
    
    [self.badge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.contentView).inset(16);
        make.height.width.mas_equalTo(16);
    }];

    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatar.mas_bottom).inset(20);
        make.height.mas_equalTo(6);
        make.left.right.mas_equalTo(self.contentView).inset(16);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).inset(12);
        make.height.mas_equalTo(20);
        make.left.right.mas_equalTo(self.contentView).inset(16);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.title.text = model.title;
    self.content.text = model.content;
    [self.progress reloadWithRate:model.width];
    
    if([ESMemberManager isAdminAndPair]){
        self.badge.hidden = model.badge == 0;
    }else{
        self.badge.hidden = YES;
    }
    self.badge.text = [NSString stringWithFormat:@"%zd", model.badge];
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        _contentView.userInteractionEnabled = NO;
        _contentView.backgroundColor = ESColor.systemBackgroundColor;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _contentView;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        _avatar.image = IMAGE_ME_MANAGEMENT_ICON;
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.numberOfLines = 0;
        _title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (ESTransferProgressView *)progress {
    if (!_progress) {
        _progress = [[ESTransferProgressView alloc] init];
        _progress.holderBackgroundColor = ESColor.secondarySystemBackgroundColor;
        [self.contentView addSubview:_progress];
    }
    return _progress;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.secondaryLabelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UILabel *)badge {
    if (!_badge) {
        _badge = [[UILabel alloc] init];
        _badge.layer.cornerRadius = 8;
        _badge.layer.masksToBounds = YES;
        _badge.backgroundColor = ESColor.redColor;
        _badge.textColor = ESColor.lightTextColor;
        _badge.textAlignment = NSTextAlignmentCenter;
        _badge.font = [UIFont systemFontOfSize:12];
        _badge.hidden = YES;
        [self.contentView addSubview:_badge];
    }
    return _badge;
}

@end
