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
//  ESMemoriesDetailMoreActionVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMemoriesDetailMoreActionVC.h"
#import "ESMemoriesDetailMoreActionListModule.h"
#import "ESActionSheetItem.h"
#import "NSObject+YYModel.h"

@interface ESMemoriesDetailMoreActionVC ()

@end

@implementation ESMemoriesDetailMoreActionVC

- (void)showFrom:(UIViewController *)vc {
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, size.height - 280, size.width, 280);
    [super showFrom:vc];
    
    NSArray<ESActionSheetItem *> *actionList = [self actionData];
    if (self.canSelecte == NO && actionList.count > 0) {
        actionList[0].canSelectedType = self.canSelecte;
        actionList[0].unSelecteableIconName = @"album_unable_selecte";
    }
    
    if (actionList.count >= 2) {
        actionList[1].iconName = self.isCollection ? @"memorise_collection" : @"memories_action_unCollection";
        actionList[1].title = self.isCollection ? NSLocalizedString(@"album_cancelCollection", @"取消收藏") : NSLocalizedString(@"album_collMemories", @"收藏回忆");
    }
    [self.listModule reloadData:actionList];
}

- (CGFloat)contentHeight {
    return 280.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView setTitle:NSLocalizedString(@"common_more", @"更多")];
}

- (Class)listModuleClass {
    return [ESMemoriesDetailMoreActionListModule class];
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
        @{@"iconName" : @"memories_action_unCollection",
          @"title" : NSLocalizedString(@"album_collMemories", @"收藏回忆"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"nextStep" : @(YES),
          @"sortIndex" : @(1),
        },
        @{@"iconName" : @"delete_item",
          @"title" : @"删除回忆",
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"nextStep" : @(YES),
          @"sortIndex" : @(3),
        },
    ];
}

@end
