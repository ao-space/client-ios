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
//  ESRecycleBinListVC.m
//  EulixSpace
//
//  Created by qu on 2022/3/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESRecycleBinListVC.h"
#import "ESRecycledApi.h"

@interface ESRecycleBinListVC()

@end

@implementation ESRecycleBinListVC

- (void)loadView {
    [super loadView];
    self.category = @"RecycleBin";
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)getFileRequestStart:(NSString *)fileUUID {
    ESRecycledApi *api = [ESRecycledApi new];
    [api spaceV1ApiRecycledListGetWithPage:@(1) pageSize:@(20) completionHandler:^(ESRspGetListRspData *output, NSError *error) {
        if (!error) {
            self.children = [NSMutableArray new];
            NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
            fileListArray = output.results.fileList.mutableCopy;
            for (ESFileInfoPub *info in fileListArray) {
                [self.children addObject:info];
            }
            ESPageInfoExt *pageInfo = output.results.pageInfo;
            self.totalInt = pageInfo.total.intValue;
            self.listView.children = self.children;

            [self.listView reloadData];
            if (self.children.count > 0) {
                self.blankSpaceView.hidden = YES;
                self.actionBlock(@(1));
            } else {
                self.blankSpaceView.hidden = NO;
                self.actionBlock(@(0));
            }
        } else {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            self.children = [[NSMutableArray alloc] init];
            [self.listView reloadData];
            self.actionBlock(@(0));
            self.blankSpaceView.hidden = NO;
        }
    }];
}

- (void)getFileRequestMoreStart:(NSString *)fileUUID {
    ESRecycledApi *api = [ESRecycledApi new];
    [api spaceV1ApiRecycledListGetWithPage:@(self.pageInt + 1) pageSize:@(20) completionHandler:^(ESRspGetListRspData *output, NSError *error) {
        [self.listView.tableView.mj_header endRefreshing];
        [self.listView.tableView.mj_footer endRefreshing];
        if (!error) {
            if (output.results.pageInfo.page.intValue > output.results.pageInfo.total.intValue) {
                [self.listView.tableView.mj_footer endRefreshingWithNoMoreData];
                if (self.delegate && [self.delegate respondsToSelector:@selector(isNomoreData)]) {
                    [self.delegate isNomoreData];
                }
                return;
            }
            if (output.results.pageInfo.page.intValue == self.pageInt + 1) {
                self.pageInt = output.results.pageInfo.page.intValue;
            }

            NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
            fileListArray = output.results.fileList.mutableCopy;
            for (ESFileInfoPub *info in fileListArray) {
                [self.children addObject:info];
            }
            ESPageInfoExt *pageInfo = output.results.pageInfo;
            self.totalInt = pageInfo.total.intValue;
            self.listView.children = self.children;
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileListBaseVCReloadData)]) {
                [self.delegate fileListBaseVCReloadData];
            }
            [self.listView reloadData];
            if (self.children.count > 0) {
                self.actionBlock(@(1));
                self.blankSpaceView.hidden = YES;
            } else {
                self.blankSpaceView.hidden = NO;
                self.actionBlock(@(0));
            }
        } else {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            self.children = [[NSMutableArray alloc] init];
            [self.listView reloadData];
            self.blankSpaceView.hidden = NO;
            self.actionBlock(@(0));
        }
    }];
}

@end
