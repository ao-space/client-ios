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
//  ESShareListVC.m
//  EulixSpace
//
//  Created by qu on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShareListVC.h"
#import "ESShreCell.h"
#import "ESFileLoadingViewController.h"
#import "ESFilePreviewViewController.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import <Masonry/Masonry.h>
#import "ESShreCell.h"
@interface ESShareListVC ()

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isAllSelect;
@property (nonatomic, strong) NSMutableArray *selectInfoArray;


@end

@implementation ESShareListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = ESColor.systemBackgroundColor;
    self.cellClass = [ESShreCell class];
    self.section = @[@(ESFileListSectionDefault)];
    self.isSelectUUIDSArray = [[NSMutableArray alloc] init];
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellSelected:) name:@"cellSelectedNSNotificationShare" object:nil];
}

- (void)cellSelected:(NSNotification *)notifi {
    NSMutableDictionary *dic = notifi.object;
    NSNumber *isSelected = dic[@"isSelected"];
    BOOL isSelect = [isSelected boolValue];
    [self selelctCellClick:isSelect uuid:dic[@"shareId"]];
}


- (void)reloadData {
    
    NSMutableArray *selectedItemArray = [NSMutableArray new];
    NSMutableArray *cellArray = [self.childrenShare yc_mapWithBlock:^id(NSUInteger idx, ESMyShareRsp *data) {
        ESFormItem *item = [ESFormItem new];
        item.height = 106;
        item.identifier = @"ESShreCell";
        item.data = data;
        item.title = data.fileName;
        item.isCopyMove = 0;
        item.category = self.category;
        NSString *uuid = data.shareId;

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
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (self.isSelectUUIDSArray && self.isSelectUUIDSArray.count > 0) {
        [dictionary setValue:self.isSelectUUIDSArray forKey:@"isSelectUUIDSArray"];
    }
    self.selectInfoArray = selectedItemArray;
    if (self.selectInfoArray && self.selectInfoArray.count > 0) {
        [dictionary setValue:selectedItemArray forKey:@"selectedInfoArray"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fileListFolderBottomHiddenShare" object:dictionary];
    // 马上进入刷新状态
    [self.tableView reloadData];
}

- (void)selectedAll:(BOOL)all {
    self.isSelectUUIDSArray = [[NSMutableArray alloc] init];
    [self.dataSource[@(ESFileListSectionDefault)] yc_each:^(ESFormItem *item) {
        item.selected = all;
        if (item.selected) {
            ESMyShareRsp *data = item.data;
            [self.isSelectUUIDSArray addObject:data.shareId];
        }
    }];
    [self reloadData];
}

- (NSArray *)sortArray:(NSArray<ESFileInfoPub *> *)array {
    return array;
}

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESFormItem *item = [self objectAtIndexPath:indexPath];
    ESMyShareRsp *file = item.data;
    NSTimeInterval timer1 = [file.expiredTime doubleValue];
    NSTimeInterval timer2 = [file.boxTime doubleValue];
        
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
    NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:timer1];
 
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:timer2];
   
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:date2 toDate:date1 options:0];

    // 获得某个时间的年月日时分秒
    NSLog(@"差值%ld天,%ld小时%ld分%ld秒",cmps.day ,cmps.hour, cmps.minute,cmps.second);
    if(cmps.day + 1 < 0){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shareVCNSNotificationGQ" object:file.shareId];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareVCNSNotification" object:file.shareId];
    }
}

- (void)selelctCellClick:(BOOL)isSelcted uuid:(NSString *)uuid {
    self.isSelectUUIDSArray = [NSMutableArray new];
    for (ESFormItem *item in self.dataSource[@(ESFileListSectionDefault)]) {
        if (item.selected) {
            ESMyShareRsp *infoData = item.data;
            [self.isSelectUUIDSArray addObject:infoData.shareId];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    ESShreCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"ESShreCellID"]];
    if (cell == nil) {
        cell = [[ESShreCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESShreCellID"];

    }
      
    return cell;
}

@end
