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
//  ESMJHeader.m
//  EulixSpace
//
//  Created by qu on 2023/6/5.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESMJHeader.h"
#import "UILabel+ESTool.h"
#import <Lottie/Lottie.h>
#import <Masonry/Masonry.h>
#import "UIView+MJExtension.h"
@interface ESMJHeader()
@property (weak, nonatomic) UILabel *label;

@property (weak, nonatomic) UIImageView *logo;
@property (weak, nonatomic) UIActivityIndicatorView *loading;

@property(nonatomic,strong) LOTAnimationView * animationView;
@end


@implementation ESMJHeader

- (void)prepare
{
    [super prepare];

    self.mj_h = 80;
    UILabel *label = [[UILabel alloc] init];
    label = [UILabel createLabel:ESFontPingFangRegular(12) color:@"#BCBFCD"];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.label = label;
    

    self.animationView = [LOTAnimationView animationNamed:@"loadingMj.json"];
    [self addSubview:self.animationView];
    self.animationView.frame = CGRectMake(ScreenWidth/2-15, 0, 30, 30);
    self.animationView.loopAnimation = YES;
    self.label.frame = self.bounds;
    
    [self.animationView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(0);
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_equalTo(38);
        make.width.mas_equalTo(38);
    }];
    
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.animationView.mas_bottom).offset(5);
        make.centerX.equalTo(self.mas_centerX);
    }];

}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];

}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];

}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    self.label.text = NSLocalizedString(@"Data_is_completely_under_your_control", @"您的数据完全由您掌控");
    switch (state) {
        case MJRefreshStateIdle:
            [self.loading stopAnimating];
            break;
        case MJRefreshStatePulling:
            [self.animationView play];
            break;
        case MJRefreshStateRefreshing:
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
//    // 1.0 0.5 0.0
//    // 0.5 0.0 0.5
//    CGFloat red = 1.0 - pullingPercent * 0.5;
//    CGFloat green = 0.5 - 0.5 * pullingPercent;
//    CGFloat blue = 0.5 * pullingPercent;
//    self.label.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
