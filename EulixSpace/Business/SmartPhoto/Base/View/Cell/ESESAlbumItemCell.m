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
//  ESESAlbumItemCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESESAlbumItemCell.h"
#import "ESAlbumCategoryModel.h"
#import "UIImageView+ESSmartPhotoThumbDownload.h"

@interface ESESAlbumItemCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ESESAlbumItemCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-24);
    }];
    
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(20.0f);
    }];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.layer.cornerRadius = 10.0f;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = ESColor.systemBackgroundColor;
    }
    return _imageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [ESColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = ESColor.labelColor;
        _nameLabel.font = ESFontPingFangRegular(14);
    }
    return _nameLabel;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[ESAlbumCategoryModel class]]) {
        return;
    }
    ESAlbumCategoryModel *albumModel = (ESAlbumCategoryModel *)data;
    
    self.nameLabel.text = albumModel.albumCategoryName ?: @"我的相册";
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;

    if (albumModel.coverUrl.length <= 0) {
        [self.imageView es_setImageWithUuid:albumModel.coverUrl placeholderImageName:[self getAlbumCatgoryEmptyIconNameByTpe:albumModel.type]];
        return;
    }
    [self.imageView es_setImageWithUuid:albumModel.coverUrl placeholderImageName:@"pic_placehold_icon"];


}

- (NSString *)getAlbumCatgoryEmptyIconNameByTpe:(ESAlbumCategoryType)type {
   NSDictionary *typeMap =  @{ @(ESAlbumCategoryTypeMyAlbum) : @"my_albums_default_icon", // 我的相簿
                               @(ESAlbumCategoryTypeAddress) : @"footprint_empty", //地点
                               @(ESAlbumCategoryTypeScreenshot) : @"screenshots_album_empty", // 截图
                               @(ESAlbumCategoryTypeGif) : @"gifs_album_empty", // 动图
                               @(ESAlbumCategoryTypeMemories) : @"memories_album_empty", // 回忆相册
                               @(ESAlbumCategoryTypeTodayInHistory) : @"", // 历史上的今天
                               @(ESAlbumCategoryTypeUserCreate) : @"", // 用户自建相册
                               @(ESAlbumCategoryTypeUserLike) : @"like_album_empty", // 用户喜欢
                               @(ESAlbumCategoryTypeVideo) : @"videos_album_empty", // 视频相册
                               
   };
   
   return  typeMap[@(type)]  ?: @"my_albums_default_icon";
}

@end
