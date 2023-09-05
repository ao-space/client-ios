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
//  ESMyAlbumPageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMyAlbumPageVC.h"
#import "ESMyAlbumListModule.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESBaseViewController+Status.h"
#import "ESAlbumInfoEditeVC.h"
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshStateHeader.h"
#import "ESSmartPhotoAsyncManager.h"

@interface ESMyAlbumPageVC ()

//@property (nonatomic, strong, readwrite) UICollectionView *listView;
//@property (nonatomic, strong, readwrite) ESMyAlbumListModule *listModule;

@end

@implementation ESMyAlbumPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    
    NSArray<ESAlbumModel *> *albumList = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeUserCreated];
    
    [self showEmpty:albumList.count <= 0];
    [self.listModule reloadData:albumList];
    
    self.title = NSLocalizedString(@"album_my", @"我的相簿");
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"add_album"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(addAlbumAction:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

//- (void)loadMyAlbumData {
//    weakfy(self)
//    [ESSmartPhotoAsyncManager.shared loadAlbumsInfo:^{
//        strongfy(self)
//       
//    }];
//}

- (void)reloadAlbumData {
    NSArray<ESAlbumModel *> *albumList = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeUserCreated];
    
    [self showEmpty:albumList.count <= 0];
    [self.listModule reloadData:albumList];
}

- (void)addAlbumAction:(id)sender {
    ESAlbumInfoEditeVC *vc = [[ESAlbumInfoEditeVC alloc] init];
    vc.editeType = ESAlbumInfoEditeTypeAddAlbum;
    [self.navigationController pushViewController:vc animated:YES];
}

- (Class)listModuleClass {
    return ESMyAlbumListModule.class;
}

#pragma mark - Empty

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_icon"];
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"album_newDes", @"还没有相簿，快去创建吧~");
}

@end
