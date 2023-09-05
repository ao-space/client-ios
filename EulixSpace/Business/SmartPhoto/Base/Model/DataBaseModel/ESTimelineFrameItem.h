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
//  ESTimelineFrameItem.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, ESTimelineFrameItemType) {
    ESTimelineFrameItemTypeUnkown,
    ESTimelineFrameItemTypeDay,
    ESTimelineFrameItemTypeMonth,
    ESTimelineFrameItemTypeYear,
};
NS_ASSUME_NONNULL_BEGIN

@interface ESTimelineFrameItem : NSObject

@property (nonatomic, assign) NSInteger localID; // year * 100 * 100  + month * 100 + day
@property (nonatomic, copy) NSString *dateWithType;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) ESTimelineFrameItemType timelineType;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;

@property (nonatomic, readonly) NSString *dateWithTypeTranslate;

@end

NS_ASSUME_NONNULL_END
