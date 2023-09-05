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
//  ESGlobalDefine.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESGlobalDefine_h
#define ESGlobalDefine_h

static NSString *const kESGlobalUploadAutoUpload = @"uploadAutoUpload";

static NSString *const kESGlobalUploadAutoUploadSuccess = @"uploadAutoUploadSuccess";

//static NSString *const kESGlobalUploadAutoUploadReady = @"uploadAutoUploadReady";


///Regex

static NSString *const kESBoxUrlRegex = @"^https://ao.space/\\?btid=([0-9a-zA-Z])+$";
static NSString *const kESBoxUrlRegex1 = @"^https://ao.space/\\?sn=([0-9a-zA-Z])+$";

static NSString *const kESBoxUrlRegexLocal = @"^https://ao.space/\\?btid=([0-9a-z])+&ipaddr=([0-9%A.])+&port=([0-9])+";
static NSString *const kESBoxUrlRegexLocalSN = @"^https://ao.space/\\?sn=([0-9a-z])+&ipaddr=([0-9%A.])+&port=([0-9])+";
static NSString *const kESBoxUrlRegexLocalNew = @"^https://ao.space/\\?btid=([0-9a-z])+";
static NSString *const kESBoxUrlRegexLocalNewSN = @"^https://ao.space/\\?sn=([0-9a-z])+";


#endif /* ESGlobalDefine_h */
