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
//  ESSmartPhotoAsyncManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSmartPhotoAsyncManager.h"
#import "ESPicAsyncModule.h"
#import "ESCache.h"
#import "ESAccountInfoStorage.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESPicModel.h"
#import "ESDateTransferManager.h"
#import "ESTimelineFrameItem.h"
#import "ESSmarPhotoCacheManager.h"
#import "ESNetworkRequestManager.h"
#import "ESPhotoUploadManager.h"
#import "ESBoxManager.h"

@interface ESSmartPhotoAsyncManager ()

@property (nonatomic, strong) ESPicAsyncModule *asyncModule;
@property (nonatomic, assign) NSUInteger lastOperateId;

@property (nonatomic, assign) NSInteger timeLineSuccessCount;
@property (nonatomic, assign) NSInteger timeLineFailCount;
@property (nonatomic, assign) NSInteger timeLinetotalCount;

@property (nonatomic, strong)dispatch_semaphore_t timeLinesSemaphoreLock;
@property (nonatomic, strong)dispatch_queue_t requestQueue;
@property (nonatomic, strong)dispatch_queue_t requestHandleQueue;
@property (nonatomic, strong)dispatch_queue_t timeLimeRequestQueue;

@property (nonatomic, strong)dispatch_queue_t downloadRequestQueue;
@property (nonatomic, strong)dispatch_semaphore_t downloadSemaphoreLock;

@property (nonatomic, strong)NSOperationQueue *picRequestQueue;

@property (nonatomic, strong)ESDateTransferManager *dateTransferManager;

@property (nonatomic, strong)NSMutableArray *incrementModifyTimelineList;
@property (nonatomic, strong)NSMutableArray *incrementModifyTimelineFrameList;

@property (nonatomic, assign) BOOL isAsyning;
@property (nonatomic, assign) BOOL isDataUpdated;

@property (nonatomic, strong) NSHashTable *asynObservers;

@end

static NSString * const ESFirstLoadFinished = @"ESFirstLoadFinished";
static NSString * const ESLastOperateId = @"ESLastOperateId";
static NSString * const ESUserId = @"ESPhontoUserId";

@implementation ESSmartPhotoAsyncManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)newServiceInstance {
    return [ESSmartPhotoAsyncManager shared];
}

- (void)startService {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    _timeLinesSemaphoreLock = dispatch_semaphore_create(6);
    self.requestQueue = dispatch_queue_create("ES_Smart_Photo_Asyn_Queue", DISPATCH_QUEUE_CONCURRENT);
    self.requestHandleQueue = dispatch_queue_create("ES_Smart_Photo_Request_Handle_Queue", DISPATCH_QUEUE_SERIAL);
    self.timeLimeRequestQueue = dispatch_queue_create("ES_Smart_Photo_Request_TimeLine_Queue", DISPATCH_QUEUE_SERIAL);
    
    self.downloadRequestQueue = dispatch_queue_create("ES_Smart_Photo_Download_Queue", DISPATCH_QUEUE_SERIAL);
    self.downloadSemaphoreLock = dispatch_semaphore_create(6);

    self.picRequestQueue = [[NSOperationQueue alloc] init];
    self.picRequestQueue.maxConcurrentOperationCount = 6;
    [self.dateTransferManager transferByDateString:@""];

    [ESPhotoUploadManager startService];
    [self tryAsyncData];
}

- (void)resetService {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];


    _timeLinesSemaphoreLock = dispatch_semaphore_create(6);
    self.requestQueue = dispatch_queue_create("ES_Smart_Photo_Asyn_Queue", DISPATCH_QUEUE_CONCURRENT);
    self.requestHandleQueue = dispatch_queue_create("ES_Smart_Photo_Request_Handle_Queue", DISPATCH_QUEUE_SERIAL);
    self.timeLimeRequestQueue = dispatch_queue_create("ES_Smart_Photo_Request_TimeLine_Queue", DISPATCH_QUEUE_SERIAL);
    
    self.downloadSemaphoreLock = dispatch_semaphore_create(6);
    self.downloadRequestQueue = dispatch_queue_create("ES_Smart_Photo_Download_Queue", DISPATCH_QUEUE_SERIAL);

    [self.picRequestQueue cancelAllOperations];
    self.picRequestQueue = [[NSOperationQueue alloc] init];
    self.picRequestQueue.maxConcurrentOperationCount = 6;
    [self.dateTransferManager transferByDateString:@""];
    [self resetFirstLoaded];

    [ESSmarPhotoCacheManager clearCache];
    [ESPhotoUploadManager startService];
    
    self.isAsyning = NO;
    [self tryAsyncData];
}



