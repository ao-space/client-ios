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
//  ESFolderList.m
//  EulixSpace
//
//  Created by qu on 2021/12/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFolderList.h"
#import "ESCommentToolVC.h"
#import "ESFolderTableList.h"
#import "ESMJHeader.h"

@interface ESFolderList () <ESCommentToolDelegate>

@property (nonatomic, strong) ESFolderTableList *fileList;

@property (nonatomic, strong) ESCommentToolVC *bottomTool;

@end

@implementation ESFolderList

- (void)loadView {
    [super loadView];
    self.category = @"Folder";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileListFolderBottomHidden:) name:@"fileListFolderBottomHidden" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCreateFolder:) name:@"newCreateFolder" object:nil];
    self.transferListBtn.hidden = YES;
}

- (UILabel *)fileTitleLabel {
    if (!_fileTitleLabel) {
        _fileTitleLabel = [[UILabel alloc] init];
        _fileTitleLabel.textColor = ESColor.labelColor;
        _fileTitleLabel.textAlignment = NSTextAlignmentCenter;
        _fileTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.view addSubview:_fileTitleLabel];
        [_fileTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 13);
            make.centerX.mas_equalTo(self.view);
            make.height.mas_equalTo(25.0f);
            make.width.mas_equalTo(200.0f);
        }];
        
        [self.fileReturnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(13.0f);
            make.centerY.mas_equalTo(self.fileTitleLabel.mas_centerY);
            make.height.mas_equalTo(48.0f);
            make.width.mas_equalTo(48.0f);
        }];
        
        [self.fileReturnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(13.0f);
            make.centerY.mas_equalTo(self.fileTitleLabel.mas_centerY);
            make.height.mas_equalTo(48.0f);
            make.width.mas_equalTo(48.0f);
        }];
    }
    return _fileTitleLabel;
}

- (UIButton *)fileReturnBtn {
    if (!_fileReturnBtn) {
        _fileReturnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fileReturnBtn setImage:IMAGE_IC_BACK_CHEVRON forState:UIControlStateNormal];
        [_fileReturnBtn addTarget:self action:@selector(didfileReturnBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_fileReturnBtn];
    }
    return _fileReturnBtn;
}

- (ESFolderTableList *)fileList {
    if (!_fileList) {
        _fileList = [[ESFolderTableList alloc] init];
        [self.view addSubview:_fileList.view];
        [self addChildViewController:_fileList];
        [self.fileList.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.view.mas_top).offset(102);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
        [self.fileList.listView.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.fileList.view.mas_top).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
    }
    return _fileList;
}

- (void)setFileInfo:(ESFileInfoPub *)fileInfo {
    if (fileInfo) {
        _fileInfo = fileInfo;
        self.fileTitleLabel.text = fileInfo.name;
        [self.fileList.enterFileUUIDArray addObject:fileInfo];
    }
}

