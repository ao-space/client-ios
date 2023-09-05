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
//  ESBindResultViewController.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/14.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <YCBase/YCBase.h>
#import "ESDiskRecognitionResp.h"


typedef NS_ENUM(NSUInteger, ESBindResultType) {
    ESBindResultTypeBind,
    ESBindResultTypeUnbind,
    ///从网关解绑, 直接删除当前盒子
    ESBindResultTypeRevokeViaGateway, // 管理员解绑，貌似也没用上啊……
};

@class ESBoxBindViewModel;
@interface ESBindResultViewController : YCViewController

@property (nonatomic, assign) ESBindResultType type;

@property (nonatomic, assign) BOOL success;

@property (nonatomic, copy) NSString *prompt;

@property (nonatomic, strong) ESBoxBindViewModel *viewModel;

@property (nonatomic, strong) ESSpaceReadyCheckResultModel * spaceReadyCheckModel;

@end
