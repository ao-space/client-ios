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
//  ESSearchView.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ESSearchBarView;
@protocol ESSearchBarViewDelegate <NSObject>

@optional
- (void)searchBarDidChange:(ESSearchBarView *)searchBar; //输入发生变化
- (void)searchBarDidEnter:(ESSearchBarView *)searchBar; //触发搜索
- (void)searchBarDidClear:(ESSearchBarView *)searchBar;  //清除搜索关键字
- (void)searchBarDidCancel:(ESSearchBarView *)searchBar; //取消搜索

@end

@interface ESSearchBarView : UIView

@property (nonatomic, copy, readonly) NSString *searchWord;

@property (nonatomic, copy) NSString *placeholderName;

@property (nonatomic, readonly) UITextField *searchInput;

- (instancetype)initWithSearchDelegate:(id<ESSearchBarViewDelegate>)delegate;
- (void)setDefaultTipWord:(NSString *)tipWord;
- (void)updateSearchBarText:(NSString *)searchWord;

@end


NS_ASSUME_NONNULL_END
