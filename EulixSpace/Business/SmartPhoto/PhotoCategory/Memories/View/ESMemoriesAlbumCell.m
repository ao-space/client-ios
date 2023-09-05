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
//  ESMemoriesAlbumCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/14.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesAlbumCell.h"
#import "UIButton+ESTouchArea.h"
#import "ESAlbumModel.h"
#import "NSDate+Format.h"
#import "UIImageView+ESSmartPhotoThumbDownload.h"

@interface ESMemoriesAlbumCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *likeBt;
@property (nonatomic, strong) UIButton *deleteBt;

@end

@implementation ESMemoriesAlbumCell

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
    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(20.0f);
        make.top.equalTo(self.contentView).inset(10.0f);
        make.bottom.equalTo(self.contentView).inset(0.0f);
    }];
    
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.iconImageView.mas_bottom).offset(-20.0f);
        make.left.right.equalTo(self.iconImageView).inset(20.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.timeLabel.mas_top).inset(4.0f);
        make.left.right.equalTo(self.iconImageView).inset(20.0f);
        make.height.mas_equalTo(30.0f);
    }];
    
    [self.contentView addSubview:self.deleteBt];
    [self.deleteBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.iconImageView).inset(10.0f);
        make.size.mas_equalTo(CGSizeMake(26.0f, 26.0f));
    }];
    
    [self.contentView addSubview:self.likeBt];
    [self.likeBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteBt.mas_top);
        make.right.mas_equalTo(self.deleteBt.mas_left).inset(20.0f);
        make.size.mas_equalTo(CGSizeMake(26.0f, 26.0f));
    }];
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.layer.cornerRadius = 4.0;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
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

- (UIButton *)likeBt {
    if (!_likeBt) {
        _likeBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_likeBt setImage:[UIImage imageNamed:@"memory_like"] forState:UIControlStateNormal];
        [_likeBt setTitle:nil forState:UIControlStateNormal];
        [_likeBt addTarget:self action:@selector(likeAction) forControlEvents:UIControlEventTouchUpInside];
        [_likeBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _likeBt;
}

- (UIButton *)deleteBt {
    if (!_deleteBt) {
        _deleteBt = [[UIButton alloc] initWithFrame:CGRectZero];
        [_deleteBt setImage:[UIImage imageNamed:@"memory_delete"] forState:UIControlStateNormal];
        [_deleteBt setTitle:nil forState:UIControlStateNormal];
        [_deleteBt addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _deleteBt;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[ESAlbumModel class]]) {
        return;
    }
    ESAlbumModel *albumModel = (ESAlbumModel *)data;
    if ([albumModel.albumName containsString:@","]) {
        NSArray *titleList = [albumModel.albumName componentsSeparatedByString:@","];
        self.titleLabel.text = titleList[0];
        if (titleList.count > 1) {
            self.timeLabel.text = titleList[1];
        }
    } else {
        self.titleLabel.text = albumModel.albumName;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:albumModel.createdAt];
        NSString *time = [date stringFromFormat:@"YYYY年MM月dd日"];
        self.timeLabel.text = time;
    }
    
    [self.likeBt setImage:(albumModel.collection ? [UIImage imageNamed:@"memory_collection"] : [UIImage imageNamed:@"memory_uncollection"]) forState:UIControlStateNormal];
    [self.iconImageView es_setCompressImageWithUuid:albumModel.coverUrl placeholderImageName:@"album_empty"];
    
    [self hiddenSeparatorStyleSingleLine:YES];
}

- (void)likeAction {
    if (self.likeActionBlock) {
        self.likeActionBlock();
    }
}

- (void)deleteAction {
    if (self.deleteActionBlock) {
        self.deleteActionBlock();
    }
}

@end
