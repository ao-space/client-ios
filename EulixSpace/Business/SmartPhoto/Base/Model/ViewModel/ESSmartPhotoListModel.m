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
//  ESSmartPhotoListSectoionModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSmartPhotoListModel.h"
#import "ESPicModel.h"
#import "ESAlbumCategoryModel.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "NSObject+YYModel.h"
#import "ESSmartPhotoAsyncManager.h"

@implementation ESSmartPhotoListBlockModel : NSObject

@end

@implementation ESSmartPhotoListSectionModel : NSObject

@end

@implementation ESSmartPhotoListModel

+ (instancetype)reloadDataFromDBDay {
    return [self reloadDataFromDBWithType:ESTimelineFrameItemTypeDay];
}

+ (instancetype)reloadDataFromDBMonth {
    return [self reloadDataFromDBWithType:ESTimelineFrameItemTypeMonth];
}

+ (instancetype)reloadDataFromDBYear {
    return [self reloadDataFromDBWithType:ESTimelineFrameItemTypeYear];
}

+ (instancetype)reloadDataFromDBAlbumId:(NSString *)albumId {
    ESSmartPhotoListModel *model = [[ESSmartPhotoListModel alloc] init];
    NSMutableArray *sections = [NSMutableArray array];
    
    [self addTimeLineWithSections:sections albumId:albumId];

    if (sections.count > 0) {
        model.sections = sections;
        return model;
    }
    
    ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
    sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    sectoion.blocks = @[];
    model.sections = @[];
    return model;
}

+ (instancetype)reloadDataFromDBByAlbumCategoryLikeType {
    ESSmartPhotoListModel *model = [[ESSmartPhotoListModel alloc] init];
    NSMutableArray *sections = [NSMutableArray array];
    
    [self addTimeLineFilterOnlyLikePicWithSections:sections];

    if (sections.count > 0) {
        model.sections = sections;
        return model;
    }
    
    ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
    sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    sectoion.blocks = @[];
    model.sections = @[];
    return model;
}

+ (void)addTimeLineFilterOnlyLikePicWithSections:(NSMutableArray *)sections {
    NSArray<ESTimelineFrameItem *> *timeLines = [[ESSmartPhotoDataBaseManager shared] getTimeLinesFromDBType:ESTimelineFrameItemTypeDay];
    timeLines = [self filterEmptySection:timeLines];
    
    [timeLines enumerateObjectsUsingBlock:^(ESTimelineFrameItem * _Nonnull frameItem, NSUInteger idx, BOOL * _Nonnull stop) {
        ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
        sectoion.sectionSubtitle = frameItem.dateWithTypeTranslate;
        sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    
        NSArray<ESPicModel *> * pics = [[ESSmartPhotoDataBaseManager shared] getPicsLikeFromDBByDateWithYear:frameItem.year
                                                                            month:frameItem.month
                                                                              day:frameItem.day];
        
        NSMutableArray *blocks = [NSMutableArray array];
        [pics enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
            if(pic.uuid.length > 0 && pic.albumIdList.count > 0) {
                ESSmartPhotoListBlockModel *block = [ESSmartPhotoListBlockModel new];
                block.blockType = ESSmartPhotoBlockTypeSinglePic;
                block.items = @[pic];
                [blocks addObject:block];
            }
        }];
        
        if (blocks.count > 0) {
            sectoion.blocks = blocks;
            [sections addObject:sectoion];
        }
    }];
}

+ (instancetype)reloadDataFromDBByAlbumCategoryTodayInHistoryType {
    ESSmartPhotoListModel *model = [[ESSmartPhotoListModel alloc] init];
    NSMutableArray *sections = [NSMutableArray array];
    
    [self addTimeLineFilterOnlyTodayInHistoryPicWithSections:sections];

    if (sections.count > 0) {
        model.sections = sections;
        return model;
    }
    
    ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
    sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    sectoion.blocks = @[];
    model.sections = @[];
    return model;
}

