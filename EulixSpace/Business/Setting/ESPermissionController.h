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
//  ESPermissionController.h
//  EulixSpace
//
//  Created by dazhou on 2023/5/4.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESPermissionType) {
    ESPermissionTypeBluetooth = 1,     // 蓝牙
    ESPermissionTypeAlbum,     // 相册
    ESPermissionTypeCamera,     // 相机
    ESPermissionTypeAddressBook,     // 通讯录
    ESPermissionTypeLocation,     // 定位
};

@interface ESPermissionController : YCViewController

+ (void)showPermissionView:(ESPermissionType)type;
/**
 settingBlock 参数若有值，则只调用该 block 行为
 */
+ (void)showPermissionView:(ESPermissionType)type setting:(void(^)(void))settingBlock;


@end

NS_ASSUME_NONNULL_END
