//
//  YCViewController.m
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#import "YCViewController.h"
#import "YCNavigationController.h"
#import <Masonry/Masonry.h>

@interface YCNavigationController ()

@property (nonatomic, assign) BOOL yc_isBeingPresented;

@end

@interface YCViewController ()

@property (nonatomic, assign) BOOL yc_viewAppeared;

@property (nonatomic, strong) UIColor *yc_previousNaviColor;

@end

@implementation YCViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _reloadWhenAppear = YES;
        _noReloadOnce = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.hidesBottomBarWhenPushed = YES;
        self.showBackBt = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarHandler];

}

-(void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationBarHandler {
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        if (self.navigationController.topViewController == self) {
            self.navigationController.navigationBarHidden = _hideNavigationBar;
        }
    }
}

- (void)changeNavigationBarColor {
    if (!self.navigationBarBackgroundColor) {
        return;
    }
    self.yc_previousNaviColor = self.yc_previousNaviColor ?: self.navigationController.navigationBar.barTintColor;
    self.navigationController.navigationBar.backgroundColor = self.navigationBarBackgroundColor;
    self.navigationController.navigationBar.barTintColor = self.navigationBarBackgroundColor;
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *navBar = self.navigationController.navigationBar.standardAppearance;
        navBar.backgroundColor = self.navigationBarBackgroundColor;
        self.navigationController.navigationBar.standardAppearance = navBar;
        self.navigationController.navigationBar.scrollEdgeAppearance = navBar;
    }
}

- (void)restoreNavigationBarColor {
    if (!self.navigationBarBackgroundColor) {
        return;
    }
    self.navigationController.navigationBar.backgroundColor = self.yc_previousNaviColor;
    self.navigationController.navigationBar.barTintColor = self.yc_previousNaviColor;
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *navBar = self.navigationController.navigationBar.standardAppearance;
        navBar.backgroundColor = self.yc_previousNaviColor;
        self.navigationController.navigationBar.standardAppearance = navBar;
        self.navigationController.navigationBar.scrollEdgeAppearance = navBar;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeNavigationBarColor];
    self.yc_viewAppeared = YES;
    [self navigationBarHandler];
    if (_noReloadOnce) {
        _noReloadOnce = NO;
        return;
    }
    if (_reloadWhenAppear || _reloadOnce) {
        [self loadData];
        _reloadOnce = NO;
    }
    if (@available(iOS 14.0, *)) {
        if(!self.navigationController.navigationBarHidden){
            if (self.navigationController.viewControllers.count > 1 && self.showBackBt) {
                self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeGeneric;
                UIImage *backImage = [UIImage imageNamed:@"ic_back_chevron"]; // 替换成你的返回图标
                UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
                UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                fixedSpace.width = 10.0; // 增大空白按钮的宽度
                self.navigationItem.backBarButtonItem = backButton;
                
                self.navigationItem.leftBarButtonItems = @[fixedSpace, backButton];
            } else {
                self.navigationItem.hidesBackButton = YES;
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                self.navigationItem.leftBarButtonItems = nil;
            }
            UIScreenEdgePanGestureRecognizer *leftSwipeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
                leftSwipeGestureRecognizer.edges = UIRectEdgeLeft;
                [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (@available(iOS 14.0, *)) {
        if(!self.navigationController.navigationBarHidden){
            if (self.navigationController.viewControllers.count > 1 && self.showBackBt) {
                self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeGeneric;
                UIImage *backImage = [UIImage imageNamed:@"ic_back_chevron"]; // 替换成你的返回图标
                UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
                UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                fixedSpace.width = 10.0; // 增大空白按钮的宽度
                self.navigationItem.backBarButtonItem = backButton;
                self.navigationItem.leftBarButtonItems = @[fixedSpace, backButton];
            } else {
                self.navigationItem.hidesBackButton = YES;
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                self.navigationItem.leftBarButtonItems = nil;
            }
        }
    }
}

- (void)setShowBackBt:(BOOL)showBackBt {
    _showBackBt = showBackBt;
    if (!(self.isViewLoaded && self.view.window)) {
        return;
    }
    if (@available(iOS 14.0, *)) {
        if(!self.navigationController.navigationBarHidden){
            if (self.navigationController.viewControllers.count > 1 && _showBackBt) {
                self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeGeneric;
                UIImage *backImage = [UIImage imageNamed:@"ic_back_chevron"]; // 替换成你的返回图标
                UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
                UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                fixedSpace.width = 10.0; // 增大空白按钮的宽度
                self.navigationItem.backBarButtonItem = backButton;
                self.navigationItem.leftBarButtonItems = @[fixedSpace, backButton];
            } else {
                self.navigationItem.hidesBackButton = YES;
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                self.navigationItem.leftBarButtonItems = nil;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.yc_viewAppeared = NO;
    [self.view endEditing:YES];
    [self restoreNavigationBarColor];
}

- (void)loadData {
}

- (void)goBack {
    YCNavigationController *navi = (YCNavigationController *)self.navigationController;
    if (navi.yc_isBeingPresented && navi.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [navi popViewControllerAnimated:YES];
}

- (void)backward:(NSUInteger)level {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > level) {
        UIViewController *target = viewControllers[viewControllers.count - level - 1];
        [self.navigationController popToViewController:target animated:YES];
    }
}

#pragma mark Did Set

- (void)setReloadWhenAppear:(BOOL)reloadWhenAppear {
    if (reloadWhenAppear == _reloadWhenAppear) {
        return;
    }
    _reloadWhenAppear = reloadWhenAppear;
    if (!_reloadWhenAppear) {
        [self loadData];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}

// Which screen directions are supported.
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (!viewControllerToPresent.transitioningDelegate) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end

@implementation YCViewController (YCNavi)

- (UIBarButtonItem *)barItemWithTitle:(NSString *)title selector:(SEL)selector {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:selector];
    return item;
}

- (UIBarButtonItem *)barItemWithImage:(UIImage *)image selector:(SEL)selector {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:selector];
    return item;
}

- (UIBarButtonItem *)barItemWithIcon:(NSString *)icon selector:(SEL)selector {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:icon]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:selector];
    return item;
}

- (void)handleLeftSwipe:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
