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
//  ESV2SettingModel.h
//  EulixSpace
//
//  Created by qu on 2023/7/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ESV2SettingCellType) {
    ESV2SettingCellTypePower = 0,
    ESV2SettingCellTypeService,
    ESV2SettingCellTypeParameter,
    ESV2SettingCellTypeSetting,
    ESV2SettingCellTypeBtn
};


@interface ESV2SettingModel : NSObject

@property(strong,nonatomic) NSString *titleStr;

@property(strong,nonatomic) NSString *valueStr;

@property(assign,nonatomic) BOOL isFirst;

@property(assign,nonatomic) BOOL isLast;

@property(assign,nonatomic) BOOL isOpen;

@property (nonatomic, assign) ESV2SettingCellType type;

@property(strong,nonatomic) NSIndexPath *indexPath;

@property(strong,nonatomic) NSString *btn1Str;

@property(strong,nonatomic) NSString *btn2Str;
@end

NS_ASSUME_NONNULL_END
