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
//  ESSortSheetVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSortSheetVC.h"
#import "ESSortSheetListModule.h"
#import "ESActionSheetItem.h"
#import "NSObject+YYModel.h"


@interface ESSortSheetVC ()

@end

@implementation ESSortSheetVC


- (void)showFrom:(UIViewController *)vc {
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, size.height - 380, size.width, 380);
    [super showFrom:vc];
}

- (CGFloat)contentHeight {
    return 380.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.listModule reloadData:[self sortData]];
    [self.headerView setTitle:NSLocalizedString(@"common_more", @"更多")];
}

- (void)selectedIndex:(NSInteger)index {
    if (self.listModule.listData.count > (index + 1)) {
        [(ESSortSheetListModule *)self.listModule selectedIndex:(index + 1)];
    }
}

- (Class)listModuleClass {
    return [ESSortSheetListModule class];
}

- (NSArray<ESActionSheetItem *> *)sortData {
    return  [NSArray yy_modelArrayWithClass:ESActionSheetItem.class json:self.sortDataList];
}

- (NSArray *)sortDataList {
    return @[
        @{@"iconName" : @"sort_menu_ select",
          @"title" : NSLocalizedString(@"Select", @"选择"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(0),
        },
        @{@"iconName" : @"",
          @"title" : NSLocalizedString(@"album_mode", @"模式切换"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(1),
          @"isSectionHeader": @(YES),
        },
        @{@"iconName" : @"sort_meu_day",
          @"title" : NSLocalizedString(@"album_day", @"日"),
          @"isSelected" : @(YES),
          @"isSelectedTyple" : @(YES),
          @"sortIndex" : @(2),
          @"selectedIconName": @"sort_meu_day_selected",
        },
        @{@"iconName" : @"sort_menu_moth",
          @"title" : NSLocalizedString(@"album_month", @"月"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(YES),
          @"sortIndex" : @(3),
          @"selectedIconName": @"sort_menu_moth_selected",
        },
        @{@"iconName" : @"sort_menu_year",
          @"title" : NSLocalizedString(@"album_year", @"年"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(YES),
          @"sortIndex" : @(4),
          @"selectedIconName": @"sort_menu_year_selected",
        },
    ];
}
@end

