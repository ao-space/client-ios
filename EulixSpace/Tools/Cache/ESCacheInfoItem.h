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
//  ESCacheInfoItem.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ESBusinessCacheInfoType) {
    ESBusinessCacheInfoTypeUnkown,
    ESBusinessCacheInfoTypeOther,
    ESBusinessCacheInfoTypeApplet,
    ESBusinessCacheInfoTypeFile,
    ESBusinessCacheInfoTypePhoto,
    ESBusinessCacheInfoTypeSDImageCache,
};

NS_ASSUME_NONNULL_BEGIN

@interface ESCacheInfoItem : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cacheDate;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) ESBusinessCacheInfoType cacheType;

@end

NS_ASSUME_NONNULL_END
