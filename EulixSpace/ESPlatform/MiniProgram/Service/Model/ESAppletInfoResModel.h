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
//  ESAppletInfoResModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESAppletInfoResModel : ESObject

/* appletid [optional]
 */
@property(nonatomic) NSString* appletId;
/* 小应用版本 [optional]
 */
@property(nonatomic) NSString* appletVersion;
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
@property(nonatomic) NSNumber* state;
/* 上一次更新时间 [optional]
 */
@property(nonatomic) NSDate* updateAt;
/* 小应用描述 [optional]
 */
@property(nonatomic) NSString* updateDesc;

//是否授权可用
@property(nonatomic) BOOL memPermission;
 
@end

NS_ASSUME_NONNULL_END
