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
//  ESAppV2SettingCell.h
//  EulixSpace
//
//  Created by qu on 2023/7/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESV2SettingModel.h"
#import "ESContainerInfo.h"
#import "ESContaineStatsInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESAppV2SettingCell : UITableViewCell

@property (nonatomic, strong) ESV2SettingModel *item;

@property (nonatomic, strong) ESContainerInfo *containerInfo;

@property (nonatomic, strong) ESContaineStatsInfo *statsInfo;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIView *separatorView;

@property (nonatomic, strong) UILabel *titleLabel;


@property (nonatomic, copy) void (^actionSwitchBlock)(id action);

@property (nonatomic, copy) void (^actionStoptBtnBlock)(id action);

@property (nonatomic, copy) void (^actionReSetBlock)(id action);

@property (nonatomic, copy) void (^actionStartBlock)(id action);

@end

NS_ASSUME_NONNULL_END
