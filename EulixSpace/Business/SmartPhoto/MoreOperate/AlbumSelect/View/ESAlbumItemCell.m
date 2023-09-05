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
//  ESAlbumItemCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/2.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumItemCell.h"
#import <Masonry/Masonry.h>
#import "ESColor.h"
#import "ESToast.h"
#import "ESAlbumModel.h"
#import "UIImageView+ESSmartPhotoThumbDownload.h"

@interface ESAlbumItemCell ()

@property (nonatomic, strong) UIImageView *albumIcon;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation ESAlbumItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

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
        make.top.mas_equalTo(self.contentView.mas_top).offset(19.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(23.0f);
        make.height.width.mas_equalTo(40.0f);
    }];
    
    [self.contentView addSubview:self.albumNameLabel];
    [self.albumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.albumIcon.mas_top);
        make.left.mas_equalTo(self.albumIcon.mas_right).offset(10.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(10.0f);
        make.height.mas_equalTo(22.0f);
    }];
    
    [self.contentView addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.albumNameLabel.mas_left);
        make.top.mas_equalTo(self.albumNameLabel.mas_bottom).offset(2.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(10.0f);
        make.height.mas_equalTo(16.0f);
    }];
}

- (UIImageView *)albumIcon {
    if (!_albumIcon) {
        _albumIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _albumIcon.layer.cornerRadius = 4.0;
        _albumIcon.layer.masksToBounds = YES;
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
    
    [self.albumIcon es_setImageWithUuid:model.coverUrl placeholderImageName:@"album_empty"];
    self.albumNameLabel.text = model.albumName;
    self.countLabel.text = [NSString stringWithFormat:@"%lu", model.picCount];
}

@end
