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
//  ESMyAlbumListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMyAlbumListModule.h"
#import "ESAlbumModel.h"
#import "ESMyAlbumCell.h"
#import "ESAlbumPageVC.h"

@interface ESMyAlbumListModule ()

@end

@implementation ESMyAlbumListModule

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.albumList.count) {
        return;
    }
    ESAlbumModel *model = self.albumList[indexPath.row];
    ESAlbumPageVC *albumPageVc = [[ESAlbumPageVC alloc] init];
    albumPageVc.albumModel = model;
    [self.parentVC.navigationController pushViewController:albumPageVc animated:YES];
}

@end
