
//
//  YCSegmentedControl.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/16.
//
//

#import "YCSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

@interface YCSegmentedControl ()
@property (nonatomic, strong) NSMutableArray<UIButton *> *segments;
@property (nonatomic, strong) NSArray<YCSegmentItem *> *items;
@property (nonatomic, assign) NSUInteger currentSelected;
@property (nonatomic, copy) YCSegmentedControlSelectionBlock selectionBlock;
@property (nonatomic, strong) UIView *indicator;
@end

@implementation YCSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items
               selectionBlock:(YCSegmentedControlSelectionBlock)block {
    self = [super initWithFrame:frame];
    if (self) {
        // Selection block
        _selectionBlock = [block copy];

        // Adding items
        [self addItems:items withFrame:frame];

        // Background Color
        self.backgroundColor = [UIColor clearColor];

        // Default selected 0
        _currentSelected = 0;
    }
    return self;
}

- (void)addItems:(NSArray *)items withFrame:(CGRect)frame {
    for (UIView *segment in self.segments) {
        [segment removeFromSuperview];
    }
    _items = items;
    [self.segments removeAllObjects];
    // Generating segments
    float buttonWith = ceil(frame.size.width / items.count);
    int i = 0;
    for (YCSegmentItem *item in items) {
        NSString *text = item.title;
        UIButton *button;
        button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWith * i, 0, buttonWith,
                                                            frame.size.height)];
        [button addTarget:self
                      action:@selector(segmentSelected:)
            forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:text forState:UIControlStateNormal];
        // Adding to self view
        [self.segments addObject:button];
        if (self.customButtonBlock) {
            self.customButtonBlock(button, i);
        }
        [self addSubview:button];

        i++;
    }
}

#pragma mark - Lazy instantiations

- (NSMutableArray *)segments {
    if (!_segments) {
        _segments = [[NSMutableArray alloc] init];
    }
    return _segments;
}

#pragma mark - Actions

- (void)segmentSelected:(id)sender {
    if (sender) {
        NSUInteger selectedIndex = [self.segments indexOfObject:sender];
        [self setSelected:YES segmentAtIndex:selectedIndex];
        if (self.selectionBlock) {
            self.selectionBlock(selectedIndex);
        }
    }
}

#pragma mark - Style

- (void)setStyle:(YCSegmentedControlStyle)style {
    _style = style;
    if (style == YCSegmentedControlStyleIndicator) {
        [self updateSegmentsFormat];
        [self layoutIfNeeded];
        self.indicatorHeight = self.indicatorHeight > 0 ?: 1;
        self.indicatorColor = self.indicatorColor ?: [UIColor blueColor];
    }
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    self.indicator.backgroundColor = indicatorColor;
    [self segmentAnimation:NO];
}

- (UIView *)indicator {
    if (!_indicator) {
        _indicator = [[UIView alloc] init];
        [self addSubview:_indicator];
    }
    return _indicator;
}

- (void)segmentAnimation:(BOOL)animation {
    if (_style != YCSegmentedControlStyleIndicator) {
        return;
    }
    if (self.segments.count == 0) {
        return;
    }
    UIButton *button = self.segments[self.currentSelected];
    CGRect frame = CGRectMake(button.frame.origin.x + button.titleLabel.frame.origin.x,
                              self.frame.size.height - self.indicatorHeight,
                              CGRectGetWidth(button.titleLabel.frame),
                              self.indicatorHeight);
    if (animation) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.indicator.frame = frame;
                         }];
    } else {
        self.indicator.frame = frame;
    }
}

#pragma mark - Getters

- (BOOL)isSelectedSegmentAtIndex:(NSUInteger)index {
    return (index == self.currentSelected);
}

- (NSUInteger)numberOfSegments {
    return self.segments.count;
}

#pragma mark - Setters

- (void)setSegmentAtIndex:(NSUInteger)index enabled:(BOOL)enabled {
    if (index >= self.segments.count) {
        return;
    }
    UIButton *button = self.segments[index];
    [button setEnabled:enabled];
    [button setUserInteractionEnabled:enabled];
}

- (void)updateSegmentsFormat {
    // Setting border color
    if (self.borderColor) {
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = self.borderColor.CGColor;
    } else {
        self.layer.borderWidth = 0;
    }
    if (self.cornerRadius > 0) {
        // Applying corners
        self.layer.masksToBounds = YES;
    } else {
        self.layer.masksToBounds = NO;
    }
    self.layer.cornerRadius = self.cornerRadius;

    // Modifying buttons with current State
    for (UIButton *segment in self.segments) {
        if (self.borderColor) {
            segment.layer.borderWidth = self.borderWidth / 2;
            segment.layer.borderColor = self.borderColor.CGColor;
        } else {
            segment.layer.borderWidth = 0;
        }
        // Setting format depending on if it's selected or not
        NSUInteger index = [self.segments indexOfObject:segment];
        YCSegmentItem *item = self.items[index];
        if (index == self.currentSelected) {
            // Selected-one
            [segment setBackgroundColor:self.selectedColor];
            if (self.selectedTextAttributes) {
                NSAttributedString *title = [[NSAttributedString alloc]
                    initWithString:item.title
                        attributes:self.selectedTextAttributes];
                [segment setAttributedTitle:title forState:UIControlStateNormal];
            }
        } else {
            // Non selected
            [segment setBackgroundColor:self.color];
            if (self.textAttributes) {
                NSAttributedString *title =
                    [[NSAttributedString alloc] initWithString:item.title
                                                    attributes:self.textAttributes];
                [segment setAttributedTitle:title forState:UIControlStateNormal];
            }
        }
        [segment layoutIfNeeded];
    }
    if (self.style == YCSegmentedControlStyleIndicator) {
        [self bringSubviewToFront:self.indicator];
    }
}

- (void)setItems:(NSArray<YCSegmentItem *> *)items {
    _items = items;
    [self addItems:items withFrame:self.frame];
    [self updateSegmentsFormat];
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)index {
    // Getting the Segment
    if (index < self.items.count) {
        YCSegmentItem *segment = self.items[index];
        if ([title isKindOfClass:[NSString class]]) {
            segment.title = title;
        }
    }
    [self updateSegmentsFormat];
}

- (void)setSelected:(BOOL)selected segmentAtIndex:(NSUInteger)index {
    if (selected) {
        self.currentSelected = index;
        [self updateSegmentsFormat];
        [self segmentAnimation:YES];
    }
}

@end
