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
//  UIImageView+ESThumb.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileInfoPub.h"
#import <UIKit/UIKit.h>

@interface UIImageView (ESThumb)

///默认是CGSizeMake(360, 360)
- (void)es_setThumbImageWithFile:(ESFileInfoPub *)file
                     placeholder:(UIImage *)placeholder;

///默认是CGSizeMake(360, 360)
- (void)es_setThumbImageWithFile:(ESFileInfoPub *)file
                            size:(CGSize)size
                     placeholder:(UIImage *)placeholder;

///默认是CGSizeMake(360, 360)
- (void)es_setThumbImageWithFile:(ESFileInfoPub *)file
                            size:(CGSize)size
                     placeholder:(UIImage *)placeholder
                       completed:(void (^)(BOOL ok))completed;

// 获取蓝色风格的 loading 
+ (UIImageView *)getLoadingImageView;
+ (UIImageView *)getLoadingImageView:(NSString *)name;

@end
