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
//  FLEXFieldEditorView.m
//  Flipboard
//
//  Created by Ryan Olson on 5/16/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXFieldEditorView.h"
#import "FLEXArgumentInputView.h"
#import "FLEXUtility.h"

@interface FLEXFieldEditorView ()

@property (nonatomic) UILabel *targetDescriptionLabel;
@property (nonatomic) UIView *targetDescriptionDivider;
@property (nonatomic) UILabel *fieldDescriptionLabel;
@property (nonatomic) UIView *fieldDescriptionDivider;

@end

@implementation FLEXFieldEditorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.targetDescriptionLabel = [UILabel new];
        self.targetDescriptionLabel.numberOfLines = 0;
        self.targetDescriptionLabel.font = [[self class] labelFont];
        [self addSubview:self.targetDescriptionLabel];
        
        self.targetDescriptionDivider = [[self class] dividerView];
        [self addSubview:self.targetDescriptionDivider];
        
        self.fieldDescriptionLabel = [UILabel new];
        self.fieldDescriptionLabel.numberOfLines = 0;
        self.fieldDescriptionLabel.font = [[self class] labelFont];
        [self addSubview:self.fieldDescriptionLabel];
        
        self.fieldDescriptionDivider = [[self class] dividerView];
        [self addSubview:self.fieldDescriptionDivider];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat horizontalPadding = [[self class] horizontalPadding];
    CGFloat verticalPadding = [[self class] verticalPadding];
    CGFloat dividerLineHeight = [[self class] dividerLineHeight];
    
    CGFloat originY = verticalPadding;
    CGFloat originX = horizontalPadding;
    CGFloat contentWidth = self.bounds.size.width - 2.0 * horizontalPadding;
    CGSize constrainSize = CGSizeMake(contentWidth, CGFLOAT_MAX);
    
    CGSize instanceDescriptionSize = [self.targetDescriptionLabel sizeThatFits:constrainSize];
    self.targetDescriptionLabel.frame = CGRectMake(originX, originY, instanceDescriptionSize.width, instanceDescriptionSize.height);
    originY = CGRectGetMaxY(self.targetDescriptionLabel.frame) + verticalPadding;
    
    self.targetDescriptionDivider.frame = CGRectMake(originX, originY, contentWidth, dividerLineHeight);
    originY = CGRectGetMaxY(self.targetDescriptionDivider.frame) + verticalPadding;
    
    CGSize fieldDescriptionSize = [self.fieldDescriptionLabel sizeThatFits:constrainSize];
    self.fieldDescriptionLabel.frame = CGRectMake(originX, originY, fieldDescriptionSize.width, fieldDescriptionSize.height);
    originY = CGRectGetMaxY(self.fieldDescriptionLabel.frame) + verticalPadding;
    
    self.fieldDescriptionDivider.frame = CGRectMake(originX, originY, contentWidth, dividerLineHeight);
    originY = CGRectGetMaxY(self.fieldDescriptionDivider.frame) + verticalPadding;

    for (UIView *argumentInputView in self.argumentInputViews) {
        CGSize inputViewSize = [argumentInputView sizeThatFits:constrainSize];
        argumentInputView.frame = CGRectMake(originX, originY, inputViewSize.width, inputViewSize.height);
        originY = CGRectGetMaxY(argumentInputView.frame) + verticalPadding;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.targetDescriptionLabel.backgroundColor = backgroundColor;
    self.fieldDescriptionLabel.backgroundColor = backgroundColor;
}

- (void)setTargetDescription:(NSString *)targetDescription {
    if (![_targetDescription isEqual:targetDescription]) {
        _targetDescription = targetDescription;
        self.targetDescriptionLabel.text = targetDescription;
        [self setNeedsLayout];
    }
}

- (void)setFieldDescription:(NSString *)fieldDescription {
    if (![_fieldDescription isEqual:fieldDescription]) {
        _fieldDescription = fieldDescription;
        self.fieldDescriptionLabel.text = fieldDescription;
        [self setNeedsLayout];
    }
}

- (void)setArgumentInputViews:(NSArray<FLEXArgumentInputView *> *)argumentInputViews {
    if (![_argumentInputViews isEqual:argumentInputViews]) {
        
        for (FLEXArgumentInputView *inputView in _argumentInputViews) {
            [inputView removeFromSuperview];
        }
        
        _argumentInputViews = argumentInputViews;
        
        for (FLEXArgumentInputView *newInputView in argumentInputViews) {
            [self addSubview:newInputView];
        }
        
        [self setNeedsLayout];
    }
}

+ (UIView *)dividerView {
    UIView *dividerView = [UIView new];
    dividerView.backgroundColor = [self dividerColor];
    return dividerView;
}

+ (UIColor *)dividerColor {
    return UIColor.lightGrayColor;
}

+ (CGFloat)horizontalPadding {
    return 10.0;
}

+ (CGFloat)verticalPadding {
    return 20.0;
}

+ (UIFont *)labelFont {
    return [UIFont systemFontOfSize:14.0];
}

+ (CGFloat)dividerLineHeight {
    return 1.0;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat horizontalPadding = [[self class] horizontalPadding];
    CGFloat verticalPadding = [[self class] verticalPadding];
    CGFloat dividerLineHeight = [[self class] dividerLineHeight];
    
    CGFloat height = 0;
    CGFloat availableWidth = size.width - 2.0 * horizontalPadding;
    CGSize constrainSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
    
    height += verticalPadding;
    height += ceil([self.targetDescriptionLabel sizeThatFits:constrainSize].height);
    height += verticalPadding;
    height += dividerLineHeight;
    height += verticalPadding;
    height += ceil([self.fieldDescriptionLabel sizeThatFits:constrainSize].height);
    height += verticalPadding;
    height += dividerLineHeight;
    height += verticalPadding;
    
    for (FLEXArgumentInputView *inputView in self.argumentInputViews) {
        height += [inputView sizeThatFits:constrainSize].height;
        height += verticalPadding;
    }
    
    return CGSizeMake(size.width, height);
}

@end
