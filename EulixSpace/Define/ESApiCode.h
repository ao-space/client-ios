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
//  ESApiCode.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESApiCode_h
#define ESApiCode_h

typedef NS_ENUM(NSUInteger, ESApiCode) {
    ESApiCodeOk = 200,
    ESApiCodeOKMax = 299,
    ESApiCodeAdminHasBeenRevoked = 462,

    ESApiCodeFileSyncFolderNotExist = 1005, //同步文件夹不存在
    ESApiCodeFileNotEnoughSpace = 1036,     //剩余空间不足
    ESApiCodeFileRangeUploaded = 1037 //分片范围已上传
};

typedef NSDictionary * (^ESBeforeParseJson)(id result);

static NSString *const ESBeforeParseJsonKey = @"before_parse_json";

#endif /* ESApiCode_h */
