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
//  ESTodayInHistoryMoreActionVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/18.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTodayInHistoryMoreActionVC.h"
#import "ESActionSheetItem.h"
#import "ESAlbumActionListModule.h"
#import "NSObject+YYModel.h"
#import "ESSmartPhotoListModel.h"
#import "ESPicModel.h"
#import "ESTodayInHistoryActionModule.h"
#import "ESSmartPhotoDataBaseManager.h"

@interface ESTodayInHistoryMoreActionVC ()

@end

@implementation ESTodayInHistoryMoreActionVC

- (void)showFrom:(UIViewController *)vc {
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, size.height - 320, size.width, 320);
    [super showFrom:vc];
    
    NSArray<ESActionSheetItem *> *actionList = [self actionData];
    if (self.canSelecte == NO && actionList.count > 0) {
        actionList[0].canSelectedType = self.canSelecte;
        actionList[0].unSelecteableIconName = @"album_unable_selecte";
    }
    
    [self.listModule reloadData:actionList];
    [self.listView layoutIfNeeded];
    [self.listView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0  inSection:0]
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
    
}

- (CGFloat)contentHeight {
    return 320.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerView setTitle:NSLocalizedString(@"common_more", @"更多")];
}

- (Class)listModuleClass {
    return [ESTodayInHistoryActionModule class];
}

- (NSArray<ESActionSheetItem *> *)actionData {
    NSArray<ESActionSheetItem *> *deflautActonList = [NSArray yy_modelArrayWithClass:ESActionSheetItem.class json:self.actionDataList];
    NSArray<ESAlbumModel*> *albums = [ESSmartPhotoDataBaseManager.shared getAlbumsFromDBByType:ESAlbumTypeTodayInHistory];
    if (albums.count <= 0) {
        return deflautActonList;
    }
    
    NSMutableArray<ESActionSheetItem *> *actonList = [NSMutableArray arrayWithArray:deflautActonList];
    [albums enumerateObjectsUsingBlock:^(ESAlbumModel * _Nonnull album, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= 3) {
            *stop = YES;
            return;
        }
        ESActionSheetItem *actionItem = [ESActionSheetItem new];
//        ESPicModel *pic = [ESSmartPhotoDataBaseManager.shared getLatestAlbumPicFromDBById:album.albumId];
        NSDate *albumDate = [NSDate dateWithTimeIntervalSince1970:album.createdAt] ;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy年MM月dd日";
        NSString *time = [formatter stringFromDate:albumDate];
        actionItem.title =  time;
//        actionItem.title = [NSString stringWithFormat:@"%lu年%lu月%lu日", pic.date_year, pic.date_month, pic.date_day];
    
        actionItem.isSelected = self.currentTopShowingSection == idx;
        actionItem.isSelectedTyple = YES;
        actionItem.sortIndex = idx + 1;
        
        [actonList addObject:actionItem];
    }];
    
    return actonList;
}

- (NSArray *)actionDataList {
    return @[
        @{@"iconName" : @"sort_menu_ select",
          @"title" : NSLocalizedString(@"Select", @"选择"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(0),
        },
        @{@"iconName" : @"",
          @"title" : NSLocalizedString(@"Date_Switch", @"日期切换"),
          @"isSelected" : @(NO),
          @"isSelectedTyple" : @(NO),
          @"sortIndex" : @(1),
          @"isSectionHeader": @(YES),
        },
    ];
}

@end
