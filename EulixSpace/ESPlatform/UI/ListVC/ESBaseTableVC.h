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
//  ESBaseTableVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESBaseTableListModule.h"
#import "ESBaseViewController+Status.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ESBaseTableVCProtocol <NSObject>

- (Class)listModuleClass;
- (UIEdgeInsets)listEdgeInsets;

//下拉刷新协议
@optional
- (BOOL)haveHeaderPullRefresh;
- (void)pullRefreshData;

@end


@interface ESBaseTableVC : ESBaseViewController <ESBaseTableVCProtocol>

@property (nonatomic, readonly) ESBaseTableListModule *listModule;

- (void)finishPullRefresh;

@end

NS_ASSUME_NONNULL_END
