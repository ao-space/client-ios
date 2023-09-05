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
//  ESAddPhoto2AlbumActionSheet.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/2.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumSelectActionSheet.h"
#import "ESAlbumSelectActionSheetListModule.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESBaseViewController+Status.h"
#import "ESPicModel.h"

@interface ESAlbumSelectActionSheet ()

@end

@implementation ESAlbumSelectActionSheet


- (void)showFrom:(UIViewController *)vc {
    if (self.view.superview) {
        [self hidden:YES];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (_maskView.superview) {
        [_maskView removeFromSuperview];
    }
    _maskView = [[UIView alloc] initWithFrame:window.bounds];
    _maskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.3];
    [window addSubview:_maskView];
    [window addSubview:self.view];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, size.height - 550, size.width, 550);
    
    [self reloadAlbumData];
}

- (void)hidden:(BOOL)immediately {
    if (_maskView.superview) {
        [_maskView removeFromSuperview];
    }
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
}

- (CGFloat)contentHeight {
    return 550.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView setTitle:NSLocalizedString(@"Add to", @"添加到")];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.3];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.view.backgroundColor = ESColor.clearColor;
}

- (void)reloadAlbumData {
    NSArray *albums = [[ESSmartPhotoDataBaseManager shared] getAlbumsFromDBByType:ESAlbumTypeUserCreated];
    NSMutableArray *needFilterAlbumIds = [NSMutableArray array];
    if (self.needFiltAlbumId.length > 0) {
        [needFilterAlbumIds addObject:self.needFiltAlbumId];
    }
    
    if (self.selectedArray.count == 1) { //只有一个文件，需屏蔽掉所有所属相册
        ESPicModel *pic = self.selectedArray[0];
        if ( [pic isKindOfClass:[ESPicModel class]] && pic.albumIdList.count > 0) {
            [needFilterAlbumIds addObjectsFromArray:pic.albumIdList];
        }
    }
    
    NSMutableArray *listData = [NSMutableArray array];
    if (needFilterAlbumIds.count > 0) {
        [albums enumerateObjectsUsingBlock:^(ESAlbumModel  *_Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *albumIdSql = [NSString stringWithFormat:@"#%@#", album.albumId];
            if (![needFilterAlbumIds containsObject:album.albumId]  &&
                ![needFilterAlbumIds containsObject:albumIdSql] ) {
                [listData addObject:album];
            }
        }];
    } else {
        [listData addObjectsFromArray:albums];
    }

    [self.listModule reloadData:listData];
    [self showEmpty:listData.count == 0];
}

- (Class)listModuleClass {
    return [ESAlbumSelectActionSheetListModule class];
}

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_icon"];
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"album_newDes", @"还没有相簿，快去创建吧~");
}

- (CGFloat)emptyViewTopOffset {
    return 200;
}

@end