- (void)tryAsyncData {
    weakfy(self)
    dispatch_async(self.requestHandleQueue, ^{
        strongfy(self)
        if (self.isAsyning) {
            ESDLog(@"tryAsyncData isAsyning");
            return;
        }
        self.isAsyning = YES;
        [self loadAlbumsInfo];

        if ([self isFirstLoaded]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.isDataUpdated) {
                    self.isDataUpdated = YES;
                    [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeIncrement asyncFinish:NO hasNewContent:YES];
                }
            });
            //拉取增加更新
            self.incrementModifyTimelineList = [NSMutableArray array];
            self.incrementModifyTimelineFrameList = [NSMutableArray array];

            [self ayncWithTimeLinesIncrementData:3];
            return;
        }
        
        //firstLoad
        [self firstLoadWithTimeLines];
    });
}

- (void)loadAlbumsInfo {
    __block NSMutableArray *albumList = [NSMutableArray array];
    [ESPicAsyncModule getAllAlbumsWithCompletion:^(NSArray<ESAlbumItemModel *> * _Nonnull albums, NSError * _Nonnull error) {
        [albums enumerateObjectsUsingBlock:^(ESAlbumItemModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([item isKindOfClass:[ESAlbumItemModel class]]) {
                ESAlbumModel *albumItem = [ESAlbumModel new];
                albumItem.albumId = item.albumId;
                albumItem.albumName = item.albumName;
                albumItem.picCount = item.count;
                albumItem.type = item.type;
                albumItem.coverUrl = item.cover;
                albumItem.modifyAt = item.modifyAt;
                albumItem.createdAt = item.createdAt;
                albumItem.collection = item.collection;
                [albumList addObject:albumItem];
            }
        }];
        if (albumList.count > 0) {
            [[ESSmartPhotoDataBaseManager shared] insertOrUpdateAlbumsToDB:albumList];
        }
    }];
}

- (void)loadAlbumsInfo:(dispatch_block_t)block {
    __block NSMutableArray *albumList = [NSMutableArray array];
    [ESPicAsyncModule getAllAlbumsWithCompletion:^(NSArray<ESAlbumItemModel *> * _Nonnull albums, NSError * _Nonnull error) {
        if (error != nil) {
            return;
        }
        [albums enumerateObjectsUsingBlock:^(ESAlbumItemModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([item isKindOfClass:[ESAlbumItemModel class]]) {
                ESAlbumModel *albumItem = [ESAlbumModel new];
                albumItem.albumId = item.albumId;
                albumItem.albumName = item.albumName;
                albumItem.picCount = item.count;
                albumItem.type = item.type;
                albumItem.coverUrl = item.cover;
                albumItem.modifyAt = item.modifyAt;
                albumItem.createdAt = item.createdAt;
                albumItem.collection = item.collection;
                [albumList addObject:albumItem];
            }
        }];
        [[ESSmartPhotoDataBaseManager shared] deletAlbumDBData];
        if (albumList.count > 0) {
            [[ESSmartPhotoDataBaseManager shared] insertOrUpdateAlbumsToDB:albumList];
        }
        if (block) {
            block();
        }
    }];
}

