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
//  ESScreenshotAlbumPageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/12/2.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESScreenshotAlbumPageVC.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESBaseViewController+Status.h"
#import "ESSmartPhotoDataBaseManager.h"

@interface ESScreenshotAlbumPageVC ()

@end

@implementation ESScreenshotAlbumPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    NSArray<ESAlbumModel*> *albums = [ESSmartPhotoDataBaseManager.shared getAlbumDataFromDBByType:ESAlbumTypeScreenshot];
    if (albums.count > 0 && self.albumModel == nil) {
        self.albumModel = albums[0];
    }
    self.title = @"截图";
    [self reloadDataByType];
}

- (void)selectAction:(id)sender {
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    [self updateShowStyle];
}

- (void)reloadDataByType {
    weakfy(self)
    dispatch_async([ESSmartPhotoAsyncManager shared].requestHandleQueue, ^{
        self.listModule.timeLineType = ESTimelineFrameItemTypeDay;
        ESSmartPhotoListModel *mockModel = [ESSmartPhotoListModel reloadDataFromDBAlbumId:self.albumModel.albumId];
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
                         [NSString stringWithFormat:@"%@(%lu)", @"截图", [self.listModule countOfAllPic]] : @"截图";
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

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"album_noScreenshots", @"您还没有任何截图哦~");
}

@end
