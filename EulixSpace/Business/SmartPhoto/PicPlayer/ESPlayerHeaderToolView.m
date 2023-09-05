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
//  ESPlayHeaderView.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPlayerHeaderToolView.h"
#import "UIButton+ESTouchArea.h"

@interface ESPlayerHeaderToolView ()

@property (nonatomic, strong) UIButton *goBackBtn;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end

static  CGFloat const kTitleViewH = 56.0f;
static  CGFloat const kTitleViewW = 280.0f;
static  CGFloat const kSearchViewH = 46.0f;
static  CGFloat const kESViewDefaultMargin = 26.0f;

@implementation ESPlayerHeaderToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)showFrom:(UIView *)view {
    if (self.superview) {
        return;
    }
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
}

- (void)hidden {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)setupViews {
    self.frame = CGRectMake(0, 0, ScreenWidth, kStatusBarHeight + kTitleViewH);
    self.backgroundColor = ESColor.systemBackgroundColor;

    UIButton *goBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 22 - 10, 18, 18)];
    [goBackBtn setImage:[UIImage imageNamed:@"player_close"] forState:UIControlStateNormal];
    [goBackBtn setTitle:nil forState:UIControlStateNormal];
    [goBackBtn addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
    self.goBackBtn = goBackBtn;
    [self.goBackBtn setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self addSubview:goBackBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 200, kStatusBarHeight + 8, 400, 22)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = ESColor.lightTextColor;
    titleLabel.font = ESFontPingFangMedium(16);
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 200, kStatusBarHeight + 31, 400, 16)];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = @"";
    messageLabel.textColor = ESColor.lightTextColor;
    messageLabel.font = ESFontPingFangRegular(12);
    self.messageLabel = messageLabel;
    [self addSubview:messageLabel];
}

- (void)goBackAction {
    if (self.goActionBlock) {
        self.goActionBlock();
    }
}

- (void)updateTitleText:(NSString *)title message:(NSString *)messageText {
    self.titleLabel.text = title;
    
    self.messageLabel.text = messageText;
}
@end
