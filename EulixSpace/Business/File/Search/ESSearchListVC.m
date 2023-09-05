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
//  ESSearchListVC.m
//  EulixSpace
//
//  Created by qu on 2021/9/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSearchListVC.h"
#import "ESFileSearchListVC.h"
#import "ESFolderList.h"
#import "ESSearchBar.h"

@interface ESSearchListVC () <ESSearchBarDelegate>

@property (nonatomic, strong) UIButton *returnSearchBtn;
@property (nonatomic, strong) ESSearchBar *searchPageBar;
@property (nonatomic, strong) UILabel *selectedNum;
@property (nonatomic, strong) ESFileSearchListVC *searchList;
@property (nonatomic, strong) UILabel *searchFileName;
@property (nonatomic, strong) ESFileInfoPub *searchSelectedFileInfo;
//@property (nonatomic, strong) ESEmptyView *emptyView;
@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, assign) BOOL isSearched;

@property (nonatomic, strong) UILabel *seachClass;

@property (nonatomic, strong) UIButton *seachClassAll;

@property (nonatomic, strong) UIButton *seachClassAllBack;

@property (nonatomic, strong) UIButton *seachClassPic;
@property (nonatomic, strong) UIButton *seachClassVideo;
@property (nonatomic, strong) UIButton *seachClassOther;
@property (nonatomic, strong) UIButton *seachClassFile;
@property (nonatomic, copy) NSString *searchKey;

@property (nonatomic, copy) NSString *searchClassKey;
@end

@implementation ESSearchListVC

- (void)loadView {
    [super loadView];
    self.category = @"Search";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.bottomView.hidden = YES;
    self.transferListNumView.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    self.categoryVC.view.hidden = YES;
    self.pageContentView.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageTitleView.hidden = YES;
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.transferListBtn.hidden = YES;
    [self.searchPageBar.textField becomeFirstResponder];
    self.searchBar.hidden = YES;
    self.recycleBinBtn.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSearchEnterFolderClick:) name:@"didSecrchEnterFolderClick" object:nil];
    self.isSearched = NO;

}

- (void)setupUI {
    [super setupUI];
    [self noSearchSelected];
    self.searchPageBar.hidden = NO;

    [self.returnSearchBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.centerY.equalTo(self.searchPageBar.mas_centerY);
        make.width.equalTo(@(48.0f));
        make.height.equalTo(@(48.0f));
    }];

    [self.selectedNum mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(26);
        make.top.equalTo(self.searchPageBar.mas_bottom).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@(20.0f));
    }];
 
    [self.searchList.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.top.equalTo(self.selectedNum.mas_bottom).offset(10);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];

    [self.searchFileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 13);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(25.0f);
        make.width.mas_equalTo(200.0f);
    }];
    
    
    [self.seachClass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(26);
        make.top.equalTo(self.searchPageBar.mas_bottom).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@(20.0f));
    }];
    
    [self.seachClassAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.top.mas_equalTo(self.seachClass.mas_bottom).offset(10);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(100);
    }];
    
    [self.seachClassPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.seachClassAll.mas_right).offset(10);
        make.top.mas_equalTo(self.seachClass.mas_bottom).offset(10);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(100);
    }];
    
    [self.seachClassVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.seachClassPic.mas_right).offset(10);
        make.top.mas_equalTo(self.seachClass.mas_bottom).offset(10);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(100);
    }];

    [self.seachClassFile mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.top.mas_equalTo(self.seachClassAll.mas_bottom).offset(10);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(100);
    }];
    
    [self.seachClassOther mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.seachClassFile.mas_right).offset(10);
        make.top.mas_equalTo(self.seachClassAll.mas_bottom).offset(10);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(100);
    }];

}

