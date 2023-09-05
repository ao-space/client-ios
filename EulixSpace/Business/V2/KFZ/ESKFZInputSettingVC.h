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
//  ESKFZInputSettingVC.h
//  EulixSpace
//
//  Created by qu on 2023/1/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <YCBase/YCBase.h>
#import "ESCellModel.h"

typedef NS_ENUM(NSUInteger, ESInputSettingVCKFZType) {
    ESInfoEditTypeKFZName,
    ESInfoEditTypeKFZSign,
    ESInfoEditTypeKFZDomin,
    ESInfoEditTypeKFZV2Domin
};

@interface ESKFZInputSettingVC : YCViewController

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *aoid;

@property (nonatomic, copy) ESCellModel *model;

@property (nonatomic, assign) ESInputSettingVCKFZType type;

@property (nonatomic, assign) BOOL isAuthority;

@property (copy, nonatomic) void (^updateName)(NSString *name);


@end
