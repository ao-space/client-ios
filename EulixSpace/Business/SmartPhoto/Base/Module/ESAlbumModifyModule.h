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
//  ESAlbumModifyModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESCreateAlbumResponseModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ESAlbumModifyType) {
    ESAlbumModifyTypeReName, // 重命名
    ESAlbumModifyTypeCollection, //收藏
    ESAlbumModifyTypeCreate,
    ESAlbumModifyTypeDelete,
    ESAlbumModifyTypeAddPhoto,
    ESAlbumModifyTypeDeletePhoto,
    ESAlbumModifyTypeDPhotoLike,
};

typedef void (^ESAlbumModifyModuleCompletionBlock)(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error);
typedef void (^ESAlbumCreateCompletionBlock)(ESAlbumModifyType modifyType, ESCreateAlbumResponseModel * _Nullable albumInfo, NSError * _Nullable error);

@interface ESAlbumModifyModule : NSObject

+ (void)modifyAlbumName:(NSString *)name
                albumId:(NSInteger)albumId
             completion:(ESAlbumModifyModuleCompletionBlock)completion;

// YES  收藏、 NO 未收藏
+ (void)collectionAlbum:(BOOL)collection
                albumId:(NSInteger)albumId
             completion:(ESAlbumModifyModuleCompletionBlock)completion;

+ (void)createAlbumName:(NSString *)name completion:(ESAlbumCreateCompletionBlock)completion;

+ (void)deleteAlbumIds:(NSArray<NSNumber *> *)albumIds completion:(ESAlbumModifyModuleCompletionBlock)completion;

+ (void)addPhtotos:(NSArray<NSString *> *)uuids
           albumId:(NSInteger)albumId
        completion:(ESAlbumModifyModuleCompletionBlock)completion;

+ (void)deletePhoto:(NSArray<NSString *> *)uuids
          fromAlbumId:(NSInteger)albumId
         deleteType:(NSInteger)type  //0代表从相册删除，1代表 从相册删除并且文件删除
         completion:(ESAlbumModifyModuleCompletionBlock)completion;

// YES  喜欢、 NO 不喜欢
+ (void)likeAlbumPic:(BOOL)like
            picUUids:(NSArray *)uuids
          completion:(ESAlbumModifyModuleCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
