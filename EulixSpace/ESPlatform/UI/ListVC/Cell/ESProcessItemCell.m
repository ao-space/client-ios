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
//  ESProcessItemCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESProcessItemCell.h"

@implementation ESProcessItem
@end

@interface ESProcessItemCell ()
@end

@implementation ESProcessItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.titleLabel];
    self.contentView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    
    self.titleLabel.textColor = ESColor.labelColor;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = ESFontPingFangMedium(16);
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).inset(21.0f);
        make.width.mas_equalTo(14.0f);
        make.height.mas_equalTo(14.0f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.icon.mas_trailing).inset(4.0f);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).inset(10.0f);
        make.height.mas_equalTo(22.0f);
    }];
}

- (void)bindData:(id)data {
    ESDLog(@"[ESProcessItemCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(iconName)] &&
           [data respondsToSelector:@selector(title)])) {
        ESDLog(@"[ESProcessItemCell] [bindData] data type error");
        return;
    }
    id<ESIconTitleCellModelProtocol> cellModel = (id <ESIconTitleCellModelProtocol>)data;
    
    self.icon.image = [UIImage imageNamed:cellModel.iconName];
    self.titleLabel.text = cellModel.title;
}

@end
