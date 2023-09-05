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
//  ESFileSearchListVC.m
//  EulixSpace
//
//  Created by qu on 2021/9/17.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileSearchListVC.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <AFNetworking/AFHTTPSessionManager.h>

#import "ESMJHeader.h"

@interface ESFileSearchListVC ()
@property (nonatomic, strong) NSString *searchKey;
@property (nonatomic, strong) NSString *categoryKey;
//@property (nonatomic, strong) ESEmptyView *emptyView;
@property (nonatomic, strong) ESEmptyView *blankSearchSpaceView;

@end

@implementation ESFileSearchListVC

- (void)addRefresh {
    weakfy(self);
    // 下拉刷新
    self.listView.tableView.mj_header = [ESMJHeader headerWithRefreshingBlock:^{
        strongfy(self);
        [self.listView.tableView.mj_header endRefreshing];
        [self.listView.tableView.mj_footer endRefreshing];
        [self loadSearchData:self.searchKey classStr:self.categoryKey];
    }];

    // 上拉加载
    self.listView.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        strongfy(self);
        if (self.totalInt >= self.pageInt) {
            [self loadMoreSearchData:self.searchKey category:self.categoryKey];
        }
    }];
}

- (void)loadView {
    [super loadView];
    self.category = @"search";
    self.listView.category = self.category;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSearch = YES;

    self.searchKeyArray = [NSMutableArray new];
    ESEmptyItem *item = [ESEmptyItem new];
    item.content = NSLocalizedString(@"No files were searched", @"未搜索到任何文件");
    item.icon = IMAGE_SEARCH_EMPTY_ICON;
    [self.blankSpaceView reloadWithData:item];
    self.blankSpaceView.hidden = YES;
    self.blankSearchSpaceView.hidden = YES;
    [self addRefresh];
    self.sloganView.hidden = YES;
}

- (void)loadSearchData:(NSString *)searchKey {
    if (searchKey.length > 0) {
        self.children = [NSMutableArray new];
        [self getFileSearchRequestStart:searchKey];
    } else {
        self.blankSpaceView.hidden = NO;
    }
    self.searchKey = searchKey;
}

- (void)loadSearchData:(NSString *)searchKey classStr:(NSString *)classStr{
    if (searchKey.length > 0) {
        self.children = [NSMutableArray new];
        [self getFileSearchRequestStart:searchKey category:classStr];
    } 
    self.searchKey = searchKey;
    self.categoryKey = classStr;

}

- (void)loadMoreSearchData:(NSString *)searchKey category:(NSString *) category{
    if (searchKey.length > 0) {
        [self getFileSearchMoreRequestStart:searchKey category:category];
    }
    self.searchKey = searchKey;
}

- (void)getFileSearchRequestStart:(NSString *)searchKey category:(NSString *)category{
    self.pageInt = 1;
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    // [self.searchKeyArray  addObject:searchKey];
    [[ESFileApi new] spaceV1ApiFileSearchGetWithName:searchKey
                                                uuid:nil
                                            category:category
                                                page:@(1)
                                            pageSize:nil
                                             orderBy:nil
                                   completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                                       [ESToast dismiss];
                                       [self.listView.tableView.mj_header endRefreshing];
                                       [self.listView.tableView.mj_footer endRefreshing];
                                       if (!error) {
                                           if (output.results.pageInfo.page.intValue >= output.results.pageInfo.total.intValue) {
                                               [self.listView.tableView.mj_footer endRefreshingWithNoMoreData];
                                           }
                                           NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
                                           fileListArray = output.results.fileList.mutableCopy;
                                           if (fileListArray.count > 0) {
                                               for (ESFileInfoPub *info in fileListArray) {
                                                   info.searchKey = searchKey;
                                                   [self.children addObject:info];
                                               }
                                               
                                               self.searchResultNum = [NSString stringWithFormat:NSLocalizedString(@"Search Results", @"搜索结果（%lu）"), (unsigned long)output.results.pageInfo.count.intValue];
                                               if (self.actionBlock) {
                                                   self.actionBlock(self.searchResultNum);
                                               }
                                               ESPageInfoExt *pageInfo = output.results.pageInfo;
                                               self.totalInt = pageInfo.total.intValue;
                                               self.category = @"";
                                               self.current.children = self.children;
                                               [self.current reloadData];
                                               self.blankSpaceView.hidden = YES;
                                               self.blankSearchSpaceView.hidden = YES;
                                               self.sloganView.hidden = NO;
                                           } else {
                                               self.children = [NSMutableArray new];
                                               self.current.children = self.children;
                                               self.searchResultNum = [NSString stringWithFormat:NSLocalizedString(@"Search Results 0", @"搜索结果（0）")];
                                               if (self.actionBlock) {
                                                   self.actionBlock(self.searchResultNum);
                                               }
                                               [self.current reloadData];
                                               self.sloganView.hidden = YES;                                               self.blankSearchSpaceView.hidden = NO;
                                           }
                                       } else {
                                            [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                           self.sloganView.hidden = YES;   
                                           self.children = [[NSMutableArray alloc] init];
                                           self.blankSearchSpaceView.hidden = NO;
                                       }
                                   }];
}


