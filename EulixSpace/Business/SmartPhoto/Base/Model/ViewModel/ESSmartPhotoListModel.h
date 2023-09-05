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
//  ESSmartPhotoListSectoionModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTimelineFrameItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESSmartPhotoSectionType) {
    ESSmartPhotoSectionTypeBanner,
    ESSmartPhotoSectionTypeAlbums,
    ESSmartPhotoSectionTypeTimelines,
    ESSmartPhotoSectionTypeUnkown
};

typedef NS_ENUM(NSUInteger, ESSmartPhotoBlockType) {
    ESSmartPhotoBlockTypeSinglePic,
    ESSmartPhotoBlockTypeMutliPic,
    ESSmartPhotoBlockTypeAlbum,
    ESSmartPhotoBlockTypeBanner,
    ESSmartPhotoBlockTypeUnkown
};

@interface ESSmartPhotoListBlockModel : NSObject

@property (nonatomic, assign) ESSmartPhotoBlockType blockType;
@property (nonatomic, copy) NSArray *items;

@end

@interface ESSmartPhotoListSectionModel : NSObject

@property (nonatomic, copy) NSString *sectionTitle;
@property (nonatomic, copy) NSString *sectionSubtitle;

@property (nonatomic, assign) ESSmartPhotoSectionType sectionType;
@property (nonatomic, copy) NSArray<ESSmartPhotoListBlockModel *> *blocks;

@end

@interface ESSmartPhotoListModel : NSObject

@property (nonatomic, copy) NSArray<ESSmartPhotoListSectionModel *> *sections;

- (instancetype)initMockData;
+ (instancetype)reloadDataFromDBDay;
+ (instancetype)reloadDataFromDBMonth;
+ (instancetype)reloadDataFromDBYear;
+ (instancetype)reloadDataFromDBWithType:(ESTimelineFrameItemType)type;

+ (instancetype)initMockEmptyData;

+ (instancetype)reloadOnlyPicDataFromDBWithType:(ESTimelineFrameItemType)type;
+ (instancetype)reloadDataFromDBAlbumId:(NSString *)albumId;
+ (instancetype)reloadDataFromDBByAlbumCategoryLikeType;
+ (instancetype)reloadDataFromDBByAlbumCategoryTodayInHistoryType;

+ (ESSmartPhotoListSectionModel *)albumCategoryWithSections;

@end

NS_ASSUME_NONNULL_END
