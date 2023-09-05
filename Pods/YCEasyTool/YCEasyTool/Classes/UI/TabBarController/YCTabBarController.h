//
//  YCTabBarController.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/21.
//
//

#import "YCTabBar.h"
#import <UIKit/UIKit.h>

/**
 Inspired by https://github.com/robbdimitrov/YCTabBarController
 */
@protocol YCTabBarControllerDelegate;

@interface YCTabBarController : UIViewController <YCTabBarDelegate>

/**
 * The tab bar controller’s delegate object.
 */
@property (nonatomic, weak) id<YCTabBarControllerDelegate> delegate;

/**
 * An array of the root view controllers displayed by the tab bar interface.
 */
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

/**
 * The tab bar view associated with this controller. (read-only)
 */
@property (nonatomic, readonly) YCTabBar *tabBar;

/**
 * The view controller associated with the currently selected tab item.
 */
@property (nonatomic, weak) UIViewController *selectedViewController;

/**
 * The index of the view controller associated with the currently selected tab item.
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 * The maximum count of items in tab bar. The last will be created as a moreNavigationController when count of item
 * exceeds `maxCount`
 */
@property (nonatomic, assign) NSUInteger maxCount;

/**
 * The tabBar will be scrollable when count of item exceeds `maxCount`.
 * Default is NO;
 */
@property (nonatomic, assign) BOOL scrollableTabBar;

/**
 * A Boolean value that determines whether the tab bar is hidden.
 */
@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

/**
 * Changes the visibility of the tab bar.
 */
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

typedef void (^YCTabBarControllerMoreBlock)(NSUInteger index);

@protocol YCTabBarControllerDelegate <NSObject>
@optional
/**
 * Asks the delegate whether the specified view controller should be made active.
 */
- (BOOL)tabBarController:(YCTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;

/**
 * Tells the delegate that the user selected an item in the tab bar.
 */
- (void)tabBarController:(YCTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

/**
 * Tells the delegate that the user selected a `More` item in the tab bar.
 */
- (void)tabBarController:(YCTabBarController *)tabBarController didSelectMoreWithBlock:(YCTabBarControllerMoreBlock)block;

@end

@interface UIViewController (YCTabBarControllerItem)

/**
 * The tab bar item that represents the view controller when added to a tab bar controller.
 */
@property (nonatomic, setter=yc_setTabBarItem:) YCTabBarItem *yc_tabBarItem;

/**
 * The nearest ancestor in the view controller hierarchy that is a tab bar controller. (read-only)
 */
@property (nonatomic, readonly) YCTabBarController *yc_tabBarController;

@end