- (void)ayncWithTimeLinesIncrementData:(NSInteger)retryCount {
    weakfy(self)
    [ESPicAsyncModule  getTimeLinesIncrementDataWithLastOpertaeId:self.lastOperateId
                                                       completion:^(NSArray<ESTimelinesItemModel *> * _Nonnull timelineItems,
                                                                    NSUInteger lastOperateId,
                                                                    BOOL needSyncRemain,
                                                                    NSError * _Nonnull error) {
        strongfy(self)
        ESDLog(@"ayncWithTimeLinesIncrementData %lu -- lastOpertateId: %lu needSyncRemain：%d -- %@", timelineItems.count, self.lastOperateId, needSyncRemain, error);
        dispatch_async(self.requestHandleQueue, ^{
            if (error) {
                if (retryCount > 0) {
                    [self ayncWithTimeLinesIncrementData:retryCount - 1];
                } else {
                    self.isAsyning = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeIncrement asyncFinish:YES hasNewContent:NO];
                    });
                }
                return;
            }
            
            if (timelineItems.count == 0) {
                self.isAsyning = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeIncrement asyncFinish:YES hasNewContent:NO];
                });
                return;
            }
            if (timelineItems.count > 0) {
                [timelineItems enumerateObjectsUsingBlock:^(ESTimelinesItemModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.incrementModifyTimelineList addObject:item.date];
                }];
                
                NSInteger rangeCount = 8;
                NSMutableArray *timelinesItemArrayList = [NSMutableArray array];
                __block NSMutableArray *timelinesItemArray = [NSMutableArray array];
                
                [timelineItems enumerateObjectsUsingBlock:^(ESTimelinesItemModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (timelinesItemArray.count >= rangeCount) {
                        [timelinesItemArrayList addObject:timelinesItemArray];
                        timelinesItemArray = [NSMutableArray array];
                        [timelinesItemArray addObject:item];
                    } else {
                        [timelinesItemArray addObject:item];
                    }
                    
                    if (idx == (timelineItems.count - 1) ) {
                        if (timelinesItemArray.count > 0) {
                            [timelinesItemArrayList addObject:timelinesItemArray];
                        }
                    }
                }];
                
                weakfy(self)
                dispatch_async(self.downloadRequestQueue, ^{
                    [timelinesItemArrayList enumerateObjectsUsingBlock:^(NSArray<ESTimelinesItemModel *> * _Nonnull timelinesItemArray, NSUInteger idx, BOOL * _Nonnull stop) {
                        strongfy(self)
                        dispatch_semaphore_wait(self.downloadSemaphoreLock, DISPATCH_TIME_FOREVER);
                        [self tryDownloadIncrementCoverWithDate:timelinesItemArray[0].date timelineItems:timelinesItemArray];
                    }];
                });
                
                [self write2DB:timelineItems];
                [self cacheLastOperateId:lastOperateId];
                [self updateTimeLineByIncrementData];
                
                if (needSyncRemain) {
                    [self ayncWithTimeLinesIncrementData:3];
                }
            }
        });
    }];
}

- (void)updateTimeLineByIncrementData {
    [self.incrementModifyTimelineList enumerateObjectsUsingBlock:^(NSString *date, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *picDate = [self.dateTransferManager transferByDateString:date];
        NSDateComponents *dateComponents = [self.dateTransferManager getComponentsWithDate:picDate];
        
        ESTimelineFrameItem *dayFrameItem = [ESTimelineFrameItem new];
        dayFrameItem.localID = dateComponents.year * 10000 + dateComponents.month * 100 + dateComponents.day;
        dayFrameItem.timelineType = ESTimelineFrameItemTypeDay;
        dayFrameItem.year = dateComponents.year;
        dayFrameItem.month = dateComponents.month;
        dayFrameItem.day = dateComponents.day;
        
        NSArray *weekDays = [NSArray arrayWithObjects: @"", @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];

        NSString *weekDay =  [weekDays objectAtIndex:dateComponents.weekday];
        dayFrameItem.dateWithType = [NSString stringWithFormat:@"%lu年%lu月%lu日 %@", dateComponents.year, dateComponents.month, dateComponents.day, weekDay];
        dayFrameItem.count = [[ESSmartPhotoDataBaseManager shared] getPicCountFromDBWithDayDate:date];
        [self.incrementModifyTimelineFrameList addObject:dayFrameItem];
    }];
    
    [[ESSmartPhotoDataBaseManager shared] insertOrUpdatTimeLineToDB:self.incrementModifyTimelineFrameList];
    NSArray<ESTimelineFrameItem *> *timelineFrameList = [[ESSmartPhotoDataBaseManager shared] getTimeLinesFromDBType:ESTimelineFrameItemTypeDay];
    
    [self incrementMapTimeLinesFrame:timelineFrameList];
    
    self.isAsyning = NO;
    ESDLog(@"ayncWithTimeLinesIncrementData updateBlock");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeIncrement asyncFinish:YES hasNewContent:YES];
    });
}

