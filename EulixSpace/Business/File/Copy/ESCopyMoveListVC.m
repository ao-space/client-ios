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
//  ESCopyMoveListVC.m
//  EulixSpace
//
//  Created by qu on 2021/8/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCopyMoveListVC.h"
#import "ESFileListCell.h"
#import "ESFileLoadingViewController.h"
#import "ESFilePreviewViewController.h"
#import "ESFormItem.h"
#import "ESLocalPath.h"
#import "ESThemeDefine.h"
#import <ESClient/ESFileInfo.h>
#import <MJRefresh/MJRefresh.h>
#import <YCEasyTool/NSArray+YCTools.h>

typedef NS_ENUM(NSUInteger, ESFileListSction) {
    ESFileListSectionDefault,
};
@interface ESCopyMoveListVC ()
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isAllSelect;
@property (nonatomic, strong) NSMutableArray *isSelectUUIDSArray;
@property (nonatomic, strong) NSMutableArray *selectInfoArray;
@end

@implementation ESCopyMoveListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = ESColor.systemBackgroundColor;
    self.cellClass = [ESFileListCell class];
    self.section = @[@(ESFileListSectionDefault)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellSelected:) name:@"cellSelected" object:nil];
    [self reloadData];
    self.isSelectUUIDSArray = [[NSMutableArray alloc] init];
}

- (void)reloadData {
    NSMutableArray *cellArray = [self.children yc_mapWithBlock:^id(NSUInteger idx, ESFileInfo *data) {
        ESFormItem *item = [ESFormItem new];
        item.height = 76;
        item.identifier = @"ESFileListCell";
        item.data = data;
        item.title = data.name;
        for (int i = 0; i < self.isSelectUUIDSArray.count; i++) {
            if (data.uuid == self.isSelectUUIDSArray[i]) {
                item.selected = YES;
            }
        }
        return item;
    }];
    self.dataSource[@(ESFileListSectionDefault)] = cellArray;

    [self.tableView reloadData];

    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:self.isSelectUUIDSArray forKey:@"isSelectUUIDSArray"];

    NSMutableArray *selectedItemArray = [NSMutableArray new];
    for (ESFormItem *item in cellArray) {
        if (item.selected) {
            [selectedItemArray addObject:item.data];
        }
    }
    self.selectInfoArray = selectedItemArray;
    [dictionary setValue:selectedItemArray forKey:@"selectedInfoArray"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fileListBottomHidden" object:dictionary];
    // 马上进入刷新状态
}

- (void)selectedAll:(BOOL)all {
    self.isSelectUUIDSArray = [[NSMutableArray alloc] init];
    [self.dataSource[@(ESFileListSectionDefault)] yc_each:^(ESFormItem *item) {
        item.selected = all;
        if (item.selected) {
            ESFileInfo *data = item.data;
            [self.isSelectUUIDSArray addObject:data.uuid];
        }
    }];
    [self reloadData];
}

- (NSArray *)sortArray:(NSArray<ESFileInfo *> *)array {
    return array;
}

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESFormItem *item = [self objectAtIndexPath:indexPath];
    ESFileInfo *file = item.data;
    //不是文件夹,并且没有选中文件
    if (!file.isDir.boolValue && self.selectInfoArray.count == 0) {
        if (LocalFileExist(file)) {
            ESFilePreview(self, [NSURL fileURLWithPath:LocalPathForFile(file).fullCachePath]);
            return;
        }
        ESFileShowLoading(self, file);
        return;
    }

    if (self.selectInfoArray.count > 0) {
        if (item.selected) {
            item.selected = NO;
        } else {
            item.selected = YES;
        }
        [self selelctCellClick:item.selected uuid:file.uuid];
    } else {
        if (self.selectFile) {
            self.selectFile(file);
        }
    }

    [self reloadIndexPath:indexPath];

    return;
}

- (void)setChildren:(NSArray<ESFileInfo *> *)children {
    _children = children.copy;
    [self reloadData];
}

- (void)enterSelectionMode {
    [self.dataSource[@(ESFileListSectionDefault)] yc_each:^(ESFormItem *item) {
        item.type = ESFileViewSelectionModeIn;
        item.selected = NO;
    }];
    [self.tableView reloadData];
}

- (void)leaveSelectionMode {
    [self.dataSource[@(ESFileListSectionDefault)] yc_each:^(ESFormItem *item) {
        item.type = ESFileViewSelectionModeOut;
        item.selected = NO;
    }];

    [self.tableView reloadData];
}

- (void)cellSelected:(NSNotification *)notifi {
    NSMutableDictionary *dic = notifi.object;
    NSNumber *isSelected = dic[@"isSelected"];
    BOOL isSelect = [isSelected boolValue];
    [self selelctCellClick:isSelect uuid:dic[@"uuid"]];
}

- (void)selelctCellClick:(BOOL)isSelcted uuid:(NSString *)uuid {
    if (isSelcted) {
        BOOL isContain = NO;
        for (NSString *uuidStr in self.isSelectUUIDSArray) {
            if (uuidStr == uuid) {
                isContain = YES;
            }
        }
        if (!isContain) {
            [self.isSelectUUIDSArray addObject:uuid];
        }
    } else {
        [self.isSelectUUIDSArray removeObject:uuid];
    }

    BOOL isBottomHidden;
    if (self.isSelectUUIDSArray.count > 0) {
        isBottomHidden = NO;
    } else {
        isBottomHidden = YES;
    }

    [self reloadData];
}
@end
