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
//  ESAvatarCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/10.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESAvatarCell.h"

@implementation ESAvatarlItem
@end

@interface ESAvatarCell ()
@property (nonatomic, strong) UIImageView *nextIcon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) id<ESAvatarItemProtocol> cellModel;

@end

@implementation ESAvatarCell

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
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    [self.contentView addSubview:self.nextIcon];
    [self.nextIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView).inset(26);
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.contentView.mas_top).inset(19);
        make.left.mas_equalTo(self.contentView).inset(26);
        make.right.mas_equalTo(self.contentView).inset(58);
    }];
    
    [self.contentView addSubview:self.avatar];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).inset(52);
    }];
}

- (void)bindData:(id)data {
    ESDLog(@"[ESAvatarCell] [bindData] bindData data: %@", data);
    
    if (! ([data respondsToSelector:@selector(title)])) {
        ESDLog(@"[ESAvatarCell] [bindData] bindData data type error");
        return;
    }
    id<ESAvatarItemProtocol> cellModel = (id <ESAvatarItemProtocol>)data;
    self.cellModel = cellModel;
    
    self.titleLabel.text = cellModel.title;
    self.nextIcon.hidden = !cellModel.hasNextStep;
    self.avatar.image = cellModel.image;
}

- (UIImageView *)nextIcon {
    if (!_nextIcon) {
        _nextIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _nextIcon.image = [UIImage imageNamed:@"file_copyback"];
    }
    return _nextIcon;
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
- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = 15;
    }
    return _avatar;
}

@end