- (void)tryDownloadIncrementCoverWithDate:(NSString *)dateDay
                   timelineItems:(NSArray<ESTimelinesItemModel *> * _Nonnull)timelineItems {
    NSMutableDictionary<NSString *, ESPicModel*> *picMap = [NSMutableDictionary dictionary];
    [timelineItems enumerateObjectsUsingBlock:^(ESTimelinesItemModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item.uuids enumerateObjectsUsingBlock:^(ESUUIDItemModel * _Nonnull uuidItem, NSUInteger idx, BOOL * _Nonnull stop) {
            ESPicModel *pic = [ESPicModel instanceWithUUIDItem:uuidItem];
            pic.date = item.date;
            
            NSDate *picDate = [self.dateTransferManager transferByDateString:item.date];
            NSDateComponents *dateComponents = [self.dateTransferManager getComponentsWithDate:picDate];
            pic.date_year = dateComponents.year;
            pic.date_month = dateComponents.month;
            pic.date_day = dateComponents.day;
            pic.like = uuidItem.like;
            
            picMap[ESSafeString(pic.uuid)] = pic;
        }];
    }];
    NSString *picZipCachePath = [ESSmarPhotoCacheManager cacheZipPathWithDate:dateDay];
    ESDLog(@"tryDownloadCoverWithDate day: %@  countL %lu pic :%@", dateDay, picMap.allKeys.count, picMap.allKeys);
    weakfy(self)
    [ESNetworkRequestManager sendCallDownloadRequest:@{ @"serviceName" : @"eulixspace-file-service",
                                                          @"apiName" : @"album_thumbs", }
                                            queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId])
                                                         }
                                              header:@{}
                                                body:@{ @"uuids" : picMap.allKeys }
                                          targetPath:picZipCachePath
                                              status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                               }
                                        successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {
        strongfy(self)
        dispatch_semaphore_signal(self.downloadSemaphoreLock);
        dispatch_async(self.requestHandleQueue,  ^{
            [ESSmarPhotoCacheManager unZipCachePath:picZipCachePath picList:picMap.allValues];
        });
        
        ESDLog(@"tryDownloadCoverWithDate day: %@ success", dateDay);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        strongfy(self)
            dispatch_semaphore_signal(self.downloadSemaphoreLock);
    }];
}

- (void)firstLoadWithTimeLines {
    weakfy(self)
    [ESPicAsyncModule getTimeLinesFrameWithCompletion:^(NSArray<ESTimelineFrameModel *> * _Nonnull frames,
                                                        NSUInteger lastOperateId,
                                                        NSError * _Nonnull error) {
        ESDLog(@"[ESSmartPhotoAsyncManager] firstLoadWithTimeLines  frames.count:%lu  lastOperateId: %lu -- error: %@", frames.count, (unsigned long)lastOperateId, error);
        strongfy(self)
        dispatch_async(self.requestHandleQueue, ^{
            if (frames.count > 0) {
                //拉取完时间抽后， 先加载mock数据
                [self asynWithTimelines:frames];
                [self cacheLastOperateId:lastOperateId];
                [self mapTimeLinesFrame:frames];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeFirstLoad asyncFinish:NO hasNewContent:YES];
                });
           
                return;
            }
            // error 或者没有数据
            self.isAsyning = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeFirstLoad asyncFinish:YES hasNewContent:YES];
            });
        });
    }];
}

