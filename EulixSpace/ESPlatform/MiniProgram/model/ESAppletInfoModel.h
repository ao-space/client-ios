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
//  ESAppletInfoModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESAppletOperateType) {
    ESAppletOperateTypeTypeUnkown,
    ESAppletOperateTypeInstall,
    ESAppletOperateTypeDown,
    ESAppletOperateTypeUpdate,
    ESAppletOperateTypeUninstall,
    ESAppletOperateTypeClose,
    ESAppletOperateTypeSetting
};

@interface ESAppletContext : NSObject

@property (nonatomic) BOOL shownedUpdateDialog;

@property (nonatomic, assign) BOOL shownedNewAction;

@property(nonatomic) BOOL isInstalled;

@end

@interface ESAppletInfoModel : NSObject

/* appletid [optional]
 */
@property(nonatomic) NSString* appletId;
/* 小应用版本 [optional]
 */
@property(nonatomic) NSString* appletVersion;

@property(nonatomic) NSString* installedAppletVersion;

@property(nonatomic) BOOL hasNewVersion;

/* iconurl [optional]
 */
@property(nonatomic) NSString* iconUrl;
/* 是否强制更新 [optional]
 */
@property(nonatomic) BOOL isForceUpdate;
/* md5 [optional]
 */
@property(nonatomic) NSString* md5;
/* 小应用名字 [optional]
 */
@property(nonatomic) NSString* name;
/* 小应用英文名字 [optional]
 */
@property(nonatomic) NSString* nameEn;
/* 小应用发布状态：0-支持安装;1-敬请期待 [optional]
 */
@property(nonatomic) BOOL installable;
/* 上一次更新时间 [optional]
 */
@property(nonatomic) NSDate* updateAt;
/* 小应用描述 [optional]
 */
@property(nonatomic) NSString* updateDesc;

@property(nonatomic) BOOL downloaded;

@property (nonatomic) NSString *localCacheUrl;

@property (nonatomic) NSString *originUrl;

@property (nonatomic) NSString *packageId;

@property (nonatomic) NSString *type;

@property (nonatomic) NSString *delDec;

@property (nonatomic) ESAppletContext *context;

@property(nonatomic) BOOL memPermission;

@property(nonatomic) NSString* source;

@property(nonatomic) NSString* deployMode;

@property(nonatomic) BOOL isUnInstalled;

@property(nonatomic) NSString* installSource;

@end

NS_ASSUME_NONNULL_END
