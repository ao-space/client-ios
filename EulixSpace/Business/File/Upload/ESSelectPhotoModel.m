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
//  ESSelectPhotoModel.m
//  EulixSpace
//
//  Created by qu on 2021/9/7.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSelectPhotoModel.h"

@implementation ESSelectPhotoModel

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.version = PHImageRequestOptionsVersionCurrent;
        [[PHCachingImageManager defaultManager] requestImageForAsset:self.asset
                                                          targetSize:CGSizeMake(240, 240)
                                                         contentMode:PHImageContentModeDefault
                                                             options:options
                                                       resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                                                           self.highDefinitionImage = result;
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               if (self.getPictureAction) {
                                                                   self.getPictureAction();
                                                               }
                                                           });
                                                       }];
    });
}
@end