- (void)mapTimeLinesFrame:(NSArray<ESTimelineFrameModel *> *)frames {
    NSMutableArray *dayList = [NSMutableArray array];
    NSMutableArray *monthList = [NSMutableArray array];
    NSMutableArray *yearList = [NSMutableArray array];

    __block NSInteger date_year = 0;
    __block NSInteger date_month = 0;
    __block NSInteger date_day = 0;

    [frames enumerateObjectsUsingBlock:^(ESTimelineFrameModel * _Nonnull frame, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *picDate = [self.dateTransferManager transferByDateString:frame.date];
        NSDateComponents *dateComponents = [self.dateTransferManager getComponentsWithDate:picDate];
        
        ESTimelineFrameItem *dayFrameItem = [ESTimelineFrameItem new];
        dayFrameItem.localID = dateComponents.year * 10000 + dateComponents.month * 100 + dateComponents.day;
        dayFrameItem.timelineType = ESTimelineFrameItemTypeDay;
        dayFrameItem.year = dateComponents.year;
        dayFrameItem.month = dateComponents.month;
        dayFrameItem.day = dateComponents.day;

        NSArray *weekDays = [NSArray arrayWithObjects: @"", @"星期日",  @"星期一",  @"星期二",  @"星期三", @"星期四", @"星期五", @"星期六", nil];
        NSString *weekDay =  [weekDays objectAtIndex:dateComponents.weekday];
        dayFrameItem.dateWithType = [NSString stringWithFormat:@"%lu年%lu月%lu日 %@", dateComponents.year, dateComponents.month, dateComponents.day, weekDay];
        dayFrameItem.count = frame.count;
        [dayList addObject:dayFrameItem];

            if (date_year == dateComponents.year  && date_month == dateComponents.month) {
                ESTimelineFrameItem *frameItem = [monthList lastObject];
                frameItem.count += frame.count;
            } else {
                ESTimelineFrameItem *frameItem = [ESTimelineFrameItem new];
                frameItem.timelineType = ESTimelineFrameItemTypeMonth;
                frameItem.year = dateComponents.year;
                frameItem.month = dateComponents.month;
                frameItem.dateWithType = [NSString stringWithFormat:@"%lu年%lu月", dateComponents.year, dateComponents.month];
                frameItem.count = frame.count;
                frameItem.localID = dateComponents.year * 10000 + dateComponents.month * 100;
                [monthList addObject:frameItem];
            }
            
            if (date_year == dateComponents.year) {
                ESTimelineFrameItem *yearFrameItem = [yearList lastObject];
                yearFrameItem.count += frame.count;
            } else {
                ESTimelineFrameItem *yearFrameItem = [ESTimelineFrameItem new];
                yearFrameItem.timelineType = ESTimelineFrameItemTypeYear;
                yearFrameItem.year = dateComponents.year;
                yearFrameItem.dateWithType = [NSString stringWithFormat:@"%lu年", dateComponents.year];
                yearFrameItem.count = frame.count;
                yearFrameItem.localID = dateComponents.year * 10000;
                [yearList addObject:yearFrameItem];
            }
       
        date_year = dateComponents.year;
        date_month = dateComponents.month;
        date_day = dateComponents.day;
    }];
    
    [[ESSmartPhotoDataBaseManager shared] insertOrUpdatTimeLineToDB:dayList];
    [[ESSmartPhotoDataBaseManager shared] insertOrUpdatTimeLineToDB:monthList];
    [[ESSmartPhotoDataBaseManager shared] insertOrUpdatTimeLineToDB:yearList];
}

