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
//  ESBannerMemberInfo.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBannerMemberInfo.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>
#import "ESCommonToolManager.h"
@interface ESBannerMemberInfo ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UILabel *label;

@end

@implementation ESBannerMemberInfo

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

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).inset(7);
        make.height.mas_equalTo(40);
        make.left.right.mas_equalTo(self.contentView).inset(16);
    }];

    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).inset(12);
        make.height.mas_equalTo(20);
        make.left.right.mas_equalTo(self.contentView).inset(16);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.title.text = model.title;
    self.content.text = model.content;
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
        _avatar.image = IMAGE_ME_MEMBER;
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.numberOfLines = 0;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.primaryColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:28 weight:UIFontWeightMedium];
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = ESColor.secondaryLabelColor;
        _label.textAlignment = NSTextAlignmentRight;
        _label.font = [UIFont systemFontOfSize:14];
        _label.text = TEXT_ME_MEMBER_COUNT;
        [self.contentView addSubview:_label];
    }
    return _label;
}

@end
