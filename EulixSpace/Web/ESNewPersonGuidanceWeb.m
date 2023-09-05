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
//  ESNewPersonGuidanceWeb.m
//  EulixSpace
//
//  Created by qu on 2021/9/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESNewPersonGuidanceWeb.h"
#import "ESPlatformClient.h"
#import "ESCommonToolManager.h"

#import <Masonry/Masonry.h>

@interface ESNewPersonGuidanceWeb ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *webViewImageView;

@property (nonatomic, strong) UIButton *delectBtn;

@end

@implementation ESNewPersonGuidanceWeb

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hideNavigationBar = YES;
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(-24.0f);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.height.mas_equalTo(ScreenHeight);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    [self.delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(64.0f);
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(18);
    }];
    
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView addSubview:self.webViewImageView];
    
    
    if (self.index != 1) {
        if ([ESCommonToolManager isEnglish]) {
            self.webViewImageView.image = [UIImage imageNamed:@"xinshouzhinan_en"];
        }else{
            self.webViewImageView.image = [UIImage imageNamed:@"xinshouzhinan"];
        }
      
        self.webViewImageView.frame = CGRectMake(0, -24, ScreenWidth, 2674);
        self.scrollView.contentSize = CGSizeMake(ScreenWidth,2674);
    } else {
        
        if ([ESCommonToolManager isEnglish]) {
            self.webViewImageView.image = [UIImage imageNamed:@"juyuwang_en"];
        }else{
            self.webViewImageView.image = [UIImage imageNamed:@"juyuwang"];
        }
        self.webViewImageView.frame = CGRectMake(0, -24, ScreenWidth, 972);
        self.scrollView.contentSize = CGSizeMake(ScreenWidth,972);
        
    }
    

  
}

- (UIImageView *)webViewImageView {
    if (!_webViewImageView) {
        _webViewImageView = [[UIImageView alloc] init];
        _webViewImageView.userInteractionEnabled = YES;
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didClickDelectBtn)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [_webViewImageView addGestureRecognizer:recognizer];
    }
    return _webViewImageView;
}


- (void)rightClick {
  
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = YES;
        //self.tableView.tableHeaderView = _scrollView;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(didClickDelectBtn) forControlEvents:UIControlEventTouchUpInside];
        //_delectBtn setImage:[UIImageView ] forState:UIControlStateNormal
//        ic_back_chevron
        [_delectBtn setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [_delectBtn setImage:[UIImage imageNamed:@"ic_back_chevron"] forState:UIControlStateNormal];
        [self.view addSubview:_delectBtn];
    }
    return _delectBtn;
}

-(void)didClickDelectBtn{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
