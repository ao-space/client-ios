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
//  ESLocalNetworkingPrompt.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/17.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLocalNetworkingPrompt.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESLocalNetworkingPrompt ()

@property (nonatomic, strong) UIControl *contentView;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@end

@implementation ESLocalNetworkingPrompt

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
        make.left.mas_equalTo(self.contentView).inset(20);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).inset(10);
        make.height.mas_equalTo(22);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.content.mas_left).inset(10);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(26);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).inset(20);
        make.width.mas_equalTo(70);
    }];
    [self reloadData];
}

- (void)reloadData {
    self.avatar.image = IMAGE_LOCAL_NETWORKING_ACCESS;
    self.title.text = TEXT_LOCAL_NETWORKING_AUTO_SWITCH;
    self.content.text = TEXT_VIEW_NOW;
}

- (void)show:(UIView *)holder {
    ESPerformBlockOnMainThread(^{
        [holder addSubview:self];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hide];
        });
    });
}

- (void)hide {
    ESPerformBlockOnMainThread(^{
        [self removeFromSuperview];
    });
}

- (void)action {
    [self hide];
    if (self.actionBlock) {
        self.actionBlock(nil);
    }
}

#pragma mark - Lazy Load

- (UIControl *)contentView {
    if (!_contentView) {
        _contentView = [[UIControl alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = [ESColor.darkTextColor colorWithAlphaComponent:0.15].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 8;
        self.backgroundColor = ESColor.systemBackgroundColor;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [_contentView addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentView;
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
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.backgroundColor = ESColor.tertiarySystemBackgroundColor;
        _content.textColor = ESColor.primaryColor;
        _content.textAlignment = NSTextAlignmentCenter;
        _content.font = [UIFont systemFontOfSize:12 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_content];
    }
    return _content;
}

@end
