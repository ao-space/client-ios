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
//  ESFeedbackDescCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFeedbackDescCell.h"
#import "ESFormItem.h"
#import "ESLongTextInputView.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESFeedbackDescCell ()

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) ESLongTextInputView *content;

@property (nonatomic, strong) ESFormItem *model;

@end

@implementation ESFeedbackDescCell

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

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.height.mas_equalTo(22);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(12);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.height.mas_equalTo(170);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.model = model;
    self.title.text = model.title;
    self.content.placeholderText = model.placeholder;
    self.content.text = model.content;
}

#pragma mark - Lazy Load

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (ESLongTextInputView *)content {
    if (!_content) {
        _content = [[ESLongTextInputView alloc] init];
        _content.wordsLimit = @(500);
        _content.canInputEnter = YES;
        _content.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _content.layer.cornerRadius = 4;
        _content.layer.masksToBounds = YES;
        weakfy(self);
        _content.textDidChangeResultBlock = ^(NSString *text) {
            weak_self.model.content = text;
        };
        [self.contentView addSubview:_content];
    }
    return _content;
}

@end
