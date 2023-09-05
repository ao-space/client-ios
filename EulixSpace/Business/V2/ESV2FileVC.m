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
//  ESV2FileVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESV2FileVC.h"
#import "ESFolderList.h"
#import "ESFolderTableList.h"
#import "ESV2FileListVC.h"
#import "ESRecyclePopUpView.h"
#import "ESRecycledApi.h"
#import "UIButton+Extension.h"
#import "ESFileInfoPub.h"
#import "ESCommonToolManager.h"
#import "ESV2FileVC.h"
#import "ESFileBottomBtnView.h"
#import "UIView+Status.h"
#import "ESCommonProcessStatusVC.h"
#import "ESNetworkRequestManager.h"


@interface ESV2FileVC ()<ESFileDelectViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) ESV2FileListVC *recycleList;

@property (nonatomic, strong) ESRecyclePopUpView *popView;

@property (nonatomic, strong) UIView *bottomToolView;

@property (nonatomic, strong) UIButton *recycleBtn;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) ESFileBottomBtnView *downBtn;

@end

@implementation ESV2FileVC

- (void)loadView {
    [super loadView];
    self.category = @"v2FileVC";
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.bottomView.hidden = YES;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileListFolderBottomHidden:) name:@"fileListFolderBottomHidden" object:nil];
    self.fileTitleLabel.hidden = NO;
    self.fileReturnBtn.hidden = NO;
    self.fileTitleLabel.text = self.name;
    self.transferListBtn.hidden = YES;
    self.recycleBinBtn.hidden = YES;
    self.popView.hidden = YES;
    self.recycleList.view.hidden = NO;
    self.bottomToolView = [self createBottomToolView];
    self.bottomToolView.hidden = YES;
    
    [self.bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0.0);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.height.mas_equalTo(50.0f + kBottomHeight);
    }];

    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.fileReturnBtn.mas_top);
        make.right.mas_equalTo(self.view.mas_right).offset(-25);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(longTagSelected:) name:@"longTagSelected" object:nil];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    // 创建手势识别器
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGesture.delegate = self;

    [self.recycleList.view addGestureRecognizer:swipeGesture];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        // 执行左滑操作
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
- (void)cancelAction {
    self.fileTitleLabel.hidden = NO;
    self.fileReturnBtn.hidden = NO;
    self.selectedTopView.hidden = YES;
    self.recycleBtn.hidden = NO;
    [self.recycleList cancelSelected];
}

- (ESV2FileListVC *)recycleList {
    if (!_recycleList) {
        _recycleList = [[ESV2FileListVC alloc] init];
        _recycleList.recordid = self.recordid;
        [self.view addSubview:_recycleList.view];
        [self addChildViewController:_recycleList];
        [self.recycleList.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.view.mas_top).offset(102);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(-50-kBottomHeight);
        }];
        [self.recycleList.listView.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(_recycleList.view.mas_top).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(-50-kBottomHeight);
        }];
        
    }
    return _recycleList;
}

- (ESRecyclePopUpView *)popView {
    if (!_popView) {
        _popView = [[ESRecyclePopUpView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _popView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _popView.delegate = self;
        _popView.tag = 100104;
        //[self.view.window addSubview:_popView];
        [[UIApplication sharedApplication].keyWindow addSubview:_popView];
          UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
          [_popView addGestureRecognizer:delectActionTapGesture];
        _popView.userInteractionEnabled = YES;
    }
    return _popView;
}


// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)delectTapGestureAction:(UITapGestureRecognizer *)tap {
    self.popView.hidden = YES;
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCancelBtn:(UIButton *_Nullable)button{
    self.popView.hidden = YES;
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button{
    NSMutableArray *uuids = [[NSMutableArray alloc] init];
    if (self.selectedInfoArray.count > 0) {
        for (ESFileInfoPub *info in self.selectedInfoArray) {
            [uuids addObject:info.uuid];
        }
    }

    [self.view showLoading:YES message:NSLocalizedString(@"delete_loading_message", @"正在删除")];
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"delete_file"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{@"uuids" : uuids ?: @""}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self.view showLoading:NO];
        [self deleteSuccess];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        strongfy(self)
        [self.view showLoading:NO];
        //show 异步删除进度条
        if ([error.userInfo[@"code"] intValue] == 201) {
            NSDictionary *results = error.userInfo[ESNetworkErrorUserInfoResposeResultKey];
            if ([results[@"results"] isKindOfClass:[NSDictionary class]] && results[@"results"][@"taskId"] != nil) {
                NSString *taskId = results[@"results"][@"taskId"];
                ESCommonProcessStatusVC *processVC = [[ESCommonProcessStatusVC alloc] init];
                processVC.taskId = taskId;
                processVC.customProcessTitle = NSLocalizedString(@"delete_loading_message", @"正在删除");
                weakfy(processVC)
                processVC.processUpdateBlock = ^(BOOL success, BOOL isFinished, CGFloat process) {
                    strongfy(processVC)
                    if (isFinished) {
                        [processVC hidden:YES];
                        if (success) {
                            [self deleteSuccess];
                        } else {
                            [self deleteFail];
                        }
                    }
                };
                [processVC showFrom:self];

            }
            return;
        }
        [self deleteFail];
    }];
}

