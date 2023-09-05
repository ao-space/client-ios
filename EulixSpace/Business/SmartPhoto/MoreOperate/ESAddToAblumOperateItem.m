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
//  ESBottomToolVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAddToAblumOperateItem.h"
#import "ESAlbumSelectActionSheet.h"
#import "ESAlbumModifyModule.h"
#import "ESToast.h"

NSNotificationName const ESMoreOperateAddToAlbum = @"ESMoreOperateAddToAlbum";

@interface ESAddToAblumOperateItem () <ESAlbumSelectActionSheetProtocol>

@property (nonatomic, strong) ESAlbumSelectActionSheet *actionSheet;

@end

static ESAddToAblumOperateItem *gAddToAblumOperateItem;

@implementation ESAddToAblumOperateItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
   if (self = [super initWithParentMoreOperateVC:moreOperateVC]) {
       __weak typeof (self) weakSelf = self;
       self.actionBlock = ^() {
           __strong typeof(weakSelf) self = weakSelf;
           [self showAddToAlbumDialog];
       };
       gAddToAblumOperateItem = self;
   }
   return self;
}

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    [self.selectedModule updateSelectedList:selectedList];
}

- (NSString *)title {
    return NSLocalizedString(@"Add to", @"添加到");
}

- (NSString *)iconName {
   return @"save_to_ablum";
}

- (void)showAddToAlbumDialog {
    [self.actionSheet hidden:YES];
    ESAlbumSelectActionSheet *actionSheet = [[ESAlbumSelectActionSheet alloc] init];
    self.actionSheet = actionSheet;
    actionSheet.selectAlbumDelegate = self;
    actionSheet.needFiltAlbumId = self.albumId;
    actionSheet.selectedArray = self.selectedModule.validSelectedInfoArray;
    [actionSheet showFrom:self.parentVC];
}

- (void)hidden {
    [self.actionSheet hidden:NO];
}

- (void)tapBackgroudAction:(UITapGestureRecognizer *)tapGes {
    [self hidden];
}

- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet selectAlbum:(ESAlbumModel *)albumModel {
    if (self.selectedModule.validSelectedUUIDArray.count <= 0 || albumModel.albumId.length <= 0) {
        return;
    }
    [self hidden];

    [ESAlbumModifyModule addPhtotos:self.selectedModule.validSelectedUUIDArray
                            albumId:[albumModel.albumId integerValue]
                            completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
        if(success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ESMoreOperateAddToAlbum object:nil];
            
            if ([self.parentVC respondsToSelector:@selector(tryAsyncData)] ) {
                [self.parentVC tryAsyncData];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ESToast toastSuccess:NSLocalizedString(@"add_success", @"添加成功")];
            });
            if ([self.parentVC respondsToSelector:@selector(finishActionShowNormalStyleWithCleanSelected)] ) {
                [self.parentVC finishActionShowNormalStyleWithCleanSelected];
            }
            return;
        }
        
        if ([error.userInfo[@"code"] isEqual:@(1060)]) {
            [ESToast toastError:@"该文件已在相簿中，请勿重复添加"];
            return;
        }
        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
    }];
}

- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet createNewAlbum:(ESAlbumModel *)albumModel {
    if ([actionSheet isKindOfClass:[ESAlbumSelectActionSheet class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [gAddToAblumOperateItem showAddToAlbumDialog];
        });
       
    }
}

- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet cancelCreateNewAlbum:(ESAlbumModel * _Nullable)albumModel {
    if ([actionSheet isKindOfClass:[ESAlbumSelectActionSheet class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [gAddToAblumOperateItem showAddToAlbumDialog];
        });
       
    }
}
@end
