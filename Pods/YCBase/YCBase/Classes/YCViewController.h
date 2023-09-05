//
//  YCViewController.h
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCViewController <NSObject>

/**
 just pop `1` level back
 */
- (void)goBack;

/**
 backward `level` level back

 @param level 往前跳的级数
 */
- (void)backward:(NSUInteger)level;

- (void)loadData;

@end

@interface YCViewController : UIViewController <YCViewController>

#pragma mark - Reload

@property (nonatomic, assign) BOOL reloadWhenAppear;

@property (nonatomic, assign) BOOL reloadOnce;

@property (nonatomic, assign) BOOL noReloadOnce;

#pragma mark - NavigationBar

@property (nonatomic, assign) BOOL hideNavigationBar;

@property (nonatomic, strong) UIColor *navigationBarBackgroundColor;

#pragma mark - TabBar

@property (nonatomic, assign) BOOL alwaysShowTabBar;

#pragma mark - Life Cycle

@property (nonatomic, readonly) BOOL yc_viewAppeared;

@property (nonatomic, assign) BOOL killWhenPushed;

@property (nonatomic, assign) BOOL showBackBt;

@end

@interface YCViewController (YCNavi)

- (UIBarButtonItem *)barItemWithTitle:(NSString *)title selector:(SEL)selector;

- (UIBarButtonItem *)barItemWithImage:(UIImage *)image selector:(SEL)selector;

- (UIBarButtonItem *)barItemWithIcon:(NSString *)icon selector:(SEL)selector;

@end
