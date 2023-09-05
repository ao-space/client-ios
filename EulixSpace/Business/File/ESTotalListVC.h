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
//  ESTotalListVC.h
//  EulixSpace
//
//  Created by qu on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESEmptyView.h"
#import "ESFileDefine.h"
#import <UIKit/UIKit.h>
#import <YCBase/YCBase.h>
@class ESFileInfoPub;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESFileListSction) {
    ESFileListSectionDefault,
};


@interface ESTotalListVC : YCTableViewController <ESFileViewProtocol>

@property (nonatomic, strong) NSArray<ESFileInfoPub *> *children;

@property (nonatomic, copy) void (^selectedFolder)(ESFileInfoPub *folder);

@property (nonatomic, copy) void (^selectFile)(ESFileInfoPub *data);

@property (nonatomic, assign) BOOL isCopyMove;

@property (nonatomic, strong) NSMutableArray<NSString *> *isSelectUUIDSArray;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, strong) ESEmptyView *emptyView;
@property (nonatomic, assign) BOOL comeFromPhotoSearchPage;

@property (nonatomic, assign) BOOL isSearch;
- (void)enterSelectionMode;

- (void)leaveSelectionMode;

- (void)selelctCellClick:(BOOL)isSelcted uuid:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
