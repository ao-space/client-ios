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
//  ESMemoriesCollectionVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesCollectionVC.h"
#import "ESSmartPhotoDataBaseManager.h"

@interface ESMemoriesCollectionVC ()

@end

@implementation ESMemoriesCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title =  NSLocalizedString(@"album_collection", @"个人收藏");
}

- (void)setupNavigationBar {
}

- (void)reloadAlbumDataFromDB {
    NSArray<ESAlbumModel *> *albumList = [ESSmartPhotoDataBaseManager.shared getCollectionAlbumDataFromDBByType:ESAlbumTypeMemories];
    NSMutableArray *collectionList = [NSMutableArray array];
    [albumList enumerateObjectsUsingBlock:^(ESAlbumModel * _Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
        if(album.collection) {
            [collectionList addObject:album];
        }
    }];
    
    NSArray *albums = [collectionList sortedArrayUsingComparator:^NSComparisonResult(ESAlbumModel  *_Nonnull obj1, ESAlbumModel *  _Nonnull obj2) {
        if (obj1.modifyAt > obj2.modifyAt) {
              return NSOrderedAscending;
          } else if (obj1.modifyAt < obj2.modifyAt) {
              return NSOrderedDescending;
          }
         return NSOrderedSame;
    }];
    
    [self.listModule reloadData:albums];
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"album_noMemories", @"暂无收藏的回忆");
}

@end
