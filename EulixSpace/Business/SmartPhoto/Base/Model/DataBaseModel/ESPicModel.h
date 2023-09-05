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
//  ESPicModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ESTimelinesResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPicModel : NSObject 

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) NSInteger date_year;
@property (nonatomic, assign) NSInteger date_month;
@property (nonatomic, assign) NSInteger date_day;

@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) NSTimeInterval shootAt;
@property (nonatomic, assign) BOOL like;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *albumIds;   //存储Json数据结构 NSArray<NSString *> *albumIds
@property (nonatomic, copy, nullable) NSString *cacheUrl;
@property (nonatomic, copy, nullable) NSString *compressUrl;
@property (nonatomic, readonly, nullable) NSArray *albumIdList;

//+ (instancetype)instanceWithUUIDItem:(ESUUIDItemModel *)itemModel;
- (BOOL)isPicture;


@end

NS_ASSUME_NONNULL_END


