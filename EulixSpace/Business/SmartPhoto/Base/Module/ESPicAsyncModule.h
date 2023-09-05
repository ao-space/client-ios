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
//  ESPicAsyncModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTimelineFrameResponseModel.h"
#import "ESAlbumModel.h"
#import "ESTimelinesResponseModel.h"
#import "ESAlbumListResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESMPBaseModuleCompletionBlock)(BOOL success, NSError * _Nullable error);
typedef void (^ESMPBaseModuleDownloadCompletionBlock)(BOOL success, NSString * _Nullable filePath, NSError * _Nullable error);



@interface ESPicAsyncModule : NSObject

//查询时间轴
+ (void)getTimeLinesFrameWithCompletion:(void (^)(NSArray<ESTimelineFrameModel *> *frames, NSUInteger lastOperateId, NSError *error))completion;

//通过时间区间查询详情
+ (void)getTimeLinesDataWithFromDay:(NSString *)fromDay
                              toDay:(NSString *)toDay
                      lastOperateId:(NSUInteger)lastOperateId
                         completion:(void (^)(NSArray<ESTimelinesItemModel *> *timelineItems, NSUInteger lastOperateId, NSError *error))completion;
//获取增量更新数据
+ (void)getTimeLinesIncrementDataWithLastOpertaeId:(NSInteger)lastOperateId
                                        completion:(void (^)(NSArray<ESTimelinesItemModel *> *timelineItems,
                                                             NSUInteger lastOperateId,
                                                             BOOL needSyncRemain,
                                                             NSError *error))completion;

//获取所有相册的数据
+ (void)getAllAlbumsWithCompletion:(void (^)(NSArray<ESAlbumItemModel *> *albums, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
