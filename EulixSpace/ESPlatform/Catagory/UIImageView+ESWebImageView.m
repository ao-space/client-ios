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
//  UIImageView+ESWebImageView.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UIImageView+ESWebImageView.h"
#import <SDWebImage/SDWebImage.h>

@implementation UIImageView (ESWebImageView)

- (void)es_setImageWithURL:(NSString *)urlString placeholderImageName:(nullable NSString *)placeholderName {
    if (urlString.length <= 0) {
        self.image = (placeholderName.length > 0 ? [UIImage imageNamed:placeholderName] : nil);
        return;
    }
    [self es_setImageURL:[NSURL URLWithString:urlString] placeholderImage: (placeholderName.length > 0 ? [UIImage imageNamed:placeholderName] : nil)];
}

- (void)es_setImageURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    if (url.absoluteString.length <= 0) {
        self.image = placeholder;
        return;
    }
//    NSString *host = url.host;
    
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
    if (cacheImage) {
        self.image = cacheImage;
        return;
    } else if (![url.scheme isEqualToString:@"http"]) {
        UIImage *image = [UIImage imageWithContentsOfFile:url.absoluteString];
        if (image == nil) {
            image = [SDAnimatedImage imageWithContentsOfFile:url.absoluteString];
        }
        if (image) {
            self.image = image;
            [[SDImageCache sharedImageCache] storeImage:image forKey:url.absoluteString toDisk:NO completion:^{
            }];
            return;
        }
        
    }
    
    self.image = placeholder;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url
                                                        completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if(error) {
            [self sd_setImageWithURL:url placeholderImage:placeholder];
            return;
        }
        [[SDImageCache sharedImageCache] storeImage:image forKey:url.absoluteString toDisk:YES completion:^{
                
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
        });
    }];
}

@end

