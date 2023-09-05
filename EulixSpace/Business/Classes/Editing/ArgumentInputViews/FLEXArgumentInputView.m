/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  FLEXArgumentInputView.m
//  Flipboard
//
//  Created by Ryan Olson on 5/30/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXArgumentInputView.h"
#import "FLEXUtility.h"
#import "FLEXColor.h"

@interface FLEXArgumentInputView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) NSString *typeEncoding;

@end

@implementation FLEXArgumentInputView

- (instancetype)initWithArgumentTypeEncoding:(const char *)typeEncoding {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.typeEncoding = typeEncoding != NULL ? @(typeEncoding) : nil;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.showsTitle) {
        CGSize constrainSize = CGSizeMake(self.bounds.size.width, CGFLOAT_MAX);
        CGSize labelSize = [self.titleLabel sizeThatFits:constrainSize];
        self.titleLabel.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.titleLabel.backgroundColor = backgroundColor;
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqual:title]) {
        _title = title;
        self.titleLabel.text = title;
        [self setNeedsLayout];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [[self class] titleFont];
        _titleLabel.textColor = FLEXColor.primaryTextColor;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (BOOL)showsTitle {
    return self.title.length > 0;
}

- (CGFloat)topInputFieldVerticalLayoutGuide {
    CGFloat verticalLayoutGuide = 0;
    if (self.showsTitle) {
        CGFloat titleHeight = [self.titleLabel sizeThatFits:self.bounds.size].height;
        verticalLayoutGuide = titleHeight + [[self class] titleBottomPadding];
    }
    return verticalLayoutGuide;
}


#pragma mark - Subclasses Can Override

- (BOOL)inputViewIsFirstResponder {
    return NO;
}

+ (BOOL)supportsObjCType:(const char *)type withCurrentValue:(id)value {
    return NO;
}


#pragma mark - Class Helpers

+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:12.0];
}

+ (CGFloat)titleBottomPadding {
    return 4.0;
}


#pragma mark - Sizing

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    
    if (self.title.length > 0) {
        CGSize constrainSize = CGSizeMake(size.width, CGFLOAT_MAX);
        height += ceil([self.titleLabel sizeThatFits:constrainSize].height);
        height += [[self class] titleBottomPadding];
    }
    
    return CGSizeMake(size.width, height);
}

@end
