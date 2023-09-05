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
//  ESAppStoreModel.h
//  EulixSpace
//
//  Created by qu on 2022/11/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+YYModel.h"
typedef NS_ENUM(NSUInteger, AppState) {
    AppStateInstalling, // 下载
    AppStateUpte, // 更新
    AppStateInstalled // 下载
};
typedef NS_ENUM(NSInteger, ESAppInstallStuts) {
    ESINSTALLING = 0, // 安装中
    ESINSTALLED = 1,//  已安装
    ESUPDATING = 2,// 更新中
    ESINSTALLFAIL = 3, // 安装失败
    ESUPDATEFAIL= 4,// 更新失败
    ESUPGRADE = 5,
    ESUNINSTALL = 10,// 未安装
};


typedef NS_ENUM(NSInteger, ESAppBtnTextStuts) {
    Open = 0,// 打开
    Install = 1, // 安装
    Installing = 2,// 安装中
    Update = 3, // 更新
    Updating= 4,// 更新中
    Updated = 5,// 更新完成
};
NS_ASSUME_NONNULL_BEGIN

@interface ESAppStoreModel : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, assign) NSInteger appSize;
@property (nonatomic, copy) NSString *bundle; // 详情
@property (nonatomic, assign) NSInteger downloadCount;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *packageId;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *shortDesc; //
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *curVersion;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, assign) ESAppInstallStuts stateCode;
@property (nonatomic, copy) NSString *deployMode;
@property (nonatomic, copy) NSString *webUrl;
@property (nonatomic, copy) NSString *containerWebUrl;
@property (nonatomic, copy) NSString *installSource;

@end

NS_ASSUME_NONNULL_END
