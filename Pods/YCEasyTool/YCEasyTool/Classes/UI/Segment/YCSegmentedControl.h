//
//  YCSegmentedControl.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/16.
//
//

#import "YCSegmentItem.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YCSegmentedControlStyle) {
    YCSegmentedControlStylePlain,
    YCSegmentedControlStyleIndicator,
};

typedef void (^YCSegmentedCustomButtonBlock)(UIButton *button, NSUInteger index);

typedef void (^YCSegmentedControlSelectionBlock)(NSUInteger segmentIndex);

@interface YCSegmentedControl : UIControl

@property (nonatomic, assign) YCSegmentedControlStyle style;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, assign) CGFloat indicatorHeight;

@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, strong) NSDictionary *textAttributes;
@property (nonatomic, strong) NSDictionary *selectedTextAttributes;
@property (nonatomic, readonly) NSUInteger numberOfSegments;
@property (nonatomic, readonly) NSUInteger currentSelected;
@property (nonatomic, strong, readonly) NSMutableArray<UIButton *> *segments;

@property (nonatomic, copy) YCSegmentedCustomButtonBlock customButtonBlock;

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray<YCSegmentItem *> *)items
               selectionBlock:(YCSegmentedControlSelectionBlock)block;

- (void)setItems:(NSArray<YCSegmentItem *> *)items;

- (void)setSelected:(BOOL)selected segmentAtIndex:(NSUInteger)index;

- (BOOL)isSelectedSegmentAtIndex:(NSUInteger)index;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)index;

- (void)setSelectedTextAttributes:(NSDictionary *)attributes;

- (void)setSegmentAtIndex:(NSUInteger)index enabled:(BOOL)enabled;

@end
