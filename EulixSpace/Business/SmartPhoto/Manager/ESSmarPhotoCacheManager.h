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
//  ESBottomToolVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDiskCacheManager.h"
#import "ESPicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESSmarPhotoCacheManager : ESDiskCacheManager

+ (NSString * _Nullable)unZipCachePath:(NSString *)picZipCachePath
                                   pic:(ESPicModel *)pic;

+ (NSString *)cachePathWithPic:(ESPicModel *)pic;
+ (NSString *)cacheDirWithPic:(ESPicModel *)pic;
+ (NSString *)cacheEncryptPathWithPic:(ESPicModel *)pic;
+ (NSString *)cacheZipPathWithPic:(ESPicModel *)pic;
+ (void)clearCache;

+ (NSString *)cacheZipPathWithDate:(NSString *)day;
+ (NSString *)cacheZipPathWithAlbumId:(NSString *)albumId;

+ (void)unZipCachePath:(NSString *)picDayZipCachePath
               picList:(NSArray<ESPicModel *> *)picList;

+ (void)unZipCompressPicCachePath:(NSString *)picDayZipCachePath
                          picList:(NSArray<ESPicModel *> *)picList;
+ (NSString *)compressCachePathWithPic:(ESPicModel *)pic;

@end

NS_ASSUME_NONNULL_END
