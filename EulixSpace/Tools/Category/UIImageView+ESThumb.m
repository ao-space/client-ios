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
//  UIImageView+ESThumb.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxManager.h"
#import "ESFileDefine.h"
#import "ESTransferManager.h"
#import "UIImageView+ESThumb.h"
#import <SDWebImage/SDWebImage.h>

@implementation UIImageView (ESThumb)

- (void)es_setThumbImageWithFile:(ESFileInfoPub *)file placeholder:(UIImage *)placeholder {
    [self es_setThumbImageWithFile:file size:CGSizeMake(360, 360) placeholder:placeholder];
}

- (void)es_setThumbImageWithFile:(ESFileInfoPub *)file
                            size:(CGSize)size
                     placeholder:(UIImage *)placeholder {
    [self es_setThumbImageWithFile:file size:CGSizeMake(360, 360) placeholder:placeholder completed:nil];
}

- (void)es_setThumbImageWithFile:(ESFileInfoPub *)file
                            size:(CGSize)size
                     placeholder:(UIImage *)placeholder
                       completed:(void (^)(BOOL ok))completed {
    [self sd_cancelCurrentImageLoad];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(360, 360);
    }
    self.image = placeholder;
    if (!file.uuid) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSString *fakeUrl = ThumbnailUrlForFile(file, size);
    [self sd_setImageWithURL:[NSURL URLWithString:fakeUrl]
            placeholderImage:placeholder
                   completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                       if (completed) {
                           completed(image != nil);
                       }
                   }];
}


+ (UIImageView *)getLoadingImageView {
    return [self getLoadingImageView:@"loadingView"];
}

+ (UIImageView *)getLoadingImageView:(NSString *)name {
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat:M_PI * 2];
    animation.duration  = 1;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [iv.layer addAnimation:animation forKey:nil];

    return iv;
}

@end
