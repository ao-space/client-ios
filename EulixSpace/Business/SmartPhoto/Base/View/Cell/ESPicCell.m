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
//  ESPicCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPicCell.h"
#import "ESPicModel.h"
#import "UIImageView+ESWebImageView.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountInfoStorage.h"
#import  <SSZipArchive/SSZipArchive.h>
#import "ESFileDefine.h"
#import "ESSmarPhotoCacheManager.h"
#import <SDAnimatedImage.h>
#import "NSObject+ESGCD.h"
#import "ESNetworkRequestDownloadTask.h"
#import "ESSmartPhotoAsyncManager.h"

@interface ESPicCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectdImageView;
@property (nonatomic, strong) UIView *selectdMaskView;
@property (nonatomic, strong) ESPicModel *picModel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) ESNetworkRequestCallDownloadTask *downloadTask;
@property (nonatomic, assign) BOOL needRefresh;
@property (nonatomic, strong)dispatch_semaphore_t downloadSemaphoreLock;

@end

@implementation ESPicCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setShowStyle:ESPicCellShowStyleNormal];
        _downloadSemaphoreLock = dispatch_semaphore_create(0);
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
        make.right.mas_equalTo(self.contentView).offset(-4.0f);
        make.bottom.mas_equalTo(self.contentView).offset(4.0f);
        make.size.mas_equalTo(CGSizeMake(27, 14));
    }];
    
    [self.contentView addSubview:self.selectdMaskView];
    [self.selectdMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.selectdImageView];
    [self.selectdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.contentView).offset(6.0f);
        make.size.mas_equalTo(CGSizeMake(22.0, 22.0f));
    }];
    
    UILongPressGestureRecognizer *pressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.contentView addGestureRecognizer:pressGes];
}

- (void)longPressAction:(id)sender {
    if(self.longPressActionBlock) {
        self.longPressActionBlock();
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.layer.cornerRadius = 4.0f;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)selectdImageView {
    if (!_selectdImageView) {
        _selectdImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _selectdImageView;
}

- (UIView *)selectdMaskView {
    if (!_selectdMaskView) {
        _selectdMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        _selectdMaskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.2];
        _selectdMaskView.layer.cornerRadius = 10.0f;
        _selectdMaskView.clipsToBounds = YES;
    }
    return _selectdMaskView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.shadowColor = [ESColor colorWithHex:0x000000 alpha:0.5];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = ESColor.lightTextColor;
        _timeLabel.font = ESFontPingFangMedium(10);
    }
    return _timeLabel;
}

- (void)bindData:(id)data {
    if (![data isKindOfClass:[ESPicModel class]]) {
        return;
    }
    ESPicModel *pic = (ESPicModel *)data;
    self.picModel = pic;
    [self updateTimeLabel];

    if (pic.cacheUrl.length > 0) {
        self.needRefresh = NO;
        ESDLog(@"[ESPicCell] load loacl url : %@", pic.cacheUrl);
        [self updateImageWithContentPath:pic.cacheUrl];
        return;
    }
    self.needRefresh = YES;
    if (self.listViewIsDraging) {
        return;
    }
    
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.image = [UIImage imageNamed:@"pic_placehold_icon"];
  
    if ([pic.uuid hasPrefix:@"mock_"]) {
        return;
    }
   
    [self tryDownloadImage:pic retryCount:2];
}

- (void)updateTimeLabel {
    if (self.picModel.duration > 0) {
        NSInteger allSecond = self.picModel.duration / 1000;
        NSInteger hour = allSecond / 60 / 60;
        NSInteger minute = allSecond / 60 % 60;
        NSInteger second = allSecond % 60;
        second = MAX(second, 0);
        
        if (hour > 0) {
            self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, minute, second];
        } else {
            self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minute, second];
        }
         [self.timeLabel sizeToFit];
         CGSize size = self.timeLabel.frame.size;
         [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
             make.size.mas_equalTo(CGSizeMake(size.width + 12, 24));
         }];
    }
    self.timeLabel.hidden = ![self.picModel.category isEqualToString:@"video"];
}