- (void)getFileSearchRequestStart:(NSString *)searchKey {
    self.pageInt = 1;
    // [self.searchKeyArray  addObject:searchKey];
    [[ESFileApi new] spaceV1ApiFileSearchGetWithName:searchKey
                                                uuid:nil
                                            category:@""
                                                page:@(1)
                                            pageSize:nil
                                             orderBy:nil
                                   completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                                       [self.listView.tableView.mj_header endRefreshing];
                                       [self.listView.tableView.mj_footer endRefreshing];
                                       if (output) {
                                           if (output.results.pageInfo.page.intValue >= output.results.pageInfo.total.intValue) {
                                               [self.listView.tableView.mj_footer endRefreshingWithNoMoreData];
                                           }
                                           NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
                                           fileListArray = output.results.fileList.mutableCopy;
                                           if (fileListArray.count > 0) {
                                               for (ESFileInfoPub *info in fileListArray) {
                                                   info.searchKey = searchKey;
                                                   [self.children addObject:info];
                                               }
                                               self.searchResultNum = [NSString stringWithFormat:NSLocalizedString(@"Search Results", @"搜索结果（%lu）"), (unsigned long)output.results.pageInfo.count.intValue];
                                               if (self.actionBlock) {
                                                   self.actionBlock(self.searchResultNum);
                                               }
                                               ESPageInfoExt *pageInfo = output.results.pageInfo;
                                               self.totalInt = pageInfo.total.intValue;
                                               self.category = @"";
                                         
                                               self.current.children = self.children;
                                               [self.current reloadData];
                                               self.blankSpaceView.hidden = YES;
                                               self.blankSearchSpaceView.hidden = YES;
                                           } else {
                                               self.children = [NSMutableArray new];
                                               self.current.children = self.children;
                                               self.searchResultNum = [NSString stringWithFormat:NSLocalizedString(@"Search Results 0", @"搜索结果（0）")];
                                               if (self.actionBlock) {
                                                   self.actionBlock(self.searchResultNum);
                                               }
                                               [self.current reloadData];

                                               self.blankSearchSpaceView.hidden = NO;
                                           }
                                       } else {
                                           self.children = [[NSMutableArray alloc] init];
                                           self.blankSearchSpaceView.hidden = NO;
                                            [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                       }
                                   }];
}

- (void)getFileSearchMoreRequestStart:(NSString *)searchKey category:(NSString *)category {
    if (searchKey.length < 1) {
        [ESToast toastError:@"搜索框内容不可以为空！"];
        return;
    }
    // [self.searchKeyArray  addObject:searchKey];
    [[ESFileApi new] spaceV1ApiFileSearchGetWithName:searchKey
                                                uuid:nil
                                            category:@""
                                                page:@(self.pageInt + 1)
                                            pageSize:nil
                                             orderBy:nil
                                   completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                                       [self.listView.tableView.mj_header endRefreshing];
                                       [self.listView.tableView.mj_footer endRefreshing];
                                       if (output) {
                                           if (output.results.pageInfo.total.intValue == self.pageInt) {
                                               [self.listView.tableView.mj_footer endRefreshingWithNoMoreData];
                                               return;
                                           }

                                           if (output.results.pageInfo.page.intValue == self.pageInt + 1) {
                                               self.pageInt = output.results.pageInfo.page.intValue;
                                           }

                                           NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
                                           fileListArray = output.results.fileList.mutableCopy;
                                           if (fileListArray.count > 0) {
                                               for (ESFileInfoPub *info in fileListArray) {
                                                   info.category = @"search";
                                                   info.searchKey = searchKey;
                                                   [self.children addObject:info];
                                               }
                                               self.searchResultNum = [NSString stringWithFormat:NSLocalizedString(@"Search Results", @"搜索结果（%lu）"), (unsigned long)output.results.pageInfo.count.intValue];
                                               if (self.actionBlock) {
                                                   self.actionBlock(self.searchResultNum);
                                               }
                                               ESPageInfoExt *pageInfo = output.results.pageInfo;
                                               self.totalInt = pageInfo.total.intValue;
                                               self.category = @"";
                                               self.current.children = self.children;
                                               [self.current reloadData];
                                               self.blankSearchSpaceView.hidden = YES;
                                           }
                                       } else {
                                           // self.children = [[NSMutableArray alloc] init];
                                            [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                           self.blankSearchSpaceView.hidden = NO;
                                       }
                                   }];
}

- (ESEmptyView *)blankSearchSpaceView {
    if (!_blankSearchSpaceView) {
        _blankSearchSpaceView = [ESEmptyView new];
        ESEmptyItem *item = [ESEmptyItem new];
        item.content =  NSLocalizedString(@"No files were searched", @"未搜索到任何文件");
        item.icon = IMAGE_SEARCH_EMPTY_ICON;
        [self.view addSubview:_blankSearchSpaceView];
        [_blankSearchSpaceView reloadWithData:item];
        [_blankSearchSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _blankSearchSpaceView;
}

@end
