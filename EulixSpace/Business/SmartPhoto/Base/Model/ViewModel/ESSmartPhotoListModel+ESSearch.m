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
//  ESSmartPhotoListModel+ESSearch.m
//  EulixSpace
//
//  Created by KongBo on 2022/12/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSmartPhotoListModel+ESSearch.h"
#import "ESDateTransferManager.h"
#import "ESPicModel.h"
#import "ESSmartPhotoDataBaseManager.h"

@implementation ESSmartPhotoListModel (ESSearch)

+ (instancetype)reloadDataFromTimeLineData:(NSArray<ESTimelinesItemModel *> *)uuidsUnderDate {
    ESSmartPhotoListModel *model = [[ESSmartPhotoListModel alloc] init];
    NSMutableArray *sections = [NSMutableArray array];
    
    [self addTimeLineWithSections:sections timelineList:uuidsUnderDate];

    if (sections.count > 1) {
        model.sections = sections;
        return model;
    }
    
    ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
    sectoion.sectionTitle =  NSLocalizedString(@"home_all", @"全部");
    sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
    sectoion.blocks = @[];
    [sections addObject:sectoion];
    model.sections = sections;
    return model;
}

+ (void)addTimeLineWithSections:(NSMutableArray *)sections timelineList:(NSArray<ESTimelinesItemModel *> *)uuidsUnderDate{
    if (uuidsUnderDate.count <= 0) {
        return;
    }
    NSArray<ESTimelinesItemModel *> *timeLines = uuidsUnderDate;
    timeLines = [self filterEmptyTimeLineSection:timeLines];
    
    [timeLines enumerateObjectsUsingBlock:^(ESTimelinesItemModel * _Nonnull frameItem, NSUInteger idx, BOOL * _Nonnull stop) {
        ESSmartPhotoListSectionModel *sectoion = [ESSmartPhotoListSectionModel new];
        NSDate *picDate = [[ESDateTransferManager shareInstance] transferByDateString:frameItem.date];
        NSDateComponents *dateComponents = [[ESDateTransferManager shareInstance] getComponentsWithDate:picDate];
        
        NSArray *weekDays = [NSArray arrayWithObjects: @"", @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
        NSString *weekDay =  [weekDays objectAtIndex:dateComponents.weekday];
        sectoion.sectionSubtitle = [NSString stringWithFormat:@"%lu年%lu月%lu日 %@", dateComponents.year, dateComponents.month, dateComponents.day, weekDay];
        sectoion.sectionType = ESSmartPhotoSectionTypeTimelines;
        
        NSMutableArray *blocks = [NSMutableArray array];
        [frameItem.uuids enumerateObjectsUsingBlock:^(ESUUIDItemModel * _Nonnull uuidItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if(uuidItem.uuid.length > 0 && uuidItem.album_ids.count > 0) {
                ESSmartPhotoListBlockModel *block = [ESSmartPhotoListBlockModel new];
                block.blockType = ESSmartPhotoBlockTypeSinglePic;
                ESPicModel *pic = [ESSmartPhotoDataBaseManager.shared getPicByUuid:uuidItem.uuid];
                if (pic != nil && pic.albumIdList.count > 0) {
                    block.items = @[pic];
                    [blocks addObject:block];
                }
            }
        }];
        
        if (blocks.count > 0) {
            sectoion.blocks = blocks;
            [sections addObject:sectoion];
        }
    }];
}

+ (NSArray<ESTimelinesItemModel *> *)filterEmptyTimeLineSection:(NSArray<ESTimelinesItemModel *> *)timeLines {
    NSMutableArray *list = [NSMutableArray array];
    [timeLines enumerateObjectsUsingBlock:^(ESTimelinesItemModel * _Nonnull frameItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (frameItem.uuids.count > 0) {
            [list addObject:frameItem];
        }
    }];
    return [list copy];
}

@end