/// 进入文件夹
- (void)didSearchEnterFolderClick:(NSNotification *)notifi {
    NSDictionary *dic = notifi.object;
    ESFileInfoPub *fileInfo = dic[@"fileInfo"];
    if ([fileInfo.isDir boolValue]) {
        ESFolderList *listVC = [ESFolderList new];
        listVC.isSourceSearch = YES;
        listVC.fileInfo = fileInfo;
        [self.navigationController pushViewController:listVC animated:YES];
    }
}

- (void)isSearchSelected {
    self.searchList.listView.tableView.scrollEnabled = NO;
    self.searchFileName.hidden = NO;
    self.returnSearchBtn.hidden = NO;
    self.searchPageBar.hidden = YES;
    self.selectedNum.hidden = YES;
    self.searchPageBar.hidden = YES;
}

- (void)noSearchSelected {
    self.searchList.listView.tableView.scrollEnabled = YES;
    self.searchFileName.hidden = YES;
    self.returnSearchBtn.hidden = NO;
    self.searchPageBar.hidden = NO;
    self.pageTitleView.hidden = YES;
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.selectedTopView.hidden = YES;
    self.bottomView.hidden = YES;
    self.selectedNum.hidden = NO;
}

- (ESSearchBar *)searchPageBar {
    if (!_searchPageBar) {
        _searchPageBar = [[ESSearchBar alloc] initWithFrame:CGRectMake(64, kStatusBarHeight + 5, ScreenWidth - 64 - 26, 46)];
        _searchPageBar.delegate = self;
        _searchPageBar.textField.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _searchPageBar.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _searchPageBar.layer.masksToBounds = YES;
        _searchPageBar.layer.cornerRadius = 10;
        [self.view addSubview:_searchPageBar];
    }
    return _searchPageBar;
}

- (UIButton *)returnSearchBtn {
    if (nil == _returnSearchBtn) {
        _returnSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnSearchBtn addTarget:self action:@selector(didreturnSearchBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_returnSearchBtn setImage:IMAGE_IC_BACK_CHEVRON forState:UIControlStateNormal];
        [self.view addSubview:_returnSearchBtn];
    }
    return _returnSearchBtn;
}


- (UILabel *)selectedNum {
    if (!_selectedNum) {
        _selectedNum = [[UILabel alloc] init];
        _selectedNum.textColor = ESColor.disableTextColor;
        _selectedNum.textAlignment = NSTextAlignmentLeft;
        _selectedNum.text = @"";
        _selectedNum.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:_selectedNum];
    }
    return _selectedNum;
}

- (UILabel *)seachClass {
    if (!_seachClass) {
        _seachClass = [[UILabel alloc] init];
        _seachClass.textColor = ESColor.labelColor;
        _seachClass.textAlignment = NSTextAlignmentLeft;
        _seachClass.text = TEXT_FILE_SEARCH_SCOPE;
        _seachClass.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:_seachClass];
    }
    return _seachClass;
}


