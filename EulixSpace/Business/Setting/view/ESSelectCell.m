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
//  ESSelectCell.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSelectCell.h"

@interface ESSelectCell()
@property (nonatomic, strong) UIImageView * selectIv;
@end

@implementation ESSelectCell


- (void)setModel:(ESCellModel *)model {
    [super setModel:model];
    
    self.selectIv.hidden = !model.isSelected;
    if (model.isSelected) {
        [self setTitleColor:[UIColor es_colorWithHexString:@"#337AFF"]];
    } else {
        [self setTitleColor:[UIColor es_colorWithHexString:@"#333333"]];
    }
}

- (void)initViews {
    [super initViews];
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_selected"]];
    [self.contentView addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-29);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(24);
    }];
    self.selectIv = iv;
}

- (void)dealloc {
}

@end
