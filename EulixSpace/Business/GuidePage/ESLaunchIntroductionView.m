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
//  ESLaunchIntroductionView.m
//  EulixSpace
//
//  Created by qu on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLaunchIntroductionView.h"
#import "ESFileProtocolView.h"
#import "ESGlobalMacro.h"
#import "ESHomeCoordinator.h"
#import "ESLocalizableDefine.h"

static NSString *const kAppVersion = @"appVersion";

@interface ESLaunchIntroductionView () <UIScrollViewDelegate> {
    UIScrollView *launchScrollView;
    UIView *pageNumView;
    UIPageControl *page;
    UIView *pagePointOne;
    UIView *pagePointTwo;
    UIView *pagePointThree;
    UIView *pagePointFour;
    UIView *protocolViewBgView;
    UIView *protocolView;
    UITextView *protocolLable;
}

@end

@implementation ESLaunchIntroductionView
NSArray *images;
BOOL isScrollOut; //在最后一页再次滑动是否隐藏引导页
CGRect enterBtnFrame;
NSString *enterBtnImage;
static ESLaunchIntroductionView *launch = nil;
NSString *storyboard;

#pragma mark - 创建对象-->>带button
+ (instancetype)sharedWithImages:(NSArray *)imageNames buttonImage:(NSString *)buttonImageName buttonFrame:(CGRect)frame {
    images = imageNames;
    isScrollOut = NO;
    enterBtnFrame = frame;
    enterBtnImage = buttonImageName;
    launch = [[ESLaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"currentColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"nomalColor" options:NSKeyValueObservingOptionNew context:nil];
        //  if ([self isFirstLauch]) {
        UIStoryboard *story;
        if (storyboard) {
            story = [UIStoryboard storyboardWithName:storyboard bundle:nil];
        }
        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
        if (story) {
            UIViewController *vc = story.instantiateInitialViewController;
            window.rootViewController = vc;
            [vc.view addSubview:self];
        } else {
            [window addSubview:self];
        }
        [self addImages];
    }
    return self;
}
#pragma mark - 判断是不是首次登录或者版本更新
- (BOOL)isFirstLauch {
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:currentAppVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kAppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    } else {
        return NO;
    }
}
#pragma mark - 添加引导页图片
- (void)addImages {
    [self createScrollView];
}
#pragma mark - 创建滚动视图
- (void)createScrollView {
    launchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    launchScrollView.showsHorizontalScrollIndicator = NO;
    launchScrollView.bounces = NO;
    launchScrollView.pagingEnabled = YES;
    launchScrollView.delegate = self;
    launchScrollView.contentSize = CGSizeMake(ScreenWidth * images.count, ScreenHeight);
    [self addSubview:launchScrollView];
    for (int i = 0; i < images.count; i++) {
        UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(i * ScreenWidth, 0, ScreenWidth, ScreenHeight)];
        UIImageView *imageView;
        if (ScreenHeight < 668) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2-290/2, 80, 290, 440)];
            imageView.image = [UIImage imageNamed:images[i]];

        } else {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2-290/2, 80+64, 290, 440)];
            imageView.image = [UIImage imageNamed:images[i]];
        }

        [pageView addSubview:imageView];
        [launchScrollView addSubview:pageView];
        if (i == images.count - 1) {
            //判断要不要添加button
            if (!isScrollOut) {
                UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 100, ScreenHeight - 110 - 40, 200, 40)];
                [enterButton setTitle:TEXT_BOX_BIND_START_TO_USE forState:UIControlStateNormal];
                //关键语句
                [enterButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
                [enterButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
                [enterButton addTarget:self action:@selector(enterBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [pageView addSubview:enterButton];
                enterButton.layer.borderColor = ESColor.primaryColor.CGColor;
                //设置边框宽度
                enterButton.layer.borderWidth = 1.0f;
                //关键语句
                [enterButton.layer setCornerRadius:10.0]; //设置矩圆角半径
                imageView.userInteractionEnabled = YES;
            }
        }
    }

    pageNumView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 32, ScreenHeight - 71, 64, 10)];
    pagePointOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    pagePointOne.layer.cornerRadius = 5;
    pagePointOne.backgroundColor = [UIColor colorWithRed:51 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1.0];
    pagePointTwo = [[UIView alloc] initWithFrame:CGRectMake(20 + 12, 0, 10, 10)];
    pagePointTwo.layer.cornerRadius = 5;
    pagePointTwo.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
    pagePointThree = [[UIView alloc] initWithFrame:CGRectMake(20 + 12 + 10 + 12, 0, 10, 10)];
    pagePointThree.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
    pagePointThree.layer.cornerRadius = 5;
    
