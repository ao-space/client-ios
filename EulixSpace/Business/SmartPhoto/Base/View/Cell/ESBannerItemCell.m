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
//  ESBannerItemCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBannerItemCell.h"
#import "ESPicModel.h"
#import "UIImageView+ESSmartPhotoThumbDownload.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESFileInfoPub.h"
#import "ESFileDefine.h"

@interface ESBannerItemCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation ESBannerItemCell

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
        make.right.mas_equalTo(self.contentView).offset(-10.0f);
        make.top.mas_equalTo(self.contentView).offset(10.0f);
        make.size.mas_equalTo(CGSizeMake(92, 24));
    }];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.layer.cornerRadius = 10.0f;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.layer.cornerRadius = 4.0f;
        _timeLabel.clipsToBounds = YES;
        _timeLabel.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.3];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = ESColor.lightTextColor;
    }
    return _timeLabel;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[ESPicModel class]]) {
        return;
    }
    ESPicModel *picModel = (ESPicModel *)data;
    picModel = [ESSmartPhotoDataBaseManager.shared getPicByUuid:picModel.uuid];
    self.timeLabel.text = [NSString stringWithFormat:@"%lu年%lu月%lu日", picModel.date_year, picModel.date_month, picModel.date_day];
    [self.timeLabel sizeToFit];
    CGSize size = self.timeLabel.frame.size;
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size.width + 12, 24));
    }];
    self.imageView.image = [UIImage imageNamed:@"banner_placehold_icon"];
    self.imageView.contentMode = UIViewContentModeCenter;
    
    [self.imageView es_setCompressImageWithUuid:picModel.uuid placeholderImageName:@"banner_placehold_icon" completion:^(BOOL isSuccess) {
        if (isSuccess == NO) {
            ESFileInfoPub *file = [ESFileInfoPub new];
            file.name = picModel.name;
            file.uuid = picModel.uuid;
            if (LocalFileExist(file)) {
                @autoreleasepool {
                    NSString *filePath = LocalPathForFile(file);
                    UIImage *localImage = [UIImage imageWithContentsOfFile:filePath];
                    if (localImage != nil) {
                        self.imageView.image = localImage;
                    }
                }
            }
        }
    }];
}

@end
