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
//  ESLikeAlbumPageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESLikeAlbumPageVC.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESBaseViewController+Status.h"
#import "ESLikeListModule.h"

@interface ESLikeAlbumPageVC ()

@end

@implementation ESLikeAlbumPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
    
    NSArray<ESAlbumModel*> *albums = [ESSmartPhotoDataBaseManager.shared getAlbumDataFromDBByType:ESAlbumTypeUserLike];
    if (albums.count > 0 && self.albumModel == nil) {
        self.albumModel = albums[0];
    }
    self.title = NSLocalizedString(@"album_like", @"喜欢");
    self.listView.backgroundColor = ESColor.systemBackgroundColor;
}

- (void)setupSubViews {
 
}

- (Class)listModuleClass {
    return ESLikeListModule.class;
}

- (void)reloadDataByType {
    weakfy(self)
    dispatch_async([ESSmartPhotoAsyncManager shared].requestHandleQueue, ^{
        self.listModule.timeLineType = ESTimelineFrameItemTypeDay;
        ESSmartPhotoListModel *mockModel = [ESSmartPhotoListModel reloadDataFromDBByAlbumCategoryLikeType];
        dispatch_async(dispatch_get_main_queue(), ^{
            strongfy(self)
            if (mockModel.sections.count == 0) {
                [self showEmpty:YES];
                [self showRightBarItem:NO];
            } else {
                [self showEmpty:NO];
                [self showRightBarItem:YES];
            }
            [self.listModule reloadData:mockModel];
            self.listModule.album = self.albumModel;
            self.title = [self.listModule countOfAllPic] > 0 ?
            [NSString stringWithFormat:@"%@(%lu)", NSLocalizedString(@"album_like", @"喜欢"), [self.listModule countOfAllPic]] : NSLocalizedString(@"album_like", @"喜欢");
        });
    });
}

- (void)showRightBarItem:(BOOL)show {
    if (show == NO) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"foot_print_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(selectAction:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)selectAction:(id)sender {
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    [self updateShowStyle];
    return;
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"album_noLike", @"您还没有标记任何喜欢的照片哦~");
}

@end
