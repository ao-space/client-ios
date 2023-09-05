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
//  ESAddPhotoActionSheetListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/2.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumSelectActionSheetListModule.h"
#import "ESAlbumItemCell.h"
#import "ESAddAlbumCell.h"
#import "ESAlbumSelectActionSheet.h"
#import "ESAlbumModel.h"
#import "ESAlbumModifyModule.h"
#import "ESCommentCreateFolder.h"
#import "ESToast.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESIconTitleCell.h"
#import "ESAlbumInfoEditeVC.h"
#import "ESBaseTableVC.h"
#import "UIWindow+ESVisibleVC.h"

@implementation ESAlbumSelectActionSheetListModule

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78.0f;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ESAlbumItemCell class];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 42.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGSize size = [UIScreen mainScreen].bounds.size;
    ESIconTitleCell *inconTitleView = [[ESIconTitleCell alloc] initWithFrame:CGRectMake(0, 0, size.width, 42)];
    inconTitleView.contentView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    inconTitleView.icon.image = [UIImage imageNamed:@"action_sheet_add_album"];
    inconTitleView.titleLabel.text = NSLocalizedString(@"New Album", @"新建相簿");
    inconTitleView.titleLabel.textColor = ESColor.primaryColor;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSectionHeadAction:)];
    [inconTitleView addGestureRecognizer:tapGes];
    return inconTitleView;
}

- (void)touchSectionHeadAction:(id)sender {
    [self createNewAlbum];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.listData.count) {
        return;
    }
    
    ESAlbumModel *album = self.listData[indexPath.row];
    if (![album isKindOfClass:[ESAlbumModel class]]) {
        return;
    }
    id <ESAlbumSelectActionSheetProtocol> actionDelegate = [(ESAlbumSelectActionSheet *)self.actionSheetVC selectAlbumDelegate];
    if ([actionDelegate respondsToSelector:@selector(actionSheet:selectAlbum:)]) {
        [actionDelegate actionSheet:self.actionSheetVC selectAlbum:album];
    }
}

- (void)createNewAlbum {
    ESAlbumInfoEditeVC *vc = [[ESAlbumInfoEditeVC alloc] init];
    vc.editeType = ESAlbumInfoEditeTypeAddAlbumFromActionSheet;
    weakfy(self)
    vc.albumModelCreatedBlock = ^(BOOL success, ESAlbumModel *ablumModel) {
        strongfy(self)
        if (!success) {
            return;
        }
        id <ESAlbumSelectActionSheetProtocol> actionDelegate = [(ESAlbumSelectActionSheet *)self.actionSheetVC selectAlbumDelegate];
        if ([actionDelegate respondsToSelector:@selector(actionSheet:createNewAlbum:)]) {
            [actionDelegate actionSheet:self.actionSheetVC createNewAlbum:ablumModel];
        }
    };
    vc.cancelBlock = ^() {
        id <ESAlbumSelectActionSheetProtocol> actionDelegate = [(ESAlbumSelectActionSheet *)self.actionSheetVC selectAlbumDelegate];
        if ([actionDelegate respondsToSelector:@selector(actionSheet:cancelCreateNewAlbum:)]) {
            [actionDelegate actionSheet:self.actionSheetVC cancelCreateNewAlbum:nil];
        }
    };

    [(ESAlbumSelectActionSheet *)self.actionSheetVC hidden:YES];
    [UIWindow.visibleViewController.navigationController pushViewController:vc animated:YES];
}

@end
