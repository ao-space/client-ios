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
//  MJRefreshNormalTrailer.h
//  MJRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#if __has_include(<MJRefresh/MJRefreshStateTrailer.h>)
#import <MJRefresh/MJRefreshStateTrailer.h>
#else
#import "MJRefreshStateTrailer.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MJRefreshNormalTrailer : MJRefreshStateTrailer

@property (weak, nonatomic, readonly) UIImageView *arrowView;

@end

NS_ASSUME_NONNULL_END
