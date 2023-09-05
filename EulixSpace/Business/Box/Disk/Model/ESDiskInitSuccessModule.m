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
//  ESDiskInitSuccessModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskInitSuccessModule.h"
#import "ESDiskInitSuccessPage.h"

@implementation ESDiskInitSuccessModule

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * containView = [[UIView alloc] init];
    ESDiskImagesView *diskImageView = [(ESDiskInitSuccessPage *)self.tableVC diskImageView];
    ESDiskListModel *diskListModel = [(ESDiskInitSuccessPage *)self.tableVC diskListModel];
    [containView addSubview:diskImageView];
    [diskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(containView).insets(UIEdgeInsetsMake(10, 26, 0, 26));
    }];
    [diskImageView setDiskInfos:diskListModel.diskInfos];
    return containView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  180 + 15 + 75 + 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  248 + 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESDiskInitSuccessView * successView = [(ESDiskInitSuccessPage *)self.tableVC successView];

    successView.model = [(ESDiskInitSuccessPage *)self.tableVC model];
    return successView;
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
