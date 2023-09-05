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
//  ESBoxBindBlePromptView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxBindBlePromptView.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import "ESCommonToolManager.h"

#import <Lottie/LOTAnimationView.h>
#import <Masonry/Masonry.h>

#define kESBoxBindPromptList @[                       \
    @{                                                \
        @"text": TEXT_BOX_SCAN_PROMPT_POWER_ON,       \
        @"image": IMAGE_BOX_SCAN_PROMPT_POWER_ON,     \
    },                                                \
    @{                                                \
        @"text": TEXT_BOX_SCAN_PROMPT_BLUETOOTH_ON,   \
        @"image": IMAGE_BOX_SCAN_PROMPT_BLUETOOTH_ON, \
    },                                                \
    @{                                                \
        @"text": TEXT_BOX_SCAN_PROMPT_SCAN_QRCODE,    \
        @"hightlight": TEXT_BOX_SCAN_QRCODE,          \
        @"image": IMAGE_BOX_SCAN_PROMPT_SCAN_QRCODE,  \
    },                                                \
    @{                                                \
        @"text": TEXT_BOX_SCAN_PROMPT_BIND_CONFIRM,   \
        @"hightlight": TEXT_NEXT,                     \
        @"image": IMAGE_BOX_SCAN_PROMPT_BIND_CONFIRM, \
    },                                                \
]

@interface ESBoxBindBlePromptView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation ESBoxBindBlePromptView

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
        make.left.right.mas_equalTo(self.animation);
        make.height.mas_equalTo(20);
    }];

    //self.backgroundView.image = IMAGE_BOX_NOT_FOUND;
    __block CGFloat offset = 0;

    if([ESCommonToolManager isEnglish]){
        [kESBoxBindPromptList enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *_Nonnull stop) {
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(-50, offset + 2, 16, 16)];
            icon.image = dict[@"image"];
            [self.container addSubview:icon];
            UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(26-50, offset, ScreenWidth - 40, 20)];
            text.textColor = ESColor.secondaryLabelColor;
            text.font = [UIFont systemFontOfSize:12];
            [self.container addSubview:text];
            text.text = dict[@"text"];
            NSString *hightlight = dict[@"hightlight"];
            if (hightlight) {
                NSDictionary *attributes = @{
                    NSFontAttributeName: [UIFont systemFontOfSize:12],
                    NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                };
                NSDictionary *highlightAttr = @{
                    NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
                    NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                };
                NSMutableAttributedString *content = [dict[@"text"] es_toAttr:attributes];
                [content matchPattern:hightlight highlightAttr:highlightAttr];
                text.attributedText = content;
            }
            offset += 20 + 20;
        }];
    }else{
        [kESBoxBindPromptList enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *_Nonnull stop) {
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, offset + 2, 16, 16)];
            icon.image = dict[@"image"];
            [self.container addSubview:icon];
            UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(26, offset, 200, 20)];
            text.textColor = ESColor.secondaryLabelColor;
            text.font = [UIFont systemFontOfSize:12];
            [self.container addSubview:text];
            text.text = dict[@"text"];
            NSString *hightlight = dict[@"hightlight"];
            if (hightlight) {
                NSDictionary *attributes = @{
                    NSFontAttributeName: [UIFont systemFontOfSize:12],
                    NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                };
                NSDictionary *highlightAttr = @{
                    NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
                    NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                };
                NSMutableAttributedString *content = [dict[@"text"] es_toAttr:attributes];
                [content matchPattern:hightlight highlightAttr:highlightAttr];
                text.attributedText = content;
            }
            offset += 20 + 20;
        }];
    }

}

- (void)reloadWithState:(ESBoxBindState)state {
    NSString *stateString = state == ESBoxBindStateScaning ? TEXT_BOX_SCAN_PROMPT_SCANING : @"";
    self.title.text = stateString;
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

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [self addSubview:_container];
        [_container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.animation.mas_bottom).inset(70);
            make.left.mas_equalTo(self.animation).inset(12);
            make.right.mas_equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
    }
    return _container;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.primaryColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_title];
    }
    return _title;
}

@end
