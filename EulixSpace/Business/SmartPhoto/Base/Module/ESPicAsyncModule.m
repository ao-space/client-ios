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
//  ESPicAsyncModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPicAsyncModule.h"
#import "ESNetworkRequestManager.h"
#import "ESAlbumListResponseModel.h"
#import "ESAccountInfoStorage.h"

@implementation ESPicAsyncModule

+ (void)getTimeLinesFrameWithCompletion:(void (^)(NSArray<ESTimelineFrameModel *> *frames, NSUInteger lastOperateId, NSError *error))completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_timelineframe"
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId]),
//                                                               @"albumId" : @(1), // 1 表示所有相册
                                                               @"model" : @"day"
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@"ESTimelineFrameResponseModel"
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                ESTimelineFrameResponseModel *model = (ESTimelineFrameResponseModel *)response;
                                                if (completion) {
                                                    completion(model.timeLineFrame, model.lastOperateId, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(nil, 0, error);
                                                }
        }];
}

+ (void)getTimeLinesDataWithFromDay:(NSString *)fromDay
                              toDay:(NSString *)toDay
                      lastOperateId:(NSUInteger)lastOperateId
                         completion:(void (^)(NSArray<ESTimelinesItemModel *> *timelineItems, NSUInteger lastOperateId, NSError *error))completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_timeline_elems"
                                                queryParams:@{
                                                                @"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                                @"lastOperateId" : @(lastOperateId),
                                                                @"fromShootDay" : ESSafeString(fromDay),
                                                                @"toShootDay" : ESSafeString(toDay)
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@"ESTimelinesResponseModel"
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                ESTimelinesResponseModel *model = (ESTimelinesResponseModel *)response;
                                                if (completion) {
                                                    completion(model.uuidsUnderDate, model.lastOperateId, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(nil, 0, error);
                                                }
        }];
}


+ (void)getTimeLinesIncrementDataWithLastOpertaeId:(NSInteger)lastOperateId
                                        completion:(void (^)(NSArray<ESTimelinesItemModel *> *timelineItems,
                                                             NSUInteger lastOperateId,
                                                             BOOL needSyncRemain,
                                                             NSError *error))completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_timeline_increment"
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                               @"lastOperateId" : @(lastOperateId)
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@"ESTimelinesResponseModel"
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                ESTimelinesResponseModel *model = (ESTimelinesResponseModel *)response;
                                                if (completion) {
                                                    completion(model.uuidsUnderDate, model.lastOperateId, model.needSyncRemain, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(nil, 0, NO, error);
                                                }
        }];
}


+ (void)getAllAlbumsWithCompletion:(void (^)(NSArray<ESAlbumItemModel *> *albums, NSError *error))completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_info"
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId])}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@"ESAlbumListResponseModel"
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                ESAlbumListResponseModel *model = (ESAlbumListResponseModel *)response;
                                                if (completion) {
                                                    completion(model.albumList, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(nil, error);
                                                }
        }];
}


+ (void)getThumbsWithUuidList:(NSArray <NSString *> *)uuidList
                   completion:(void (^)(NSArray<ESAlbumItemModel *> *albums, NSError *error))completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_info"
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId])}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@"ESAlbumListResponseModel"
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                ESAlbumListResponseModel *model = (ESAlbumListResponseModel *)response;
                                                if (completion) {
                                                    completion(model.albumList, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(nil, error);
                                                }
        }];
}
@end
