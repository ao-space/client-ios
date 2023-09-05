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
//  ESActionSheetHeadCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/18.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESActionSheetHeadCell.h"
#import "ESActionSheetItem.h"

@implementation ESActionSheetHeadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    }
    return self;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[ESActionSheetItem class]]) {
        return;
    }
    ESActionSheetItem *actionItem = (ESActionSheetItem *)data;
    if (!actionItem.isSectionHeader) {
        return;
    }
    
    self.titleLabel.text = actionItem.title;
    self.titleLabel.textColor = ESColor.secondaryLabelColor;
    self.titleLabel.font = ESFontPingFangRegular(12);
    
    if (actionItem.iconName.length <= 0) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(23.0f);
        }];
    } else {
        self.icon.image = [UIImage imageNamed:ESSafeString(actionItem.iconName)];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.icon.mas_right).offset(10.0f);
        }];
    }
}

@end
