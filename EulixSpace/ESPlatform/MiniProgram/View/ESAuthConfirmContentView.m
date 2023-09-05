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
//  ESAuthConfirmContentView.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthConfirmContentView.h"

@interface ESAuthConfirmContentView ()

@property (nonatomic, strong) UIView *line;

@end

@implementation ESAuthConfirmContentView

- (instancetype)initWithFrame:(CGRect)frame {

   self = [super initWithFrame:frame];
   if (self) {
       [self setupViews];
   }
   return self;
}

- (void)setupViews {
   self.backgroundColor = ESColor.systemBackgroundColor;
  
   [self addSubview:self.userIcon];
   
   [self.userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.mas_top).offset(20.0f);
       make.left.mas_equalTo(self.mas_left).offset(20.0f);
       make.height.width.mas_equalTo(40.0f);
   }];
   
   [self addSubview:self.nameLabel];
   [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(self.userIcon.mas_right).offset(10.0f);
       make.right.mas_equalTo(self.mas_right).offset(-20.0f);
       make.top.mas_equalTo(self.userIcon.mas_top);
       make.height.mas_equalTo(20.0f);
   }];
   
   [self addSubview:self.domainLabel];
   [self.domainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(self.nameLabel.mas_left);
       make.right.mas_equalTo(self.mas_right).offset(-20.0f);
       make.top.mas_equalTo(self.nameLabel.mas_bottom);
       make.height.mas_equalTo(17.0f);
   }];
   
   [self addSubview:self.line];
   [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(self.mas_left).offset(20.0f);
       make.right.mas_equalTo(self.mas_right).offset(-20.0f);
       make.top.mas_equalTo(self.mas_bottom).offset(-1.0f);
       make.height.mas_equalTo(1.0f);
   }];
}

- (UIImageView *)userIcon {
   if (!_userIcon) {
       _userIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
       _userIcon.layer.cornerRadius = 20.0f;
       _userIcon.clipsToBounds = YES;
   }
   return _userIcon;
}

- (UILabel *)nameLabel {
   if (!_nameLabel) {
       _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
       _nameLabel.textColor = ESColor.labelColor;
       _nameLabel.font = ESFontPingFangMedium(14);
   }
   return _nameLabel;
}

- (UILabel *)domainLabel {
   if (!_domainLabel) {
       _domainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
       _domainLabel.textColor = ESColor.secondaryLabelColor;
       _domainLabel.font = ESFontPingFangMedium(12);
   }
   return _domainLabel;
}


- (UIView *)line {
   if (!_line) {
       _line = [[UIView alloc] initWithFrame:CGRectZero];
       _line.backgroundColor = [ESColor colorWithHex:0xF7F7F9];
   }
   return _line;
}

- (CGFloat)contentHeight {
    return 80.0f;
}
@end
