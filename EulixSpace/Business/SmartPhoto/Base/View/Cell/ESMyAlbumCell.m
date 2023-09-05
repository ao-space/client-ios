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
//  ESMyAlbumCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMyAlbumCell.h"
#import <Masonry/Masonry.h>
#import "ESColor.h"
#import "ESToast.h"
#import "ESAlbumModel.h"
#import "UIImageView+ESSmartPhotoThumbDownload.h"

@interface ESMyAlbumCell ()

@property (nonatomic, strong) UIImageView *albumIcon;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation ESMyAlbumCell

- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.albumIcon];
    [self.albumIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-68.0f);
    }];
    
    [self.contentView addSubview:self.albumNameLabel];
    [self.albumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.albumIcon.mas_bottom).offset(10.0f);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.contentView addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.albumNameLabel.mas_bottom).offset(2.0f);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(14.0f);
    }];
}

- (UIImageView *)albumIcon {
    if (!_albumIcon) {
        _albumIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _albumIcon.layer.cornerRadius = 10.0;
        _albumIcon.contentMode = UIViewContentModeScaleAspectFill;
        _albumIcon.layer.masksToBounds = YES;
        _albumIcon.backgroundColor = ESColor.secondarySystemBackgroundColor;
    }
    return _albumIcon;
}

- (UILabel *)albumNameLabel {
    if (!_albumNameLabel) {
        _albumNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _albumNameLabel.textColor = ESColor.labelColor;
        _albumNameLabel.font = ESFontPingFangMedium(14);
        _albumNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _albumNameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = ESColor.secondaryLabelColor;
        _countLabel.font = ESFontPingFangMedium(12);
        _countLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _countLabel;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[ESAlbumModel class]]) {
        return;
    }
    ESAlbumModel *model = (ESAlbumModel *)data;
    
    if (model.coverUrl.length <= 0) {
        [self.albumIcon es_setImageWithUuid:model.coverUrl placeholderImageName:@"album_empty"];
    } else {
        [self.albumIcon es_setImageWithUuid:model.coverUrl placeholderImageName:@"pic_placehold_icon"];
    }
    
    self.albumNameLabel.text = model.albumName;
    self.countLabel.text = [NSString stringWithFormat:@"%lu", model.picCount];
}

@end
