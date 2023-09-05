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
//  ESBaseViewController.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseViewController.h"

@interface ESBaseViewController ()

@property (nonatomic, assign) BOOL hasEnterBackground;
@property (nonatomic, assign) NSInteger viewAppearCount;
@property (nonatomic, strong) UIColor *navigationBarOrigalColor;
@property (nonatomic, strong) UIView *statusBar;

@end

@implementation ESBaseViewController

- (void)dealloc
{
    ESDLog(@"dealloc %@", self);

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registCommonNotifications
{
 
    //add by deronhuang
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    // 监听进入前后台消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _viewAppearCount = 0;
    }

    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
     self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _viewAppearCount = 0;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showBackBt = YES;
    [self registCommonNotifications];
    
    self.navigationController.delegate = self;
}

- (void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    ESDLog(@"viewWillAppear ViewControllers:%@", self);
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:![self es_needShowNavigationBar] animated:NO];

    self.navigationBarOrigalColor = self.navigationController.navigationBar.barTintColor;
    self.navigationController.navigationBar.backgroundColor = [self customeNavigationBarBackgroudColor];
    self.navigationController.navigationBar.barTintColor = [self customeNavigationBarBackgroudColor];
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *navBar = self.navigationController.navigationBar.standardAppearance;
        navBar.backgroundColor = [self customeNavigationBarBackgroudColor];
        navBar.shadowColor = [UIColor clearColor];
        self.navigationController.navigationBar.standardAppearance = navBar;
        self.navigationController.navigationBar.scrollEdgeAppearance = navBar;
    }
    
    //自定义 状态栏颜色跟navigationBar颜色一致
//    [self setStatusBarBackgroudColor:[self customeNavigationBarBackgroudColor]];
    if (@available(iOS 14.0, *)) {
        if (self.navigationController.viewControllers.count > 1) {
            self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeGeneric;
            UIImage *backImage = [UIImage imageNamed:@"ic_back_chevron"]; // 替换成你的返回图标
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
            UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            fixedSpace.width = 16.0; // 增大空白按钮的宽度
            self.navigationItem.hidesBackButton = !self.showBackBt;
            self.navigationItem.backBarButtonItem = self.showBackBt ? backButton : nil;
            self.navigationItem.leftBarButtonItems = self.showBackBt ? @[fixedSpace, backButton] : @[];
        } else {
            self.navigationItem.hidesBackButton = YES;
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationItem.leftBarButtonItems = nil;
        }
        // 添加左滑手势识别器
        UIScreenEdgePanGestureRecognizer *leftSwipeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
        leftSwipeGestureRecognizer.edges = UIRectEdgeLeft;
        [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    }
    ++_viewAppearCount;
}

- (UIColor *)customeNavigationBarBackgroudColor {
    return ESColor.systemBackgroundColor;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self viewDidAppearHandleLoadingView:animated];

    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
   
    if (@available(iOS 14.0, *)) {
        if (self.navigationController.viewControllers.count > 1) {
            self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeGeneric;
            UIImage *backImage = [UIImage imageNamed:@"ic_back_chevron"]; // 替换成你的返回图标
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
            UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            fixedSpace.width = 16.0; // 增大空白按钮的宽度
            self.navigationItem.backBarButtonItem = self.showBackBt ? backButton : nil;
            self.navigationItem.leftBarButtonItems = self.showBackBt ? @[fixedSpace, backButton] : @[];
        } else {
            self.navigationItem.hidesBackButton = YES;
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationItem.leftBarButtonItems = nil;
        }
    }
}


- (void)viewDidAppearHandleLoadingView:(BOOL)animated {}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
#endif

- (void)viewWillDisappear:(BOOL)animated
{
    ESDLog(@"viewWillDisappear ViewControllers:%@", self);
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.backgroundColor = self.navigationBarOrigalColor;
    self.navigationController.navigationBar.barTintColor = self.navigationBarOrigalColor;
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *navBar = self.navigationController.navigationBar.standardAppearance;
        navBar.backgroundColor = self.navigationBarOrigalColor;
        navBar.shadowColor = [UIColor clearColor];
        self.navigationController.navigationBar.standardAppearance = navBar;
        self.navigationController.navigationBar.scrollEdgeAppearance = navBar;
    }
    
    if (@available(iOS 13.0, *)) {
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:self.statusBar]) {
                [self.statusBar removeFromSuperview];
            }
        } else {
            UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
            if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                statusBar.backgroundColor = UIColor.clearColor;
            }
        }
}

- (BOOL)es_needShowNavigationBar {
    return YES;
}

#pragma mark-
- (void)willResignActive:(id)sender {}

- (void)didBecomeActive:(id)sender {}

- (void)enterForground:(id)sender
{
    if (self.hasEnterBackground) {
        self.hasEnterBackground = NO;
    }
}

- (void)enterBackground:(id)sender
{
    if (self.isViewVisible) {
        self.hasEnterBackground = YES;
    }
}

-(UIInterfaceOrientationMask) navigationControllerSupportedInterfaceOrientations:(UINavigationController*)navigationController {
    return UIInterfaceOrientationMaskPortrait; 
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


- (void)handleLeftSwipe:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
