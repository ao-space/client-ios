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
//  ESPreviewUnsupportFileView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/12/23.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPreviewUnsupportFileView.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESPreviewUnsupportFileView ()

@property (nonatomic, readonly) UIView *contentView;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UILabel *prompt;

@end

@implementation ESPreviewUnsupportFileView

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
        make.centerX.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(40);
        make.top.mas_equalTo(self.contentView).inset(112);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatar.mas_bottom).inset(20);
        make.left.right.mas_equalTo(self.contentView).inset(68);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(10);
        make.height.mas_equalTo(17);
        make.left.right.mas_equalTo(self.contentView).inset(68);
    }];

    [self.prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.content.mas_bottom).inset(20);
        make.height.mas_equalTo(17);
        make.left.right.mas_equalTo(self.contentView).inset(68);
    }];
    self.prompt.text = TEXT_FILE_PREVIEW_UNSUPPORT_FILE;
}

- (void)reloadWithData:(ESFormItem *)model {
    self.avatar.image = model.icon;
    self.title.text = model.title;
    self.content.text = model.content;
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    return self;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:16];
        _title.numberOfLines = 2;
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.secondaryLabelColor;
        _content.textAlignment = NSTextAlignmentCenter;
        _content.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UILabel *)prompt {
    if (!_prompt) {
        _prompt = [[UILabel alloc] init];
        _prompt.textColor = ESColor.redColor;
        _prompt.textAlignment = NSTextAlignmentCenter;
        _prompt.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_prompt];
    }
    return _prompt;
}

@end
