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
//  ESSmartPhotoDataBaseManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSmartPhotoDataBaseManager.h"
#import <WCDB/WCDB.h>
#import "ESAlbumModel.h"
#import "ESPicModel.h"
#import "ESAlbumModel+WCTTableCoding.h"
#import "ESPicModel+WCTTableCoding.h"
#import "ESAccountInfoStorage.h"
#import "ESTimelineFrameItem+WCTTableCoding.h"
#import "ESPhotoUploadMetaModel+WCTTableCoding.h"

@interface ESSmartPhotoDataBaseManager ()

@property (nonatomic,strong) WCTDatabase *database;

@end

@implementation ESSmartPhotoDataBaseManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        [instance createDataBase];
    });
    return instance;
}

- (BOOL)cleanDBCache {
    BOOL picResult = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESPicModel.class)];
    BOOL albumResult = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESAlbumModel.class)];
    BOOL timeLineResult = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESTimelineFrameItem.class)];
    BOOL uploadResult = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESPhotoUploadMetaModel.class)];

    return picResult && albumResult && timeLineResult && uploadResult;
}

- (WCTDatabase *)createDataBase {
    if (_database) {
        return _database;
    }
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //注意，此处数据库名字不要带sqlite的后缀名，恢复数据库的时候如果有这个后缀名，会造成无法恢复的情况。这是一个坑啊，大家千万要注意
    NSString *path = [NSString stringWithFormat:@"%@/chatDB_%@",docDir, ESSafeString([ESAccountInfoStorage userUniqueKey])];
    _database = [[WCTDatabase alloc] initWithPath:path];
    BOOL timeLineResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESTimelineFrameItem.class)
                                                    withClass:ESTimelineFrameItem.class];
    BOOL albumResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESAlbumModel.class)
                                                    withClass:ESAlbumModel.class];
    BOOL picResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESPicModel.class)
                                                  withClass:ESPicModel.class];
    BOOL uploadResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESPhotoUploadMetaModel.class)
                                                     withClass:ESPhotoUploadMetaModel.class];
    if (timeLineResult && albumResult && picResult && uploadResult) {
        return _database;
    }
    return nil;
}

- (BOOL)cleanDBCacheAndReCreateDB {
    if ([self cleanDBCache]) {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        //注意，此处数据库名字不要带sqlite的后缀名，恢复数据库的时候如果有这个后缀名，会造成无法恢复的情况。这是一个坑啊，大家千万要注意
        NSString *path = [NSString stringWithFormat:@"%@/chatDB_%@",docDir, ESSafeString([ESAccountInfoStorage userUniqueKey])];
        _database = [[WCTDatabase alloc] initWithPath:path];
        BOOL timeLineResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESTimelineFrameItem.class)
                                                        withClass:ESTimelineFrameItem.class];
        BOOL albumResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESAlbumModel.class)
                                                        withClass:ESAlbumModel.class];
        BOOL picResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESPicModel.class)
                                                      withClass:ESPicModel.class];
        BOOL uploadResult = [_database createTableAndIndexesOfName:NSStringFromClass(ESPhotoUploadMetaModel.class)
                                                         withClass:ESPhotoUploadMetaModel.class];
        if (timeLineResult && albumResult && picResult && uploadResult) {
            return YES;
        }
    }
    return NO;
}

+ (void)cleanAllDB {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //注意，此处数据库名字不要带sqlite的后缀名，恢复数据库的时候如果有这个后缀名，会造成无法恢复的情况。这是一个坑啊，大家千万要注意
    NSString *path = [NSString stringWithFormat:@"%@/chatDB_%@",docDir, ESSafeString([ESAccountInfoStorage userUniqueId])];
    WCTDatabase *database = [[WCTDatabase alloc] initWithPath:path];
    [database close];
    NSError *error;
    [database removeFilesWithError:&error];
}

#pragma mark - timelines
- (NSArray<ESTimelineFrameItem *> *)getTimeLinesFromDBType:(ESTimelineFrameItemType)type {
    NSArray *ary = [self.database getObjectsOfClass:ESTimelineFrameItem.class
                                             fromTable:NSStringFromClass(ESTimelineFrameItem.class)
                                                 where:ESTimelineFrameItem.timelineType == type
                                            orderBy:ESTimelineFrameItem.localID.order(WCTOrderedDescending)];
    return ary;
}