- (UIButton *)seachClassAll {
    if (!_seachClassAll) {
        _seachClassAll = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seachClassAll setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_seachClassAll setTitle:TEXT_HOME_ALL forState:UIControlStateNormal];
        [_seachClassAll setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
        [_seachClassAll setImage:IMAGE_SEARCH_ALL_SED forState:UIControlStateNormal];
        [_seachClassAll addTarget:self action:@selector(didSeachClassAllBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_seachClassAll.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_seachClassAll.layer setCornerRadius:6.0]; //设置矩圆角半径
        _seachClassAll.layer.masksToBounds = YES;
        CGFloat spacing = 4;
        _seachClassAll.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        _seachClassAll.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
        [self.view addSubview:_seachClassAll];
        [self.view bringSubviewToFront:_seachClassAll];
    }
    return _seachClassAll;
}


- (UIButton *)seachClassAllBack {
    if (!_seachClassAllBack) {
        _seachClassAllBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seachClassAllBack setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_seachClassAllBack setTitle:TEXT_HOME_ALL forState:UIControlStateNormal];
        [_seachClassAllBack setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
        [_seachClassAllBack addTarget:self action:@selector(didSeachClassAllBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_seachClassAllBack.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_seachClassAllBack.layer setCornerRadius:6.0]; //设置矩圆角半径
        _seachClassAllBack.layer.masksToBounds = YES;
        CGFloat spacing = 4;
        _seachClassAllBack.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        _seachClassAllBack.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
        [self.view addSubview:_seachClassAllBack];
        [self.view bringSubviewToFront:_seachClassAllBack];
        
    }
    return _seachClassAllBack;
}

- (UIButton *)seachClassPic {
    if (nil == _seachClassPic) {
        _seachClassPic = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seachClassPic addTarget:self action:@selector(didSeachClassPicClick) forControlEvents:UIControlEventTouchUpInside];
        [_seachClassPic setImage:IMAGE_SEARCH_PIC forState:UIControlStateNormal];
        [_seachClassPic setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [_seachClassPic setTitle:TEXT_HOME_PHOTO forState:UIControlStateNormal];
        [_seachClassPic setBackgroundColor:ESColor.secondarySystemBackgroundColor];
        [_seachClassPic.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_seachClassPic.layer setCornerRadius:6.0]; //设置矩圆角半径
        _seachClassPic.layer.masksToBounds = YES;
        CGFloat spacing = 4;
        _seachClassPic.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        _seachClassPic.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
        [self.view addSubview:_seachClassPic];
    }
    return _seachClassPic;
}


- (UIButton *)seachClassVideo {
    if (nil == _seachClassVideo) {
        _seachClassVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seachClassVideo addTarget:self action:@selector(didSeachClassVideoClick) forControlEvents:UIControlEventTouchUpInside];
        [_seachClassVideo setImage:IMAGE_SELECH_VIDEO forState:UIControlStateNormal];
        [_seachClassVideo setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [_seachClassVideo setTitle:TEXT_HOME_VIDEO forState:UIControlStateNormal];
        [_seachClassVideo setBackgroundColor:ESColor.secondarySystemBackgroundColor];
        [_seachClassVideo.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [self.view addSubview:_seachClassVideo];
        CGFloat spacing = 4;
        _seachClassVideo.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        _seachClassVideo.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
        [_seachClassVideo.layer setCornerRadius:6.0]; //设置矩圆角半径
        _seachClassVideo.layer.masksToBounds = YES;
    }
    return _seachClassVideo;
}


- (UIButton *)seachClassOther {
    if (nil == _seachClassOther) {
        _seachClassOther = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seachClassOther addTarget:self action:@selector(didSeachClassOtherBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_seachClassOther setImage:IMAGE_SEARCH_OTHER forState:UIControlStateNormal];
        [_seachClassOther setTitle:TEXT_HOME_OTHER forState:UIControlStateNormal];
        [_seachClassOther setBackgroundColor:ESColor.secondarySystemBackgroundColor];
        [_seachClassOther setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [_seachClassOther.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_seachClassOther.layer setCornerRadius:6.0]; //设置矩圆角半径
        _seachClassOther.layer.masksToBounds = YES;
        CGFloat spacing = 4;
        _seachClassOther.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        _seachClassOther.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
        [self.view addSubview:_seachClassOther];
    }
    return _seachClassOther;
}


- (UIButton *)seachClassFile {
    if (nil == _seachClassFile) {
        _seachClassFile = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seachClassFile addTarget:self action:@selector(didSeachClassFileClick) forControlEvents:UIControlEventTouchUpInside];
        [_seachClassFile setImage:IMAGE_SEARCH_FILE forState:UIControlStateNormal];
        [_seachClassFile.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_seachClassFile setTitle:TEXT_HOME_FILE forState:UIControlStateNormal];
        [_seachClassFile setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [_seachClassFile setBackgroundColor:ESColor.secondarySystemBackgroundColor];
        [_seachClassFile.layer setCornerRadius:6.0]; //设置矩圆角半径
        CGFloat spacing = 4;
        _seachClassFile.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        _seachClassFile.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
        _seachClassFile.layer.masksToBounds = YES;
        [self.view addSubview:_seachClassFile];
    }
    return _seachClassFile;
}


- (void)didreturnSearchBtnClick {
    self.searchList.listView.isSelectUUIDSArray = [NSMutableArray new];
    if (self.searchList.enterFileUUIDArray.count > 0) {
        [self.searchList.enterFileUUIDArray removeLastObject];
        if (self.searchList.enterFileUUIDArray.count == 0) {
            [self noSearchSelected];
            [self.searchList.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.view.mas_top).offset(120);
            }];
            self.searchPageBar.textField.text = @"";
            self.searchList.current.children = [NSMutableArray new];
            self.searchList.enterFileUUIDArray = [NSMutableArray new];
            self.selectedNum.hidden = YES;
            [self.searchList.current reloadData];
            [self.view layoutIfNeeded];
        } else {
            ESFileInfoPub *info = self.searchList.enterFileUUIDArray[self.searchList.enterFileUUIDArray.count - 1];
            [self.searchList headerRefreshWithUUID:info.uuid];
            self.searchFileName.text = info.name;
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (ESFileSearchListVC *)searchList {
    if (!_searchList) {
        _searchList = [[ESFileSearchListVC alloc] init];
        weakfy(self);
        _searchList.actionBlock = ^(NSString *selectedNum) {
            strongfy(self);
            self.selectedNum.text = selectedNum;
            self.selectedNum.hidden = NO;
        };
        [self.view addSubview:_searchList.view];
        [self addChildViewController:_searchList];
    }
    return _searchList;
}

- (UILabel *)searchFileName {
    if (!_searchFileName) {
        _searchFileName = [[UILabel alloc] init];
        _searchFileName.textColor = ESColor.labelColor;
        _searchFileName.textAlignment = NSTextAlignmentCenter;
        _searchFileName.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:_searchFileName];
    }
    return _searchFileName;
}

- (void)didsearchreturnSearchBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)totalAllSlelectedAction {
    if ([self.topViewselelctBtn.titleLabel.text isEqual:NSLocalizedString(@"select_all", @"全选")]) {
        [self.searchList selectAll:YES];
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
    } else {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];
        [self.searchList selectAll:NO];
        [self cancelAction];
    }
}

- (void)searchBarDidEndEditing:(ESSearchBar *)searchPageBar {
    self.searchList.view.hidden = NO;
    self.isSearched = YES;
    [self noSelected];
    [self.searchList loadSearchData:searchPageBar.textField.text classStr:self.searchClassKey];
    self.searchKey = searchPageBar.textField.text;

    if (searchPageBar.textField.text.length < 1) {
        self.selectedNum.text = NSLocalizedString(@"Search Results 0", @"搜索结果（0）");
        self.selectedNum.hidden = NO;
    }

    self.tabBarController.tabBar.hidden = YES;
    [self searchFinish];
    
}

-(void)searchFinish{
    self.seachClass.hidden = YES;
    self.seachClassAll.hidden = YES;
    
    [self.selectedNum mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(26);
        make.top.equalTo(self.searchPageBar.mas_bottom).offset(66);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@(20.0f));
    }];
    

    
    [self.seachClassAll mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.top.equalTo(self.searchPageBar.mas_bottom).offset(20);
        make.width.mas_equalTo(56.0);
        make.height.mas_equalTo(26.0);
    }];
   
    [self.seachClassAllBack mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.top.mas_equalTo(self.seachClassAll.mas_centerY).offset(0);
        make.width.mas_equalTo(56.0);
        make.height.mas_equalTo(26.0);
    }];
    
    [self.seachClassPic mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.seachClassAll.mas_right).offset(10);
        make.top.mas_equalTo(self.seachClassAll.mas_centerY).offset(0);
        make.width.mas_equalTo(56.0);
        make.height.mas_equalTo(26.0);
    }];

    [self.seachClassVideo mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.seachClassPic.mas_right).offset(10);
        make.top.mas_equalTo(self.seachClassAll.mas_centerY).offset(0);
        make.width.mas_equalTo(56.0);
        make.height.mas_equalTo(26.0);
    }];

    [self.seachClassFile mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(224);
        make.top.mas_equalTo(self.seachClassAll.mas_centerY).offset(0);
        make.width.mas_equalTo(56.0);
        make.height.mas_equalTo(26.0);
    }];

    [self.seachClassOther mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.seachClassFile.mas_right).offset(10);
        make.top.mas_equalTo(self.seachClassAll.mas_centerY).offset(0);
        make.width.mas_equalTo(56.0);
        make.height.mas_equalTo(26.0);
    }];
    
    
    [_seachClassVideo setImage:nil forState:UIControlStateNormal];
    [_seachClassOther setImage:nil forState:UIControlStateNormal];
    [_seachClassPic setImage:nil forState:UIControlStateNormal];
    [_seachClassFile setImage:nil forState:UIControlStateNormal];
    [_seachClassAll setImage:nil forState:UIControlStateNormal];
    [_seachClassAllBack setImage:nil forState:UIControlStateNormal];
    
    _seachClassVideo.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _seachClassOther.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _seachClassPic.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _seachClassFile.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _seachClassAll.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _seachClassAllBack.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    [self.view layoutIfNeeded];
}

