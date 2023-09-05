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
//  ESBoxBindWiredConnectionPromptView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxBindWiredConnectionPromptView.h"


@interface ESBoxBindWiredConnectionPromptView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation ESBoxBindWiredConnectionPromptView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;

    [self.animation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(64);
        make.size.mas_equalTo(CGSizeMake(196, 196));
        make.centerX.mas_equalTo(self.contentView);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.animation.mas_bottom).inset(10);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(25);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(20);
        make.left.right.mas_equalTo(self.contentView).inset(20);
        make.height.mas_greaterThanOrEqualTo(40);
    }];
}

- (void)reloadWithState:(ESBoxBindState)state {
    if (state == ESBoxBindStateScaning) {
        self.title.text = TEXT_BOX_SCAN_PROMPT_SCANING;
        self.title.textColor = ESColor.primaryColor;
        self.title.font = [UIFont systemFontOfSize:12];
        self.content.text = TEXT_BOX_BIND_WIRED_CONNECTION_PROMPT;
    } else if (state == ESBoxBindStateNotFound) {
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        paragraphStyle.minimumLineHeight = 20;
        paragraphStyle.maximumLineHeight = 20;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        NSDictionary *highlightAttr = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
            NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        NSMutableAttributedString *content = [TEXT_BOX_SCAN_NO_BOX_PROMPT es_toAttr:attributes];
        [content matchPattern:TEXT_BOX_SCAN_AGAIN highlightAttr:highlightAttr];
        self.content.attributedText = content;
        self.title.text = TEXT_BOX_BIND_NOT_FOUND;
        self.title.textColor = ESColor.labelColor;
        self.title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
    } else {
        self.title.text = nil;
        self.content.text = TEXT_BOX_BIND_WIRED_CONNECTION_PROMPT;
    }

    if (state == ESBoxBindStateScaning) {
        [self.animation play];
    } else {
        [self.animation stop];
    }
}

#pragma mark - Lazy Load

- (LOTAnimationView *)animation {
    if (!_animation) {
        _animation = [LOTAnimationView animationNamed:@"scaning"];
        _animation.loopAnimation = YES;
        [self addSubview:_animation];
    }
    return _animation;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return _contentView;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.textColor = ESColor.primaryColor;
        _title.font = [UIFont systemFontOfSize:12];
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
        _content.text = TEXT_BOX_BIND_WIRED_CONNECTION_PROMPT;
        _content.numberOfLines = 0;
        [self.contentView addSubview:_content];
    }
    return _content;
}

@end
