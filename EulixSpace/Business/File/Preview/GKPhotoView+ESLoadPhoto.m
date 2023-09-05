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
//  GKPhotoView+ESLoadPhoto.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/4.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "GKPhotoView+ESLoadPhoto.h"
#import <SDWebImage/SDAnimatedImage.h>
#import <objc/runtime.h>
#import "NSObject+ESGCD.h"
#import "ESPreviewUnsupportFileView.h"
#import "ESFormItem.h"
#import "UIImage+ESTool.h"

@interface GKPhotoView()

@property (nonatomic, strong, readwrite) GKScrollView   *scrollView;

@property (nonatomic, strong, readwrite) UIImageView    *imageView;

@property (nonatomic, strong, readwrite) GKLoadingView  *loadingView;

@property (nonatomic, strong, readwrite) GKPhoto        *photo;

@property (nonatomic, strong) id<GKWebImageProtocol>    imageProtocol;

@property (nonatomic, assign) CGFloat realZoomScale;

@property (nonatomic, assign) PHImageRequestID requestID;

- (void)setupImageView:(UIImage *)image;

@end

@implementation GKPhotoView (ESLoadPhoto)

#pragma mark - 加载图片
- (void)loadImageWithPhoto:(GKPhoto *)photo isOrigin:(BOOL)isOrigin {
    // 取消以前的加载
    if (photo == nil) {
        self.imageView.image = nil;
        [self adjustFrame];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        [self.scrollView addSubview:self.imageView];
    });

    
    // 每次设置数据时，恢复缩放
    [self.scrollView setZoomScale:1.0 animated:NO];
    if (photo.url.absoluteString.length <= 0) {
        return;
    }
    weakfy(self)
    ESPerformBlockAsyn(^{
        @autoreleasepool {
            strongfy(self)
            
            NSString *imagePath = photo.url.absoluteString;
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            if ([imagePath containsString:@"%"]) {
                imagePath = [imagePath stringByRemovingPercentEncoding];
            }
            UIImage *placeholderImage = [UIImage imageWithContentsOfFile:imagePath];
            if (placeholderImage == nil) {
                ESDLog(@"[GKPhotoView] imageWithContentsOfFile nil :%@", imagePath);
                placeholderImage = [SDAnimatedImage imageWithContentsOfFile:imagePath];
            }
            
            placeholderImage = [placeholderImage normalizedImage];
            
            CGSize size = placeholderImage.size;
            if (size.width > 2600 || size.height > 2600) {
                placeholderImage = [self kj_QuartzChangeImage:placeholderImage scale: 2600 / (MAX(size.width, size.height))];
            }
            
            if (placeholderImage == nil) {
                //未能正常加载出图片
                ESDLog(@"[GKPhotoView] placeholderImage nil");
                placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cloud_image_default" ofType:@"png"]];
            }
            ESPerformBlockOnMainThread(^{
                strongfy(self)
                [self setupImageView:placeholderImage];
            });
        }
    });
    
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

- (void)showPlayIcon {
    if (self.addPlayViewMask.superview) {
        [self.addPlayViewMask removeFromSuperview];
    }
    self.addPlayViewMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smart_photo_play"]];
    [self addSubview:self.addPlayViewMask];
    self.addPlayViewMask.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y);
}

- (void)hiddenPlayIcon {
    if (self.addPlayViewMask.superview) {
        [self.addPlayViewMask removeFromSuperview];
    }
    
    self.addPlayViewMask = nil;
}

- (UIView *)addPlayViewMask {
    return objc_getAssociatedObject(self, @selector(addPlayViewMask));
}

- (void)setAddPlayViewMask:(UIView *)maskView {
    objc_setAssociatedObject(self, @selector(addPlayViewMask),
                             maskView, OBJC_ASSOCIATION_RETAIN);
}

- (void)showUnsupportFileView:(ESFormItem *)item {
    if (self.unsupportFileView.superview) {
        [self.unsupportFileView removeFromSuperview];
    }
    self.unsupportFileView = [[ESPreviewUnsupportFileView alloc] initWithFrame:self.bounds];
    self.unsupportFileView.backgroundColor = ESColor.systemBackgroundColor;
    self.unsupportFileView.userInteractionEnabled = NO;
    [self.unsupportFileView reloadWithData:item];
    [self addSubview:self.unsupportFileView];
}

- (void)hiddenUnsupportFileView {
    if (self.unsupportFileView.superview) {
        [self.unsupportFileView removeFromSuperview];
    }
    
    self.unsupportFileView = nil;
}


- (ESPreviewUnsupportFileView *)unsupportFileView {
    return objc_getAssociatedObject(self, @selector(unsupportFileView));
}


- (void)setUnsupportFileView:(ESPreviewUnsupportFileView *)unsupportFileView {
    objc_setAssociatedObject(self, @selector(unsupportFileView),
                             unsupportFileView, OBJC_ASSOCIATION_RETAIN);
}

@end