- (void)loadMoreData {
    if (self.searchList.enterFileUUIDArray.count > 0) {
        ESFileInfoPub *info = self.searchList.enterFileUUIDArray[self.searchList.enterFileUUIDArray.count - 1];
        [self.searchList headerRefreshWithUUID:info.uuid];
    } else {
        [self.searchList headerRefreshWithUUID:nil];
    }
    self.searchList.listView.isSelectUUIDSArray = [NSMutableArray new];
    self.categoryVC = self.searchList;
    self.isMoveCopy = self.fileVC.listView.isCopyMove;
}

- (void)cancelAction {
    // [super cancelAction];
    self.searchList.listView.isSelectUUIDSArray = [NSMutableArray new];
    self.searchList.listView.cellClassArray = [NSMutableArray new];
    self.isSelectUUIDSArray = [NSMutableArray new];
    [self noSelected];
    [self.searchList cancelSelected];
    [self.searchPageBar.textField resignFirstResponder];
    [self canClassClick];
}

//- (ESEmptyView *)emptyView {
//    if (!_emptyView) {
//        _emptyView = [[ESEmptyView alloc] initWithFrame:self.view.bounds];
//        [self.view addSubview:_emptyView];
//        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self.view);
//        }];
//    }
//    return _emptyView;
//}