- (void)incrementMapTimeLinesFrame:(NSArray<ESTimelineFrameItem *> *)frames {
    NSMutableArray *monthList = [NSMutableArray array];
    NSMutableArray *yearList = [NSMutableArray array];

    __block NSInteger date_year = 0;
    __block NSInteger date_month = 0;

    [frames enumerateObjectsUsingBlock:^(ESTimelineFrameItem * _Nonnull frame, NSUInteger idx, BOOL * _Nonnull stop) {
            if (date_year == frame.year  && date_month == frame.month) {
                ESTimelineFrameItem *frameItem = [monthList lastObject];
                frameItem.count += frame.count;
            } else {
                ESTimelineFrameItem *frameItem = [ESTimelineFrameItem new];
                frameItem.timelineType = ESTimelineFrameItemTypeMonth;
                frameItem.year = frame.year;
                frameItem.month = frame.month;
                frameItem.dateWithType = [NSString stringWithFormat:@"%lu年%lu月", frame.year, frame.month];
                frameItem.count = frame.count;
                frameItem.localID = frame.year * 10000 + frame.month * 100;
                [monthList addObject:frameItem];
            }
            
            if (date_year == frame.year) {
                ESTimelineFrameItem *yearFrameItem = [yearList lastObject];
                yearFrameItem.count += frame.count;
            } else {
                ESTimelineFrameItem *yearFrameItem = [ESTimelineFrameItem new];
                yearFrameItem.timelineType = ESTimelineFrameItemTypeYear;
                yearFrameItem.year = frame.year;
                yearFrameItem.dateWithType = [NSString stringWithFormat:@"%lu年", frame.year];
                yearFrameItem.count = frame.count;
                yearFrameItem.localID = frame.year * 10000;
                [yearList addObject:yearFrameItem];
            }
       
        date_year = frame.year;
        date_month = frame.month;
    }];
    
    [[ESSmartPhotoDataBaseManager shared] insertOrUpdatTimeLineToDB:monthList];
    [[ESSmartPhotoDataBaseManager shared] insertOrUpdatTimeLineToDB:yearList];
}


//按照day timelines 全量拉取数据
- (void)asynWithTimelines:(NSArray<ESTimelineFrameModel *> *)frames {
    self.timeLinetotalCount = frames.count;
    self.timeLineSuccessCount = 0;
    self.timeLineFailCount = 0;
    
    NSInteger rangeCount = 8;
    NSMutableArray *timelinesFrameArrayList = [NSMutableArray array];
    __block NSMutableArray *timelinesFrameArray = [NSMutableArray array];
    
    [frames enumerateObjectsUsingBlock:^(ESTimelineFrameModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (timelinesFrameArray.count >= rangeCount) {
            [timelinesFrameArrayList addObject:timelinesFrameArray];
            timelinesFrameArray = [NSMutableArray array];
            [timelinesFrameArray addObject:item];
        } else {
            [timelinesFrameArray addObject:item];
        }
        
        if (idx == (frames.count - 1) ) {
            if (timelinesFrameArray.count > 0) {
                [timelinesFrameArrayList addObject:timelinesFrameArray];
            }
        }
    }];
    weakfy(self)
    dispatch_async(self.timeLimeRequestQueue, ^{
        [timelinesFrameArrayList enumerateObjectsUsingBlock:^( NSArray<ESTimelineFrameModel *> * _Nonnull frameList, NSUInteger idx, BOOL * _Nonnull stop) {
            //需控制线程数
            dispatch_semaphore_wait(self.timeLinesSemaphoreLock, DISPATCH_TIME_FOREVER);
            dispatch_async(self.requestQueue, ^{
                strongfy(self)
                [self ayncTimeLinesDataWithDay:frameList tryCount:3];
            });
        }];
    });
}

