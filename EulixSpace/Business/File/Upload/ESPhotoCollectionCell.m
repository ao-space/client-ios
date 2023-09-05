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
//  ESPhotoCollectionCell.m
//  EulixSpace
//
//  Created by qu on 2021/9/5.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPhotoCollectionCell.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import "PHAsset+ESTool.h"
#import "UILabel+ESAutoSize.h"
#import <Masonry/Masonry.h>

@interface ESPhotoCollectionCell ()
/// 相片
@property (nonatomic, strong) UIImageView *photoImageView;

@property (nonatomic, strong) UIImageView *selectIcon;
/// 选中按钮
@property (nonatomic, strong) UIButton *selectButton;
/// 半透明遮罩
@property (nonatomic, strong) UIView *translucentView;

@property (nonatomic, strong) UILabel *duration;
@end

@implementation ESPhotoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self photoImageView];
        [self translucentView];
        [self selectButton];
        [self selectIcon];
    }

    return self;
}

#pragma mark - Set方法
- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.translucentView.hidden = !isSelected;
    self.selectIcon.image = isSelected ? IMAGE_FILE_SELECTED : nil;
    self.selectIcon.layer.borderWidth = isSelected ? 0 : 1;
    //_translucentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}

#pragma mark - 加载图片
- (void)loadImage:(NSIndexPath *)indexPath {
    self.photoImageView.image = nil;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    // 同步获得图片, 只会返回1张图片
    options.synchronous = NO;

    [[PHCachingImageManager defaultManager] requestImageForAsset:self.asset
                                                      targetSize:CGSizeMake(240, 240)
                                                     contentMode:PHImageContentModeDefault
                                                         options:options
                                                   resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                                                       if (self.row == indexPath.row) {
                                                           self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
                                                           self.photoImageView.image = result;
                                                           self.photoImageView.clipsToBounds = YES;
                                                       }
                                                   }];

    _duration.hidden = YES;
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        self.duration.hidden = NO;
        // shadow
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 2;
        shadow.shadowColor = [ESColor.darkTextColor colorWithAlphaComponent:0.5];
        shadow.shadowOffset = CGSizeMake(0, 0);

        self.duration.attributedText = [[self.asset es_duration] es_toAttr:@{
            NSFontAttributeName: self.duration.font,
            NSForegroundColorAttributeName: self.duration.textColor,
            NSShadowAttributeName: shadow
        }];
        [self.duration es_flexible];
    }
}

#pragma mark - 点击事件
- (void)selectPhoto:(UIButton *)button {
    if (self.selectPhotoAction) {
        self.selectPhotoAction(self.asset);
    }
}

#pragma mark - Get方法
- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [UIImageView new];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.layer.masksToBounds = YES;
        _photoImageView.layer.cornerRadius = 4;
        [self.contentView addSubview:_photoImageView];
        [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return _photoImageView;
}

- (UIImageView *)selectIcon {
    if (!_selectIcon) {
        _selectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 22, 22)];
        _selectIcon.contentMode = UIViewContentModeScaleAspectFill;
        _selectIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        _selectIcon.layer.borderWidth = 1.f;
        _selectIcon.layer.cornerRadius = 11.f;
        _selectIcon.layer.masksToBounds = YES;
        [self.contentView addSubview:_selectIcon];
    }
    return _selectIcon;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectButton];
        _selectButton.frame = CGRectMake(0, 0, 44, 44);
    }

    return _selectButton;
}

- (UIView *)translucentView {
    if (!_translucentView) {
        _translucentView = [[UIView alloc] init];
        _translucentView.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.2];
        [self.contentView addSubview:_translucentView];
        _translucentView.hidden = YES;
        [_translucentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return _translucentView;
}

- (UILabel *)duration {
    if (!_duration) {
        _duration = [UILabel new];
        _duration.textColor = ESColor.lightTextColor;
        _duration.font = [UIFont systemFontOfSize:10 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_duration];
        [_duration mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(self.contentView).inset(4);
            make.width.mas_equalTo(28);
            make.height.mas_equalTo(14);
        }];
    }
    return _duration;
}

@end
