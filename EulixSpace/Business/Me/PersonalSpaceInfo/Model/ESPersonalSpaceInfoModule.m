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
//  ESPersonalSpaceInfoModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESPersonalSpaceInfoModule.h"
#import "ESTitleDetailLeftCell.h"
#import "ESTitleTagLeftCell.h"
#import "ESFormCell.h"
#import "ESLocalizableDefine.h"
#import "ESAccountManager.h"
#import "ESBoxListViewController.h"
#import "ESFormCell.h"
#import "ESGradientButton.h"
#import "ESInfoEditViewController.h"
#import "ESLocalPath.h"
#import "ESThemeDefine.h"
#import "ESBoxItem.h"
#import "ESCommentCachePlistData.h"
#import "ESBoxManager.h"
#import <Masonry/Masonry.h>
#import "ESAccountServiceApi.h"
#import <AVFoundation/AVFoundation.h>
#import "ESPermissionController.h"
#import "ESAccountInfoStorage.h"
#import "ESPersonalSpaceInfoVC.h"
#import "ESAvatarCell.h"
#import "ESSpaceChannelInfoVC.h"

typedef NS_ENUM(NSUInteger, ESPersonalInfoActionTag) {
    ESPersonalInfoActionTagAvatar,
    ESPersonalInfoActionTagNickname,
    ESPersonalInfoActionTagSign,
    ESPersonalInfoActionTagChannel,
    ESPersonalInfoActionTagDomain,
};

@implementation ESPersonalSpaceInfoModule

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return self.listData.count - 3;
}

- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.listData[indexPath.row];
    }
    
    if (indexPath.section == 1 && self.listData.count > indexPath.row + 3) {
        return self.listData[indexPath.row + 3];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * containView = [[UIView alloc] init];
    containView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    return containView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 0 || indexPath.section >= self.listData.count) {
        return 0;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 89 - 14;
    }
    
    return 89;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id <ESNextActionProtocol> item;
    if (indexPath.section == 0) {
        item = self.listData[indexPath.row];
    }
 
    if (indexPath.section == 1 && self.listData.count > indexPath.row + 3) {
        item = self.listData[indexPath.row + 3];
    }
    
    if (!item.hasNextStep) {
        return;
    }
    switch (item.actionTag) {
        case ESPersonalInfoActionTagAvatar: {
            //修改头像    mine.click.switchHead
            [(ESPersonalSpaceInfoVC *)self.tableVC changeAvatar];
        } break;
        case ESPersonalInfoActionTagNickname: {
            //修改昵称    mine.click.changeName
            ESInfoEditViewController *next = [ESInfoEditViewController new];
            next.type = ESInfoEditTypeName;
            next.value = [(id<ESTitleDetailItemProtocol>)item detail];
            ESBoxItem *box = ESBoxManager.activeBox;
            NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
            next.aoid = dic[@"aoId"];
            
            next.updateName = ^(NSString *name) {
                        ESAccountManager.manager.userInfo.personalName = name;
                        box.spaceName = name;
                        box.bindUserName = name;
                      };
            [self.tableVC.navigationController pushViewController:next animated:YES];
        } break;
        case ESPersonalInfoActionTagSign: {
            //修改个性签名    mine.click.changeSignature
            ESInfoEditViewController *next = [ESInfoEditViewController new];
            next.type = ESInfoEditTypeSign;
            next.value = [(id<ESTitleDetailItemProtocol>)item detail];
            ESBoxItem *box = ESBoxManager.activeBox;
            NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
            next.aoid = dic[@"aoId"];
            [self.tableVC.navigationController pushViewController:next animated:YES];
        } break;
        case ESPersonalInfoActionTagChannel: {
            if(ESBoxManager.activeBox.boxType == ESBoxTypeAuth){
                return;
            }
            ESSpaceChannelInfoVC *next = [ESSpaceChannelInfoVC new];
            next.boxItem = ESBoxManager.activeBox;
            next.platformUrl = ESBoxManager.activeBox.platformUrl;
            [self.tableVC.navigationController pushViewController:next animated:YES];
        } break;
        case ESPersonalInfoActionTagDomain: {
//            ESInfoEditViewController *next = [ESInfoEditViewController new];
//            next.type = ESInfoEditTypeDomin;
//            ESBoxItem *box = ESBoxManager.activeBox;
//            NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
//            next.value = dic[@"userDomain"];
//            next.aoid = dic[@"aoId"];
//            [self.tableVC.navigationController pushViewController:next animated:YES];
        } break;
    
            default:
                break;
        }
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [ESAvatarCell class];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [ESTitleTagLeftCell class];
        }
    }
    
    return [ESTitleDetailLeftCell class];
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 && indexPath.row == 2) ||
        (indexPath.section == 1 && indexPath.row == 1) ||
        (indexPath.section == 1 && indexPath.row == 0 && !ESBoxManager.activeBox.enableInternetAccess)) {
        return NO;
    }
    return YES;
}

