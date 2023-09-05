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
//  ESSearchBar.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/24.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESSearchBarDelegate;

@interface ESSearchBar : UIView

@property (nonatomic, weak) id<ESSearchBarDelegate> delegate;

@property (nonatomic, assign) BOOL active;

@property (nonatomic, assign) BOOL hideCancelButton;

@property (nonatomic, copy) NSString *keyText;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, copy) NSString *placeStr;

@end

@protocol ESSearchBarDelegate <NSObject>

@optional

- (void)searchBarDidBeginEditing:(ESSearchBar *)searchBar;

- (void)searchBarDidEndEditing:(ESSearchBar *)searchBar;

- (void)searchBarBackAction:(ESSearchBar *)searchBar;

- (void)searchBarCancelAction:(ESSearchBar *)searchBar;

- (void)searchBarClearAction:(ESSearchBar *)searchBar;

- (void)searchBar:(ESSearchBar *)searchBar keyText:(NSString *)keyText textFielDidChangeText:(NSString *)text;

@end
