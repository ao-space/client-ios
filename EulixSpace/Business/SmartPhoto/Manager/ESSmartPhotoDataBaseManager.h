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
//  ESSmartPhotoDataBaseManager.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTimelineFrameItem.h"
#import "ESAlbumModel.h"
#import "ESPhotoUploadMetaModel.h"

@class ESPicModel;

NS_ASSUME_NONNULL_BEGIN

@interface ESSmartPhotoDataBaseManager : NSObject

+ (instancetype)shared;

//删除DB数据，不懂数据库表
- (BOOL)cleanDBCache;
//删除DB库文件
+ (void)cleanAllDB;

//删除之前用户的DB数据， 重新生新用户成数据库表
- (BOOL)cleanDBCacheAndReCreateDB;

#pragma mark - timelines

- (NSArray<ESTimelineFrameItem *> *)getTimeLinesFromDBType:(ESTimelineFrameItemType)type;

- (BOOL)insertOrUpdatTimeLineToDB:(NSArray<ESTimelineFrameItem *> *)timeLineFrames;

- (BOOL)deleteAllTimeLineDBData;

#pragma mark - Album
- (NSArray<ESAlbumModel *> *)getAllAlbumsFromDB;
- (NSArray<ESAlbumModel *> *)getAlbumsFromDBByType:(ESAlbumType)type;

- (ESAlbumModel * _Nullable)getAlbumByid:(NSString *)albumId;
- (ESAlbumModel * _Nullable)getLatestAlbumPicFromDBByType:(ESAlbumType)type;
- (BOOL)insertOrUpdateAlbumsToDB:(NSArray<ESAlbumModel *> *)albums;
- (BOOL)deletAlbumDBDataWithAlbumIds:(NSArray *)ids;
- (BOOL)deletAlbumDBData;

- (ESAlbumModel * _Nullable)getMainAblum;
- (NSArray<ESAlbumModel*> * _Nullable)getAlbumDataFromDBByType:(ESAlbumType)type;
- (NSArray<ESAlbumModel*> * _Nullable)getCollectionAlbumDataFromDBByType:(ESAlbumType)type;

#pragma mark - Pic

- (ESPicModel *_Nullable)getPicByUuid:(NSString *)uuid;
- (NSArray<ESPicModel *> *_Nullable)getPicByUuids:(NSArray<NSString *> *)uuids;
- (BOOL)insertOrUpdatePicsToDB:(NSArray<ESPicModel *> *)pics;
- (BOOL)deletPicsDBDataWithUuids:(NSArray *)uuids;

- (NSInteger)getPicCountFromDBWithDayDate:(NSString *)date;
- (NSInteger)getDayDateCountFromDB;

- (NSArray<ESPicModel *> *)getPicsFromDBByDateWithYear:(NSInteger)year
                                        month:(NSInteger)month
                                          day:(NSInteger)day;
#pragma mark -
- (NSArray<ESPicModel *> *)getPicsLikeFromDBByDateWithYear:(NSInteger)year
                                        month:(NSInteger)month
                                          day:(NSInteger)day;

- (NSArray<ESPicModel *> *)getPicsLikeFromDB;

#pragma mark - TodayInHistory
- (NSArray<ESPicModel *> *)getPicsTodayInHistoryFromDBByDateWithYear:(NSInteger)year
                                                     month:(NSInteger)month
                                                                 day:(NSInteger)day;

- (NSArray<ESPicModel *> *)getPicsFromDBByYear:(NSInteger)year month:(NSInteger)month;

- (NSArray<ESPicModel *> *)getPicsFromDBByYear:(NSInteger)year;


- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId
                                        dateWithYear:(NSInteger)year
                                        month:(NSInteger)month
                                          day:(NSInteger)day;

- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId
                                             dateWithYear:(NSInteger)year
                                              month:(NSInteger)month;

- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId
                                             dateWithYear:(NSInteger)year;

- (NSArray<ESPicModel *> *)getPicsFromDBWithAlbumId:(NSString *)ablumId;
- (NSArray<ESPicModel *> *)getPicsFromDB;

- (ESPicModel * _Nullable)getLatestAlbumPicFromDBById:(NSString *)albumId;
- (ESPicModel * _Nullable)getLatestAlbumUserPicFromDBByAlbumType:(ESAlbumType)type;

@end

NS_ASSUME_NONNULL_END
