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
//  ESTabBarController.m
//  EulixSpace
//
//  Created by qu on 2021/9/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTabBarController.h"
#import "ESDebugMacro.h"
#import "ESFileAddBtnVC.h"
#import "ESGlobalMacro.h"
#import "ESTabBar.h"
#import <AudioToolbox/AudioToolbox.h>
#import <YCBase/YCNavigationController.h>
#ifdef ES8ackD00r
#import "ESSetting8ackd00rViewController.h"
#endif

@interface ESTabBarController () <ESTabBarDelegate>

@property (nonatomic, strong) ESTabBar *ylTabBar;
@property (nonatomic, strong) UIView *backView;

@end

@implementation ESTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIApplication.sharedApplication.applicationSupportsShakeToEdit = YES;
    [self setupUI];
}

- (void)setupUI {
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [self setValue:self.ylTabBar forKey:@"tabBar"];
}

#pragma mark - ShakeToEdit 摇动手机之后的回调方法

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        // your code
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) {
#ifdef ES8ackD00r
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //振动效果 需要#import <AudioToolbox/AudioToolbox.h>
        ESSetting8ackd00rViewController *next = [ESSetting8ackd00rViewController new];
        YCNavigationController *navi = [[YCNavigationController alloc] initWithRootViewController:next];
        [self presentViewController:navi animated:YES completion:nil];
#endif
    }
}

- (ESTabBar *)ylTabBar {
    if (!_ylTabBar) {
        _ylTabBar = [ESTabBar instanceCustomTabBarWithType:kTbaBarItemUIType_Three];
        [_ylTabBar setBackgroundColor:[UIColor redColor]];
        _ylTabBar.centerBtnIcon = @"";
        [_ylTabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
        _ylTabBar.tabDelegate = self;
    }
    return _ylTabBar;
}

- (void)tabBar:(ESTabBar *)tabBar clickCenterButton:(UIButton *)sender {
    ESFileAddBtnVC *vc = [[ESFileAddBtnVC alloc] init];
    vc.modalPresentationStyle = 0;
    vc.definesPresentationContext = YES;
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path"];
    if (path.length > 0) {
        vc.path = path;
    } else {
        vc.path = path;
    }
    vc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    YCNavigationController *nav = [[YCNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    nav.view.backgroundColor = [UIColor clearColor];
    nav.navigationBar.backgroundColor = [UIColor clearColor];
    weakfy(self);
    self.backView.hidden = NO;
    
    vc.actionBlock = ^(NSString *selectedNum) {
        strongfy(self);
        self.backView.hidden = YES;
    };
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _backView.userInteractionEnabled = YES;
        //给图片添加点击手势（也可以添加其他手势）
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTag)];
        [_backView addGestureRecognizer:tap];
        [self.view addSubview:_backView];
    }
    return _backView;
}

//点击事件
- (void)backViewTag {
    self.backView.hidden = YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
   return [self.selectedViewController shouldAutorotate];
}
@end
