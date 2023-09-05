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
//  UIImage+ESCompress.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UIImage+ESCompress.h"

@implementation UIImage (ESCompress)

- (NSData *)compressImageWithLimitLength:(NSInteger)maxLength canResize:(BOOL)bResize
{
    NSData *imageData = UIImageJPEGRepresentation(self, 1.f);
    NSUInteger oriLength = [imageData length];
    CGFloat compression = 1.0f;
    while ([imageData length] > maxLength && compression > 0.1)
    {
        // 如果压缩目标远小于原图size，必须走快速压缩分支
        if (bResize || oriLength>(3 * maxLength)) {
            // 快速收敛
            compression -= 0.1;
            imageData = [self resizeWithScale:compression compression:compression];
        } else {
            // 兼顾质量
            compression -= 0.025f;
            imageData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], compression);
        }
    }
    return imageData;
}

- (NSData *)resizeWithScale:(CGFloat)scale compression:(CGFloat)compression
{
    CGSize newSize = CGSizeMake(ceilf(self.size.width*scale), ceilf(self.size.height*scale));
    
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImageJPEGRepresentation(newImage, compression);
}

@end
