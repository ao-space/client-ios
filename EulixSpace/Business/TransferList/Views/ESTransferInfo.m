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
//  ESTransferInfo.m
//  ESTransferInfo
//
//  Created by Ye Tao on 2021/8/13.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTransferInfo.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESTransferInfo ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@end

@implementation ESTransferInfo

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
        make.left.mas_equalTo(self).inset(kESViewDefaultMargin);
        make.bottom.mas_equalTo(self).inset(30);
        make.width.height.mas_equalTo(16);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).inset(10);
        make.top.mas_equalTo(self.icon).inset(-1);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self).inset(10);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.title);
        make.top.mas_equalTo(self.title.mas_bottom).inset(3);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self).inset(10);
    }];
}

- (void)reloadWithData:(ESFormItem *)data {
    self.icon.image = data.icon;
    self.title.text = data.title;
    self.content.text = data.content;
}

#pragma mark - Lazy Load

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.image = IMAGE_STORAGE_INFO;
        [self addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.secondaryLabelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:12];
        [self addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:12];
        [self addSubview:_content];
    }
    return _content;
}

@end