- (void)deleteSuccess {
   [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
    self.popView.hidden = YES;
    [self.recycleList getFileRequestStart];
}

- (void)deleteFail {
    self.popView.hidden = YES;
    [ESToast toastError:NSLocalizedString(@"Delete Fail", @"删除失败")];
}

/// 是否有文件被选中
- (void)fileListFolderBottomHidden:(NSNotification *)notifi {
    
    NSDictionary *dic = notifi.object;
    self.isSelectUUIDSArray = dic[@"isSelectUUIDSArray"];
    self.selectedInfoArray = dic[@"selectedInfoArray"];
    self.selectLable.text = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), (unsigned long)self.isSelectUUIDSArray.count];
    if (self.selectedInfoArray.count > 0) {
        self.popView.category = @"reduction";
        self.bottomToolView.hidden = NO;
        [self updataListFrameHidden:NO];
        self.fileTitleLabel.hidden = YES;
        self.selectBtn.hidden = YES;
        self.fileReturnBtn.hidden = YES;
        [self.recycleList.listView.tableView.mj_header endRefreshing];
        [self.recycleList.listView.tableView.mj_header removeFromSuperview];
        self.tabBarController.tabBar.hidden = YES;
        self.selectedTopView.hidden = NO;
        [self.recycleBtn setHidden:YES];
        for (UIView *view in[self.view subviews]) {
            if((view.tag == 100105)){
                view.hidden = YES;
            }
        }
        //[[self.view viewWithTag:100105] removeFromSuperview];
    } else {
        self.bottomToolView.hidden = YES;
        [self.recycleList addRefresh];
        self.fileTitleLabel.hidden = NO;
        self.fileReturnBtn.hidden = NO;
        self.selectedTopView.hidden = YES;
        self.selectBtn.hidden = NO;
        self.fileReturnBtn.hidden = NO;
        [self updataListFrameHidden:YES];
        for (UIView *view in[self.view subviews]) {
            if(view.tag == 100105){
                view.hidden = YES;
            }
        }
        self.recycleBtn.hidden = NO;
        
    }
    if (self.isSelectUUIDSArray.count > 0) {
        if (self.selectedInfoArray.count == 1) {
          
        }
        if (self.isSelectUUIDSArray.count != self.recycleList.children.count) {
            [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];
        } else {
            [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全选") forState:UIControlStateNormal];

        }
    }
}