+ (void)addTimeLineFilterOnlyTodayInHistoryPicWithSections:(NSMutableArray *)sections {
    NSArray<ESTimelineFrameItem *> *timeLines = [[ESSmartPhotoDataBaseManager shared] getTimeLinesFromDBType:ESTimelineFrameItemTypeDay];
    timeLines = [self filterEmptySection:timeLines];
    
    [timeLines enumerateObjectsUsingBlock:^(ESTimelineFrameItem * _Nonnull frameItem, NSUInteger idx, BOOL * _Nonnull stop) {
        ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
        sectoion.sectionSubtitle = frameItem.dateWithTypeTranslate;
        sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    
        NSArray<ESPicModel *> * pics = [[ESSmartPhotoDataBaseManager shared] getPicsTodayInHistoryFromDBByDateWithYear:frameItem.year
                                                                            month:frameItem.month
                                                                              day:frameItem.day];
        
        NSMutableArray *blocks = [NSMutableArray array];
        [pics enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
            if(pic.uuid.length > 0 && pic.albumIdList.count > 0) {
                ESSmartPhotoListBlockModel *block = [ESSmartPhotoListBlockModel new];
                block.blockType = ESSmartPhotoBlockTypeSinglePic;
                block.items = @[pic];
                [blocks addObject:block];
            }
        }];
        
        if (blocks.count > 0) {
            sectoion.blocks = blocks;
            [sections addObject:sectoion];
        }
    }];
}

+ (instancetype)reloadDataFromDBWithType:(ESTimelineFrameItemType)type {
    ESSmartPhotoListModel *model = [[ESSmartPhotoListModel alloc] init];
    NSMutableArray *sections = [NSMutableArray array];
    
    [self addAlbumCategoryWithSections:sections];
    [self addTimeLineWithSections:sections timelineType:type];

    if (sections.count > 1) {
        model.sections = sections;
        return model;
    }
    
    ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
    sectoion.sectionTitle = NSLocalizedString(@"home_all", @"全部");
    sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    sectoion.blocks = @[];
    [sections addObject:sectoion];
    model.sections = sections;
    return model;
}

+ (instancetype)reloadOnlyPicDataFromDBWithType:(ESTimelineFrameItemType)type {
    ESSmartPhotoListModel *model = [[ESSmartPhotoListModel alloc] init];
    NSMutableArray *sections = [NSMutableArray array];
    
    [self addTimeLineWithSections:sections timelineType:type];

    if (sections.count > 0) {
        ESSmartPhotoListSectionModel *sectoion = sections[0];
        sectoion.sectionTitle = @"";
        model.sections = sections;
        return model;
    }
    
    model.sections = @[];
    return model;
}


+ (NSArray<ESAlbumCategoryModel *> *)albumCategoryModelList {
    return  [NSArray yy_modelArrayWithClass:ESAlbumCategoryModel.class json:self.albumCategoryDataList];
}

