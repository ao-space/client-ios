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
//  ESBaseTableListModule.h
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESBaseTableVC;

NS_ASSUME_NONNULL_BEGIN
@class ESBaseCell;
@protocol ESBaseTableListModuleProtocol <NSObject>

@optional

- (void)beforeBindData:(id _Nullable)data cell:(ESBaseCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath;
- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESBaseTableListModule : NSObject <UITableViewDelegate, UITableViewDataSource, ESBaseTableListModuleProtocol>

@property (nonatomic, weak) UITableView *listView;
@property (nonatomic, weak) ESBaseTableVC *tableVC;
@property (nonatomic, readonly) NSArray *listData;

- (void)reloadData:(NSArray *)listData;

//over write
- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath;
- (CGFloat)defalutActionHeight;

@end

NS_ASSUME_NONNULL_END
