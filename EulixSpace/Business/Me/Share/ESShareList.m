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
//  ESShareList.m
//  EulixSpace
//
//  Created by qu on 2022/7/4.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShareList.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import <Masonry/Masonry.h>
#import "ESFileInfoPub.h"
#import "ESShareListCell.h"
#import "ESShareApi.h"
#import "ESFileApi.h"

@interface ESShareList ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ESShareList

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self getManagementServiceApi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleName;
    [self initUI];

}

- (void)initUI {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(0.0f);
        make.left.mas_equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.view).offset(-kBottomHeight);
        make.right.mas_equalTo(self.view).offset(0);
    }];
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 83;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESShareListCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                         @"ESShareListCellCellID"];
    if (cell == nil) {
        cell = [[ESShareListCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESShareListCellCellID"];
    }
    if (self.dataList.count > indexPath.row) {
        cell.model = self.dataList[indexPath.row];
    }
    if (indexPath.row != self.dataList.count - 1) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25, 79, ScreenWidth - 50, 1)];
        lineView.backgroundColor = ESColor.separatorColor;
        [cell.contentView addSubview:lineView];
    }
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESFileInfoPub *info = self.dataList[indexPath.row];
    if([info.isDir boolValue]){
        ESFileApi *apiFile = [ESFileApi new];
        [apiFile spaceV1ApiFileListGetWithUuid:info.uuid isDir:@(0) page:@(1) pageSize:@(100) orderBy:nil category:nil completionHandler:^(ESRspGetListRspData *output, NSError *error) {
            ESShareList *shareList = [ESShareList new];
            shareList.titleName = info.name;
            shareList.dataList = output.results.fileList;
            [self.navigationController pushViewController:shareList animated:YES];
        }];
    }
}

@end
