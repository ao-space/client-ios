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
//  ESSelectedTopVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSelectedTopToolVC.h"
#import "UIButton+ESTouchArea.h"
#import "ESLocalizableDefine.h"
#import "ESCommonToolManager.h"

@interface ESSelectedTopToolVC ()

@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *goBackBtn;

@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UILabel *limitSelectLabel;
@property (nonatomic, strong) UIButton *topViewselelctBtn;
@property (nonatomic, assign) BOOL isAllSelected;
@property (nonatomic, assign) BOOL preNavigationShow;
@property (nonatomic, strong) UIViewController *showVC;

@end

static  CGFloat const kTitleViewH = 56.0f;
static  CGFloat const kESViewDefaultMargin = 26.0f;

@implementation ESSelectedTopToolVC

- (void)showFrom:(UIViewController *)vc {
    if (self.view.superview) {
        return;
    }
    
   
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSArray *subViews = window.subviews;
    __block UIView *promptView = nil;
    [subViews enumerateObjectsUsingBlock:^(UIView  *_Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:NSClassFromString(@"ESLocalNetworkingPrompt")]) {
            promptView = view;
            *stop = YES;
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    if (promptView != nil) {
        [window bringSubviewToFront:promptView];
    }
    
    self.limitSelectLabel.hidden = !_limitSelectStyle;
}

- (void)hidden {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, ScreenWidth, kStatusBarHeight + kTitleViewH);
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    [self setupViews];
}

- (void)setupViews {
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 25 - 10, 60, 25)];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [cancelBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = cancelBtn;
    [self.cancelBtn setEnlargeEdge:UIEdgeInsetsMake(10, 10, 10, 10)];

    [self.view addSubview:cancelBtn];
    
    UIButton *goBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 22 - 10, 18, 18)];
    [goBackBtn setImage:[UIImage imageNamed:@"photo_back"] forState:UIControlStateNormal];
    [goBackBtn setTitle:nil forState:UIControlStateNormal];
    [goBackBtn addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
    self.goBackBtn = goBackBtn;
    [self.goBackBtn setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self.view addSubview:goBackBtn];
    
    UILabel *selectLable = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 200, kStatusBarHeight + 8, 400, 22)];
    if (_limitSelectStyle == NO) {
        selectLable.frame = CGRectMake(ScreenWidth / 2 - 200, kStatusBarHeight + 25, 400, 22);
    }
    selectLable.textAlignment = NSTextAlignmentCenter;
    selectLable.textColor = ESColor.labelColor;
    selectLable.font = ESFontPingFangMedium(16);
    self.selectLabel = selectLable;
    [self.view addSubview:selectLable];
    
    UILabel *limitSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 200, kStatusBarHeight + 31, 400, 16)];
    limitSelectLabel.textAlignment = NSTextAlignmentCenter;
    limitSelectLabel.text = NSLocalizedString(@"Up_to_500_files_optional", @"最多可选500个文件");
    limitSelectLabel.textColor = ESColor.secondaryLabelColor;
    limitSelectLabel.font = ESFontPingFangRegular(12);
    self.limitSelectLabel = limitSelectLabel;
    [self.view addSubview:limitSelectLabel];
    if (_limitSelectStyle == NO) {
        self.limitSelectLabel.hidden = YES;
    }
    UIButton *topViewselelctBtn;
    if ([ESCommonToolManager isEnglish]) {
        topViewselelctBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 40 - kESViewDefaultMargin - 60, kStatusBarHeight + kTitleViewH - 25 - 10, 120, 25)];
    }else{
        topViewselelctBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 40 - kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 25 - 10, 60, 25)];
    }
   // UIButton *topViewselelctBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 40 - kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 25 - 10, 60, 25)];
    [topViewselelctBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [topViewselelctBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    [topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];

    [topViewselelctBtn addTarget:self action:@selector(totalAllSlelectedAction) forControlEvents:UIControlEventTouchUpInside];
    self.topViewselelctBtn = topViewselelctBtn;
    [self.view addSubview:topViewselelctBtn];
    
    [self setShowStyle:ESSelectedTopToolVCShowStyleSelecte];
}

- (void)updateSelectdCount:(NSInteger)count isAllSelected:(BOOL)allSelected {
    _isAllSelected = allSelected;
    if (allSelected) {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
    } else {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];
    }
    
    self.selectLabel.text = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), (unsigned long)count];
}

- (void)totalAllSlelectedAction {
    _isAllSelected = !_isAllSelected;
    if (self.selecteAllActionBlock) {
        self.selecteAllActionBlock();
    }
}

- (void)cancelAction {
    if (self.cancelActionBlock) {
        self.cancelActionBlock();
    }
}

- (void)goBackAction {
    if (self.goActionBlock) {
        self.goActionBlock();
    }
}

- (void)setShowStyle:(ESSelectedTopToolVCShowStyle)style {
    if (style == ESSelectedTopToolVCShowStyleCanGoBack) {
        self.cancelBtn.hidden = YES;
        self.goBackBtn.hidden = NO;
        return;
    }
    
    self.cancelBtn.hidden = NO;
    self.goBackBtn.hidden = YES;
}

- (void)setLimitSelectStyle:(BOOL)limitSelectStyle {
    _limitSelectStyle = limitSelectStyle;
    if (limitSelectStyle == NO) {
        self.selectLabel.frame = CGRectMake(ScreenWidth / 2 - 200, kStatusBarHeight + 17, 400, 22);
        self.limitSelectLabel.hidden = YES;
    }
}

@end