- (void)ayncTimeLinesDataWithDay:(NSArray<ESTimelineFrameModel *> *)frameList tryCount:(NSInteger)tryCount {
    weakfy(self)
    [ESPicAsyncModule getTimeLinesDataWithFromDay:[frameList lastObject].date
                                            toDay:frameList[0].date
                                    lastOperateId:self.lastOperateId
                                       completion:^(NSArray<ESTimelinesItemModel *> * _Nonnull timelineItems,
                                                    NSUInteger lastOperateId,
                                                    NSError * _Nonnull error) {
        strongfy(self)
        dispatch_semaphore_signal(self.timeLinesSemaphoreLock);
        dispatch_async(self.requestHandleQueue,  ^{
            ESDLog(@"[ESSmartPhotoAsyncManager] ayncTimeLinesDataWithDay  %lu  -- %lu -- %lu", self.timeLinetotalCount, self.timeLineSuccessCount, self.timeLineFailCount);
            ESDLog(@"[ESSmartPhotoAsyncManager] ayncTimeLinesDataWithDay Info  %@  -- %lu -- request Lastoperateid: %lu  -- return: %lu", frameList[0].date,
                                                                                           (timelineItems.count > 0) ? timelineItems[0].uuids.count : timelineItems.count,
                                                                                           self.lastOperateId,
                                                                                           lastOperateId);
            if (error) {
                if (tryCount > 0) {
                    dispatch_async(self.timeLimeRequestQueue, ^{
                            //需控制线程数
                        dispatch_semaphore_wait(self.timeLinesSemaphoreLock, DISPATCH_TIME_FOREVER);
                        dispatch_async(self.requestQueue, ^{
                            strongfy(self)
                            [self ayncTimeLinesDataWithDay:frameList tryCount: tryCount -1];
                        });
                    });
                    return;
                } else {
                    self.timeLineFailCount += frameList.count;
                }
            }
            
                self.timeLineSuccessCount += frameList.count;
                if (timelineItems.count > 0) {
                    [self write2DB:timelineItems];
                    [self tryDownloadCoverWithDate:frameList[0].date timelineItems:timelineItems];
                }
                if (self.timeLinetotalCount == self.timeLineSuccessCount) {
                    [self setFirstLoaded:YES];
                }
                
                if (self.timeLinetotalCount <= self.timeLineSuccessCount + self.timeLineFailCount) {
                    self.isAsyning = NO;
                    ESDLog(@"[ESSmartPhotoAsyncManager] ayncTimeLinesDataWithDay  %lu  -- %lu -- %lu", self.timeLinetotalCount, self.timeLineSuccessCount, self.timeLineFailCount);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ESDLog(@"[ESSmartPhotoAsyncManager] ayncTimeLinesDataWithDay  updateBlock");
                        [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeFirstLoad asyncFinish:YES hasNewContent:YES];
                    });
                }
            });
    }];
}


- (void)write2DB:(NSArray<ESTimelinesItemModel *> * _Nonnull)timelineItems {
    NSMutableArray<ESPicModel *> * picList = [NSMutableArray array];
    NSMutableArray<NSString *> *picUuidRemoveList = [NSMutableArray array];
    [timelineItems enumerateObjectsUsingBlock:^(ESTimelinesItemModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item.uuids enumerateObjectsUsingBlock:^(ESUUIDItemModel * _Nonnull uuidItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (uuidItem.album_ids.count <= 0) {
                [picUuidRemoveList addObject: ESSafeString(uuidItem.uuid)];
            } else {
                ESPicModel *pic = [ESPicModel instanceWithUUIDItem:uuidItem];
                pic.date = item.date;
                
                NSDate *picDate = [self.dateTransferManager transferByDateString:item.date];
                NSDateComponents *dateComponents = [self.dateTransferManager getComponentsWithDate:picDate];
                pic.date_year = dateComponents.year;
                pic.date_month = dateComponents.month;
                pic.date_day = dateComponents.day;
                [picList addObject:pic];
            }
        }];
    }];
    [[ESSmartPhotoDataBaseManager shared] insertOrUpdatePicsToDB:picList];
    [[ESSmartPhotoDataBaseManager shared] deletPicsDBDataWithUuids:[picUuidRemoveList copy]];

}

