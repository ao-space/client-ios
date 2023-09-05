//
//  YCTabBar.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/21.
//
//

#import "YCTabBarItem.h"
#import <UIKit/UIKit.h>
@class YCTabBar;

@protocol YCTabBarDelegate <NSObject>

/**
 * Asks the delegate if the specified tab bar item should be selected.
 */
- (BOOL)tabBar:(YCTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index;

/**
 * Tells the delegate that the specified tab bar item is now selected.
 */
- (void)tabBar:(YCTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

@optional
/**
 * Tells the delegate that the specified tab bar item is now double tap.
 */
- (void)tabBar:(YCTabBar *)tabBar didDoubleTapItemAtIndex:(NSInteger)index;

@end

@interface YCTabBar : UIView

/**
* The tab bar’s delegate object.
*/
@property (nonatomic, weak) id<YCTabBarDelegate> delegate;

/**
 * The items displayed on the tab bar.
 */
@property (nonatomic, copy) NSArray *items;

/**
 * The currently selected item on the tab bar.
 */
@property (nonatomic, weak) YCTabBarItem *selectedItem;

/**
 * backgroundView stays behind tabBar's items. If you want to add additional views,
 * add them as subviews of backgroundView.
 */
@property (nonatomic, readonly) UIScrollView *backgroundView;

/*
 * contentEdgeInsets can be used to center the items in the middle of the tabBar.
 */
@property UIEdgeInsets contentEdgeInsets;

/**
 * Sets the height of tab bar.
 */
- (void)setHeight:(CGFloat)height;

/**
 * Sets the width of tab bar.
 */
- (void)setItemWidth:(CGFloat)itemWidth;

/**
 * Gets the width of tab bar with count.
 */
- (CGFloat)itemWidthWithCount:(NSUInteger)count;

/**
 * Returns the minimum height of tab bar's items.
 */
- (CGFloat)minimumContentHeight;

/*
 * Enable or disable tabBar translucency. Default is NO.
 */
@property (nonatomic, getter=isTranslucent) BOOL translucent;

/**
 * Center selected item when `scrollableTabBar` is `YES`.
 * Default is YES;
 */
@property (nonatomic, assign) BOOL centerSelectedItem;

- (void)centerItem:(NSUInteger)index;

@end
