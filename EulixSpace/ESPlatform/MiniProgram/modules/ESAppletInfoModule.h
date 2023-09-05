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
//  ESMimiProgramInfoModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/5/31.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESAppletInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESMPInfoModuleGetAppletInfosCompletionBlock)(NSArray<ESAppletInfoModel *> * _Nullable infoList, NSError * _Nullable error);

@interface ESAppletInfoModule : NSObject

//二个接口的merge信息
- (void)getAppletInfoListWithCompletionBlock:(ESMPInfoModuleGetAppletInfosCompletionBlock)block;

//单appletInfo接口数据
- (void)getAppletInfoListFromNetworkWithCompletionBlock:(ESMPInfoModuleGetAppletInfosCompletionBlock)block;

@end

NS_ASSUME_NONNULL_END