+ (NSArray *)albumCategoryDataList {
    ESPicModel *lastestUserCreatedPic = [[ESSmartPhotoDataBaseManager shared] getLatestAlbumUserPicFromDBByAlbumType:ESAlbumTypeUserCreated];
    ESPicModel *lastestAddressPic = [[ESSmartPhotoDataBaseManager shared] getLatestAlbumUserPicFromDBByAlbumType:ESAlbumTypeAddress];
    ESPicModel *lastestMemoriesPic = [[ESSmartPhotoDataBaseManager shared] getLatestAlbumUserPicFromDBByAlbumType:ESAlbumTypeMemories];
    ESPicModel *lastestLikePic = [[ESSmartPhotoDataBaseManager shared] getLatestAlbumUserPicFromDBByAlbumType:ESAlbumTypeUserLike];
    ESPicModel *lastestVideoPic = [[ESSmartPhotoDataBaseManager shared] getLatestAlbumUserPicFromDBByAlbumType:ESAlbumTypeVideo];
    ESPicModel *lastestScreenshotPic = [[ESSmartPhotoDataBaseManager shared] getLatestAlbumUserPicFromDBByAlbumType:ESAlbumTypeScreenshot];
    ESPicModel *lastestGifPic = [[ESSmartPhotoDataBaseManager shared] getLatestAlbumUserPicFromDBByAlbumType:ESAlbumTypeGif];

    return @[
        @{@"albumCategoryName" :NSLocalizedString(@"album_my", @"我的相簿"),
          @"albumCount" : @(0),
          @"coverUrl" :  ESSafeString(lastestUserCreatedPic.uuid),
          @"type" : @(ESAlbumCategoryTypeMyAlbum)
        },
        @{@"albumCategoryName" : NSLocalizedString(@"album_footprint", @"足迹"),
          @"albumCount" : @(0),
          @"coverUrl" :  ESSafeString(lastestAddressPic.uuid),
          @"type" : @(ESAlbumCategoryTypeAddress)
        },
        @{@"albumCategoryName" : NSLocalizedString(@"album_memories", @"回忆"),
          @"albumCount" : @(0),
          @"coverUrl" :  ESSafeString(lastestMemoriesPic.uuid),
          @"type" : @(ESAlbumCategoryTypeMemories)
        },
        @{@"albumCategoryName" : NSLocalizedString(@"Like", @"喜欢"),
          @"albumCount" : @(0),
          @"coverUrl" :  ESSafeString(lastestLikePic.uuid),
          @"type" : @(ESAlbumCategoryTypeUserLike)
        },
        @{@"albumCategoryName" : NSLocalizedString(@"home_video", @"视频"),
          @"albumCount" : @(0),
          @"coverUrl" :  ESSafeString(lastestVideoPic.uuid),
          @"type" : @(ESAlbumCategoryTypeVideo)
        },
        @{@"albumCategoryName" : NSLocalizedString(@"Screenshots", @"截图"),
          @"albumCount" : @(0),
          @"coverUrl" :  ESSafeString(lastestScreenshotPic.uuid),
          @"type" : @(ESAlbumCategoryTypeScreenshot)
        },
        @{@"albumCategoryName" :NSLocalizedString(@"GIFs", @"动图"),
          @"albumCount" : @(0),
          @"coverUrl" :  ESSafeString(lastestGifPic.uuid),
          @"type" : @(ESAlbumCategoryTypeGif)
        },
    ];
}

+ (void)addTimeLineWithSections:(NSMutableArray *)sections albumId:(NSString *)albumId {
    NSArray<ESTimelineFrameItem *> *timeLines = [[ESSmartPhotoDataBaseManager shared] getTimeLinesFromDBType:ESTimelineFrameItemTypeDay];
    timeLines = [self filterEmptySection:timeLines];
    
    [timeLines enumerateObjectsUsingBlock:^(ESTimelineFrameItem * _Nonnull frameItem, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSInteger sectionBlockCount = frameItem.count;
        ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
        sectoion.sectionSubtitle = frameItem.dateWithTypeTranslate;
        sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    
        NSArray<ESPicModel *> * pics = [[ESSmartPhotoDataBaseManager shared] getPicsFromDBWithAlbumId:albumId
                                                                     dateWithYear:frameItem.year
                                                                            month:frameItem.month
                                                                              day:frameItem.day];
        
        NSMutableArray *blocks = [NSMutableArray array];
        [pics enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
            if(pic.uuid.length > 0 && pic.albumIdList.count > 0) {
                ESSmartPhotoListBlockModel *block = [ESSmartPhotoListBlockModel new];
                block.blockType = ESSmartPhotoBlockTypeSinglePic;
                block.items = @[pic];
                [blocks addObject:block];
            }
        }];
        
        if (blocks.count > 0) {
            sectoion.blocks = blocks;
            [sections addObject:sectoion];
        }
    }];
}

+ (void)addAlbumCategoryWithSections:(NSMutableArray *)sections {
    NSArray<ESAlbumCategoryModel *> *albumList = [self albumCategoryModelList];
    if (albumList.count > 0) {
        ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
        sectoion.sectionTitle = NSLocalizedString(@"Album Classify", @"相册分类") ;
        sectoion.sectionType = ESSmartPhotoSectionTypeAlbums;
        
        ESSmartPhotoListBlockModel *albumCategoryList = [ESSmartPhotoListBlockModel new];
        albumCategoryList.blockType = ESSmartPhotoBlockTypeAlbum;
        albumCategoryList.items = albumList;
        sectoion.blocks = @[albumCategoryList];
        [sections addObject:sectoion];
    }
}