//    pagePointFour = [[UIView alloc] initWithFrame:CGRectMake(20 + 12 + 10 + 12 + 22, 0, 10, 10)];
//    pagePointFour.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
//    pagePointFour.layer.cornerRadius = 5;
    
    [pageNumView addSubview:pagePointOne];
    [pageNumView addSubview:pagePointTwo];
    [pageNumView addSubview:pagePointThree];
//    [pageNumView addSubview:pagePointFour];
    [self addSubview:pageNumView];
    ESFileProtocolView *protocolView = [[ESFileProtocolView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    protocolView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
    [self addSubview:protocolView];
}
#pragma mark - 进入按钮
- (void)enterBtnClick {
    [self hideGuidView];
    [ESHomeCoordinator showHome];
}
#pragma mark - 隐藏引导页
- (void)hideGuidView {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self removeFromSuperview];
                         });
                     }];
}
#pragma mark - scrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    int cuttentIndex = (int)(scrollView.contentOffset.x + ScreenWidth / 2) / ScreenWidth;
    if (cuttentIndex == images.count - 1) {
        if ([self isScrolltoLeft:scrollView]) {
            if (!isScrollOut) {
                return;
            }
            [self hideGuidView];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == launchScrollView) {
        int cuttentIndex = (int)(scrollView.contentOffset.x + ScreenWidth / 2) / ScreenWidth;
        page.currentPage = cuttentIndex;
        if (cuttentIndex == 0) {
            pagePointOne.frame = CGRectMake(0, 0, 20, 10);
            pagePointOne.backgroundColor = [UIColor colorWithRed:51 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointTwo.frame = CGRectMake(20 + 12, 0, 10, 10);
            pagePointTwo.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointThree.frame = CGRectMake(20 + 12 + 10 + 12, 0, 10, 10);
            pagePointThree.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointFour.frame = CGRectMake(20 + 12 + 10 + 12 + 10 + 12, 0, 10, 10);
            pagePointFour.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
        } else if (cuttentIndex == 1) {
            pagePointOne.frame = CGRectMake(0, 0, 10, 10);
            pagePointOne.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointTwo.frame = CGRectMake(10 + 12, 0, 20, 10);
            pagePointTwo.backgroundColor = [UIColor colorWithRed:51 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointThree.frame = CGRectMake(20 + 12 + 10 + 12, 0, 10, 10);
            pagePointThree.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointFour.frame = CGRectMake(20 + 12 + 10 + 12 + 10 + 12, 0, 10, 10);
            pagePointFour.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
        }
        else if (cuttentIndex == 2) {
           pagePointOne.frame = CGRectMake(0, 0, 10, 10);
           pagePointOne.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
           pagePointTwo.frame = CGRectMake(10 + 12, 0, 10, 10);
           pagePointTwo.backgroundColor =  [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
           pagePointThree.frame = CGRectMake(10 + 12 + 10 + 12, 0, 20, 10);
           pagePointThree.backgroundColor = [UIColor colorWithRed:51 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1.0];
           pagePointFour.frame = CGRectMake(20 + 12 + 10 + 12 + 10 + 12, 0, 10, 10);
           pagePointFour.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
       }
        else {
            pagePointOne.frame = CGRectMake(0, 0, 10, 10);
            pagePointOne.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointTwo.frame = CGRectMake(10 + 12, 0, 10, 10);
            pagePointTwo.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointThree.frame = CGRectMake(10 + 12 + 10 + 12, 0, 10, 10);
            pagePointThree.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:214 / 255.0 blue:255 / 255.0 alpha:1.0];
            pagePointFour.frame = CGRectMake(10 + 12 + 10 + 12 + 10 + 12, 0, 20, 10);
            pagePointFour.backgroundColor = [UIColor colorWithRed:51 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1.0];
        }
    }
}
#pragma mark - 判断滚动方向
- (BOOL)isScrolltoLeft:(UIScrollView *)scrollView {
    //返回YES为向左反动，NO为右滚动
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        return YES;
    } else {
        return NO;
    }
}
#pragma mark - KVO监测值的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentColor"]) {
        page.currentPageIndicatorTintColor = self.currentColor;
    }
    if ([keyPath isEqualToString:@"nomalColor"]) {
        page.pageIndicatorTintColor = self.nomalColor;
    }
}

@end
