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
//  ESNavigationBar.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesCustomNavigationBar.h"
#import "UIButton+ESTouchArea.h"

@interface ESMemoriesCustomNavigationBar ()

@property (nonatomic, strong) UIButton *goBackBtn;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *moreActionBtn;

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *subTitleText;

@end

static  CGFloat const kTitleViewH = 56.0f;
static  CGFloat const kTitleViewW = 280.0f;
static  CGFloat const kSearchViewH = 46.0f;
static  CGFloat const kESViewDefaultMargin = 26.0f;

@implementation ESMemoriesCustomNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                     subTitle:(NSString *)subTitle {
    if (self = [super initWithFrame:frame]) {
        self.titleText = title;
        self.subTitleText = subTitle;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = ESColor.systemBackgroundColor;
    CGFloat height = self.frame.size.height;
    UIButton *goBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, height - 18 - 17, 18, 18)];
    [goBackBtn setImage:[UIImage imageNamed:@"photo_back"] forState:UIControlStateNormal];
    [goBackBtn setTitle:nil forState:UIControlStateNormal];
    [goBackBtn addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
    self.goBackBtn = goBackBtn;
    [self.goBackBtn setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self addSubview:goBackBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 200, height - 24 - 22, 400, 22)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = ESColor.labelColor;
    titleLabel.font = ESFontPingFangMedium(16);
    titleLabel.text = self.titleText;
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 200, height - 6 - 16, 400, 16)];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.text = self.subTitleText;
    subTitleLabel.textColor = ESColor.secondaryLabelColor;
    subTitleLabel.font = ESFontPingFangRegular(12);
    self.subTitleLabel = subTitleLabel;
    [self addSubview:subTitleLabel];
    
    UIButton *moreActionBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 14 - 44, height - 44 - 4, 44, 44)];
    [moreActionBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [moreActionBtn setTitle:nil forState:UIControlStateNormal];
    [moreActionBtn setImage:[UIImage imageNamed:@"smart_photo_more"] forState:UIControlStateNormal];
    [moreActionBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    self.moreActionBtn = moreActionBtn;
    [self addSubview:moreActionBtn];
}


- (void)moreAction {
    if (self.moreActionBlock) {
        self.moreActionBlock();
    }
}

- (void)goBackAction {
    if (self.goActionBlock) {
        self.goActionBlock();
    }
}

@end
