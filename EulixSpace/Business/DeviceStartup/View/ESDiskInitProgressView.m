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
//  ESDiskInitProgressView.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDiskInitProgressView.h"
#import "ESTransferProgressView.h"
#import "UILabel+ESTool.h"

@interface ESDiskInitProgressView()
@property (nonatomic, strong) ESTransferProgressView * progressView;
@property (nonatomic, strong) UILabel * progressLabel;
@property (nonatomic, strong) UILabel * hintLabel;
@property (nonatomic, strong) UILabel * hintLabel1;
@end

@implementation ESDiskInitProgressView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setProgress:(CGFloat)num {
    [self.progressView reloadWithRate:num];
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(num * 100)];
}

- (void)setHintString:(NSString *)text {
    self.hintLabel.text = text;
}

- (void)setHint1String:(NSString *)text {
    self.hintLabel1.text = text;
}

- (void)setupViews {
    UILabel * label = [UILabel createLabel:@"0%" font:ESFontPingFangMedium(26) color:@"#333333"];
    [self addSubview:label];
    self.progressLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(60);
        make.centerX.mas_equalTo(self);
    }];
    
    ESTransferProgressView * view = [[ESTransferProgressView alloc] init];
    [view setCornerRadius:5];
    [self addSubview:view];
    self.progressView = view;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.progressLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(10);
    }];
    
    label = [UILabel createLabel:@" " font:ESFontPingFangMedium(14) color:@"#F6222D"];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.hintLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(26);
        make.trailing.mas_equalTo(self).offset(-26);
    }];
    
    // 此过程请勿执行关机、拔出磁盘等操作
    NSString * text = NSLocalizedString(@"Disk init hint 3", @"");
    label = [UILabel createLabel:text font:ESFontPingFangMedium(14) color:@"#F6222D"];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.hintLabel1 = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.hintLabel.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(26);
        make.trailing.mas_equalTo(self).offset(-26);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
}

@end
