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
//  ESDiskInitStartPageModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskInitStartPageModule.h"
#import "ESDiskInitStartPage.h"
#import "ESDiskInfoCell.h"

@interface ESDiskInfoItem : NSObject <ESDiskInfoItemProtocol>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *iconName;

@end

@implementation ESDiskInfoItem

@end

@interface ESDiskInitStartPageModule ()

@property (nonatomic, assign) BOOL isScrollingAnimation;

@end

@implementation ESDiskInitStartPageModule

-(void)loadDataWithDiskModel:(ESDiskListModel *)diskListModel {
    ESDiskInfoItem *item1 = [ESDiskInfoItem new];
    item1.title = @"存储模式";   //NSLocalizedString(@"binding_LANchannel", @"局域网通道");
    item1.detail = diskListModel.raidType == ESDiskStorageModeType_Raid ? @"双盘互备模式" : @"最大容量模式";   //NSLocalizedString(@"binding_IPdirectaccess", @"手机、傲空间设备在同一网络内，通过IP直连访问");
    item1.iconName = @"StorageMode";

    ESDiskInfoItem *item2 = [ESDiskInfoItem new];
    item2.title = @"主存储";   NSLocalizedString(@"LAN_P2Pacceleration", @"P2P 加速") ;
    item2.detail = @"M.2高速存储";   //NSLocalizedString(@"LAN_P2Pacceleration", @"P2P 加速") ;
    item2.iconName = @"PrimaryStorage";

    ESDiskInfoItem *item3 = [ESDiskInfoItem new];
    item3.title =  @"磁盘加密";    //NSLocalizedString(@"binding_internetaccess" ,@"互联网通道");
    item3.detail =  @"是";       //NSLocalizedString(@"binding_end-to-endencrypted", @"开通端对端加密访问通道，随时随地实时访问");
    item3.iconName = @"DiskEncryption";
    [self reloadData:@[item1, item2, item3]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}

- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listData.count > indexPath.row) {
        return self.listData[indexPath.row];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * containView = [[UIView alloc] init];
    ESDiskImagesView *diskImageView = [(ESDiskInitStartPage *)self.tableVC diskImageView];
    ESDiskListModel *diskListModel = [(ESDiskInitStartPage *)self.tableVC diskListModel];
    [containView addSubview:diskImageView];
    [diskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(containView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
    [diskImageView setDiskInfos:diskListModel.diskInfos];
    return containView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 74 + 180 + 15 + 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 0 || indexPath.section >= self.listData.count) {
        return 0;
    }
    
    return 78;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ESDiskInfoCell class];
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static CGFloat offsetY = 0;
    BOOL isUp = offsetY < scrollView.contentOffset.y;
    offsetY = scrollView.contentOffset.y;

    if (self.isScrollingAnimation) {
        return;
    }
    
    if(isUp && scrollView.contentOffset.y > 50 && scrollView.contentOffset.y <= 163) {
        self.isScrollingAnimation = YES;
        [UIView animateWithDuration:0.5 animations:^{
            [scrollView setContentOffset:CGPointMake(0, 183)];
        } completion:^(BOOL finished) {
            self.isScrollingAnimation = NO;
        }];
        self.tableVC.navigationItem.title = NSLocalizedString(@"disk init", @"磁盘初始化");
        return;
    }
    
    if(!isUp && scrollView.contentOffset.y < (163 - 50)) {
        self.isScrollingAnimation = YES;
        [UIView animateWithDuration:0.5 animations:^{
            [scrollView setContentOffset:CGPointMake(0, 0)];
        } completion:^(BOOL finished) {
            self.isScrollingAnimation = NO;
        }];
        
        self.tableVC.navigationItem.title = nil;
    }
}
@end
