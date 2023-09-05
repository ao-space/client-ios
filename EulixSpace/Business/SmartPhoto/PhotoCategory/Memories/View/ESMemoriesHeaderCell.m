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
//  ESMemoriesHeaderCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesHeaderCell.h"
#import "ESPicModel.h"
#import "UIImageView+ESSmartPhotoThumbDownload.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "UIButton+ESTouchArea.h"
#import "NSDate+Format.h"
#import "UIImageView+ESSmartPhotoThumbDownload.h"

@interface ESMemoriesHeaderCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *playBt;

@end

@implementation ESMemoriesHeaderCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        self.contentView.backgroundColor = [ESColor colorWithHex:0xF0F1F6];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).offset(-20.0f);
        make.left.mas_equalTo(self.contentView).offset(26.0f);
        make.size.mas_equalTo(CGSizeMake(300, 20));
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.timeLabel.mas_top).offset(-4.0f);
        make.left.mas_equalTo(self.timeLabel.mas_left);
        make.size.mas_equalTo(CGSizeMake(300, 30));
    }];
    
    [self.contentView addSubview:self.playBt];
    [self.playBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-14.0f);
        make.bottom.mas_equalTo(self.contentView).offset(-20.0f);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = ESColor.darkTextColor;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ESColor.lightTextColor;
        _titleLabel.font = ESFontPingFangMedium(24);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = ESColor.lightTextColor;
        _timeLabel.font = ESFontPingFangMedium(14);
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UIButton *)playBt {
    if (!_playBt) {
        _playBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_playBt setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [_playBt setTitle:nil forState:UIControlStateNormal];
        [_playBt addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [_playBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _playBt;
}

- (void)playAction {
    if (self.playActionBlock) {
        self.playActionBlock();
    }
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[ESPicModel class]]) {
        return;
    }
    ESPicModel *picModel = (ESPicModel *)data;
    picModel = [ESSmartPhotoDataBaseManager.shared getPicByUuid:picModel.uuid];
    self.titleLabel.text = self.titleText;
    self.timeLabel.text = self.timeText;
    [self.timeLabel sizeToFit];
    CGSize size = self.timeLabel.frame.size;
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size.width + 12, 24));
    }];
    self.imageView.image = [UIImage imageNamed:@"banner_placehold_icon"];
    self.imageView.contentMode = UIViewContentModeCenter;
    
    [self.imageView es_setCompressImageWithUuid:picModel.uuid placeholderImageName:@"banner_placehold_icon"];
    
    self.playBt.hidden = !self.showPlayerEnter;
}

@end
