//
//  YCTabBarController.m
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/21.
//
//

#import "YCTabBarController.h"
#import "YCTabBarItem.h"
#import <objc/runtime.h>

@interface UIViewController (YCTabBarControllerItemInternal)

- (void)yc_setTabBarController:(YCTabBarController *)tabBarController;

@end

@interface YCTabBarController () {
    UIView *_contentView;
    BOOL _hasMore;
}

@property (nonatomic, strong) YCTabBar *tabBar;

@end

@implementation YCTabBarController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:[self contentView]];
    [self.view addSubview:[self tabBar]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setSelectedIndex:[self selectedIndex]];

    [self setTabBarHidden:self.isTabBarHidden animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.selectedViewController.preferredStatusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.selectedViewController.preferredStatusBarUpdateAnimation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAll;
    for (UIViewController *viewController in [self viewControllers]) {
        if (![viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
            return UIInterfaceOrientationMaskPortrait;
        }

        UIInterfaceOrientationMask supportedOrientations = [viewController supportedInterfaceOrientations];

        if (orientationMask > supportedOrientations) {
            orientationMask = supportedOrientations;
        }
    }

    return orientationMask;
}

- (BOOL)shouldAutorotate {
    for (UIViewController *viewCotroller in [self viewControllers]) {
        if (![viewCotroller respondsToSelector:@selector(shouldAutorotate)] ||
            ![viewCotroller shouldAutorotate]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Methods

- (UIViewController *)selectedViewController {
    if (self.selectedIndex >= self.viewControllers.count) {
        return nil;
    }
    return [[self viewControllers] objectAtIndex:[self selectedIndex]];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        return;
    }

    UIViewController *selectedViewController = [self selectedViewController];
    if (selectedViewController) {
        [selectedViewController willMoveToParentViewController:nil];
        [[selectedViewController view] removeFromSuperview];
        [selectedViewController removeFromParentViewController];
    }

    _selectedIndex = selectedIndex;
    if (selectedIndex < self.tabBar.items.count) {
        [[self tabBar] setSelectedItem:[[self tabBar] items][selectedIndex]];
    }

    [self setSelectedViewController:[[self viewControllers] objectAtIndex:selectedIndex]];
    selectedViewController = [self selectedViewController];
    [self addChildViewController:selectedViewController];
    [[selectedViewController view] setFrame:[[self contentView] bounds]];
    [[self contentView] addSubview:[selectedViewController view]];
    [selectedViewController didMoveToParentViewController:self];

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers && _viewControllers.count) {
        for (UIViewController *viewController in _viewControllers) {
            if (viewController.viewLoaded) {
                [viewController willMoveToParentViewController:nil];
                [viewController.view removeFromSuperview];
                [viewController removeFromParentViewController];
            }
        }
    }

    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        _viewControllers = [viewControllers copy];

        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        _hasMore = NO;
        if (self.maxCount > 0 && viewControllers.count > self.maxCount) {
            _hasMore = YES;
        }
        [viewControllers enumerateObjectsUsingBlock:^(UIViewController *_Nonnull viewController,
                                                      NSUInteger idx,
                                                      BOOL *_Nonnull stop) {
            [viewController yc_setTabBarController:self];
            if (self->_hasMore && idx >= self.maxCount - 1 && !self.scrollableTabBar) {
                return;
            }
            YCTabBarItem *tabBarItem = [[YCTabBarItem alloc] init];
            [tabBarItem setTitle:viewController.title];
            [tabBarItems addObject:tabBarItem];
        }];

        if (_hasMore) {
            if (!self.scrollableTabBar) {
                YCTabBarItem *tabBarItem = [[YCTabBarItem alloc] init];
                [tabBarItem setTitle:@"More"];
                [tabBarItems addObject:tabBarItem];
            } else {
                [self.tabBar setItemWidth:[self.tabBar itemWidthWithCount:self.maxCount]];
            }
        }

        [[self tabBar] setItems:tabBarItems];
    } else {
        _hasMore = NO;
        for (UIViewController *viewController in _viewControllers) {
            [viewController yc_setTabBarController:nil];
        }

        _viewControllers = nil;
    }
}

- (NSInteger)indexForViewController:(UIViewController *)viewController {
    UIViewController *searchedController = viewController;
    if ([searchedController navigationController]) {
        searchedController = [searchedController navigationController];
    }
    return [[self viewControllers] indexOfObject:searchedController];
}

- (YCTabBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[YCTabBar alloc] init];
        [_tabBar setBackgroundColor:[UIColor clearColor]];
        [_tabBar setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleBottomMargin)];
        [_tabBar setDelegate:self];
    }
    return _tabBar;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
        [_contentView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight)];
    }
    return _contentView;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    _tabBarHidden = hidden;

    __weak YCTabBarController *weakSelf = self;

    void (^block)(void) = ^{
        CGSize viewSize = weakSelf.view.bounds.size;
        CGFloat tabBarStartingY = viewSize.height;
        CGFloat contentViewHeight = viewSize.height;
        CGFloat tabBarHeight = CGRectGetHeight([[weakSelf tabBar] frame]);

        if (!tabBarHeight) {
            tabBarHeight = 49;
        }

        if (!hidden) {
            tabBarStartingY = viewSize.height - tabBarHeight;
            if (![[weakSelf tabBar] isTranslucent]) {
                contentViewHeight -= ([[weakSelf tabBar] minimumContentHeight] ?: tabBarHeight);
            }
            [[weakSelf tabBar] setHidden:NO];
        }

        [[weakSelf tabBar] setFrame:CGRectMake(0, tabBarStartingY, viewSize.width, tabBarHeight)];
        [[weakSelf contentView] setFrame:CGRectMake(0, 0, viewSize.width, contentViewHeight)];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        if (hidden) {
            [[weakSelf tabBar] setHidden:YES];
        }
    };

    if (animated) {
        [UIView animateWithDuration:0.24 animations:block completion:completion];
    } else {
        block();
        completion(YES);
    }
}

