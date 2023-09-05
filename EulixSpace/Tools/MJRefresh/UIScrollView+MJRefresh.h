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

//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  UIScrollView+MJRefresh.h
//  MJRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  给ScrollView增加下拉刷新、上拉刷新、 左滑刷新的功能

#import <UIKit/UIKit.h>
#if __has_include(<MJRefresh/MJRefreshConst.h>)
#import <MJRefresh/MJRefreshConst.h>
#else
#import "MJRefreshConst.h"
#endif

@class MJRefreshHeader, MJRefreshFooter, MJRefreshTrailer;

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (MJRefresh)
/** 下拉刷新控件 */
@property (strong, nonatomic, nullable) MJRefreshHeader *mj_header;
@property (strong, nonatomic, nullable) MJRefreshHeader *header MJRefreshDeprecated("使用mj_header");
/** 上拉刷新控件 */
@property (strong, nonatomic, nullable) MJRefreshFooter *mj_footer;
@property (strong, nonatomic, nullable) MJRefreshFooter *footer MJRefreshDeprecated("使用mj_footer");

/** 左滑刷新控件 */
@property (strong, nonatomic, nullable) MJRefreshTrailer *mj_trailer;

#pragma mark - other
- (NSInteger)mj_totalDataCount;

@end

NS_ASSUME_NONNULL_END
