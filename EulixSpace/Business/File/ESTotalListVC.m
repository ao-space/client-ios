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
//  ESTotalListVC.m
//  EulixSpace
//
//  Created by qu on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTotalListVC.h"
#import "ESFileListCell.h"
#import "ESFileLoadingViewController.h"
#import "ESFilePreviewViewController.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESFileInfoPub.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import "ESImagesPreviewVC.h"
#import "ESSmartPhotoPreviewVC.h"

@interface ESTotalListVC ()
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isAllSelect;
@property (nonatomic, strong) NSMutableArray *selectInfoArray;
@end

FOUNDATION_EXPORT NSString *const ESComeFromSmartPhotoPageTag;

@implementation ESTotalListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = ESColor.systemBackgroundColor;
    self.cellClass = [ESFileListCell class];
    self.section = @[@(ESFileListSectionDefault)];
    self.isSelectUUIDSArray = [[NSMutableArray alloc] init];
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *notificationName = [NSString stringWithFormat:@"cellSelectedNSNotification%@", self.category];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellSelected:) name:notificationName object:nil];

}

- (void)cellSelected:(NSNotification *)notifi {
    NSMutableDictionary *dic = notifi.object;
    NSNumber *isSelected = dic[@"isSelected"];
    BOOL isSelect = [isSelected boolValue];
    [self selelctCellClick:isSelect uuid:dic[@"uuid"]];
}




- (void)cellSelectedSearch:(NSNotification *)notifi {
    NSMutableDictionary *dic = notifi.object;
    NSNumber *isSelected = dic[@"isSelected"];
    BOOL isSelect = [isSelected boolValue];
    [self selelctCellClick:isSelect uuid:dic[@"uuid"]];
}

- (void)reloadData {
    NSMutableArray *selectedItemArray = [NSMutableArray new];
    NSMutableArray *cellArray = [self.children yc_mapWithBlock:^id(NSUInteger idx, ESFileInfoPub *data) {
        ESFormItem *item = [ESFormItem new];
        item.height = 76;
        item.identifier = @"ESFileListCell";
        item.data = data;
        item.title = data.name;
        item.isCopyMove = self.isCopyMove;
        item.category = self.category;
        NSString *uuid = data.uuid;
        
        for (int i = 0; i < self.isSelectUUIDSArray.count; i++) {
            NSString *selectedUUID = self.isSelectUUIDSArray[i];
            if ([uuid isEqualToString:selectedUUID]) {
                item.selected = YES;
                [selectedItemArray addObject:item.data];
            }
        }
        return item;
    }];
    self.dataSource[@(ESFileListSectionDefault)] = cellArray;
    if (!self.isCopyMove) {
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        if (self.isSelectUUIDSArray && self.isSelectUUIDSArray.count > 0) {
            [dictionary setValue:self.isSelectUUIDSArray forKey:@"isSelectUUIDSArray"];
        }
        self.selectInfoArray = selectedItemArray;
        if (self.selectInfoArray && self.selectInfoArray.count > 0) {
            [dictionary setValue:selectedItemArray forKey:@"selectedInfoArray"];
        }
        if (self.category) {
            if ([self.category isEqual:@"Folder"] || [self.category isEqual:@"RecycleBin"] || [self.category isEqual:@"v2FileListVC"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileListFolderBottomHidden" object:dictionary];
            } else {
                if (![self.category isEqual:@"move"] && ![self.category isEqual:@"copy"])
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"fileListBottomHidden" object:dictionary];
            }
        }
    }

    // 马上进入刷新状态
    [self.tableView reloadData];
}

- (void)selectedAll:(BOOL)all {
    self.isSelectUUIDSArray = [[NSMutableArray alloc] init];
    [self.dataSource[@(ESFileListSectionDefault)] yc_each:^(ESFormItem *item) {
        item.selected = all;
        if(item.selected) {
            ESFileInfoPub *data = item.data;
            [self.isSelectUUIDSArray addObject:data.uuid];
        }
    }];
    [self reloadData];
}

