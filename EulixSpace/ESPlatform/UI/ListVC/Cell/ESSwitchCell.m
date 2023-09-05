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
//  ESSwitchCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSwitchCell.h"
#import "UIImageView+ESWebImageView.h"


@interface ESSwitchCell ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, weak) id<ESSwitchCellChangeProtocol> observer;

@end

@implementation ESSwitchCell

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
    [self.contentView addSubview:self.switchView];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).inset(26.0f);
        make.width.mas_equalTo(30.0f);
        make.height.mas_equalTo(30.0f);
    }];
    
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).inset(28.0f);
        make.width.mas_equalTo(50.0f);
        make.height.mas_equalTo(30.0f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.icon.mas_trailing).inset(10.0f);
        make.trailing.mas_equalTo(self.switchView.mas_leading).inset(10.0f);
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
        _titleLabel.font = ESFontPingFangRegular(16);
    }
    return _titleLabel;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchView addTarget:self action:@selector(switchViewAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESSwitchCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(iconUrl)] &&
           [data respondsToSelector:@selector(title)] &&
           [data respondsToSelector:@selector(switchOn)] &&
           [data respondsToSelector:@selector(iconUrl)] &&
           [data respondsToSelector:@selector(defaultIconName)]) ) {
        ESDLog(@"[ESSwitchCell] [bindData] bindData data type error");
        return;
    }
    id<ESSwitchCellModelProtocol> cellModel = (id <ESSwitchCellModelProtocol>)data;
    [self.icon es_setImageWithURL:cellModel.iconUrl placeholderImageName:cellModel.defaultIconName];
    self.titleLabel.text = cellModel.title;
    self.switchView.on = cellModel.switchOn;
}

- (void)switchViewAction:(UISwitch *)sender {
    if ([self.observer respondsToSelector:@selector(switchCell:valueChanged:)]) {
        [self.observer switchCell:self valueChanged:self.switchView.on];
    }
}

- (void)registerObserver:(id<ESSwitchCellChangeProtocol>)observer {
    self.observer = observer;
}

- (void)setSwitchOn:(BOOL)switchOn {
    self.switchView.on = switchOn;
}

@end
