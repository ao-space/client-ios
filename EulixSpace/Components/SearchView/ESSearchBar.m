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
//  ESSearchBar.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/24.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSearchBar.h"
#import "ESImageDefine.h"
#import "ESThemeDefine.h"

@interface ESSearchBar () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation ESSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = ESColor.systemBackgroundColor;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    //    //[self addSubview:self.cancelButton];
    //    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.top.bottom.equalTo(self);
    //        make.width.equalTo(@(47));
    //    }];

    self.textField.frame = CGRectMake(10, 5, width - 10, height - 10);
    [self addSubview:self.textField];
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelButton addTarget:self action:@selector(cancleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (void)setActive:(BOOL)active {
    _active = active;
    if (!active) {
        self.textField.text = nil;
        self.hideCancelButton = YES;
    }
}

#pragma mark - delegate
#pragma mark textField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.keyText) {
        NSString *keyString = [NSString stringWithFormat:@"%@ ", self.keyText];
        NSRange keyRange = [self.textField.text rangeOfString:keyString];
        if (range.location < keyRange.length) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarClearAction:)]) {
        [self.delegate searchBarClearAction:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _active = YES;
    if ([self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:)]) {
        [self.delegate searchBarDidBeginEditing:self];
    } else {
        self.hideCancelButton = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarDidEndEditing:)]) {
        [self.delegate searchBarDidEndEditing:self];
    }
}

#pragma mark 输入改变通知

- (void)editingChanged:(UITextField *)textField {
    UITextRange *selectedRange = [textField markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 有高亮选择的字，说明不是拼音输入
    if (position) {
        return;
    }
    NSString *searchString = self.textField.text;
    if (self.keyText && ![@"" isEqualToString:searchString]) {
        searchString = [searchString substringFromIndex:self.keyText.length + 1];
    }
    if ([self.delegate respondsToSelector:@selector(searchBar:keyText:textFielDidChangeText:)]) {
        [self.delegate searchBar:self keyText:self.keyText textFielDidChangeText:searchString];
    }
    if (textField.text.length == 0) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    } else {
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }
}

#pragma mark - 事件
#pragma mark 取消

- (void)cancleButtonAction:(UIButton *)sender {
    _active = NO;
    if ([self.delegate respondsToSelector:@selector(searchBarCancelAction:)]) {
        [self.delegate searchBarCancelAction:self];
    } else {
        self.textField.text = @"";
        [self.textField resignFirstResponder];
        self.hideCancelButton = YES;
        [self textFieldDidEndEditing:self.textField];
    }
}

#pragma mark 返回

- (void)backButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(searchBarBackAction:)]) {
        [self.delegate searchBarBackAction:self];
    }
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = ESColor.systemBackgroundColor;
        _textField.layer.cornerRadius = 5;
        _textField.layer.masksToBounds = YES;
        _textField.placeholder = TEXT_FILE_SEARCH_ALL;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.textColor = ESColor.labelColor;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.returnKeyType = UIReturnKeySearch;
        [_textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
        _textField.delegate = self;
        _textField.leftView = ({
            CGFloat imageWidth = 11;
            CGFloat imageLeftSpace = 8.5;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
            UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageLeftSpace, 0, imageWidth, imageWidth)];
            searchImageView.center = CGPointMake(searchImageView.center.x, view.bounds.size.height * 0.5);
            searchImageView.image = IMAGE_MAIN_SEARCH;
            [view addSubview:searchImageView];
            view;
        });
    }
    return _textField;
}

- (void)setHideCancelButton:(BOOL)hideCancelButton {
    if (_hideCancelButton == hideCancelButton) {
        return;
    }
    _hideCancelButton = hideCancelButton;
    if (hideCancelButton) {
        self.cancelButton.hidden = YES;
        CGRect frame = self.textField.frame;
        frame.size.width += 40;
        [UIView animateWithDuration:0.38
                         animations:^{
                             self.textField.frame = frame;
                         }];
    } else {
        self.cancelButton.hidden = NO;
        CGRect frame = self.textField.frame;
        frame.size.width -= 40;
        [UIView animateWithDuration:0.38
                         animations:^{
                             self.textField.frame = frame;
                         }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setPlaceStr:(NSString *)placeStr{
    _placeStr = placeStr;
    if(placeStr.length > 0){
        _textField.placeholder = placeStr;
    }
}


@end