+ (ESSmartPhotoListSectionModel *)albumCategoryWithSections {
    NSArray<ESAlbumCategoryModel *> *albumList = [self albumCategoryModelList];
    ESSmartPhotoListSectionModel *sectoion;
    if (albumList.count > 0) {
        sectoion = [ESSmartPhotoListSectionModel new];
        sectoion.sectionTitle = NSLocalizedString(@"Album Classify", @"相册分类") ;
        sectoion.sectionType = ESSmartPhotoSectionTypeAlbums;
        
        ESSmartPhotoListBlockModel *albumCategoryList = [ESSmartPhotoListBlockModel new];
        albumCategoryList.blockType = ESSmartPhotoBlockTypeAlbum;
        albumCategoryList.items = albumList;
        sectoion.blocks = @[albumCategoryList];
    }
    return sectoion;
}

+ (void)addTimeLineWithSections:(NSMutableArray *)sections timelineType:(ESTimelineFrameItemType)type {
    NSArray<ESTimelineFrameItem *> *timeLines = [[ESSmartPhotoDataBaseManager shared] getTimeLinesFromDBType:type];
    timeLines = [self filterEmptySection:timeLines];
    
    [timeLines enumerateObjectsUsingBlock:^(ESTimelineFrameItem * _Nonnull frameItem, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger sectionBlockCount = frameItem.count;
        ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
        if (idx == 0) {
            sectoion.sectionTitle = NSLocalizedString(@"home_all", @"全部");
        }
        sectoion.sectionSubtitle = frameItem.dateWithTypeTranslate;
        sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
        
        NSArray<ESPicModel *> *pics;
        if (type == ESTimelineFrameItemTypeDay) {
            pics = [[ESSmartPhotoDataBaseManager shared] getPicsFromDBByDateWithYear:frameItem.year
                                                                              month:frameItem.month
                                                                                day:frameItem.day];
        } else if (type == ESTimelineFrameItemTypeMonth) {
            pics = [[ESSmartPhotoDataBaseManager shared] getPicsFromDBByYear:frameItem.year month:frameItem.month];
        } else if (type == ESTimelineFrameItemTypeYear) {
            pics = [[ESSmartPhotoDataBaseManager shared] getPicsFromDBByYear:frameItem.year];
            pics = [pics subarrayWithRange:NSMakeRange(0, MIN(pics.count, 16))];
        }
        
        NSMutableArray *blocks = [NSMutableArray array];
        [pics enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
            if(pic.uuid.length > 0 && pic.albumIdList.count > 0) {
                ESSmartPhotoListBlockModel *block = [ESSmartPhotoListBlockModel new];
                block.blockType = ESSmartPhotoBlockTypeSinglePic;
                block.items = @[pic];
                [blocks addObject:block];
            }
        }];
        BOOL isFirstLoaded = [ESSmartPhotoAsyncManager.shared isFirstLoaded];
        if (0 < sectionBlockCount && !isFirstLoaded && type != ESTimelineFrameItemTypeYear ) {
            for (int i = 0; i < sectionBlockCount; i++ ) {
                ESSmartPhotoListBlockModel *block = [ESSmartPhotoListBlockModel new];
                block.blockType = ESSmartPhotoBlockTypeSinglePic;
                ESPicModel *pic = [ESPicModel new];
                pic.uuid = [NSString stringWithFormat:@"mock_%@", NSUUID.UUID.UUIDString.lowercaseString];
                block.items = @[pic];
                [blocks addObject:block];
            }
        }
        
        if (blocks.count > 0) {
            sectoion.blocks = blocks;
            [sections addObject:sectoion];
        }
    }];
}

