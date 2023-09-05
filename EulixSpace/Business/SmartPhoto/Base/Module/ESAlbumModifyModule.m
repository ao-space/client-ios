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
//  ESAlbumModifyModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumModifyModule.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountInfoStorage.h"
#import "ESSmartPhotoAsyncManager.h"

@implementation ESAlbumModifyModule

+ (void)modifyAlbumName:(NSString *)name
                albumId:(NSInteger)albumId
             completion:(ESAlbumModifyModuleCompletionBlock)completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_modify"
                                                queryParams:@{@"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                            }
                                                     header:@{}
                                                       body:@{
                                                                @"albumId" : @(albumId),
                                                                @"newAlbumName" : ESSafeString(name),
                                                            }
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeReName, YES, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeReName, NO, error);
                                                }
        }];
}

// YES  收藏、 NO 未收藏
+ (void)collectionAlbum:(BOOL)collection
                albumId:(NSInteger)albumId
             completion:(ESAlbumModifyModuleCompletionBlock)completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_modify"
                                                queryParams:@{@"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                            }
                                                     header:@{}
                                                       body:@{
                                                                @"albumId" : @(albumId),
                                                                @"collection" : @(collection),
                                                            }
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeCollection, YES, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeCollection, NO, error);
                                                }
        }];
}


// YES  喜欢、 NO 不喜欢
+ (void)likeAlbumPic:(BOOL)like
                picUUids:(NSArray *)uuids
             completion:(ESAlbumModifyModuleCompletionBlock)completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_likephoto"
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                            }
                                                     header:@{}
                                                       body:@{@"uuids" : ESSafeString(uuids),
                                                              @"like" : @(like),
                                                            }
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeDPhotoLike, YES, nil);
                                                  }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeDPhotoLike, NO, error);
                                                }
        }];
}

+ (void)createAlbumName:(NSString *)name completion:(ESAlbumCreateCompletionBlock)completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_create"
                                                queryParams:@{@"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                            }
                                                     header:@{}
                                                       body:@{@"albumName" : ESSafeString(name)
                                                             }
                                                  modelName:@"ESCreateAlbumResponseModel"
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                ESCreateAlbumResponseModel *model = (ESCreateAlbumResponseModel *)response;
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeCreate, model, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeCreate, nil, error);
                                                }
        }];
}

+ (void)deleteAlbumIds:(NSArray<NSNumber *> *)albumIds completion:(ESAlbumModifyModuleCompletionBlock)completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_delete"
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                            }
                                                     header:@{}
                                                       body:@{@"albumIds" : albumIds.count > 0 ? albumIds : @""}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                    if (completion) {
                                                        completion(ESAlbumModifyTypeDelete, YES, nil);
                                                    }
                                                    [ESSmartPhotoAsyncManager.shared forceReloadData];
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeDelete, NO, error);
                                                }
        }];
}

+ (void)addPhtotos:(NSArray<NSString *> *)uuids
           albumId:(NSInteger)albumId
        completion:(ESAlbumModifyModuleCompletionBlock)completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_addphoto"
                                                queryParams:@{ @"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                            }
                                                     header:@{}
                                                       body:@{@"albumId" : @(albumId),
                                                              @"uuids" : (uuids.count > 0 ? uuids : @"")
                                                            }
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeAddPhoto, YES, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(ESAlbumModifyTypeAddPhoto, NO, error);
                                                }
        }];
}

+ (void)deletePhoto:(NSArray<NSString *> *)uuids
          fromAlbumId:(NSInteger)albumId
         deleteType:(NSInteger)type
         completion:(ESAlbumModifyModuleCompletionBlock)completion {
//    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
//                                                    apiName:@"album_deletephoto"
//                                                queryParams:@{@"userId" : ESSafeString([ESAccountInfoStorage userId]),
//                                                            }
//                                                     header:@{}
//                                                       body:@{@"albumId" : @(albumId),
//                                                              @"uuids" : (uuids.count > 0 ? uuids : @""),
//                                                              @"deleteType" : @(type)
//                                                            }
//                                                  modelName:nil
//                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
//        if (completion) {
//            completion(ESAlbumModifyTypeDeletePhoto, YES, nil);
//        }
//    }
//                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (completion) {
//            completion(ESAlbumModifyTypeDeletePhoto, NO, error);
//        }
//    }];
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"delete_file"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{@"uuids" : uuids ?: @""}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        if (completion) {
            completion(ESAlbumModifyTypeDeletePhoto, YES, nil);
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(ESAlbumModifyTypeDeletePhoto, NO, error);
        }
    }];
}

@end