- (NSArray *)sortArray:(NSArray<ESFileInfoPub *> *)array {
    return array;
}

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESFormItem *item = [self objectAtIndexPath:indexPath];
    ESFileInfoPub *file = item.data;
    if ([self.category isEqual:@"RecycleBin"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recycleBinActionNSNotification" object:nil];
        return;
    }
    //不是文件夹,并且没有选中文件
    if (!file.isDir.boolValue && self.selectInfoArray.count == 0) {
        if ((IsImageForFile(file) || IsVideoForFile(file))) {
            //相册搜索
            NSArray<ESFormItem *> *formItemList = self.dataSource[@(ESFileListSectionDefault)];
            __block NSMutableArray *imageFiles = [NSMutableArray array];
            [formItemList enumerateObjectsUsingBlock:^(ESFormItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
                ESFileInfoPub *file = item.data;
                if (IsImageForFile(file) || IsVideoForFile(file)) {
                    [imageFiles addObject:file];
                }
            }];
            ESPhotoPreviewWithFiles(self.parentViewController, imageFiles, file.uuid, @"", self.comeFromPhotoSearchPage ? ESComeFromSmartPhotoPageTag : @"");
            return;
        }
        
//        if (IsImageForFile(file)) {
//           NSArray<ESFormItem *> *formItemList = self.dataSource[@(ESFileListSectionDefault)];
//           __block NSMutableArray *imageFiles = [NSMutableArray array];
//           [formItemList enumerateObjectsUsingBlock:^(ESFormItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
//               ESFileInfoPub *file = item.data;
//               if (IsImageForFile(file)) {
//                   [imageFiles addObject:file];
//               }
//           }];
//           if (imageFiles.count > 0) {
//               ESImagesPreview(self.parentViewController, imageFiles, file);
//               return;
//           }
//        }
        
        if (LocalFileExist(file) || IsImageForFile(file) || UnsupportFileForPreview(file)) {
            ESFilePreview(self, file);
            return;
        }
        ///视频 要先下载
        if (IsVideoForFile(file)) {
            ESFileShowLoading(self, file, YES, nil);
            return;
        }
        ESFilePreview(self, file);
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

- (void)setChildren:(NSArray<ESFileInfoPub *> *)children {
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

- (void)selelctCellClick:(BOOL)isSelcted uuid:(NSString *)uuid {
    self.isSelectUUIDSArray = [NSMutableArray new];
    for (ESFormItem *item in self.dataSource[@(ESFileListSectionDefault)]) {
        if (item.selected) {
            ESFileInfoPub *infoData = item.data;
            [self.isSelectUUIDSArray addObject:infoData.uuid];
        }
    }
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

- (void)setCategory:(NSString *)category {
    _category = category;
    NSString *notificationName = [NSString stringWithFormat:@"cellSelectedNSNotification%@", category];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellSelectedSearch:) name:notificationName object:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESFileListCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ESFileListCellID%ld%ld",indexPath.section,indexPath.row]];
    if (cell == nil) {
        cell = [[ESFileListCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESFileListCellID"];

    }
      
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(lpGR:)];
    longPressGR.minimumPressDuration = 1;
    longPressGR.view.tag = indexPath.row;
    cell.tag = indexPath.row;
    [cell addGestureRecognizer:longPressGR];
    
    return cell;
}


-(void)lpGR:(UILongPressGestureRecognizer *)lpGR
{
    if (self.isSelectUUIDSArray.count > 0) {
        return;
    }
    NSMutableArray *children = [[NSMutableArray alloc] init];
    NSMutableArray *isSelectUUIDSArray = [[NSMutableArray alloc] init];
    NSMutableArray *selectedItemArray = [[NSMutableArray alloc] init];
    NSArray *array = [NSArray new];
    array = self.dataSource[@(ESFileListSectionDefault)];
   
    for (int i = 0; i<array.count; i++ ) {
        ESFormItem *item = array[i];
        if(lpGR.view.tag == i){
            item.selected = YES;
            ESFileInfoPub *infoData = item.data;
            [isSelectUUIDSArray addObject:infoData.uuid];
            [selectedItemArray addObject:infoData];
        }
        [children addObject:item];
    }
    self.isSelectUUIDSArray = isSelectUUIDSArray;
    // 马上进入刷新状态
  
    if (!self.isCopyMove) {
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        if (self.isSelectUUIDSArray && self.isSelectUUIDSArray.count > 0) {
            [dictionary setValue:self.isSelectUUIDSArray forKey:@"isSelectUUIDSArray"];
        }
        self.selectInfoArray = selectedItemArray;
        if (self.selectInfoArray && self.selectInfoArray.count > 0) {
            [dictionary setValue:selectedItemArray forKey:@"selectedInfoArray"];
        }
        if (self.category) {
            if ([self.category isEqual:@"Folder"] || [self.category isEqual:@"RecycleBin"] || [self.category isEqual:@"v2FileListVC"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileListFolderBottomHidden" object:dictionary];
            } else {
                if (![self.category isEqual:@"move"] && ![self.category isEqual:@"copy"])
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"fileListBottomHidden" object:dictionary];
            }
        }
    }
    [self.tableView reloadData];
}


@end
