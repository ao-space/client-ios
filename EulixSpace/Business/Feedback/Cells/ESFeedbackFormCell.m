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
//  ESFeedbackFormCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFeedbackFormCell.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "UIView+ESTool.h"
#import <Masonry/Masonry.h>

@interface ESFeedbackFormCell () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UITextField *content;

@property (nonatomic, strong) ESFormItem *model;

@end

@implementation ESFeedbackFormCell

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
        make.top.mas_equalTo(self.contentView).inset(20);
        make.height.mas_equalTo(22);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(10);
        make.height.mas_equalTo(22);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];

    [self.contentView es_addline:0 offset:0];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.model = model;
    self.title.text = model.title;
    self.content.placeholder = model.placeholder;
    self.content.text = model.content;
}

- (void)editingChanged {
    self.model.content = self.content.text;
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

- (UITextField *)content {
    if (!_content) {
        _content = [[UITextField alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:16];
        [_content addTarget:self action:@selector(editingChanged) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:_content];
    }
    return _content;
}

@end
