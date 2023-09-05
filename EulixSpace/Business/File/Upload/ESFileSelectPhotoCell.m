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
//  ESFileSelectPhotoCell.m
//  EulixSpace
//
//  Created by qu on 2021/9/4.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileSelectPhotoCell.h"

@interface ESFileSelectPhotoCell ()

@property (nonatomic, strong) UIImageView *arrowImageView;
@end

@implementation ESFileSelectPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(26.0);
        make.top.mas_equalTo(self.contentView.mas_top).offset(20.0);
        make.height.width.mas_equalTo(60);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(20);
        make.left.mas_equalTo(self.iconImageView.mas_right).inset(20);
        make.height.mas_equalTo(25);
        make.right.mas_equalTo(self.contentView.mas_right).inset(-50.0);
    }];

    [self.size mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(8);
        make.left.mas_equalTo(self.title.mas_left);
        make.height.mas_equalTo(17);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(41.0);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26.0);
        make.height.width.mas_equalTo(16);
    }];
}

#pragma mark - Lazy Load

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)size {
    if (!_size) {
        _size = [[UILabel alloc] init];
        _size.textColor = ESColor.secondaryLabelColor;
        _size.textAlignment = NSTextAlignmentLeft;
        _size.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_size];
    }
    return _size;
}
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = IMAGE_ME_ARROW;
        [self.contentView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (void)loadImage:(NSIndexPath *)index {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    __weak typeof(self) weakSelf = self;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.albumModel.firstAsset
                                                      targetSize:CGSizeMake(240, 240)
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:options
                                                   resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                                                       if (weakSelf.row == index.row) {
                                                           weakSelf.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
                                                           weakSelf.iconImageView.image = result;
                                                           weakSelf.iconImageView.clipsToBounds = YES;
                                                       }
                                                   }];
}

#pragma mark - Set方法
- (void)setAlbumModel:(ESPhotoModel *)albumModel {
    _albumModel = albumModel;
    self.title.text = albumModel.collectionTitle;
    self.size.text = [NSString stringWithFormat:@"%@张", albumModel.collectionNumber];
}

@end
