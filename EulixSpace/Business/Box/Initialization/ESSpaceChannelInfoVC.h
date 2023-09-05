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
//  ESSpaceTunInfoVC.h
//  EulixSpace
//
//  Created by KongBo on 2023/6/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN
@class ESBoxBindViewModel;
@class ESBoxItem;
@interface ESSpaceChannelInfoVC : ESBaseTableVC
//绑定流程使用
@property (nonatomic, strong) ESBoxBindViewModel *viewModel;
//修改通道
@property (nonatomic, strong) ESBoxItem *boxItem;
@property (nonatomic, assign) BOOL isInternetOn;
@property (nonatomic, strong) NSString * platformUrl;
@end

NS_ASSUME_NONNULL_END
