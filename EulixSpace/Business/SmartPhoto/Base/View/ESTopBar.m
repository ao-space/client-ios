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
//  ESTopBar.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTopBar.h"
#import "ESSearchBarView.h"
#import "ESTransferListBtn.h"
#import "ESSearchListVC.h"

@interface ESTopBar () <ESSearchBarViewDelegate>

@property (nonatomic, strong) ESSearchBarView *searchBar;
@property (nonatomic, strong) ESTransferListBtn *transferListBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@end

@implementation ESTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (void)refreshStatus {
    [self.transferListBtn refreshStatus];
}

- (void)setupSubViews {
    _searchBar = [[ESSearchBarView alloc] initWithSearchDelegate:self];
    _searchBar.searchInput.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTapAction:)];
    [_searchBar addGestureRecognizer:tapGes];
    
    [self addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(22.0f);
        make.right.mas_equalTo(self.mas_right).offset(-127.0f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(46.0f);
    }];
    
    [self addSubview:self.transferListBtn];
    [_transferListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchBar.mas_right).offset(15.0f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];
    
    [self addSubview:self.moreBtn];
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-14.0f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];
}

- (ESTransferListBtn *)transferListBtn {
    if (!_transferListBtn) {
        _transferListBtn = [[ESTransferListBtn alloc] initWithFrame:CGRectZero];
    }
    return _transferListBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtn setImage:[UIImage imageNamed:@"smart_photo_more"] forState:UIControlStateNormal];
    }
    return _moreBtn;
}

- (void)moreAction:(UIButton *)bt {
    if (_moreActionBlock) {
        _moreActionBlock();
    }
}

- (void)searchTapAction:(id *)sender {
    if (self.searchActionBlock) {
        self.searchActionBlock();
    }
}

@end
