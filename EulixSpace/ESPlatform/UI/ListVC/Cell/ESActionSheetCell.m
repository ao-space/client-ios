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
//  ESSortSheetCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESActionSheetCell.h"

@interface ESActionSheetCell ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *selectedIcon;

@end

@implementation ESActionSheetCell

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
    [self.contentView addSubview:self.selectedIcon];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).inset(24.0f);
        make.width.mas_equalTo(24.0f);
        make.height.mas_equalTo(24.0f);
    }];
    
    [self.selectedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).inset(24.0f);
        make.width.mas_equalTo(24.0f);
        make.height.mas_equalTo(24.0f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.icon.mas_trailing).inset(10.0f);
        make.trailing.mas_equalTo(self.selectedIcon.mas_leading).inset(10.0f);
        make.height.mas_equalTo(22.0f);
    }];
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _icon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = ESFontPingFangMedium(16);
    }
    return _titleLabel;
}

- (UIImageView *)selectedIcon {
    if (!_selectedIcon) {
        _selectedIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _selectedIcon;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESSwitchCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(iconName)] &&
           [data respondsToSelector:@selector(title)] &&
           [data respondsToSelector:@selector(isSelected)])) {
        ESDLog(@"[ESSwitchCell] [bindData] data type error");
        return;
    }
    id<ESActionSheetCellModelProtocol> cellModel = (id <ESActionSheetCellModelProtocol>)data;
    
    BOOL canSelectedType = YES;
    if ([data respondsToSelector:@selector(canSelectedType)] &&
        [data respondsToSelector:@selector(unSelecteableIconName)] &&
        cellModel.unSelecteableIconName.length > 0) {
        canSelectedType = cellModel.canSelectedType;
    }
    
    self.icon.image = canSelectedType == YES ?
                                      ((cellModel.isSelectedTyple && cellModel.isSelected) ?
                               [UIImage imageNamed:cellModel.selectedIconName] : [UIImage imageNamed:cellModel.iconName])  : [UIImage imageNamed:cellModel.unSelecteableIconName];
    self.titleLabel.text = cellModel.title;
    self.titleLabel.textColor = canSelectedType == YES ?
                              ((cellModel.isSelectedTyple && cellModel.isSelected) ? ESColor.primaryColor :ESColor.labelColor) : ESColor.secondaryLabelColor;
    
    self.selectedIcon.image =  (cellModel.isSelectedTyple && cellModel.isSelected) ?  [UIImage imageNamed:@"sort_selected"] : nil;
    
    if (self.icon.image == nil) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.leading.mas_equalTo(self.icon.mas_leading);
            make.trailing.mas_equalTo(self.selectedIcon.mas_leading).inset(10.0f);
            make.height.mas_equalTo(22.0f);
        }];
    }
    else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.leading.mas_equalTo(self.icon.mas_trailing).inset(10.0f);
            make.trailing.mas_equalTo(self.selectedIcon.mas_leading).inset(10.0f);
            make.height.mas_equalTo(22.0f);
        }];
    }
}

@end
