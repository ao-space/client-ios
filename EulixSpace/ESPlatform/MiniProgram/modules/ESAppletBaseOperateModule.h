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
//  ESMimiProgramDownloadModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESAppletInfoRes.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESMPBaseModuleCompletionBlock)(BOOL success, NSError * _Nullable error);
typedef void (^ESMPBaseModuleDownloadCompletionBlock)(BOOL success, NSString * _Nullable filePath, NSError * _Nullable error);

@interface ESAppletBaseOperateModule : NSObject

- (void)installAppletWithId:(NSString *)appletId completionBlock:(ESMPBaseModuleCompletionBlock)block;

- (void)unintallAppletWithId:(NSString *)appletId completionBlock:(ESMPBaseModuleCompletionBlock)block;

- (void)updateAppletWithId:(NSString *)appletId packageId:(NSString *)packageId  completionBlock:(ESMPBaseModuleCompletionBlock)block;

- (void)downAppletWithId:(NSString *)appletId
           appletVersion:(NSString *)appletVersion
         completionBlock:(ESMPBaseModuleDownloadCompletionBlock)block;

@end

NS_ASSUME_NONNULL_END
