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
//  ESRecycleBinVC.m
//  EulixSpace
//
//  Created by qu on 2022/3/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESRecycleBinVC.h"
#import "ESFolderList.h"
#import "ESFolderTableList.h"
#import "ESRecyclePopUpView.h"
#import "ESRecycledApi.h"
#import "UIButton+Extension.h"
#import "ESFileInfoPub.h"
#import "ESCommonToolManager.h"
#import "ESMJHeader.h"
#import "UIView+Status.h"
#import "ESCommonProcessStatusVC.h"
#import "ESNetworkRequestManager.h"

@interface ESRecycleBinVC ()<ESFileDelectViewDelegate>

@property (nonatomic, strong) ESRecycleBinListVC *recycleList;

@property (nonatomic, strong) ESRecyclePopUpView *popView;

@property (nonatomic, strong) UIView *bottomToolView;

@property (nonatomic, strong) UIButton *recycleBtn;
@end

@implementation ESRecycleBinVC

- (void)loadView {
    [super loadView];
    self.category = @"recycleBinVC";

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileListFolderBottomHidden:) name:@"fileListFolderBottomHidden" object:nil];
    self.fileTitleLabel.hidden = NO;
    self.fileReturnBtn.hidden = NO;
    self.fileTitleLabel.text = NSLocalizedString(@"main_recycleBinBtn", @"回收站");
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
 
    __weak typeof(self) weakSelf = self;
    self.recycleList.actionBlock = ^(id action) {
        if ([action intValue]) {
            [weakSelf.recycleList cancelSelected];
            weakSelf.recycleBtn =  [[UIButton alloc] init];
            [weakSelf.view addSubview:weakSelf.recycleBtn];
            [weakSelf.recycleBtn setImage:nil forState:UIControlStateNormal];
            [weakSelf.recycleBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:18]];
            [weakSelf.recycleBtn addTarget:weakSelf action:@selector(recycleBtn:) forControlEvents:UIControlEventTouchUpInside];
            [weakSelf.recycleBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
            [weakSelf.recycleBtn setTitle:NSLocalizedString(@"Clear", @"清空") forState:UIControlStateNormal];
            weakSelf.recycleBtn.tag = 100105;
            [weakSelf.recycleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(weakSelf.view).offset(kStatusBarHeight + 15);
                make.right.mas_equalTo(weakSelf.view.mas_right).offset(-26.0);
                make.height.mas_equalTo(25.0f);
            }];
        }else{
            weakSelf.recycleBtn.hidden = YES;
        }
    };
}

- (void)cancelAction {
    self.fileTitleLabel.hidden = NO;
    self.fileReturnBtn.hidden = NO;
    self.selectedTopView.hidden = YES;
    self.recycleBtn.hidden = NO;
    [self.recycleList cancelSelected];
}

