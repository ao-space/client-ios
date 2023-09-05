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
//  ESFootPrintAlbumVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESFootPrintAlbumHomeVC.h"
#import "ESFootPrintHomePageListModule.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESBaseViewController+Status.h"

@interface ESFootPrintAlbumHomeVC ()

@end

@implementation ESFootPrintAlbumHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];

    self.title = NSLocalizedString(@"album_footprint", @"足迹");
}

- (void)reloadAlbumData {
    NSArray<ESAlbumModel *> *albumList = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeAddress];

    NSMutableArray *albumFliter = [NSMutableArray array];
    [albumList enumerateObjectsUsingBlock:^(ESAlbumModel * _Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
        if (album.picCount > 0) {
            [albumFliter addObject:album];
        }
    }];
    NSArray *albums = [albumFliter sortedArrayUsingComparator:^NSComparisonResult(ESAlbumModel  *_Nonnull obj1, ESAlbumModel *  _Nonnull obj2) {
        if (obj1.picCount > obj2.picCount) {
              return NSOrderedAscending;
          } else if (obj1.picCount < obj2.picCount) {
              return NSOrderedDescending;
          }
         return NSOrderedSame;
    }];
    [self showEmpty:albums.count <= 0];
    [self.listModule reloadData:albums];
}

- (Class)listModuleClass {
    return ESFootPrintHomePageListModule.class;
}

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_icon"];
}

- (NSString *)titleForEmpty {
    return  NSLocalizedString(@"You havent left any footprints yet", @"您还没留下任何足迹");
}


@end
