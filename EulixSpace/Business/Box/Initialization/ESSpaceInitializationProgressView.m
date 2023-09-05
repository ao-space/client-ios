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
//  ESSpaceInitializationProgressView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/12/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSpaceInitializationProgressView.h"
#import "ESThemeDefine.h"
#import "ESCommonToolManager.h"
#import "ESTransferProgressView.h"
#import <Masonry/Masonry.h>

@interface ESSpaceInitializationProgressView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) ESTransferProgressView *progress;

@property (nonatomic, strong) UILabel *content;

@end

@implementation ESSpaceInitializationProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.5];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];

    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.avatar).inset(kESViewDefaultMargin + 1);
        make.top.mas_equalTo(self.avatar).inset(127);
        make.height.mas_equalTo(6);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kESViewDefaultMargin);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.bottom.mas_equalTo(self.contentView).inset(32);
    }];
}

- (void)reloadWithRate:(CGFloat)rate {
    [self.progress reloadWithRate:rate];
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(self);
            make.width.mas_equalTo(300);
            make.height.mas_equalTo(350);
        }];
    }
    return _contentView;
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        if ([ESCommonToolManager isEnglish]) {
            _avatar.image = [UIImage imageNamed:@"initialization_prgresss_en"];
        }else{
            _avatar.image = IMAGE_INITIALIZATION_PRGRESSS;
        }
   
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (ESTransferProgressView *)progress {
    if (!_progress) {
        _progress = [ESTransferProgressView new];
        [self.contentView addSubview:_progress];
    }
    return _progress;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.primaryColor;
        _content.textAlignment = NSTextAlignmentCenter;
        _content.text = TEXT_SPACE_LOADING;
        _content.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_content];
    }
    return _content;
}

@end