/// 返回
- (void)didfileReturnBtnClick {
    if (self.enterFileUUIDArray.count > 0) {
        [self.enterFileUUIDArray removeLastObject];
    }
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path"];
    
    NSArray *array = [path componentsSeparatedByString:@"/"]; //从字符A中分隔成2个元素的数组
    NSString *pathNew;
    for (int i = 0; i < array.count; i++) {
        if (i < array.count - 1) {
            if (pathNew) {
                pathNew = [NSString stringWithFormat:@"%@/%@", pathNew, array[i]];
            } else {
                pathNew = array[i];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:pathNew forKey:@"select_up_path"];

    if (self.enterFileUUIDArray.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1] forKey:@"select_up_path_uuid"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"select_up_path_uuid"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    //self.fileTitleLabel.text =
    self.bottomTool.currentWindow = self.view.window;
    self.selectLable.text = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), (unsigned long)self.isSelectUUIDSArray.count];
    if (self.selectedInfoArray.count > 0) {
        [self.fileList.listView.tableView.mj_header endRefreshing];
        [self.fileList.listView.tableView.mj_header removeFromSuperview];
        self.fileTitleLabel.hidden = YES;
        self.fileReturnBtn.hidden = YES;
        // [self.bottomTool showSelectArray:self.selectedInfoArray];
        if (self.enterFileUUIDArray.count > 0) {
            [self.bottomTool showSelectArray:self.selectedInfoArray currentDirUUID:self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1]];
        } else {
            [self.bottomTool showSelectArray:self.selectedInfoArray currentDirUUID:self.fileInfo.uuid];
        }
        self.bottomTool.bottomView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        self.selectedTopView.hidden = NO;
    } else {
        [self.fileList addRefresh];
        self.fileTitleLabel.hidden = NO;
        self.fileReturnBtn.hidden = NO;
        self.selectedTopView.hidden = YES;
        if (self.isSourceSearch) {
            self.tabBarController.tabBar.hidden = YES;
        }else{
            self.tabBarController.tabBar.hidden = NO;
        }
        
        [self.bottomTool hidden];
    }
    if (self.isSelectUUIDSArray.count > 0) {
        if (self.selectedInfoArray.count == 1) {
            self.bottomTool.bottomView.fileInfo = self.selectedInfoArray[0];
            self.bottomTool.bottomView.isMoreSelect = NO;
            self.bottomTool.bottomView.isMoreSelect = NO;
            
        }
        if (self.isSelectUUIDSArray.count > 1) {
            self.bottomTool.bottomView.isMoreSelect = YES;
        } else {
            self.bottomTool.bottomView.isMoreSelect = NO;
        }
        if (self.isSelectUUIDSArray.count != self.fileList.children.count) {
            [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];
        } else {
            [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
        }
    }
}

/// 取消
- (void)cancelAction {
    self.fileTitleLabel.hidden = NO;
    self.fileReturnBtn.hidden = NO;
    self.selectedTopView.hidden = YES;
    [self.bottomTool hidden];
    [self.fileList cancelSelected];
}

//全选/全不选
- (void)totalAllSlelectedAction {
    //  [self loadMoreData];

    if ([self.topViewselelctBtn.titleLabel.text isEqual:NSLocalizedString(@"select_all", @"全选")]) {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
        [self.fileList selectAll:YES];
    } else {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];

        [self.fileList selectAll:NO];
    }
}

- (ESCommentToolVC *)bottomTool {
    if (!_bottomTool) {
        _bottomTool = [ESCommentToolVC new];
        _bottomTool.alwaysShow = YES;
        _bottomTool.delegate = self;
    }
    return _bottomTool;
}

- (void)completeLoadData {
    [self.fileList reRefresh];
    [self cancelAction];
    if(self.tabBarController.tabBar.hidden){
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (void)newCreateFolder:(NSNotification *)notifi {
    [self completeLoadData];
}


- (void)fileSortView:(ESFileSortView *_Nullable)fileSortView moreTag:(NSString * _Nonnull)moreTag{
        self.bottomTool.bottomView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        self.selectedTopView.hidden = NO;
}


- (void)fileSortView:(ESFileSortView *_Nullable)fileSortView didSortType:(ESSortClass)type isUpSort:(BOOL)isUpSort {
    if (type == ESSortClassName) {
        if (isUpSort) {
            self.fileList.sortType = @"is_dir desc,name asc";
        } else {
            self.fileList.sortType = @"is_dir desc,name desc";
        }
    } else if (type == ESSortClassTime) {
        if (isUpSort) {
            self.fileList.sortType = @"is_dir desc,operation_time asc";
        } else {
            self.fileList.sortType = @"is_dir desc,operation_time desc";
        }
    } else if (type == ESSortClassType) {
        if (isUpSort) {
            self.fileList.sortType = @"mime asc";
        } else {
            self.fileList.sortType = @"mime desc";
        }
    }
    [self.fileList headerRefreshWithUUID:self.fileInfo.uuid];
    self.sortView.hidden = YES;
}
@end