- (ESRecycleBinListVC *)recycleList {
    if (!_recycleList) {
        _recycleList = [[ESRecycleBinListVC alloc] init];
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


- (void)recycleBtn:(UIButton *)completeBtn {
    
    [ESCommonToolManager isBackupInComple];
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"backupInProgress"];
    if([str isEqual:@"YES"]){
        [ESToast toastSuccess:NSLocalizedString(@"Executing backup task", @"正在执行备份任务，暂不支持此操作")];
        return;
    }
    self.popView.category = @"clear";
    self.popView.hidden = NO;
    self.recycleBtn.hidden = YES;
}

// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)delectTapGestureAction:(UITapGestureRecognizer *)tap {
    self.popView.hidden = YES;
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCancelBtn:(UIButton *_Nullable)button{
    self.popView.hidden = YES;
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button{
    ESRecycledApi *api =  [ESRecycledApi new];
    NSMutableArray *uuids = [[NSMutableArray alloc] init];
    if (self.selectedInfoArray.count > 0) {
        for (ESFileInfoPub *info in self.selectedInfoArray) {
            [uuids addObject:info.uuid];
        }
    }
  
    if([self.popView.category isEqual:@"reduction"]){
        self.popView.hidden = YES;

        [self.view showLoading:YES message:NSLocalizedString(@"recover_loading_message", @"正在还原")];
        weakfy(self)
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                        apiName:@"restore_recycled"
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
                    processVC.customProcessTitle = NSLocalizedString(@"recover_loading_message", @"正在还原");

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
        return;
    }else{
        [ESCommonToolManager isBackupInComple];
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"backupInProgress"];
        if([str isEqual:@"YES"]){
            [ESToast toastSuccess:NSLocalizedString(@"Executing backup task", @"正在执行备份任务，暂不支持此操作")];
            return;
        }
        ESRecycledPhyDeleteReq *deleteReq = [ESRecycledPhyDeleteReq new];
        deleteReq.uuids = uuids;
        [api spaceV1ApiRecycledClearPostWithUuids:deleteReq
                                completionHandler:^(ESRsp *output, NSError *error) {
            NSLog(@"%@",output);
            self.popView.hidden = YES;
            if (output.code.intValue == 200) {
                self.popView.hidden = YES;  
                [self.recycleList getFileRequestStart:nil];
                if ([self.popView.category isEqual:@"clear"]) {
                    [ESToast toastSuccess:NSLocalizedString(@"Clear Succeed", @"清除成功")];
                }else if ([self.popView.category isEqual:@"del"]) {
                    [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
                }
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }
}

- (void)deleteSuccess {
    [self.recycleList getFileRequestStart:nil];
    [ESToast toastSuccess:NSLocalizedString(@"Restore Succeed", @"还原成功")];
}

- (void)deleteFail {
    [self.recycleList getFileRequestStart:nil];
    [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
}

/// 是否有文件被选中
- (void)fileListFolderBottomHidden:(NSNotification *)notifi {
    
    // 马上进入刷新状态
   // self.categoryVC.listView.tableView.scrollEnabled = NO;
    [self.categoryVC.listView.tableView.mj_header endRefreshing];
    [self.categoryVC.listView.tableView.mj_header removeFromSuperview];
    NSDictionary *dic = notifi.object;
    self.isSelectUUIDSArray = dic[@"isSelectUUIDSArray"];
    self.selectedInfoArray = dic[@"selectedInfoArray"];
    self.selectLable.text = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), (unsigned long)self.isSelectUUIDSArray.count];

    if (self.selectedInfoArray.count > 0) {
        self.popView.category = @"reduction";
        self.bottomToolView.hidden = NO;
        [self updataListFrameHidden:NO];
        self.fileTitleLabel.hidden = YES;
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
            [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];

        }
    }
}

-(UIView *)createBottomToolView {
    UIView *bottom = [[UIView alloc]init];
    bottom.backgroundColor = ESColor.systemBackgroundColor;
    self.bottomToolView = bottom;
    [self.view addSubview:bottom];
  //  [[UIApplication sharedApplication].keyWindow addSubview:bottom];
    UIButton *reductionBtn = [[UIButton alloc] initWithFrame:CGRectMake(110, 9, 44, 44)];
    [reductionBtn setTitle:NSLocalizedString(@"Restore", @"还原") forState:UIControlStateNormal];
    [reductionBtn setImage:IMAGE_ME_REDUCTION forState:UIControlStateNormal];
    [reductionBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:10]];
    [reductionBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
    [reductionBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:2];
    [reductionBtn addTarget:self action:@selector(reduction) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:reductionBtn];
    
    UIButton *delectBtn = [[UIButton alloc] initWithFrame:CGRectMake(110 + 44 + 100, 9, 44, 44)];
    [delectBtn setImage:IMAGE_FILE_BOTTOM_DEL forState:UIControlStateNormal];
    [delectBtn setTitle:NSLocalizedString(@"delete", @"删除") forState:UIControlStateNormal];
    [delectBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
    [delectBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:2];
    [delectBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:10]];
    [delectBtn addTarget:self action:@selector(delect) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:delectBtn];
    return bottom;
}

- (void)totalAllSlelectedAction {
    if ([self.topViewselelctBtn.titleLabel.text isEqual:NSLocalizedString(@"select_all", @"全选")]) {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
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

-(void)delect{
    self.popView.category = @"del";
    self.popView.hidden = NO;
}


-(void)updataListFrameHidden:(BOOL)isHidden{
    if (isHidden) {
        [self.recycleList.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.view.mas_top).offset(102);
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
            make.top.equalTo(self.view.mas_top).offset(102);
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

@end
