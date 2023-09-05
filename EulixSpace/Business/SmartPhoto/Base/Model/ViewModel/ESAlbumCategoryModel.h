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
//  ESAlbumCategoryModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESAlbumCategoryType) {
    ESAlbumCategoryTypeMyAlbum = 1, // 我的相簿
    ESAlbumCategoryTypeAddress, //地点
    ESAlbumCategoryTypeScreenshot, // 截图
    ESAlbumCategoryTypeGif, // 动图
    ESAlbumCategoryTypeMemories, // 回忆相册
    ESAlbumCategoryTypeTodayInHistory, // 历史上的今天
    ESAlbumCategoryTypeUserCreate, // 用户自建相册
    ESAlbumCategoryTypeUserLike, // 用户喜欢
    ESAlbumCategoryTypeVideo, // 视频相册
};

NS_ASSUME_NONNULL_BEGIN

@interface ESAlbumCategoryModel : NSObject

@property (nonatomic, copy) NSString *albumCategoryId;
@property (nonatomic, copy) NSString *albumCategoryName;
@property (nonatomic, assign) NSInteger albumCount;
@property (nonatomic, assign) ESAlbumCategoryType type;
@property (nonatomic, assign) NSInteger picCount;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval modifyAt;

@end

NS_ASSUME_NONNULL_END
