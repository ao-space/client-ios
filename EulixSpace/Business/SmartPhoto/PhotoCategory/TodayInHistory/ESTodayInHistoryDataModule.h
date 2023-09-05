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
//  ESTodayInHistoryDataModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/11/18.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESTodayInHistoryBannerItemModel : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *year;

@end

@interface ESTodayInHistoryResponseModel : NSObject

@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, strong) NSArray<ESTodayInHistoryBannerItemModel *> *banners;

@end



typedef void (^ESTodayInHistoryAlbumCompletionBlock)(ESTodayInHistoryResponseModel * _Nullable responseModel, NSError * _Nullable error);

@interface ESTodayInHistoryDataModule : NSObject

+ (void)getToadyInHistouryDataWithCompletion:(ESTodayInHistoryAlbumCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
