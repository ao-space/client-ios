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
//  ESTodayInHistoryDataModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/18.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTodayInHistoryDataModule.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountInfoStorage.h"


@implementation ESTodayInHistoryBannerItemModel

@end

@implementation ESTodayInHistoryResponseModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
   return @{@"banners" : @"ESTodayInHistoryBannerItemModel",
           };
}
@end

@implementation ESTodayInHistoryDataModule

+ (void)getToadyInHistouryDataWithCompletion:(ESTodayInHistoryAlbumCompletionBlock)completion {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"album_todayinhis"
                                                queryParams:@{@"userId" : ESSafeString([ESAccountInfoStorage userId]),
                                                             }
                                                     header:@{}
                                                       body:@{
                                                            }
                                                  modelName:@"ESTodayInHistoryResponseModel"
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                if (completion) {
                                                    completion((ESTodayInHistoryResponseModel *)response, nil);
                                                }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (completion) {
                                                    completion(nil, error);
                                                }
        }];
}

@end