+ (NSArray<ESTimelineFrameItem *> *)filterEmptySection:(NSArray<ESTimelineFrameItem *> *)timeLines {
    NSMutableArray *list = [NSMutableArray array];
    [timeLines enumerateObjectsUsingBlock:^(ESTimelineFrameItem * _Nonnull frameItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (frameItem.count > 0) {
            [list addObject:frameItem];
        }
    }];
    return [list copy];
}

+ (instancetype)initMockEmptyData {
    ESSmartPhotoListModel *model = [[ESSmartPhotoListModel alloc] init];
    NSMutableArray *sections = [NSMutableArray array];
    [self addAlbumCategoryWithSections:sections];
    
    ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
    sectoion.sectionTitle = NSLocalizedString(@"home_all", @"全部");
    sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    sectoion.blocks = @[];
    
    [sections addObject:sectoion];
    model.sections = sections;
    
    return model;
}

- (instancetype)initMockData {
    if (self = [super init]) {
        ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
        sectoion.sectionTitle = NSLocalizedString(@"History Today", @"历史今天");
        sectoion.sectionType = ESSmartPhotoSectionTypeBanner;
        
        ESSmartPhotoListBlockModel *block = [ESSmartPhotoListBlockModel new];
        ESPicModel *pic1 = [ESPicModel new];
        ESPicModel *pic2 = [ESPicModel new];
        ESPicModel *pic3 = [ESPicModel new];
        block.blockType = ESSmartPhotoBlockTypeMutliPic;
        block.items = @[pic1, pic2, pic3];
        sectoion.blocks = @[block];
        
        
        ESSmartPhotoListSectionModel *sectoion2 = [ESSmartPhotoListSectionModel new];
        sectoion2.sectionTitle = NSLocalizedString(@"Album Classify", @"相册分类");
        sectoion2.sectionType = ESSmartPhotoSectionTypeAlbums;
        
        ESSmartPhotoListBlockModel *block2 = [ESSmartPhotoListBlockModel new];
        ESAlbumModel *ablum1 = [ESAlbumModel new];
        ESAlbumModel *ablum2 = [ESAlbumModel new];
        ESAlbumModel *ablum3 = [ESAlbumModel new];
        block2.blockType = ESSmartPhotoBlockTypeAlbum;
        block2.items = @[ablum1, ablum2, ablum3];
        sectoion2.blocks = @[block2];
        
        ESSmartPhotoListSectionModel *sectoion3 = [ESSmartPhotoListSectionModel new];
        sectoion3.sectionTitle =  NSLocalizedString(@"home_all", @"全部");
        sectoion3.sectionSubtitle = @"2022年8月";
        sectoion3.sectionType = ESSmartPhotoSectionTypeTimelines;
        
        ESSmartPhotoListBlockModel *block3 = [ESSmartPhotoListBlockModel new];
        ESPicModel *pic31 = [ESPicModel new];
        pic31.uuid = @"31";
        block3.blockType = ESSmartPhotoBlockTypeSinglePic;
        block3.items = @[pic31];

        ESSmartPhotoListBlockModel *block4 = [ESSmartPhotoListBlockModel new];
        ESPicModel *pic32 = [ESPicModel new];
        pic32.uuid = @"33";
        block4.items = @[pic32];

        ESSmartPhotoListBlockModel *block5 = [ESSmartPhotoListBlockModel new];
        ESPicModel *pic33 = [ESPicModel new];
        pic33.uuid = @"35";
        block5.items = @[pic33];

        sectoion3.blocks = @[block3, block4, block5];

        
        ESSmartPhotoListSectionModel *sectoion4 = [ESSmartPhotoListSectionModel new];
        sectoion4.sectionSubtitle = @"2022年7月";
        sectoion4.sectionType = ESSmartPhotoSectionTypeTimelines;
        
        ESSmartPhotoListBlockModel *block6 = [ESSmartPhotoListBlockModel new];
        ESPicModel *pic41 = [ESPicModel new];
        pic33.uuid = @"45";
        block6.blockType = ESSmartPhotoBlockTypeSinglePic;
        block6.items = @[pic41];
        sectoion4.blocks = @[block6];
        
        self.sections = @[sectoion, sectoion2, sectoion3, sectoion4];
    }
    return self;
}

@end