- (void)fileListBottomHidden:(NSNotification *)notifi {
    [super fileListBottomHidden:notifi];
    self.tabBarController.tabBar.hidden = YES;
    if (self.isSelectUUIDSArray.count > 0) {
        self.returnSearchBtn.hidden = YES;
        self.searchFileName.hidden = YES;
        [self canNoClassClick];
    } else {
        self.searchPageBar.hidden = NO;
        self.returnSearchBtn.hidden = NO;
        self.searchFileName.hidden = NO;
    }
    if (self.searchList.enterFileUUIDArray.count > 0) {
        self.searchPageBar.hidden = YES;
    } else {
        self.searchFileName.hidden = YES;
    }
}

- (void)searchBarClearAction:(ESSearchBar *)searchBar {
    self.searchList.view.hidden = YES;
    self.selectedNum.hidden = YES;
}

- (void)copyMoveApiWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category{
    [super copyMoveApiWithPathName:pathName selectUUID:uuid category:category];
    [self completeLoadData];
}

- (void)completeLoadData{
    [self.searchList.current reloadData];
    [self.searchList loadSearchData:self.searchKey];
    [self cancelAction];
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button{
    [super fileBottomDelectView:fileBottomDelectView didClickCompleteBtn:button];
    [self completeLoadData];
}

-(void)didSeachClassAllBtnClick{

    self.searchClassKey = @"";

    [self.seachClassAllBack setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    [self.seachClassAll setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    [self.seachClassPic setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];

    [self.seachClassVideo setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
 
    [self.seachClassOther setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];

    [self.seachClassFile setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassFile setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassAllBack setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
    [self.seachClassAll setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
    [self.seachClassOther setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassPic setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassVideo setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    
    if(!self.isSearched){
      //  [self.seachClassAllBack setImage:IMAGE_SEARCH_ALL_SED forState:UIControlStateNormal];
        [self.seachClassAll setImage:IMAGE_SEARCH_ALL_SED forState:UIControlStateNormal];
        [self.seachClassPic setImage:IMAGE_SEARCH_PIC forState:UIControlStateNormal];
        [self.seachClassVideo setImage:IMAGE_SELECH_VIDEO forState:UIControlStateNormal];
        [self.seachClassOther setImage:IMAGE_SEARCH_OTHER forState:UIControlStateNormal];
        [self.seachClassFile setImage:IMAGE_SEARCH_FILE forState:UIControlStateNormal];
    }else{
        [self.searchList loadSearchData:self.searchPageBar.textField.text classStr:@""];
    }
}

-(void)didSeachClassPicClick{
    self.searchClassKey = @"picture";
  
    [self.seachClassAllBack setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    [self.seachClassAll setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    [self.seachClassPic setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];

    [self.seachClassVideo setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassOther setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassFile setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassFile setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassAllBack setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassAll setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassOther setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassPic setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
    [self.seachClassVideo setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    
    if(!self.isSearched){
    //    [self.seachClassAllBack setImage:IMAGE_SEARCH_ALL forState:UIControlStateNormal];
        [self.seachClassAll setImage:IMAGE_SEARCH_ALL forState:UIControlStateNormal];
        [self.seachClassPic setImage:IMAGE_SEARCH_PIC_SED forState:UIControlStateNormal];
        [self.seachClassVideo setImage:IMAGE_SELECH_VIDEO forState:UIControlStateNormal];
        [self.seachClassOther setImage:IMAGE_SEARCH_OTHER forState:UIControlStateNormal];
        [self.seachClassFile setImage:IMAGE_SEARCH_FILE forState:UIControlStateNormal];
    }else{
        [self.searchList loadSearchData:self.searchPageBar.textField.text classStr:@"picture"];
    }
}

-(void)didSeachClassVideoClick{
    self.searchClassKey = @"video";
  
    [self.seachClassAllBack setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    [self.seachClassAll setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];

    [self.seachClassPic setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassVideo setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
 
    [self.seachClassOther setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
  
    [self.seachClassFile setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassFile setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassAllBack setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassOther setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassPic setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassVideo setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
    [self.seachClassAll setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    if(!self.isSearched){
     //   [self.seachClassAllBack setImage:IMAGE_SEARCH_ALL forState:UIControlStateNormal];
        [self.seachClassPic setImage:IMAGE_SEARCH_PIC forState:UIControlStateNormal];
        [self.seachClassVideo setImage:IMAGE_SELECH_VIDEO_SED forState:UIControlStateNormal];
        [self.seachClassOther setImage:IMAGE_SEARCH_OTHER forState:UIControlStateNormal];
        [self.seachClassFile setImage:IMAGE_SEARCH_FILE forState:UIControlStateNormal];
        [self.seachClassAll setImage:IMAGE_SEARCH_ALL forState:UIControlStateNormal];
    }else{
        [self.searchList loadSearchData:self.searchPageBar.textField.text classStr:@"video"];
    }
}

-(void)didSeachClassFileClick{
    self.searchClassKey = @"document";
    [self.seachClassAllBack setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    [self.seachClassAll setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    [self.seachClassPic setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassVideo setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassOther setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassFile setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    
    [self.seachClassFile setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
    [self.seachClassAllBack setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassOther setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassPic setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassVideo setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassAll setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    if(!self.isSearched){
        [self.seachClassAll setImage:IMAGE_SEARCH_ALL forState:UIControlStateNormal];
        [self.seachClassPic setImage:IMAGE_SEARCH_PIC forState:UIControlStateNormal];
        [self.seachClassVideo setImage:IMAGE_SELECH_VIDEO forState:UIControlStateNormal];
        [self.seachClassOther setImage:IMAGE_SEARCH_OTHER forState:UIControlStateNormal];
        [self.seachClassFile setImage:IMAGE_SEARCH_FILE_SED forState:UIControlStateNormal];
    }else{
        [self.searchList loadSearchData:self.searchPageBar.textField.text classStr:@"document"];
    }
}

-(void)didSeachClassOtherBtnClick{
    self.searchClassKey = @"other";
   
    [self.seachClassAllBack setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];

    [self.seachClassAll setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    [self.seachClassPic setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
 
    [self.seachClassVideo setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
   
    [self.seachClassOther setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
  
    [self.seachClassFile setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
    
    [self.seachClassFile setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassAllBack setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassOther setBackgroundColor:ESColor.tertiarySystemBackgroundColor];
    [self.seachClassPic setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassVideo setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    [self.seachClassAll setBackgroundColor:ESColor.secondarySystemBackgroundColor];
    
    if(!self.isSearched){
       // [self.seachClassAllBack setImage:IMAGE_SEARCH_ALL forState:UIControlStateNormal];
        [self.seachClassAll setImage:IMAGE_SEARCH_ALL forState:UIControlStateNormal];
        [self.seachClassPic setImage:IMAGE_SEARCH_PIC forState:UIControlStateNormal];
        [self.seachClassVideo setImage:IMAGE_SELECH_VIDEO forState:UIControlStateNormal];
        [self.seachClassOther setImage:IMAGE_SEARCH_OTHER_SED forState:UIControlStateNormal];
        [self.seachClassFile setImage:IMAGE_SEARCH_FILE forState:UIControlStateNormal];
    }else{
        [self.searchList loadSearchData:self.searchPageBar.textField.text classStr:@"other"];
    }
}


-(void)canNoClassClick{
    [self.seachClassAllBack setEnabled:NO];
    [self.seachClassPic setEnabled:NO];
    [self.seachClassVideo setEnabled:NO];
    [self.seachClassOther setEnabled:NO];
    [self.seachClassFile setEnabled:NO];
    

    [self.seachClassAllBack setTitleColor:ESColor.searchLabelColor forState:UIControlStateNormal];
    [self.seachClassPic setTitleColor:ESColor.searchLabelColor forState:UIControlStateNormal];
    [self.seachClassVideo setTitleColor:ESColor.searchLabelColor forState:UIControlStateNormal];
    [self.seachClassOther setTitleColor:ESColor.searchLabelColor forState:UIControlStateNormal];
    [self.seachClassFile setTitleColor:ESColor.searchLabelColor forState:UIControlStateNormal];
    
}

-(void)canClassClick{
    [self.seachClassAllBack setEnabled:YES];
    [self.seachClassPic setEnabled:YES];
    [self.seachClassVideo setEnabled:YES];
    [self.seachClassOther setEnabled:YES];
    [self.seachClassFile setEnabled:YES];
    
    if ([self.searchClassKey isEqual:@"document"]) {
        [self didSeachClassFileClick];
    }else if([self.searchClassKey isEqual:@"video"]){
        [self didSeachClassVideoClick];
    }else if([self.searchClassKey isEqual:@"other"]){
        [self didSeachClassOtherBtnClick];
    }else if([self.searchClassKey isEqual:@"picture"]){
        [self didSeachClassPicClick];
    }else{
        [self didSeachClassAllBtnClick];
    }

}
@end
