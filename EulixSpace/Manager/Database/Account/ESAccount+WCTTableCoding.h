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
//  ESAccount+WCTTableCoding.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAccount.h"
#import <WCDB/WCDB.h>

@interface ESAccount (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(boxUUID)
WCDB_PROPERTY(userId)

WCDB_PROPERTY(autoUploadImage)
WCDB_PROPERTY(autoUploadVideo)
WCDB_PROPERTY(autoUploadBackground)
WCDB_PROPERTY(autoUploadWWAn)

WCDB_PROPERTY(autoUploadPath)
WCDB_PROPERTY(lastSyncPromptTime)
WCDB_PROPERTY(lastSyncCompleteTime)
WCDB_PROPERTY(uploadCountOfToday)

@end
