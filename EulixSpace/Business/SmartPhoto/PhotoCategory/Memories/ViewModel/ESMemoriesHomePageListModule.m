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
//  ESMemoriesHomePageListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/14.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesHomePageListModule.h"
#import "ESMemoriesAlbumCell.h"
#import "ESMemoriesDetailPageVC.h"
#import "ESBaseTableVC.h"
#import "ESMemoriesHomePageVC.h"

@interface ESMemoriesHomePageVC ()

- (void)showDeleteAlbumDialog:(ESAlbumModel *)albumModel;
- (void)likeAlbum:(ESAlbumModel *)albumModel;

@end

@implementation ESMemoriesHomePageListModule

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return ceilf((size.width - 40 ) * 400.0f / 334.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.listData.count) {
        ESAlbumModel *albumModel = self.listData[indexPath.row];
        ESMemoriesDetailPageVC *vc = [[ESMemoriesDetailPageVC alloc] init];
        vc.albumModel = albumModel;
        [self.tableVC.navigationController pushViewController:vc animated:YES];
    }
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ESMemoriesAlbumCell class];
}

- (void)beforeBindData:(id _Nullable)data cell:(ESBaseCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.row >= self.listData.count) {
        return;
    }
    ESAlbumModel *albumModel = self.listData[indexPath.row];
    weakfy(self)
    if ([cell isKindOfClass:[ESMemoriesAlbumCell class]]) {
        [(ESMemoriesAlbumCell *)cell setLikeActionBlock:^{
            strongfy(self)
            [(ESMemoriesHomePageVC *)self.tableVC likeAlbum:albumModel];
        }];
        
        [(ESMemoriesAlbumCell *)cell setDeleteActionBlock:^{
            strongfy(self)
            [(ESMemoriesHomePageVC *)self.tableVC showDeleteAlbumDialog:albumModel];
        }];
    }
}

@end
