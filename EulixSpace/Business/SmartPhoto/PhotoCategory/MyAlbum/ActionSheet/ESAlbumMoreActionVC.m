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
//  ESAlbumMoreActionVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumMoreActionVC.h"
#import "ESActionSheetItem.h"
#import "ESAlbumActionListModule.h"
#import "NSObject+YYModel.h"

@interface ESAlbumMoreActionVC ()

@end

@implementation ESAlbumMoreActionVC

- (void)showFrom:(UIViewController *)vc {
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, size.height - 330, size.width, 330);
    [super showFrom:vc];
    
    NSArray<ESActionSheetItem *> *actionList = [self actionData];
    if (self.canSelecte == NO && actionList.count > 0) {
        actionList[0].canSelectedType = self.canSelecte;
        actionList[0].unSelecteableIconName = @"album_unable_selecte";
    }
    
    [self.listModule reloadData:actionList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView setTitle:NSLocalizedString(@"common_more", @"更多")];
}

- (Class)listModuleClass {
    return [ESAlbumActionListModule class];
}

- (NSArray<ESActionSheetItem *> *)actionData {
    return  [NSArray yy_modelArrayWithClass:ESActionSheetItem.class json:self.actionDataList];
}

- (NSArray *)actionDataList {
    return @[
        @{@"iconName" : @"sort_menu_ select",
          @"title" : NSLocalizedString(@"Select", @"选择"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(0),
        },
        @{@"iconName" : @"album_add",
          @"title" :  NSLocalizedString(@"home_add", @"添加"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"nextStep" : @(YES),
          @"sortIndex" : @(1),
        },
        @{@"iconName" : @"album_rename",
          @"title" : NSLocalizedString(@"album_name", @"相簿名称"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(2),
        },
        @{@"iconName" : @"delete_item",
          @"title" : NSLocalizedString(@"album_deleteAlbum", @"删除相簿"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"nextStep" : @(YES),
          @"sortIndex" : @(3),
        },
    ];
}

@end