- (void)setTabBarHidden:(BOOL)hidden {
    [self setTabBarHidden:hidden animated:NO];
}

- (void)setScrollableTabBar:(BOOL)scrollableTabBar {
    _scrollableTabBar = scrollableTabBar;
    self.tabBar.centerSelectedItem = scrollableTabBar;
}

#pragma mark - YCTabBarDelegate

- (BOOL)tabBar:(YCTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index {
    if ([[self delegate] respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![[self delegate] tabBarController:self shouldSelectViewController:[self viewControllers][index]]) {
            return NO;
        }
    }

    if ([self selectedViewController] == [self viewControllers][index]) {
        if ([[self selectedViewController] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *selectedController = (UINavigationController *)[self selectedViewController];

            if ([selectedController topViewController] != [selectedController viewControllers][0]) {
                [selectedController popToRootViewControllerAnimated:YES];
            }
        }
        if (_hasMore && index >= self.maxCount - 1 && !self.scrollableTabBar) {
            return YES;
        }
        return NO;
    }

    return YES;
}

- (void)tabBar:(YCTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= [[self viewControllers] count]) {
        return;
    }
    if (_hasMore && index == self.maxCount - 1 && !self.scrollableTabBar) {
        if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectMoreWithBlock:)]) {
            [self.delegate tabBarController:self
                     didSelectMoreWithBlock:^(NSUInteger index) {
                         if ([self tabBar:tabBar shouldSelectItemAtIndex:index]) {
                             [self setSelectedIndex:index];
                             if ([[self delegate] respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
                                 [[self delegate] tabBarController:self didSelectViewController:[self viewControllers][index]];
                             }
                         }
                     }];
        }
        return;
    }
    [self setSelectedIndex:index];

    if ([[self delegate] respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [[self delegate] tabBarController:self didSelectViewController:[self viewControllers][index]];
    }
}

@end

#pragma mark - UIViewController+YCTabBarControllerItem

@implementation UIViewController (YCTabBarControllerItemInternal)

- (void)yc_setTabBarController:(YCTabBarController *)tabBarController {
    objc_setAssociatedObject(self, @selector(yc_tabBarController), tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIViewController (YCTabBarControllerItem)

- (YCTabBarController *)yc_tabBarController {
    YCTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(yc_tabBarController));

    if (!tabBarController && self.parentViewController) {
        tabBarController = [self.parentViewController yc_tabBarController];
    }

    return tabBarController;
}

- (YCTabBarItem *)yc_tabBarItem {
    YCTabBarController *tabBarController = [self yc_tabBarController];
    NSInteger index = [tabBarController indexForViewController:self];
    return [[[tabBarController tabBar] items] objectAtIndex:index];
}

- (void)yc_setTabBarItem:(YCTabBarItem *)tabBarItem {
    YCTabBarController *tabBarController = [self yc_tabBarController];

    if (!tabBarController) {
        return;
    }

    YCTabBar *tabBar = [tabBarController tabBar];
    NSInteger index = [tabBarController indexForViewController:self];

    NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithArray:[tabBar items]];
    [tabBarItems replaceObjectAtIndex:index withObject:tabBarItem];
    [tabBar setItems:tabBarItems];
}
@end
