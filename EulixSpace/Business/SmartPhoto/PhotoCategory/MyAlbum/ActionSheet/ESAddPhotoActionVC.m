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
//  ESAddPhotoActionVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAddPhotoActionVC.h"
#import "ESActionSheetItem.h"
#import "ESAlbumActionListModule.h"
#import "NSObject+YYModel.h"

@implementation ESAddPhotoActionVC

- (void)showFrom:(UIViewController *)vc {
    [super showFrom:vc];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, size.height - 260, size.width, 260);
    
    NSArray<ESActionSheetItem *> *actionList = [self actionData];
    [self.listModule reloadData:actionList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView setTitle:NSLocalizedString(@"home_add", @"添加")];
}

- (CGFloat)contentHeight {
    return 260.0f;
}

- (Class)listModuleClass {
    return [ESAlbumActionListModule class];
}

- (NSArray<ESActionSheetItem *> *)actionData {
    return  [NSArray yy_modelArrayWithClass:ESActionSheetItem.class json:self.actionDataList];
}

- (NSArray *)actionDataList {
    return @[
        @{
          @"title" : NSLocalizedString(@"album_add", @"从傲空间添加"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(0),
        },
        @{
          @"title" : NSLocalizedString(@"album_local", @"从本地添加"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(1),
        },
    ];
}

@end
