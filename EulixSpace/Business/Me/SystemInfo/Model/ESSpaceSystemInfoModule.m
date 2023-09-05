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
//  ESSpaceSystemInfoModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSpaceSystemInfoModule.h"
#import "ESSystemInfoCell.h"
#import "ESSystemInfoSectionView.h"

typedef NS_ENUM(NSUInteger, ESSpaceSystemInfoSectionType) {
    ESSpaceSystemInfoSectionTypeBaseInfo = 0,
    ESSpaceSystemInfoSectionTypeServiceInfo = 1,
};

@interface ESSystemInfoSection : NSObject

@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, assign) ESSpaceSystemInfoSectionType sectionType;
@property (nonatomic, copy) NSArray *infoItems;

@end

@interface ESSystemInfoDetailItem : NSObject

@property (nonatomic, strong) NSString *infoTitle;
@property (nonatomic, strong) NSString *infoDetail;

@end

@implementation ESSystemInfoSection

@end

@implementation ESSystemInfoDetailItem

@end

@interface ESSpaceSystemInfoModule ()

@property (nonatomic, copy) NSDictionary *listDic;

@end


@implementation ESSpaceSystemInfoModule


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESSystemInfoSection *sectionItem = self.listDic[@(section)];
    if (!sectionItem) {
        return nil;
    }
    ESSystemInfoSectionView *setcionView = [[ESSystemInfoSectionView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0)];
    setcionView.titleLabel.text = sectionItem.sectionName;
    return setcionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listDic.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ESSystemInfoSection *sectionItem = self.listDic[@(section)];
    return sectionItem.infoItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESSystemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                 @"ESSystemInfoCell"];
    if (cell == nil) {
        cell = [[ESSystemInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ESSystemInfoCell"];
    }
    ESSystemInfoSection *section = self.listDic[@(indexPath.section)];
    if (!section || section.infoItems.count <= indexPath.row) {
        return nil;
    }
    
    ESSystemInfoDetailItem *item = section.infoItems[indexPath.row];
    [cell setTitle:item.infoTitle];
    cell.detailLabel.text = item.infoDetail;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell hiddenSeparatorStyleSingleLine:(indexPath.row == (section.infoItems.count - 1) ? YES : NO)];
    
    return cell;
}

- (void)reloadDeviceInfo:(ESDeviceInfoModel *)deviceInfo {
    self.listDic = @{ @(ESSpaceSystemInfoSectionTypeBaseInfo) : [self systemBaseInfoSection:deviceInfo],
                      @(ESSpaceSystemInfoSectionTypeServiceInfo) : [self systemServiceInfoSection:deviceInfo],
    };
    [self.listView reloadData];
}

- (ESSystemInfoSection *)systemBaseInfoSection:(ESDeviceInfoModel *)deviceInfo {
    ESSystemInfoSection *section = [ESSystemInfoSection new];
    section.sectionType = ESSpaceSystemInfoSectionTypeBaseInfo;
    section.sectionName =  NSLocalizedString(@"System_A", @"系统");

    ESSystemInfoDetailItem *versionItem = [ESSystemInfoDetailItem new];
    versionItem.infoTitle = NSLocalizedString(@"Version", @"版本");
    NSString *name =  NSLocalizedString(@"device_base_info_box_name_default", @"傲空间");
    versionItem.infoDetail = [NSString stringWithFormat:@"%@ %@",name, deviceInfo.systemInfo.spaceVersion];
    
    ESSystemInfoDetailItem *spaceVersionItem = [ESSystemInfoDetailItem new];
    spaceVersionItem.infoTitle = NSLocalizedString(@"Kernel Version", @"Kernel 版本");

    spaceVersionItem.infoDetail = deviceInfo.systemInfo.osVersion;
    
    section.infoItems = @[versionItem, spaceVersionItem];
    return section;
}

- (ESSystemInfoSection *)systemServiceInfoSection:(ESDeviceInfoModel *)deviceInfo {
    ESSystemInfoSection *section = [ESSystemInfoSection new];
    section.sectionType = ESSpaceSystemInfoSectionTypeServiceInfo;
    section.sectionName = NSLocalizedString(@"Service_A", @"服务");
    
    NSMutableArray *serviceItemsTemp = [NSMutableArray array];
    [deviceInfo.systemInfo.serviceItems enumerateObjectsUsingBlock:^(ESServiceDetailModel * _Nonnull detailItem, NSUInteger idx, BOOL * _Nonnull stop) {
        ESSystemInfoDetailItem *item = [ESSystemInfoDetailItem new];
        item.infoTitle = detailItem.serviceName;
        item.infoDetail = detailItem.version;
        [serviceItemsTemp addObject:item];
    }];
    
    section.infoItems = [serviceItemsTemp copy];
    return section;
}

@end
