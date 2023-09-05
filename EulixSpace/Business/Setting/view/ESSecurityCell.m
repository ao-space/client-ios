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
//  ESSecurityCell.m
//  EulixSpace
//
//  Created by dazhou on 2023/2/10.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSecurityCell.h"

@implementation ESSecurityCell

- (void)setModel:(ESCellModel *)model {
    [super setModel:model];
    
    self.mDescribeLabel.text = model.describeContent;
    if (model.describeContent && model.describeContent.length > 0) {
        [self.mDescribeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(26);
            make.top.mas_equalTo(self.mTitleLabel.mas_bottom).offset(10);
            make.bottom.mas_equalTo(self.contentView).offset(-19);
            make.right.mas_equalTo(self.contentView).offset(-26);
        }];
    } else {
        [self.mDescribeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(26);
            make.top.mas_equalTo(self.mTitleLabel.mas_bottom).offset(0);
            make.bottom.mas_equalTo(self.contentView).offset(-19);
            make.right.mas_equalTo(self.contentView).offset(-26);
        }];
    }
}

- (void)initViews {
    [super initViews];
    
    UILabel * label = [[UILabel alloc] init];
    label.font = ESFontPingFangRegular(12);
    label.numberOfLines = 0;
    label.textColor = [UIColor es_colorWithHexString:@"#85899C"];
    [self.contentView addSubview:label];
    self.mDescribeLabel = label;
    
    [self.mTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(26);
        make.top.mas_equalTo(self.contentView).offset(19);
        make.right.mas_equalTo(self.contentView).offset(-150);
    }];
    
    [self.mDescribeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(26);
        make.top.mas_equalTo(self.mTitleLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.contentView).offset(-19);
        make.right.mas_equalTo(self.contentView).offset(-26);
    }];
    
    [self.arrowIv mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.centerY.mas_equalTo(self.mTitleLabel);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(16);
    }];
    
    [self.mContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mTitleLabel);
        make.left.mas_greaterThanOrEqualTo(self.mTitleLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.arrowIv.mas_left).offset(-10);
    }];
}

@end
