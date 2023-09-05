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
//  ESSearchView.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSearchBarView.h"

@interface ESSearchBarView () <UITextFieldDelegate,ESSearchBarViewDelegate>

@property (nonatomic, strong) UIImageView *searchIcon;
@property (nonatomic, strong) UITextField *searchInput;

@property (nonatomic, weak) id<ESSearchBarViewDelegate> delegate;
@property (nonatomic, copy) NSString *searchWord;

@end

@implementation ESSearchBarView

- (instancetype)initWithSearchDelegate:(id<ESSearchBarViewDelegate>)delegate
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.delegate = delegate;
        self.backgroundColor = ESColor.systemBackgroundColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    _searchIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    _searchIcon.image = [[UIImage imageNamed:@"main_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    [self addSubview:_searchIcon];
    [_searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(20.0f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(18.0f);
        make.width.mas_equalTo(18.0f);
    }];
    
    [self addSubview:self.searchInput];
    [_searchInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right).offset(10.0f);
        make.right.mas_equalTo(self.mas_right).offset(-10.0f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20.0f);
    }];
}

- (void)updateSearchBarText:(NSString *)searchWord {
    self.searchWord = searchWord;
    self.searchInput.text = searchWord;
}


- (UITextField *)searchInput {
    if (!_searchInput) {
        _searchInput = [[UITextField alloc] initWithFrame:CGRectZero];
        
        _searchInput.delegate = self;
        _searchInput.returnKeyType = UIReturnKeySearch;
        [_searchInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_searchInput addTarget:self action:@selector(textFieldDidEnter:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _searchInput.textColor = ESColor.placeholderTextColor;
        _searchInput.font = ESFontPingFangRegular(14);
        _searchInput.clearButtonMode = UITextFieldViewModeAlways;
        _searchInput.tintColor = ESColor.systemBackgroundColor;
        
        [self setClearButtonImage];
        if ([_searchInput respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            [self setDefaultTipWord:NSLocalizedString(@"File name, album name, date", @"文件、相薄名、日期")];
        }
     
      
    }
    return _searchInput;
}

- (void)setClearButtonImage {
    UIImage *searchClearImage = [UIImage imageNamed:@"icon_delete_small"];
   
    UIButton *clearButton = [self getTextFieldClearButton:_searchInput];
    clearButton.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
    [clearButton setImage:searchClearImage forState:UIControlStateNormal];
}

- (UIButton *)getTextFieldClearButton:(UITextField *)textField {
    return  [textField valueForKey:@"_clearButton"];
}

- (void)setDefaultTipWord:(NSString *)tipWord {
    _searchInput.placeholder = tipWord;
}

- (void)actionWithOperateBtn {
    if ([self.delegate respondsToSelector:@selector(searchBarDidCancel:)]) {
        [self.delegate searchBarDidCancel:self];
    }
    return;
}

- (BOOL)becomeFirstResponder {
    [self.searchInput becomeFirstResponder];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [self.searchInput resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)updateSearchWord {
    self.searchWord = self.searchInput.text;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self updateSearchWord];
    if ([self.delegate respondsToSelector:@selector(searchBarDidClear:)]) {
        [self.delegate searchBarDidClear:self];
    }
    return YES;
}

- (void)textFieldDidEnter:(UITextField *)textField {
    [self updateSearchWord];
    if ([self.delegate respondsToSelector:@selector(searchBarDidEnter:)]) {
        [self.delegate searchBarDidEnter:self];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self updateSearchWord];
    if ([self.delegate respondsToSelector:@selector(searchBarDidChange:)]) {
        [self.delegate searchBarDidChange:self];
    }
}


-(void)setPlaceholderName:(NSString *)placeholderName{
    _placeholderName = placeholderName;
    _searchInput.placeholder = placeholderName;
}
@end
