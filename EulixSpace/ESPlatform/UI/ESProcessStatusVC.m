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
//  ESProcessStatusVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/4/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESProcessStatusVC.h"
#import "ESProcessView.h"

@interface ESProcessStatusVC ()

@property (nonatomic, strong) UIView *processContainerView;
@property (nonatomic, strong) UILabel *processMessageLabel;
@property (nonatomic, strong) ESProcessView *progressView;

@end

@implementation ESProcessStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    [self.view addSubview:self.processContainerView];
    [self.processContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
        make.width.mas_offset(270.0f);
        make.height.mas_offset(78.0f);
    }];
    
    [self.processContainerView addSubview:self.processMessageLabel];
    [self.processMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.processContainerView.mas_left).mas_offset(20.0f);
        make.top.mas_equalTo(self.processContainerView.mas_top).mas_offset(20.0f);
        make.width.mas_offset(120.0f);
        make.height.mas_offset(22.0f);
    }];
    
    [self.processContainerView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.processContainerView.mas_left).mas_offset(20.0f);
        make.right.mas_equalTo(self.processContainerView.mas_right).mas_offset(-20.0f);
        make.top.mas_equalTo(self.processMessageLabel.mas_bottom).mas_offset(10.0f);
        make.height.mas_offset(6.0f);
    }];
}

- (void)updateProcess:(CGFloat)process {
    _progressView.progressValue = process;
}

- (UIView *)processContainerView {
    if (!_processContainerView) {
        _processContainerView = [[UIView alloc] init];
        _processContainerView.backgroundColor = ESColor.systemBackgroundColor;
        _processContainerView.layer.cornerRadius = 12.0;
        _processContainerView.clipsToBounds = YES;
    }
    return _processContainerView;
}

- (UILabel *)processMessageLabel {
    if (_processMessageLabel == nil) {
        _processMessageLabel = [[UILabel alloc] init];
        _processMessageLabel.textColor = ESColor.labelColor;
        _processMessageLabel.textAlignment = NSTextAlignmentLeft;
        _processMessageLabel.font = ESFontPingFangRegular(14);
    }
    return _processMessageLabel;
}


- (ESProcessView *)progressView {
    if (_progressView == nil) {
        //滑动条
        _progressView = [[ESProcessView alloc] init];
    }
    return _progressView;
}

@end
