//
//  YCPopMenu.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/21.
//
//

#import <UIKit/UIKit.h>

extern const NSUInteger YCPopMenuNoSelectionIndex;

typedef NS_ENUM(NSUInteger, YCPopMenuDirection) {
    YCPopMenuDirectionUp,
    YCPopMenuDirectionDown
};

@protocol YCPopMenuItemProtocol <NSObject>

@optional
@property (nonatomic, assign) BOOL available;

@property (nonatomic, copy) NSString *cellIdentifier;

- (CGFloat)menuHeight;

@end

@protocol YCPopMenuCellProtocol <NSObject>

- (void)reloadWithData:(id)data;
@optional
+ (CGSize)menuSize;

- (UIView *)line;

@end

/*!
 @code
 YCPopMenu *pop = [YCPopMenu popMenuWithCellClass:[YCMenuCell class]
                                        dataArray:@[@"1",@"2",@"3"]
                                      actionBlock:^(NSUInteger index, id data) {
    [self.button setTitle:[data description] forState:UIControlStateNormal];
 }];
 //pop.vector = CGVectorMake(0, 0);
 [pop setDirection:YCPopMenuDirectionDown];
 [pop showFromView:self.button];
 */
@interface YCPopMenu : UIView

/**
 Convinient init

 @param cellClass must not be nil
 @param dataArray what to display
 @param actionBlock to receive call back
 @return your pop menu
 */
+ (instancetype)popMenuWithCellClass:(Class)cellClass
                           dataArray:(NSArray *)dataArray
                         actionBlock:(void (^)(NSUInteger index, id data))actionBlock;

/**
 @warning please check index is not equal to YCPopMenuNoSelectionIndex
 */
- (void)setActionBlock:(void (^)(NSUInteger index, id data))actionBlock;

- (void)setDataArray:(NSArray *)dataArray;

/**
 Pop Up

 @param view Just to get left-bottom location of view on the window
 */
- (void)showFromView:(UIView *)view;

/**
 @param point point of left bottom
 */
- (void)showFromPoint:(CGPoint)point;

- (void)setDirection:(YCPopMenuDirection)direction; //default is YCPopMenuDirectionUp

- (void)hide; //auto hide when selected some menu, or just touched background

@property (nonatomic, readonly, getter=isVisible) BOOL visible;

- (void)reloadData;

#pragma mark - Custom

/**
 as it's name
 */
@property (nonatomic, assign) CGSize menuSize; // default is 6

/**
 as it's name
 */
@property (nonatomic, assign) CGFloat maxCellCount; // default is 6

/**
 define your own offset
 */
@property (nonatomic, assign) CGVector vector; //default is {0,0}

#pragma mark - animation

/**
 as it's name
 */
@property (nonatomic, assign) BOOL animated; // default is YES

/**
 as it's name
 */
@property (nonatomic, assign) CGFloat animationDuration; // default is 0.3

/**
 + (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(7_0);
 */
@property (nonatomic, assign) CGFloat damping; // default is 1

@property (nonatomic, assign) CGFloat initialSpringVelocity; // default is 0

@property (nonatomic, assign) UIViewAnimationOptions options;

/**
 as it's name
 */
@property (nonatomic, assign) CGFloat cornerRadius; // default is 4

/**
 background color of outside part of the menu
 */
@property (nonatomic, strong) UIColor *coverColor; //default is nil

@property (nonatomic, weak, readonly) UIView *cover; //`PopMenu` is on the top of cover, and cover is on the top of key window

@property (nonatomic, assign) UIEdgeInsets coverEdgeInsets; //default is `UIEdgeInsetsZero`

@property (nonatomic, assign) CGSize arrowSize; // default is {10, 5}

@property (nonatomic, assign) UIOffset arrowOffset; // default is {0, 0}, guild line the centerX of self

/**
 custom menu as you like, just before menu will show
 */
@property (nonatomic, copy) void (^customViewBlock)(YCPopMenu *popMenu);

/**
 custom cell as you like, just before menu will show
 */
@property (nonatomic, copy) void (^customCellBlock)(__kindof UITableViewCell *cell, NSIndexPath *indexPath);

/**
 OK, just a tableView, do what you like.
 */
@property (nonatomic, readonly) UITableView *tableView;

/**
 shadowColor : [UIColor blackColor]
 shadowOpacity : 0.6
 shadowRadius : 4
 */
@property (nonatomic, assign) BOOL shadow; //default is `YES`

@property (nonatomic, assign) BOOL stickHeader; //default is `NO`

@property (nonatomic, strong) UIView *headerView; //default is nil

/**
 auto dismiss when selected some menu
 */
@property (nonatomic, assign) BOOL dismissWhenSelectedMenu; //default is `YES`

/**
 @[
 @(32),
 @(32),
 ]
 */
@property (nonatomic, strong) NSArray<NSNumber *> *sectionArray;

@property (nonatomic, copy) UIView * (^customSectionBlock)(NSUInteger section);

@end
