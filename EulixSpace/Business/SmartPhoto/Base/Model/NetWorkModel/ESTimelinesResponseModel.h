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
//  ESTimelinesResponseModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESUUIDItemModel : NSObject

@property (nonatomic, copy) NSArray<NSNumber *> *album_ids;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, assign) BOOL like;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSTimeInterval shootAt;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *path;

@end


@interface ESTimelinesItemModel : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSArray<ESUUIDItemModel *> *uuids;

@end


@interface ESTimelinesResponseModel : NSObject

@property (nonatomic, assign) NSInteger lastOperateId;
@property (nonatomic, assign) BOOL needSyncRemain;

@property (nonatomic, copy) NSArray<ESTimelinesItemModel *> *uuidsUnderDate;

@end

NS_ASSUME_NONNULL_END
