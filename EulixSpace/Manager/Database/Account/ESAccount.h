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
//  ESAccount.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESAccount : NSObject

@property (nonatomic, copy) NSString *boxUUID;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, assign) BOOL autoUploadImage;

@property (nonatomic, assign) BOOL autoUploadVideo;

@property (nonatomic, assign) BOOL autoUploadBackground;

@property (nonatomic, assign) BOOL autoUploadWWAN;

@property (nonatomic, readonly) BOOL canAutoUpload; //是否能上传

//同步文件夹id
@property (nonatomic, copy) NSString *autoUploadPath;

//上次提示开启自动同步提示
@property (nonatomic, assign) NSInteger lastSyncPromptTime;

@property (nonatomic, assign) NSInteger lastSyncCompleteTime;

///今天同步文件数
@property (nonatomic, assign) NSInteger uploadCountOfToday;

/// self.autoUploadImage || self.autoUploadVideo
/// 快捷判断是否开启上传了
@property (nonatomic, readonly) BOOL autoUpload;

@property (nonatomic, readonly) BOOL shouldShowSyncPrompt;

- (void)save;

@property (nonatomic, readonly) NSString *lastSyncCompleteTimeString;

@end
