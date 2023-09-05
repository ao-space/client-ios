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
//  ESFormView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/2.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFormView.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESBoxManager.h"

#import "UILabel+ESAutoSize.h"
#import "UIView+ESTool.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIImageView+ESWebImageView.h"

@interface ESFormView ()

@property (nonatomic, readonly) UIView *contentView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UIButton *arrow;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView *dot;

@property (nonatomic, strong) UISwitch *switchButton;

@end

static const CGFloat kESFormViewIconWidth = 16;

@implementation ESFormView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).inset(16);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(kESFormViewIconWidth);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).inset(42);
        make.centerY.mas_equalTo(self.contentView);
        make.height.width.mas_equalTo(22);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.title.mas_right).inset(10);
        make.right.mas_equalTo(self.arrow.mas_left).inset(10);
    }];

    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(16);
    }];

    self.line = [self.contentView es_addline:kESViewDefaultMargin];

    [self addTarget:self action:@selector(tapCell) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reloadWithData:(ESFormItem *)model {
    ///如果有 icon.显示 icon
    if (model.icon) {
        self.icon.hidden = NO;
        self.icon.image = model.icon;
        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).inset(kESViewDefaultMargin + kESFormViewIconWidth);
        }];
    } else if (model.iconURL) {
        self.icon.hidden = NO;
        [self.icon es_setImageWithURL:model.iconURL placeholderImageName:nil];
        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).inset(kESViewDefaultMargin + kESFormViewIconWidth);
        }];
    }
    else {
        self.icon.hidden = YES;
        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        }];
    }
    /// 显示 avatar, 调整布局
    _avatar.hidden = YES;
    if (model.avatar || model.avatarImage) {
        self.avatar.hidden = NO;
        [self.avatar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.arrow.mas_left).inset(model.arrowLeft);
        }];
        if (model.avatar) {
            [self.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:IMAGE_ME_AVATAR_DEFAULT];
        } else {
            self.avatar.image = model.avatarImage;
        }
    }
    ///更新底部线的布局
    [self.line mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView).inset(model.lineMargin);
    }];
    ///更新箭头的布局
    [self.arrow mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).inset(model.arrowRight);
        make.width.mas_equalTo(model.arrowWidth);
        make.height.mas_equalTo(model.arrowHeight);
    }];
    [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.arrow.mas_left).inset(model.arrowLeft);
    }];
    self.title.text = model.title;
    [self.title es_flexible];
    self.content.text = model.content;
    self.content.textColor = model.contentColor ?: ESColor.secondaryLabelColor;
    [self.arrow setImage:model.arrowImage ?: IMAGE_ME_ARROW forState:UIControlStateNormal];
  
    self.line.hidden = model.hideLine;
    _dot.hidden = YES;
    if (model.dot) {
        self.dot.hidden = NO;
    }
    _switchButton.hidden = YES;
    if (model.showSwitch) {
        self.switchButton.hidden = NO;
        self.switchButton.on = model.selected;
        self.arrow.hidden = YES;
        self.content.text = nil;
    }
    if(ESBoxManager.activeBox.boxType == ESBoxTypeAuth && [model.title isEqual:NSLocalizedString(@"me_pro_file_photo", @"头像")]){
        self.arrow.hidden =YES;
    }
    if([model.title isEqual:NSLocalizedString(@"me_pro_file_photo", @"头像")]){
        [self.arrow setImage:IMAGE_ME_ARROW forState:UIControlStateNormal];
        self.arrow.hidden = NO;
    }
    if(model.isHiddenArrowBtn){
        self.arrow.hidden = YES;
    }

}

- (void)tapArrow {
    if (self.actionBlock) {
        self.actionBlock(@(ESFormViewActionArrow));
    }
}

- (void)tapCell {
    if (self.actionBlock) {
        self.actionBlock(@(ESFormViewActionTapCell));
    }
}

- (void)switchAction {
    _switchButton.enabled = NO;
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD showWithStatus:@"开启/关闭中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.switchButton.enabled = YES;
        self.actionBlock(@(self.switchButton.on ? ESFormViewActionSwitchOn : ESFormViewActionSwitchOff));
    });
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    return self;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
        [self.contentView addSubview:_icon];
        _icon.layer.masksToBounds = YES;
        _icon.layer.cornerRadius = 5;
    }
    return _icon;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.secondaryLabelColor;
        _content.textAlignment = NSTextAlignmentRight;
        _content.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UIButton *)arrow {
    if (!_arrow) {
        _arrow = [UIButton new];
        [_arrow setImage:IMAGE_ME_ARROW forState:UIControlStateNormal];
        _arrow.tag = ESFormViewActionArrow;
        [self.contentView addSubview:_arrow];
        [_arrow addTarget:self action:@selector(tapArrow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrow;
}

- (UIView *)dot {
    if (!_dot) {
        _dot = [UIView new];
        _dot.backgroundColor = ESColor.redColor;
        [self.contentView addSubview:_dot];
        _dot.layer.cornerRadius = 4;
        _dot.layer.masksToBounds = YES;
        [_dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(8);
            make.right.mas_equalTo(self.arrow.mas_left);
            make.top.mas_equalTo(self.arrow).offset(-3);
        }];
    }
    return _dot;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = 15;
        [self.contentView addSubview:_avatar];
        [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.arrow.mas_left);
            make.centerY.mas_equalTo(self.contentView);
            make.width.height.mas_equalTo(30);
        }];
    }
    return _avatar;
}

- (UISwitch *)switchButton {
    if (!_switchButton) {
        _switchButton = [UISwitch new];
        [self.contentView addSubview:_switchButton];
        [_switchButton addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
        [_switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
            make.centerY.mas_equalTo(self.contentView);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(50);
        }];
    }
    return _switchButton;
}

@end
