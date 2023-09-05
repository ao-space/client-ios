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
//  ESFileListBaseVC.h
//  EulixSpace
//
//  Created by qu on 2021/8/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESEmptyView.h"
#import "ESFileActionView.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESTotalListVC.h"
#import "MJRefresh.h"
#import "ESFileApi.h"
#import <Masonry/Masonry.h>
#import <UIKit/UIKit.h>
#import <YCBase/YCViewController.h>
#import <YYModel/YYModel.h>

@class ESFileListBaseVC;

@protocol EESFileListBaseVCDelegate <NSObject>

@optional

- (void)fileListBaseVCReloadData;

- (void)isNomoreData;

@end

@interface ESFileListBaseVC : YCViewController <ESFileViewProtocol>

@property (nonatomic, weak) id<EESFileListBaseVCDelegate> delegate;

@property (nonatomic, strong) NSMutableArray<ESFileInfoPub *> *children;

@property (nonatomic, strong) ESEmptyView *blankSpaceView;

@property (nonatomic, strong) NSMutableArray<ESFileInfoPub *> *enterFileUUIDArray;

@property (nonatomic, assign) int pageInt;

@property (nonatomic, strong) ESTotalListVC *listView;

@property (nonatomic, strong) UIViewController<ESFileViewProtocol> *current;

@property (nonatomic, assign) BOOL inSelection;

@property (nonatomic, strong) ESFileActionView *actionView;

@property (nonatomic, strong) NSString *fileUUID;

@property (nonatomic, strong) NSString *reName;

@property (nonatomic, strong) NSString *selectBtnStr;

@property (nonatomic, assign) int totalInt;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *sortType;

@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, strong) UIView * sloganView;

- (void)cancelSelected;

- (void)selectAll:(BOOL)all;

- (void)getFileRequestStart:(NSString *)fileUUID;

- (void)headerRefreshWithUUID:(NSString *)uuid;

- (void)loadDataWithUUID:(NSString *)uuid;

- (void)addRefresh;

- (ESEmptyView *)blankSpaceView;

- (ESTotalListVC *)listView;

- (void)reRefresh;
@end