-(UIView *)createBottomToolView {
    UIView *bottom = [[UIView alloc]init];
    bottom.backgroundColor = ESColor.systemBackgroundColor;
    self.bottomToolView = bottom;
    [self.view addSubview:bottom];
    
    UIButton *reductionBtn = [[UIButton alloc] initWithFrame:CGRectMake(110, 9, 44, 44)];
    [reductionBtn setTitle:NSLocalizedString(@"file_bottom_share", @"分享") forState:UIControlStateNormal];
    [reductionBtn setImage:IMAGE_FILE_BOTTOM_SHARE forState:UIControlStateNormal];
    [reductionBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:10]];
    [reductionBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
    [reductionBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:8];
    [reductionBtn addTarget:self action:@selector(shareAct:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:reductionBtn];
    [reductionBtn mas_updateConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(bottom.mas_top).offset(9);
         make.centerX.equalTo(bottom.mas_centerX);
         make.width.mas_equalTo(44);
         make.height.mas_equalTo(44);
     }];
    
 
    [bottom addSubview:self.downBtn];

    [self.downBtn mas_updateConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(bottom.mas_top).offset(9);
         make.left.equalTo(bottom.mas_left).offset(70);
         make.width.mas_equalTo(44);
         make.height.mas_equalTo(44);
     }];
    
    UIButton *delectBtn = [[UIButton alloc] initWithFrame:CGRectMake(110 + 44 + 100, 9, 44, 44)];
    [delectBtn setImage:IMAGE_FILE_BOTTOM_DEL forState:UIControlStateNormal];
    [delectBtn setTitle:NSLocalizedString(@"delete", @"删除") forState:UIControlStateNormal];
    [delectBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
    [delectBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:2];
    [delectBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:10]];
    [delectBtn addTarget:self action:@selector(delect) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:delectBtn];
    
    [delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(bottom.mas_top).offset(9);
         make.right.equalTo(bottom.mas_right).offset(-70);
         make.width.mas_equalTo(44);
         make.height.mas_equalTo(44);
     }];
    return bottom;
}

- (void)totalAllSlelectedAction {

    if ([self.topViewselelctBtn.titleLabel.text isEqual:NSLocalizedString(@"select_all", @"全选")]) {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选")  forState:UIControlStateNormal];
        [self.recycleList selectAll:YES];
    } else {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];

        [self.recycleList selectAll:NO];
        self.bottomView.hidden = YES;
    }
}

-(void)reduction{
    self.popView.category = @"reduction";
    self.popView.hidden = NO;
}


-(void)updataListFrameHidden:(BOOL)isHidden{
    NSString *deviceType = [UIDevice currentDevice].model;
    CGFloat topHight;
    if([deviceType isEqualToString:@"iPad"]){
        topHight = 64;
    }else{
        topHight = 102;
    }
    if (isHidden) {
        [self.recycleList.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.view.mas_top).offset(topHight);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
        [self.recycleList.listView.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(_recycleList.view.mas_top).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
    }else{
        [self.recycleList.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.view.mas_top).offset(topHight);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(- 50 - kBottomHeight);
        }];
        [self.recycleList.listView.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(_recycleList.view.mas_top).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(- 50 - kBottomHeight);
        }];
    }
}

- (void)noSelected {
    [self.categoryVC addRefresh];
    self.pageContentView.collectionView.scrollEnabled = YES;
    self.selectedTopView.hidden = YES;
    self.bottomView.hidden = YES;
    self.searchBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}


- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        _selectBtn.backgroundColor = ESColor.clearColor;
        [_selectBtn setImage:[UIImage imageNamed:@"xuanze"] forState:UIControlStateNormal];
        [_selectBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectBtn];
    }
    return _selectBtn;
}

-(void)selectBtnAction{
    self.selectBtn.hidden = YES;
    self.selectedTopView.hidden = NO;
    self.fileReturnBtn.hidden = YES;
    self.fileTitleLabel.hidden = YES;
}


- (ESFileBottomBtnView *)downBtn {
    if (nil == _downBtn) {
        _downBtn = [[ESFileBottomBtnView alloc] init];
        _downBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_DOWN;
        _downBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_DOWN;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickDownBtn:)];
        [_downBtn addGestureRecognizer:tapGesture];
        [self.view addSubview:_downBtn];
    }
    return _downBtn;
}


-(void)didClickDownBtn:(UIButton *)downBtn{
    self.selectBtn.hidden  = NO;
    [ESToast toastSuccess:TEXT_ADDED_TO_TRANSFER_LIST];
    ESFileBottomView *view = [ESFileBottomView new];
    [self fileBottomToolView:view didClickDownBtn:downBtn];
}

-(void)delect{
    self.popView.category = @"del";
    self.popView.hidden = NO;
}

-(void)shareAct:(UIButton *)shareBtn{
    ESFileBottomView *view = [ESFileBottomView new];
    [self fileBottomToolView:view didClickShareBtn:shareBtn];
}

-(void)longTagSelected:(NSNotification *)notifi{
    self.fileTitleLabel.hidden = YES;
    self.selectBtn.hidden = YES;
    self.fileReturnBtn.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    self.selectedTopView.hidden = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

@end

