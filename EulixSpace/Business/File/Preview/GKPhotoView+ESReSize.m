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
//  GKPhotoView+ESReSize.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "GKPhotoView+ESReSize.h"

@interface GKPhotoView()

@property (nonatomic, assign) CGFloat realZoomScale;

@end

@implementation GKPhotoView (ESReSize)

- (void)adjustFrame {
    CGRect frame = self.scrollView.frame;
    if (frame.size.width == 0 || frame.size.height == 0) return;
    
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGRect imageF = (CGRect){{0, 0}, imageSize};
        
        // 图片的宽度 = 屏幕的宽度
        CGFloat ratio = frame.size.width / imageF.size.width;
        imageF.size.width  = frame.size.width;
        imageF.size.height = ratio * imageF.size.height;
        
        // 默认情况下，显示出的图片的宽度 = 屏幕的宽度
        // 如果kIsFullWidthForLandScape = NO，需要把图片全部显示在屏幕上
        // 此时由于图片的宽度已经等于屏幕的宽度，所以只需判断图片显示的高度>屏幕高度时，将图片的高度缩小到屏幕的高度即可
        
        if (!self.isFullWidthForLandScape) {
            // 图片的高度 > 屏幕的高度
            if (imageF.size.height > frame.size.height) {
                CGFloat scale = imageF.size.width / imageF.size.height;
                imageF.size.height = frame.size.height;
                imageF.size.width  = imageF.size.height * scale;
            }
        }
        
        // 设置图片的frame
        
        if (imageSize.width < imageF.size.width && imageSize.height < imageF.size.height) {
            self.imageView.frame = (CGRect){{0, 0}, imageSize};;
        } else {
            self.imageView.frame = imageF;
        }
        
        self.scrollView.contentSize = self.imageView.frame.size;
        
        if (imageF.size.height <= self.scrollView.bounds.size.height) {
            self.imageView.center = CGPointMake(self.scrollView.bounds.size.width * 0.5, self.scrollView.bounds.size.height * 0.5);
        }else {
            self.imageView.center = CGPointMake(self.scrollView.bounds.size.width * 0.5, imageF.size.height * 0.5);
        }
        
        // 根据图片大小找到最大缩放等级，保证最大缩放时候，不会有黑边
        // 找到最大的缩放比例
        CGFloat scaleH = frame.size.height / imageF.size.height;
        CGFloat scaleW = frame.size.width / imageF.size.width;
        self.realZoomScale = MAX(MAX(scaleH, scaleW), self.maxZoomScale);
        
        if (self.doubleZoomScale == self.maxZoomScale) {
            self.doubleZoomScale = self.realZoomScale;
        }else if (self.doubleZoomScale > self.realZoomScale) {
            self.doubleZoomScale = self.realZoomScale;
        }
        // 初始化
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = self.realZoomScale;
    }else if (!CGRectEqualToRect(self.photo.sourceFrame, CGRectZero)) {
        if (self.photo.sourceFrame.size.width == 0 || self.photo.sourceFrame.size.height == 0) return;
        CGFloat width = frame.size.width;
        CGFloat height = width * self.photo.sourceFrame.size.height / self.photo.sourceFrame.size.width;
        self.imageView.bounds = CGRectMake(0, 0, width, height);
        self.imageView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        self.scrollView.contentSize = self.imageView.frame.size;
        
        self.loadingView.bounds = self.scrollView.frame;
        self.loadingView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    }else {
        self.loadingView.bounds = self.scrollView.frame;
        self.loadingView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    }

    
    // frame调整完毕，重新设置缩放
    if (self.photo.isZooming) {
        self.scrollView.maximumZoomScale = 1.0f;
        self.scrollView.zoomScale = 1.0f;
        [self zoomToRect:self.photo.zoomRect animated:NO];
    }
    
    // 重置offset
    self.scrollView.contentOffset = self.photo.offset;
    
}

@end