- (BOOL)insertOrUpdatTimeLineToDB:(NSArray<ESTimelineFrameItem *> *)timeLineFrames {
    BOOL result = [self.database insertOrReplaceObjects:timeLineFrames into:NSStringFromClass(ESTimelineFrameItem.class)];
    return result;
}

- (BOOL)deleteAllTimeLineDBData {
    BOOL result = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESTimelineFrameItem.class)];
    return result;
}

#pragma mark - Album

- (NSArray<ESAlbumModel *> *)getAllAlbumsFromDB {
    NSArray *ary = [self.database getAllObjectsOfClass:ESAlbumModel.class fromTable:NSStringFromClass(ESAlbumModel.class)];
    return ary;
}

- (NSArray<ESAlbumModel *> *)getAlbumsFromDBByType:(ESAlbumType)type {
    NSArray *ary = [self.database getObjectsOfClass:ESAlbumModel.class
                                          fromTable:NSStringFromClass(ESAlbumModel.class)
                                              where:ESAlbumModel.type == type
                                            orderBy:ESAlbumModel.createdAt.order(WCTOrderedDescending)];
    return ary;
}

- (ESAlbumModel * _Nullable)getMainAblum {
    NSArray *ary = [self.database getObjectsOfClass:ESAlbumModel.class fromTable:NSStringFromClass(ESAlbumModel.class) where:ESAlbumModel.type == 1];
    return ary.count > 0 ? ary[0] : nil;
}

- (ESAlbumModel * _Nullable)getAlbumByid:(NSString *)albumId {
    if (albumId.length <= 0) {
        return nil;
    }
    NSArray *ary = [self.database getObjectsOfClass:ESAlbumModel.class fromTable:NSStringFromClass(ESAlbumModel.class) where:ESAlbumModel.albumId == albumId];
    if (ary.count > 0) {
        return ary[0];
    }
    return nil;
}

- (ESAlbumModel * _Nullable)getLatestAlbumPicFromDBByType:(ESAlbumType)type {
    NSArray *ary = [self.database getObjectsOfClass:ESAlbumModel.class
                                            fromTable:NSStringFromClass(ESAlbumModel.class)
                                              where:ESAlbumModel.type == type];
    if (ary.count > 0) {
        return ary[0];
    }
    return nil;
}

- (NSArray<ESAlbumModel*> * _Nullable)getAlbumDataFromDBByType:(ESAlbumType)type {
    NSArray *ary = [self.database getObjectsOfClass:ESAlbumModel.class
                                            fromTable:NSStringFromClass(ESAlbumModel.class)
                                              where:ESAlbumModel.type == type];
    if (ary.count > 0) {
        return ary;
    }
    return nil;
}

- (NSArray<ESAlbumModel*> * _Nullable)getCollectionAlbumDataFromDBByType:(ESAlbumType)type {
    NSArray *ary = [self.database getObjectsOfClass:ESAlbumModel.class
                                            fromTable:NSStringFromClass(ESAlbumModel.class)
                                              where:ESAlbumModel.type == type &&
                                                    ESAlbumModel.collection == YES];
    if (ary.count > 0) {
        return ary;
    }
    return nil;
}


- (BOOL)insertOrUpdateAlbumsToDB:(NSArray<ESAlbumModel *> *)albums {
    if (albums.count <= 0) {
        return NO;
    }
    BOOL result = [self.database insertOrReplaceObjects:albums into:NSStringFromClass(ESAlbumModel.class)];
    return result;
}

- (BOOL)deletAlbumDBDataWithAlbumIds:(NSArray *)ids {
    if (ids.count <= 0) {
        return NO;
    }
    BOOL result = [self.database deleteObjectsFromTable:NSStringFromClass(ESAlbumModel.class) where:ESAlbumModel.albumId.in(ids)];
    return result;
}

- (BOOL)deletAlbumDBData {
    BOOL result = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESAlbumModel.class)];
    return result;
}

#pragma mark - Pic

