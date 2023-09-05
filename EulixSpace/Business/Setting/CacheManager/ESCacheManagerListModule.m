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
//  ESCacheManagerListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCacheManagerListModule.h"
#import "ESTitleDetailCell.h"
#import "ESUniversalSelectCell.h"
#import "ESTitleDetailBaseView.h"
#import "ESCacheCleanTools.h"
#import "ESCacheCleanTools+ESBusiness.h"
#import "ESFileDefine.h"

@interface ESSettingCacheTitleDetailItem : NSObject <ESTitleDetailCellModelProtocol>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;

@end

@implementation ESSettingCacheTitleDetailItem

@end

@interface ESSettingCacheSelecteItem : NSObject <ESUniversalSelectCellModelProtocol>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) ESBusinessCacheInfoType caheType;
@property (nonatomic, assign) NSInteger size;

@end

@implementation ESSettingCacheSelecteItem

@end

@interface ESCacheManagerListModule ()

@property (nonatomic, strong) ESSettingCacheTitleDetailItem *totalCacheInfo;

@end


@interface ESCacheManagerListModule ()

@property (nonatomic, copy) NSString *totalCacheSize;
@property (nonatomic, strong) NSMutableArray *selectedIndexList;

@end

@implementation ESCacheManagerListModule

- (void)loadCacheData:(NSArray *)cacheInfoList totalSize:(NSString *)totalSize {
    self.totalCacheSize = totalSize;
    
    NSMutableArray *cacheSelectItemList = [NSMutableArray array];
    [cacheInfoList enumerateObjectsUsingBlock:^(ESBusinessCacheInfoItem * _Nonnull cacheInfoItem, NSUInteger idx, BOOL * _Nonnull stop) {
        ESSettingCacheSelecteItem *item = [ESSettingCacheSelecteItem new];
        item.title = [self typeTransferName:cacheInfoItem];
        item.detail = cacheInfoItem.sizeString;
        item.isSelected = NO;
        item.caheType = cacheInfoItem.caheType;
        item.size = cacheInfoItem.size;
        [cacheSelectItemList addObject:item];
    }];
    
    self.totalCacheInfo.detail = self.totalCacheSize;
    [self reloadData:cacheSelectItemList];
    self.selectedIndexList = [NSMutableArray array];
}

- (NSString *)typeTransferName:(ESBusinessCacheInfoItem *)cacheInfoItem {
    switch(cacheInfoItem.caheType) {
        case ESBusinessCacheInfoTypeApplet: {
            return NSLocalizedString(@"contacts", @"通讯录");
        }
        case ESBusinessCacheInfoTypeFile: {
            return NSLocalizedString(@"home_file", @"文件");
        }
        case ESBusinessCacheInfoTypePhoto: {
            return NSLocalizedString(@"photo", @"相册");
        }
        default: {
            return NSLocalizedString(@"main_other",@"其他");
        }
    }
    return  NSLocalizedString(@"main_other",@"其他");
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 45.0f;
    }
    return 0.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.listData.count <= 0) {
        return 0;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return self.listData.count;
}

- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.totalCacheInfo;
    }
    if (self.listData.count > indexPath.row) {
        return self.listData[indexPath.row];
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        ESTitleDetailBaseView *headerView = [[ESTitleDetailBaseView alloc] initWithFrame:CGRectZero];
        [headerView setTitle: (section == 0 ? NSLocalizedString(@"usage", @"使用量") : NSLocalizedString(@"use_details", @"使用详情"))
                      detail:@""
                   showArrow:NO];
        headerView.titleLabel.font = ESFontPingFangMedium(10);
        headerView.titleLabel.textColor = [ESColor secondaryLabelColor];
        headerView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        return headerView;
    }
    
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = ESColor.secondaryLabelColor;
        label.font = ESFontPingFangRegular(12);
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        [footView addSubview:label];
        
        label.text = NSLocalizedString(@"cache_manage_desc", @"缓存是使用过程中产生的临时数据，相册缓存建议保留，让您在浏览相册的时候体验更佳。");
        CGFloat width = size.width - 26 * 2;
        
        CGSize fitSize = [label.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName : ESFontPingFangRegular(12)}
                                             context:nil].size;
        
        label.frame = CGRectMake(26, 19, width, fitSize.height);
        return footView;
    }
    
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0 && indexPath.row < self.listData.count) {
        
        if ([self.selectedIndexList containsObject:@(indexPath.row)]) {
            [self.selectedIndexList removeObject:@(indexPath.row)];
            ESSettingCacheSelecteItem *preSelectedItem = self.listData[indexPath.row];
            preSelectedItem.isSelected = NO;
            [self.listView reloadData];
        } else {
            
            ESSettingCacheSelecteItem *preSelectedItem = self.listData[indexPath.row];
            if (preSelectedItem.size <= 0) {
                return;
            }
            [self.selectedIndexList addObject:@(indexPath.row)];
            preSelectedItem.isSelected = YES;
            [self.listView reloadData];
        }
        if (self.selectedUpdateBlock) {
            self.selectedUpdateBlock();
        }
    }
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [ESTitleDetailCell class];
    }
    return [ESUniversalSelectCell class];
}

- (ESSettingCacheTitleDetailItem *)totalCacheInfo {
    if (!_totalCacheInfo) {
        _totalCacheInfo = [ESSettingCacheTitleDetailItem new];
        _totalCacheInfo.title = NSLocalizedString(@"used_cache_size", @"已用缓存大小");
    }
    return _totalCacheInfo;
}

- (NSInteger)selectedCount {
    return self.selectedIndexList.count;
}

- (void)cleanSelectedCache:(void(^)(NSString *cleanSize))completionBlock {
    if (self.selectedIndexList.count <= 0) {
        return;
    }
    __block NSInteger finishCount = 0;
    NSString *cleanSize = [self canCleanCacheSize];
    weakfy(self)
    [self.selectedIndexList enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
        strongfy(self)
        if (index.integerValue < self.listData.count) {
            ESSettingCacheSelecteItem *selectedItem = self.listData[index.integerValue];
            [ESCacheCleanTools clearCacheByType:selectedItem.caheType completion:^{
                finishCount++;
                if (finishCount == self.selectedIndexList.count) {
                    [self cleanAllSelect];
                    if (self.selectedUpdateBlock) {
                        self.selectedUpdateBlock();
                    }
                    if (self.cleanFinishBlock) {
                        self.cleanFinishBlock();
                    }
                    if (completionBlock) {
                        completionBlock(cleanSize);
                    }
                }
            }];
        }
    }];
}

- (void)cleanAllCache:(NSString *)cleanSize block:(void(^)(NSString *cleanSize))completionBlock {
    [self.listData enumerateObjectsUsingBlock:^(ESSettingCacheSelecteItem * selectedItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [ESCacheCleanTools clearCacheByType:selectedItem.caheType completion:^{
            [self cleanAllSelect];
            if (self.selectedUpdateBlock) {
                self.selectedUpdateBlock();
            }
            if (self.cleanFinishBlock) {
                self.cleanFinishBlock();
            }
            if (completionBlock) {
                completionBlock(cleanSize);
            }
        }];
    }];
}

- (void)cleanAllSelect {
    weakfy(self)
    [self.selectedIndexList enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
        strongfy(self)
        if (index.integerValue < self.listData.count) {
            ESSettingCacheSelecteItem *selectedItem = self.listData[index.integerValue];
            selectedItem.isSelected = NO;
        }
        [self.listView reloadData];
    }];
     self.selectedIndexList = [NSMutableArray array];
}

- (NSString *)canCleanCacheSize {
    weakfy(self)
    __block NSInteger cacheSize = 0;
    [self.selectedIndexList enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
        strongfy(self)
        if (index.integerValue < self.listData.count) {
            ESSettingCacheSelecteItem *selectedItem = self.listData[index.integerValue];
            cacheSize += selectedItem.size;
        }
    }];
    return FileSizeString(cacheSize, YES);
}

@end

