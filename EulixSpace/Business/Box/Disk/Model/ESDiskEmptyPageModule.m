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
//  ESDiskEmptyPageModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskEmptyPageModule.h"
#import "ESDiskEmptyPage.h"

@implementation ESDiskEmptyPageModule

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * containView = [[UIView alloc] init];
    ESDiskImagesView *diskImageView = [(ESDiskEmptyPage *)self.tableVC diskImageView];
    ESDiskListModel *diskListModel = [(ESDiskEmptyPage *)self.tableVC diskListModel];
    [containView addSubview:diskImageView];
    [diskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(containView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
    [diskImageView setDiskInfos:diskListModel.diskInfos];
    return containView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  180 + 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  48 + 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * containView = [[UIView alloc] init];
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.numberOfLines = 0;
    hintLabel.font = ESFontPingFangMedium(14);
    hintLabel.textColor = ESColor.labelColor;
    hintLabel.text = @"傲空间未检测到存储设备，请您在关机后安装磁盘重\n新开机";
    [containView addSubview:hintLabel];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(containView).insets(UIEdgeInsetsMake(20, 0, 20, 0));
    }];
    return containView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 0 || indexPath.section >= self.listData.count) {
        return 0;
    }
    
    return 0;
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    return NO;
}

@end