- (NSArray<ESPicModel *> *_Nullable)getPicByUuids:(NSArray<NSString *> *)uuids {
    if (uuids.count <= 0) {
        return nil;
    }
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class fromTable:NSStringFromClass(ESPicModel.class) where:ESPicModel.uuid.in(uuids)];
    return ary;
}

- (ESPicModel *_Nullable)getPicByUuid:(NSString *)uuid {
    if (uuid.length <= 0) {
        return nil;
    }
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class fromTable:NSStringFromClass(ESPicModel.class) where:ESPicModel.uuid == uuid];
    return [ary firstObject];
}

- (BOOL)insertOrUpdatePicsToDB:(NSArray<ESPicModel *> *)pics {
    if (pics.count <= 0) {
        return NO;
    }
    BOOL result = [_database insertOrReplaceObjects:pics into:NSStringFromClass(ESPicModel.class)];
    return result;
}

- (BOOL)deletPicsDBDataWithUuids:(NSArray *)uuids {
    if (uuids.count <= 0) {
        return NO;
    }
    BOOL result = [self.database deleteObjectsFromTable:NSStringFromClass(ESPicModel.class)  where:ESPicModel.uuid.in(uuids)];
    return result;
}

- (NSInteger)getPicCountFromDBWithDayDate:(NSString *)date {
    NSNumber *count = [self.database getOneValueOnResult:ESPicModel.uuid.count()
                                            fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date == date && ESPicModel.uuid != @"null" && ESPicModel.albumIds.length() > 2];
    return [count intValue];
}

- (NSInteger)getDayDateCountFromDB {
    NSNumber *count = [self.database getOneValueOnResult:ESPicModel.date.count() fromTable:NSStringFromClass(ESPicModel.class)];
    return [count intValue];
}

- (NSArray<ESPicModel *> *)getPicsFromDBByDateWithYear:(NSInteger)year
                                        month:(NSInteger)month
                                          day:(NSInteger)day {
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date_year == year &&
                                                    ESPicModel.date_month == month &&
                                                    ESPicModel.date_day == day
                    orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)
    ];
    
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsLikeFromDBByDateWithYear:(NSInteger)year
                                        month:(NSInteger)month
                                                       day:(NSInteger)day {
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date_year == year &&
                                                    ESPicModel.date_month == month &&
                                                    ESPicModel.date_day == day &&
                                                    ESPicModel.like == YES
                    orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)
    ];
    
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsTodayInHistoryFromDBByDateWithYear:(NSInteger)year
                                                     month:(NSInteger)month
                                                       day:(NSInteger)day {
    
    NSArray<ESAlbumModel*> *albums = [ESSmartPhotoDataBaseManager.shared getAlbumDataFromDBByType:ESAlbumTypeTodayInHistory];
    if (albums.count <= 0) {
        return nil;
    }
    NSMutableArray *picList = [NSMutableArray array];

    [albums enumerateObjectsUsingBlock:^(ESAlbumModel * _Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *albumIdSql = [@"%#" stringByAppendingString:ESSafeString(album.albumId)];
        albumIdSql = [albumIdSql stringByAppendingString:@"#%"];
        NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                              fromTable:NSStringFromClass(ESPicModel.class)
                                                  where:ESPicModel.date_month == month &&
                                                        ESPicModel.date_year == year &&
                                                        ESPicModel.date_day == day &&
                                                        ESPicModel.albumIds.like(albumIdSql)
                                                orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
        if (ary.count > 0) {
            [picList addObjectsFromArray:ary];
        }
    }];
    
    return [picList copy];
}

