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
//  ESPhotoModel.h
//  EulixSpace
//
//  Created by qu on 2021/9/4.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESPhotoModelAction)(void);
@interface ESPhotoModel : NSObject
/// 相片
@property (nonatomic, strong) PHAsset *asset;
/// 相册
@property (nonatomic, strong) PHAssetCollection *collection;
/// 第一个相片
@property (nonatomic, strong) PHAsset *firstAsset;

@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;
/// 相册名
@property (nonatomic, copy) NSString *collectionTitle;
/// 总数
@property (nonatomic, copy) NSString *collectionNumber;
/// 选中的图片
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selectRows;

/// 获取图片成功事件
@property (nonatomic, copy) ESPhotoModelAction getPictureAction;

@property (nonatomic, strong) NSMutableArray<PHAsset *> *assetsUpload;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, strong) NSMutableArray<PHAsset *> *photoAssets;

@end

NS_ASSUME_NONNULL_END
