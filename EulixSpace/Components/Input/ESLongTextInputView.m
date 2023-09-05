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
//  ESLongTextInputView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLongTextInputView.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESLongTextInputView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UILabel *placeholderLable;

@property (nonatomic, strong) UILabel *count;

@end

@implementation ESLongTextInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.textView.delegate = self;
    [self initUI];
    return self;
}

- (void)initUI {
    self.backgroundColor = ESColor.clearColor;
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).inset(12);
        make.right.mas_equalTo(self.mas_right).inset(12);
        make.top.mas_equalTo(self.mas_top).inset(8);
        make.bottom.mas_equalTo(self.mas_bottom).inset(24);
    }];

    [self.placeholderLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textView.mas_left).offset(4.5);
        make.top.mas_equalTo(self.textView.mas_top).offset(1);
        make.right.mas_equalTo(self.textView.mas_right).offset(-4.5);
    }];

    [self.count mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self).inset(10);
        make.bottom.mas_equalTo(self.mas_bottom).inset(10);
        make.height.mas_equalTo(10);
    }];
    self.count.text = [NSString stringWithFormat:@"（%zd/%@）", self.textView.text.length, self.wordsLimit];
}

#pragma mark - textView

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        self.placeholderLable.text = @"";
    } else {
        self.placeholderLable.text = self.placeholderText;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    NSString *newText = [textView textInRange:selectedRange];
    if (!newText.length) {
        if (textView.text.length > self.wordsLimit.integerValue) {
            textView.text = [textView.text substringToIndex:self.wordsLimit.integerValue];
        }
    }
    self.count.text = [NSString stringWithFormat:@"（%zd/%@）", textView.text.length, self.wordsLimit];
    if (self.textDidChangeResultBlock) {
        self.textDidChangeResultBlock(textView.text);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!self.canInputEnter && [text isEqualToString:@"\n"]) {
        if (self.enterBlock) {
            self.enterBlock(textView.text);
        }
        return NO;
    }
    return YES;
}

#pragma mark - Lazy Load

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = placeholderText;
    self.placeholderLable.text = placeholderText;
}

- (void)setText:(NSString *)text {
    if (text.length > self.wordsLimit.integerValue) {
        _text = [text substringToIndex:self.wordsLimit.integerValue];
    } else {
        _text = text;
    }
    self.textView.text = _text;
    if (text.length > 0) {
        self.placeholderLable.text = @"";
    } else {
        self.placeholderLable.text = self.placeholderText ?: @"";
    }
    self.count.text = [NSString stringWithFormat:@"（%zd/%@）", _text.length, self.wordsLimit];
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [UITextView new];
        _textView.backgroundColor = ESColor.clearColor;
        _textView.textColor = ESColor.labelColor;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.contentInset = UIEdgeInsetsZero;
        [self addSubview:_textView];
    }
    return _textView;
}

- (UILabel *)placeholderLable {
    if (!_placeholderLable) {
        _placeholderLable = [UILabel new];
        _placeholderLable.backgroundColor = ESColor.clearColor;
        _placeholderLable.textColor = ESColor.disableTextColor;
        _placeholderLable.font = [UIFont systemFontOfSize:16];
        _placeholderLable.lineBreakMode = NSLineBreakByWordWrapping;
        _placeholderLable.numberOfLines = 0;
        _placeholderLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_placeholderLable];
    }
    return _placeholderLable;
}

- (UILabel *)count {
    if (!_count) {
        _count = [UILabel new];
        _count.textAlignment = NSTextAlignmentRight;
        _count.textColor = ESColor.secondaryLabelColor;
        _count.font = [UIFont systemFontOfSize:10];
        [self addSubview:_count];
    }
    return _count;
}

@end
