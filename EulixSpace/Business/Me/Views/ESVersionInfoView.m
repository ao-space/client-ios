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
//  ESVersionInfoView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESVersionInfoView.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "UIView+ESTool.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <Masonry/Masonry.h>

@interface ESVersionInfoView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) FLAnimatedImageView *avatar;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UITextView *content;

@property (nonatomic, strong) UIButton *cancel;

@property (nonatomic, strong) UIButton *upgrade;

@end

@implementation ESVersionInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.backgroundColor = [[ESColor darkTextColor] colorWithAlphaComponent:0.5];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(20);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(72);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatar.mas_bottom).inset(10);
        make.centerX.mas_equalTo(self.contentView);
        make.height.mas_equalTo(25);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(16);
        make.left.mas_equalTo(self.contentView).inset(30);
        make.right.mas_equalTo(self.contentView).inset(30);
        make.height.mas_equalTo(166);
    }];

    [self.cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView).dividedBy(2);
        make.height.mas_equalTo(44);
    }];

    [self.upgrade mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView).dividedBy(2);
        make.height.mas_equalTo(44);
    }];

    [self.contentView es_addline:0 offset:-44];
    [self.cancel es_addline:0 offset:0 vertical:YES];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.title.text = model.title;
    self.content.text = model.content;
    if (self.force) {
        self.cancel.hidden = YES;
        [self.upgrade mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(self.contentView);
            make.width.mas_equalTo(self.contentView);
            make.height.mas_equalTo(44);
        }];
        [self.upgrade setTitle:NSLocalizedString(@"me_upgrade_right_now", @"立即更新") forState:UIControlStateNormal];
    }
}

- (void)cancelAction {
    self.hidden = YES;
}

- (void)upgradeAction {
    if (self.actionBlock) {
        self.actionBlock(nil);
    }
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [ESColor systemBackgroundColor];
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).inset(52);
            make.left.mas_equalTo(self).inset(53);
            make.height.mas_equalTo(380);
            make.centerY.mas_equalTo(self);
        }];
    }
    return _contentView;
}

- (FLAnimatedImageView *)avatar {
    if (!_avatar) {
        _avatar = [FLAnimatedImageView new];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"version_info" ofType:@"gif"]]];
        [image setValue:@(0) forKey:@"loopCount"];
        _avatar.animatedImage = image;
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UITextView *)content {
    if (!_content) {
        _content = [[UITextView alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:14];
        _content.editable = NO;
        _content.contentInset = UIEdgeInsetsZero;
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UIButton *)cancel {
    if (!_cancel) {
        _cancel = [UIButton new];
        [_cancel setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        [_cancel setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        _cancel.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_cancel];
        [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancel;
}

- (UIButton *)upgrade {
    if (!_upgrade) {
        _upgrade = [UIButton new];
        [_upgrade setTitle:NSLocalizedString(@"me_upgrade", @"更新") forState:UIControlStateNormal];
        [_upgrade setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        _upgrade.titleLabel.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_upgrade];
        [_upgrade addTarget:self action:@selector(upgradeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _upgrade;
}

@end