- (NSArray *)loadData {
    ESAvatarlItem *avatarItem = [ESAvatarlItem new];
    avatarItem.title = TEXT_ME_PERSONAL_AVATAR;
    if (ESAccountManager.manager.avatarPath) {
        avatarItem.image = [UIImage imageWithContentsOfFile:ESAccountManager.manager.avatarPath];
    } else {
        avatarItem.image = IMAGE_ME_AVATAR_DEFAULT;
    }
    avatarItem.hasNextStep = YES;
    
    ESTitleDetailItem *spaceNameItem = [ESTitleDetailItem new];
    spaceNameItem.title = NSLocalizedString(@"binding_spacename", @"空间名称");
    spaceNameItem.detail = ESAccountManager.manager.userInfo.personalName ?: ESBoxManager.activeBox.spaceName;
    spaceNameItem.hasNextStep = YES;
    spaceNameItem.actionTag = ESPersonalInfoActionTagNickname;
    
    ESTitleDetailItem *signItem = [ESTitleDetailItem new];
    signItem.title = TEXT_ME_PERSONAL_SIGN;
    signItem.detail = ESAccountManager.manager.userInfo.personalSign ?: TEXT_ME_PERSONAL_NO_SIGN;
    signItem.hasNextStep = YES;
    signItem.actionTag = ESPersonalInfoActionTagSign;
    
    ESTitleTagItem *tagItem = [ESTitleTagItem new];
    tagItem.title = NSLocalizedString(@"binding_accesschannel", "空间访问通道");
    tagItem.hasNextStep = [ESAccountInfoStorage isAdminAccount];
    tagItem.actionTag = ESPersonalInfoActionTagChannel;
    
    ESTagItem *item = [ESTagItem new];
    item.title = NSLocalizedString(@"network_local", @"局域网");
    item.titleColor = [ESColor colorWithHex:0x43D9AF];
    item.backgroudColor = [ESColor colorWithHex:0xDCFEF4];
    
//    ESTagItem *item2 = [ESTagItem new];
//    item2.title = @"P2P 加速";
//    item2.titleColor = [ESColor colorWithHex:0xEAAE39];
//    item2.backgroudColor = [ESColor colorWithHex:0xFFEFCE];
//    ESTagItem *item2 = [ESTagItem new];
//    item2.title = NSLocalizedString(@"LAN_P2Pacceleration", @"P2P 加速");
//    item2.titleColor = [ESColor colorWithHex:0xEAAE39];
//    item2.backgroudColor = [ESColor colorWithHex:0xFFEFCE];
    
    ESTagItem *item3 = [ESTagItem new];
    item3.title =  NSLocalizedString(@"network_internet", @"互联网");
    item3.titleColor = [ESColor colorWithHex:0x337AFF];
    item3.backgroudColor = [ESColor colorWithHex:0xDFEAFF];
    // 判断互联网是否开启
//    tagItem.tagList = @[item3];
    tagItem.tagList = ESBoxManager.activeBox.enableInternetAccess ? @[item, item3] : @[item];
    
    if (!ESBoxManager.activeBox.enableInternetAccess) {
        return @[avatarItem, spaceNameItem, signItem, tagItem];
    }
    
    ESTitleDetailItem *domainItem = [ESTitleDetailItem new];
    domainItem.title = NSLocalizedString(@"es_internet_domian", @"互联网访问域名");

    NSDictionary *dic = [ESBoxManager cacheInfoForBox:ESBoxManager.activeBox];
    domainItem.detail = dic[@"userDomain"];
//    domainItem.hasNextStep = ![ESAccountInfoStorage isAuthAccount];
    domainItem.actionTag = ESPersonalInfoActionTagDomain;
    return @[avatarItem, spaceNameItem, signItem, tagItem, domainItem];
}

@end