- (NSArray<ESPicModel *> *)getPicsLikeFromDB {
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.like == YES
                    orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)
    ];
    
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsFromDBByYear:(NSInteger)year month:(NSInteger)month {
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date_month == month && ESPicModel.date_year == year
                                            orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsFromDBByYear:(NSInteger)year {
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date_year == year
                                            orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId
                                        dateWithYear:(NSInteger)year
                                        month:(NSInteger)month
                                                day:(NSInteger)day {
    if (ablumId.length <= 0) {
        return @[];
    }
    NSString *albumIdSql = [@"%#" stringByAppendingString:ablumId];
    albumIdSql = [albumIdSql stringByAppendingString:@"#%"];
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date_year == year &&
                                                    ESPicModel.date_month == month &&
                                                    ESPicModel.date_day == day &&
                                                    ESPicModel.albumIds.like(albumIdSql)
                    orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)
    ];
    
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId
                                             dateWithYear:(NSInteger)year
                                              month:(NSInteger)month {
    NSString *albumIdSql = [@"%#" stringByAppendingString:ablumId];
    albumIdSql = [albumIdSql stringByAppendingString:@"#%"];
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date_month == month &&
                                                    ESPicModel.date_year == year &&
                                                    ESPicModel.albumIds.like(albumIdSql)
                                            orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId
                                       dateWithYear:(NSInteger)year {
    NSString *albumIdSql = [@"%#" stringByAppendingString:ablumId];
    albumIdSql = [albumIdSql stringByAppendingString:@"#%"];
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.date_year == year &&
                                                    ESPicModel.albumIds.like(albumIdSql)
                                            orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId {
    NSString *albumIdSql = [@"%#" stringByAppendingString:ablumId];
    albumIdSql = [albumIdSql stringByAppendingString:@"#%"];
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.albumIds.like(albumIdSql)
                                            orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
    return ary;
}

- (NSArray<ESPicModel *> *)getPicsFromDB {
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                          fromTable:NSStringFromClass(ESPicModel.class)
                                            orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
    return ary;
}

- (ESPicModel * _Nullable)getLatestAlbumPicFromDBById:(NSString *)albumId {
    if (albumId.length <= 0) {
        return nil;
    }
    NSString *albumIdSql = [@"%#" stringByAppendingString:albumId];
    albumIdSql = [albumIdSql stringByAppendingString:@"#%"];
    NSNumber *latestePicItem = [self.database getOneValueOnResult:ESPicModel.shootAt.max()
                                            fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.albumIds.like(albumIdSql)];
    
    if (latestePicItem == nil) {
        return nil;
    }
    
    NSTimeInterval latestShootAt = [latestePicItem doubleValue];
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                                 fromTable:NSStringFromClass(ESPicModel.class)
                                                   where: ESPicModel.shootAt == latestShootAt];
                                                        
    if (ary.count > 0) {
        return ary[0];
    }
    return nil;
}

- (ESPicModel * _Nullable)getLatestAlbumUserPicFromDBByAlbumType:(ESAlbumType)type {
    NSArray *albumAry = [self.database getObjectsOfClass:ESAlbumModel.class
                                          fromTable:NSStringFromClass(ESAlbumModel.class)
                                              where:ESAlbumModel.type == type
                                            orderBy:ESAlbumModel.modifyAt.order(WCTOrderedDescending)];
    if (albumAry.count <= 0) {
        return nil;
    }
    
    __block ESAlbumModel *ablumItem = albumAry[0];
    [albumAry enumerateObjectsUsingBlock:^(ESAlbumModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.picCount > 0) {
            ablumItem = obj;
            *stop = YES;
        }
    }];
    
    NSString *albumIdSql = [@"%#" stringByAppendingString:[ablumItem albumId]];
    albumIdSql = [albumIdSql stringByAppendingString:@"#%"];
    NSNumber *latestePicItem = [self.database getOneValueOnResult:ESPicModel.shootAt.max()
                                            fromTable:NSStringFromClass(ESPicModel.class)
                                              where:ESPicModel.albumIds.like(albumIdSql)];
    
    if (latestePicItem == nil) {
        if (type == ESAlbumTypeUserLike) {
            NSArray *picAry  = [self.database getObjectsOfClass:ESPicModel.class
                                                    fromTable:NSStringFromClass(ESPicModel.class)
                                                          where:ESPicModel.like == YES
                                                        orderBy:ESPicModel.shootAt.order(WCTOrderedDescending)];
            if (picAry.count > 0) {
                return picAry[0];
            }
        }
        
        return nil;
    }
    
    NSTimeInterval latestShootAt = [latestePicItem doubleValue];
    NSArray *ary = [self.database getObjectsOfClass:ESPicModel.class
                                                 fromTable:NSStringFromClass(ESPicModel.class)
                                                   where: ESPicModel.shootAt == latestShootAt];
                                                        
    if (ary.count > 0) {
        return ary[0];
    }
    return nil;
}

@end

