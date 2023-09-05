//
//  YCGridViewCell.m
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/22.
//
//

#import "YCGridViewCell.h"

@implementation YCGridViewPosition

@end

@interface YCGridViewItem ()

@property (nonatomic, strong) NSDictionary *themeAttributes;

@end

@implementation YCGridViewItem

- (void)_privateSetThemeAttributes:(NSDictionary *)themeAttributes {
    self.themeAttributes = themeAttributes;
}

@end

@implementation YCGridViewLabel

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

@end

@interface YCGridViewCell ()

@property (nonatomic, strong) YCGridViewLabel *content;

@property (nonatomic, strong) CAShapeLayer *separator;

@property (nonatomic, strong) YCGridViewItem *data;

@property (nonatomic, strong) NSMutableDictionary *attributes;

@end

@implementation YCGridViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.content];
}

- (void)presetData:(YCGridViewItem *)data {
    self.data = data;
}

- (void)reloadWithData:(YCGridViewItem *)data {
    self.contentView.frame = self.bounds; //some bug.resize it manually
    self.data = data;
    _attributes = [data.themeAttributes mutableCopy];
    if (self.willDisplayBlock) {
        self.willDisplayBlock();
    }
    CGRect frame = self.contentView.bounds;
    if (data.columnPosition == YCGridViewCellTableColumnPositionFirst) {
        frame.origin.x += kYCGridViewExtraOffset;
        frame.size.width -= kYCGridViewExtraOffset;
    }
    self.content.frame = frame;
    [self updateContentWithAttributes:self.attributes];
    self.contentView.backgroundColor = self.attributes[YCGridViewBackgroundColorAttributeName];
    if (data.selected && data.selectedColor) {
        self.contentView.backgroundColor = data.selectedColor;
    }
}

- (void)updateContentWithAttributes:(NSDictionary *)attributes {
    NSMutableDictionary *contentAttributes = [NSMutableDictionary dictionary];
    contentAttributes[NSFontAttributeName] = attributes[NSFontAttributeName];
    contentAttributes[NSForegroundColorAttributeName] = attributes[NSForegroundColorAttributeName];
    NSString *plainText = [self.data.data description];
    if (attributes.count > 0 && plainText.length > 0) {
        NSMutableAttributedString *attributedText = [self.content.attributedText mutableCopy];
        if (![attributedText.string isEqualToString:plainText]) {
            attributedText = [[NSMutableAttributedString alloc] initWithString:plainText attributes:attributes];
        } else {
            [attributedText addAttributes:attributes range:NSMakeRange(0, attributedText.length)];
        }
        self.content.attributedText = attributedText;
    } else {
        self.content.text = plainText;
    }
    if (attributes[YCGridViewSeparatorStyleAttributeName]) { //with separator style
        [self updateSeparator:attributes];
    }
}

- (void)updateSeparator:(NSDictionary *)attributes {
    NSNumber *styleNumber = attributes[YCGridViewSeparatorStyleAttributeName];
    if (styleNumber == nil) {
        _separator.hidden = YES;
        return;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    UIBezierPath *path = [UIBezierPath bezierPath];
    YCGridViewCellSeparatorStyle style = [styleNumber integerValue];
    UIColor *color = attributes[YCGridViewSeparatorColorAttributeName];
    NSNumber *lineWidthNumber = attributes[YCGridViewSeparatorWidthAttributeName];
    CGFloat lineWidth = MAX(0.5, lineWidthNumber.floatValue);
    if (lineWidthNumber != nil) {
        self.separator.lineWidth = lineWidth;
    } else {
        NSNumber *presetWidth = self.attributes[YCGridViewSeparatorWidthAttributeName];
        self.separator.lineWidth = MAX(0.5, presetWidth.floatValue);
    }
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    if (style & YCGridViewCellSeparatorStyleLineBottom) {
        [path moveToPoint:CGPointMake(0, height - lineWidth)];
        [path addLineToPoint:CGPointMake(width, height - lineWidth)];
    }
    if (style & YCGridViewCellSeparatorStyleLineRight) {
        [path moveToPoint:CGPointMake(width, 0)];
        [path addLineToPoint:CGPointMake(width, height - lineWidth)];
    }
    if (style & YCGridViewCellSeparatorStyleLineLeft) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(0, height - lineWidth)];
    }
    if (style & YCGridViewCellSeparatorStyleLineTop) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(width, 0)];
    }

    self.separator.frame = self.contentView.bounds;
    if (color) {
        self.separator.strokeColor = color.CGColor;
    }
    self.separator.fillColor = nil;
    self.separator.path = path.CGPath;
    self.separator.hidden = NO;
    [CATransaction commit];
}

- (void)action {
    if (self.actionBlock) {
        self.actionBlock(@(YCGridViewTitleColumnIndex));
    }
}

- (YCGridViewLabel *)content {
    if (!_content) {
        _content = [[YCGridViewLabel alloc] initWithFrame:self.bounds];
        _content.textAlignment = NSTextAlignmentCenter;
        _content.numberOfLines = 1;
        _content.adjustsFontSizeToFitWidth = YES;
        _content.minimumScaleFactor = 0.5;
    }
    return _content;
}

- (CAShapeLayer *)separator {
    if (!_separator) {
        _separator = [CAShapeLayer layer];
        _separator.lineWidth = 0.5; //default width
        [self.contentView.layer addSublayer:_separator];
    }
    return _separator;
}

@end
