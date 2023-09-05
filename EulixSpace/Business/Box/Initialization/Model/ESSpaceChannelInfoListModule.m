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
//  ESSpaceTunInfoListModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceChannelInfoListModule.h"
#import "ESTitleDetailSwitchCell.h"
#import "ESSpaceChannelInfoVC.h"
#import "ESPlatformClient.h"
#import "ESCommonToolManager.h"

@interface ESSpaceTunInfoListItem : NSObject <ESTitleDetailSwitchListItemProtocol>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSAttributedString *detailAtr;
@property (nonatomic, assign) BOOL isOn ;
@property (nonatomic, assign) ESSwitchType switchType;
@property (nonatomic, strong) NSString * platformAddress;
@property (nonatomic, assign) BOOL isBind;

@end

@implementation ESSpaceTunInfoListItem

@end

@interface ESSpaceChannelInfoVC ()

- (void)trySwitchNetworkTun:(ESTitleDetailSwitchCell *)switchView newValue:(BOOL)value;

@end

@implementation ESSpaceChannelInfoListModule

-(NSArray *)defaultListData {
    ESSpaceTunInfoListItem *item1 = [ESSpaceTunInfoListItem new];
    item1.title = NSLocalizedString(@"binding_LANchannel", @"局域网通道");
    item1.detail = NSLocalizedString(@"binding_IPdirectaccess", @"手机、傲空间设备在同一网络内，通过IP直连访问");
    item1.isOn = YES;
    item1.switchType = ESSwitchTypeText;
    
    BOOL isInternetOn = [(ESSpaceChannelInfoVC *)self.tableVC isInternetOn];
    NSString * platformUrl = [(ESSpaceChannelInfoVC *)self.tableVC platformUrl];
    
    ESSpaceTunInfoListItem *item3 = [ESSpaceTunInfoListItem new];
    item3.title = NSLocalizedString(@"binding_internetaccess" ,@"互联网通道");
    item3.detail = NSLocalizedString(@"binding_end-to-endencrypted", @"开通端对端加密访问通道，随时随地实时访问");
    item3.isOn = isInternetOn;
    item3.switchType = ESSwitchTypeSwitch;
    item3.platformAddress = platformUrl;
    item3.isBind = self.isBind;

    return @[item1, item3];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listData.count > indexPath.section) {
        return self.listData[indexPath.section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 0 || indexPath.section >= self.listData.count) {
        return 0;
    }
    id<ESTitleDetailSwitchListItemProtocol> data = self.listData[indexPath.section];
    if (data.switchType == ESSwitchTypeText) {
        return 91;
    }
    
    CGFloat height = data.isOn ? 158 : 120;
    return [ESCommonToolManager isEnglish] ? height + 22 : height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ESTitleDetailSwitchCell class];
}

- (void)beforeBindData:(id _Nullable)data cell:(ESBaseCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section< 0 || indexPath.section >= self.listData.count) {
        return;
    }
    weakfy(self)
    if ([cell isKindOfClass:[ESTitleDetailSwitchCell class]]) {
        [(ESTitleDetailSwitchCell *)cell setChangedBlock:^(ESTitleDetailSwitchCell *switchView, BOOL newValue) {
            strongfy(self)
            [(ESSpaceChannelInfoVC *)self.tableVC trySwitchNetworkTun:switchView newValue:newValue];
        }];
    }
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    return NO;
}

@end