- (void)tryDownloadCoverWithDate:(NSString *)dateDay
                   timelineItems:(NSArray<ESTimelinesItemModel *> * _Nonnull)timelineItems {
    NSMutableDictionary<NSString *, ESPicModel*> *picMap = [NSMutableDictionary dictionary];
    [timelineItems enumerateObjectsUsingBlock:^(ESTimelinesItemModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item.uuids enumerateObjectsUsingBlock:^(ESUUIDItemModel * _Nonnull uuidItem, NSUInteger idx, BOOL * _Nonnull stop) {
            ESPicModel *pic = [ESPicModel instanceWithUUIDItem:uuidItem];
            pic.date = item.date;
            
            NSDate *picDate = [self.dateTransferManager transferByDateString:item.date];
            NSDateComponents *dateComponents = [self.dateTransferManager getComponentsWithDate:picDate];
            pic.date_year = dateComponents.year;
            pic.date_month = dateComponents.month;
            pic.date_day = dateComponents.day;
            
            picMap[ESSafeString(pic.uuid)] = pic;
        }];
    }];
    NSString *picZipCachePath = [ESSmarPhotoCacheManager cacheZipPathWithDate:dateDay];
    ESDLog(@"tryDownloadCoverWithDate day: %@  countL %lu pic :%@", dateDay, picMap.allKeys.count, picMap.allKeys);
    weakfy(self)
    dispatch_async(self.downloadRequestQueue, ^{
        dispatch_semaphore_wait(self.downloadSemaphoreLock, DISPATCH_TIME_FOREVER);
        [ESNetworkRequestManager sendCallDownloadRequest:@{ @"serviceName" : @"eulixspace-file-service",
                                                              @"apiName" : @"album_thumbs", }
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId])
                                                             }
                                                  header:@{}
                                                    body:@{ @"uuids" : picMap.allKeys }
                                              targetPath:picZipCachePath
                                                  status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                                   }
                                            successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {
            strongfy(self)
            dispatch_semaphore_signal(self.downloadSemaphoreLock);
            dispatch_async(self.requestHandleQueue,  ^{
                [ESSmarPhotoCacheManager unZipCachePath:picZipCachePath picList:picMap.allValues];
            });
            
            ESDLog(@"tryDownloadCoverWithDate day: %@ success", dateDay);
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            strongfy(self)
                dispatch_semaphore_signal(self.downloadSemaphoreLock);
        }];
    });
}

- (BOOL)isFirstLoaded {
    NSString *key = [NSString stringWithFormat:@"%@-%@",ESFirstLoadFinished, [ESAccountInfoStorage userUniqueId]];
    NSNumber *firstLoadFinished = [[ESCache defaultCache] objectForKey:key];
    return [firstLoadFinished boolValue];
}

- (void)resetFirstLoaded {
    [self setFirstLoaded:NO];
    [ESSmartPhotoDataBaseManager.shared cleanDBCacheAndReCreateDB];
}

- (void)setFirstLoaded:(BOOL)loaded {
    NSString *key = [NSString stringWithFormat:@"%@-%@",ESFirstLoadFinished, [ESAccountInfoStorage userUniqueId]];
    [[ESCache defaultCache] setObject:@(loaded) forKey:key];
}

- (NSUInteger)lastOperateId {
    NSNumber *lastOperateIdNum = [[ESCache defaultCache] objectForKey:ESLastOperateId];
    if (!lastOperateIdNum) {
        return 0;
    }
    return [lastOperateIdNum unsignedIntegerValue];
}

- (void)cacheLastOperateId:(NSUInteger)lastOperateId {
    self.lastOperateId = lastOperateId;
    [[ESCache defaultCache] setObject:@(lastOperateId) forKey:ESLastOperateId];
}

- (ESDateTransferManager *)dateTransferManager {
    if (!_dateTransferManager) {
        _dateTransferManager = [[ESDateTransferManager alloc] init];
        [_dateTransferManager setDateFormat:@"yyyy-MM-dd"];
        
        [_dateTransferManager setCalendarComponentType: NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday];
    }
    return _dateTransferManager;
}

- (void)didBecomeActive:(NSNotification *)notification {
    [self tryAsyncData];
}

- (void)notifyAsyncUpdate:(ESSmartPhotoAsyncType)type asyncFinish:(BOOL)asyncFinish hasNewContent:(BOOL)hasNewContent {
    [[self.asynObservers allObjects] enumerateObjectsUsingBlock:^(id<ESSmartPhotoAsyncUpdateProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(asyncUpdate:asyncFinish:hasNewContent:)]) {
            [obj asyncUpdate:type asyncFinish:asyncFinish hasNewContent:hasNewContent];
        }
    }];
}

- (void)addAsyncUpdateObserver:(id)observer {
    if (self.asynObservers == nil) {
        self.asynObservers = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    [self.asynObservers addObject:observer];
}

- (void)forceReloadData {
    [self notifyAsyncUpdate:ESSmartPhotoAsyncTypeIncrement asyncFinish:YES hasNewContent:YES];
}

@end
