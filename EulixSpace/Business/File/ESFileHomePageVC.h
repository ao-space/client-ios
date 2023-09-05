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
//  ESFileHomePageVC.h
//  EulixSpace
//
//  Created by qu on 2021/7/19.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCommentAddViewVC.h"
#import "ESFileBottomView.h"
#import "ESFilePageContentView.h"
#import "ESFilePageTitleView.h"
#import "ESFileSortView.h"
#import "ESFileTotalVC.h"
#import <UIKit/UIKit.h>
#import <YCBase/YCViewController.h>
#import "ESFileDelectView.h"
#import "ESSearchBarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESFileHomePageVC : ESCommentAddViewVC

@property (nonatomic, strong) ESFilePageTitleView *pageTitleView;

@property (assign, nonatomic) int selectNum;

@property (nonatomic, strong) UIView *selectedTopView;

@property (nonatomic, strong) ESFileTotalVC *fileVC;

@property (nonatomic, assign) CGFloat tabBarHeight;

@property (nonatomic, strong) ESFileBottomView *bottomView;

@property (nonatomic, strong) ESFilePageContentView *pageContentView;
/// 传输列表
@property (nonatomic, strong) UIButton *transferListBtn;
///旋转按钮
@property (nonatomic, strong) UIImageView *transferRotateImage;
/// 回收站
@property (nonatomic, strong) UIButton *recycleBinBtn;

@property (nonatomic, strong) ESSearchBarView *searchBar;

@property (nonatomic, copy) NSString *category;

//@property (nonatomic, strong) UIButton *returnBtn;
//
//@property (nonatomic, strong) UILabel *fileName;

@property (nonatomic, strong) UIButton *topViewselelctBtn;

@property (nonatomic, strong) ESFileListBaseVC *categoryVC;

@property (nonatomic, strong) NSMutableArray *isSelectUUIDSArray;

@property (nonatomic, strong) NSMutableArray *selectedInfoArray;

@property (nonatomic, assign) BOOL isMoveCopy;

@property (nonatomic, strong) UILabel *numLable;

@property (nonatomic, strong) UIView *transferListNumView;

@property (nonatomic, strong) UILabel *selectLable;

@property (nonatomic, strong) ESFileSortView *sortView;

- (void)setupUI;
- (void)isSelected;
- (void)noSelected;
- (void)totalAllSlelectedAction;
- (void)loadMoreData;
- (void)startAnimation;
- (void)cancelAction;
- (void)fileListBottomHidden:(NSNotification *)notifi;
- (void)fileSortView:(ESFileSortView *_Nullable)fileSortView didSortType:(ESSortClass)type isUpSort:(BOOL)isUpSort;
- (void)copyMoveApiWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category;
- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button;
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDownBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickShareBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDelectBtn:(UIButton *)button;
//- (void)didReturnBtnClick;
@end

NS_ASSUME_NONNULL_END
