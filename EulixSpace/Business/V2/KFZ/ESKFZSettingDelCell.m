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
//  ESKFZSettingDelCell.m
//  EulixSpace
//
//  Created by qu on 20212/1/09.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESKFZSettingDelCell.h"
#import "ESFormItem.h"
#import "ESLongTextInputView.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESKFZSettingDelCell ()

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *pointOut;

@property (nonatomic, strong) ESLongTextInputView *content;

@property (nonatomic, strong) UIImageView * icon;

@property (nonatomic, strong) ESFormItem *model;

@property (nonatomic, strong) UIView *line;

@end

@implementation ESKFZSettingDelCell

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

    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(21);
        make.left.mas_equalTo(self.contentView).offset(26);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    
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
        _title.text = NSLocalizedString(@"container_internal_path", @"容器内部路径");
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

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"kfz_add"];
        _icon.layer.cornerRadius = 4.0;
        _icon.layer.masksToBounds = YES;
        [self.content addSubview:_icon];
    }
    return _icon;
}


- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_line];
    }
    return _line;
}


@end
