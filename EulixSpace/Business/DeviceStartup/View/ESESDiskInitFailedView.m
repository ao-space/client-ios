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
//  ESESDiskInitFailedView.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESESDiskInitFailedView.h"
#import "UILabel+ESTool.h"

@interface ESESDiskInitFailedView()
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * contentLabel;
@end

@implementation ESESDiskInitFailedView


- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setTitle:(NSString *)title content:(NSString *)content {
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    [self layoutIfNeeded];
}

- (void)setupViews {
    UILabel * label = [UILabel createLabel:ESFontPingFangMedium(18) color:@"#333333"];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.titleLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(40);
        make.centerX.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(48);
        make.trailing.mas_equalTo(self).offset(-48);
    }];
    
    label = [UILabel createLabel:ESFontPingFangRegular(14) color:@"#85899C"];
    [self addSubview:label];
    self.contentLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self);
        make.leading.mas_greaterThanOrEqualTo(self).offset(48);
        make.trailing.mas_lessThanOrEqualTo(self).offset(-48);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
}

@end
