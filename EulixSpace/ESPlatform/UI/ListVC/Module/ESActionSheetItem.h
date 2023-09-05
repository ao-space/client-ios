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
//  ESActionSheetItem.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESActionSheetCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESActionSheetItem : NSObject <ESActionSheetCellModelProtocol>

@property (nonatomic, strong) NSString *iconName; //normal图标
@property (nonatomic, strong) NSString *unSelecteableIconName; //不可选择状态图标
@property (nonatomic, strong) NSString *selectedIconName; //已选择状态图标

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSelected; // YES 已选择 NO 未选择
@property (nonatomic, assign) NSInteger sortIndex;
@property (nonatomic, assign) BOOL isSelectedTyple; // 是否展示已选择状态

@property (nonatomic, assign) BOOL canSelectedType; // 是否可选择操作 NO不能选择
@property (nonatomic, assign) BOOL nextStep; // 是否有第二次弹框

@property (nonatomic, assign) BOOL isSectionHeader; // 是否SectionHeder

@end

NS_ASSUME_NONNULL_END
