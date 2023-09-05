//
//  YCNavigationController.m
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#import "YCNavigationController.h"
#import "YCViewController.h"

@interface YCViewController ()

@property (nonatomic, assign) BOOL yc_viewAppeared;

@end

@interface YCNavigationController ()

@property (nonatomic, assign) BOOL yc_isBeingPresented;

@end

@implementation YCNavigationController

- (void)setGlobalUI {
    if (@available(iOS 11.0, *)) {
        //do nothing
        //SIDLog(@"remove sonar warning");
    } else {
        [UIBarButtonItem.appearance setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -64) forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setGlobalUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.parentViewController) {
        self.yc_isBeingPresented = self.parentViewController.isBeingPresented;
    } else {
        self.yc_isBeingPresented = self.isBeingPresented;
    }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated {
    [super setNavigationBarHidden:navigationBarHidden animated:animated];
}

- (void)pushViewController:(YCViewController *)viewController animated:(BOOL)animated {
    if ([self.viewControllers containsObject:viewController]) {
        return;
    }
    YCViewController *source = (YCViewController *)self.topViewController;
    BOOL YCBaseVC = [source isKindOfClass:[YCViewController class]];
    if (YCBaseVC) {
        source.yc_viewAppeared = NO;
    }
    if (YCBaseVC && source.killWhenPushed) {
        NSMutableArray *viewControllers = self.viewControllers.mutableCopy;
        if (viewControllers.count >= 1) {
            [viewControllers removeLastObject];
        }
        [viewControllers addObject:viewController];
        [super setViewControllers:viewControllers animated:YES];
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    YCViewController *source = (YCViewController *)self.topViewController;
    if ([source isKindOfClass:[YCViewController class]]) {
        source.yc_viewAppeared = NO;
    }
    return [super popViewControllerAnimated:animated];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (!viewControllerToPresent.transitioningDelegate) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

// Which screen directions are supported
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

// The default screen direction (the current ViewController must be represented by a modal UIViewController (which is not valid with modal navigation) to call this method).
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

//- (UIViewController *)childViewControllerForStatusBarStyle {
//    return self.topViewController;
//}
//
//- (UIViewController *)childViewControllerForStatusBarHidden {
//    return self.topViewController;
//}

@end