- (void)updateImageWithContentPath:(NSString *)path {
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    @autoreleasepool {
        UIImage *image = image = [UIImage imageWithContentsOfFile:path];
        if (!image) {
            image = [SDAnimatedImage imageWithContentsOfFile:path];
        }
        CGSize size = image.size;
        if (size.width > 600 || size.height > 600) {
            image = [self kj_QuartzChangeImage:image scale: 600 / (MAX(size.width, size.height))];
        }
        self.imageView.image = image;
    }
}

- (UIImage*)kj_QuartzChangeImage:(UIImage *)image scale:(CGFloat)scale {
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height *scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)tryDownloadImage:(ESPicModel *)pic retryCount:(NSInteger)count {
    NSString *picZipCachePath = [ESSmarPhotoCacheManager cacheZipPathWithPic:pic];
    
    [self.downloadTask cancel];
    
    ESNetworkRequestCallDownloadTask *requestTask = [ESNetworkRequestCallDownloadTask new];
    self.downloadTask = requestTask;
    
    __weak typeof(self) weakSelf = self;
    [[ESSmartPhotoAsyncManager shared].picRequestQueue addOperationWithBlock:^{
        __strong typeof (weakSelf) self = weakSelf;

        
        requestTask.downloadSuccessBlock = ^(NSInteger requestId, NSURL * _Nonnull location) {
            ESDLog(@"ESPicCell request download  success %@  --%lu", pic.uuid, count);
            __strong typeof (weakSelf) self = weakSelf;
            dispatch_semaphore_signal(self.downloadSemaphoreLock);

            NSString *picPath = [ESSmarPhotoCacheManager unZipCachePath:picZipCachePath pic:pic];
             if (picPath.length <= 0  && count > 0) {
                [self tryDownloadImage:pic retryCount:(count - 1)];
                 return;
             }
            if ([pic.uuid isEqualToString:self.picModel.uuid] && picPath.length > 0) {
                ESPerformBlockAsynOnMainThread(^{
                    __strong typeof (weakSelf) self = weakSelf;
                    ESDLog(@"ESPicCell request download updateImageWithContentPath %@ --uuid:%@", picPath, pic.uuid);
                   [self updateImageWithContentPath:picPath];
                });
            }
        };
        requestTask.failBlock = ^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            ESDLog(@"ESPicCell request download  fail %@ -- %lu", pic.uuid, count);
            __strong typeof (weakSelf) self = weakSelf;
            dispatch_semaphore_signal(self.downloadSemaphoreLock);

            if (count > 0) {
                [self tryDownloadImage:pic retryCount:(count - 1)];
            }
        };
        
        ESDLog(@"ESPicCell request download %@", pic.uuid);
        if (!self.downloadTask || self.downloadTask.status == ESNetworkRequestServiceStatus_Cancel) {
            ESDLog(@"ESPicCell request download cancel %@", pic.uuid);
            return;
        }

     
        [requestTask sendCallDownloadRequest:@{@"serviceName" : @"eulixspace-file-service",
                                               @"apiName" : @"album_thumbs", }
                                 queryParams:@{
                                                @"userId" : ESSafeString([ESAccountInfoStorage userId])
                                                }
                                      header:@{}
                                        body:@{@"uuids" : @[pic.uuid] }
                                  targetPath:picZipCachePath];
        dispatch_semaphore_wait(self.downloadSemaphoreLock, DISPATCH_TIME_FOREVER);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.image = [UIImage imageNamed:@"pic_placehold_icon"];
    
    [self.downloadTask cancel];
    self.downloadTask = nil;
}

- (void)setShowStyle:(ESPicCellShowStyle)showStyle {
    _showStyle = showStyle;
    switch (showStyle) {
        case ESPicCellShowStyleUnSelecte:
            {
                _selectdImageView.image = [UIImage imageNamed:@"pic_unselected"];
                _selectdImageView.hidden = NO;
                _selectdMaskView.hidden = YES;
            }
            break;
        case ESPicCellShowStyleSelected:
            {
                _selectdImageView.image = [UIImage imageNamed:@"pic_selected"];
                _selectdImageView.hidden = NO;
                _selectdMaskView.hidden = NO;
            }
            break;
        case ESPicCellShowStyleNormal:
            {
                _selectdImageView.hidden = YES;
                _selectdMaskView.hidden = YES;
            }
            break;
        default:
            break;
    }
}

- (BOOL)isSelected {
    return _showStyle == ESPicCellShowStyleSelected;
}

@end
