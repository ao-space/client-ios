//
//  ESSpaceAccountInfoModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceKeyInfoModule.h"
#import "ESSpaceAccountKeyCell.h"
#import "ESSpaceIdCell.h"
#import "ESSpaceMainKeyVC.h"
#import "ESDIDDocManager.h"
#import "ESBoxManager.h"

@implementation ESSpaceKeyInfoModule

-(NSArray *)defaultListData {
    ESDIDDocModel *docModel = [[ESDIDDocManager shareInstance] getLatestDIDDocModelByBoxUId:ESBoxManager.activeBox.uniqueKey];
    
    ESSpaceIdItem *spaceIdItem = [ESSpaceIdItem new];
    spaceIdItem.spaceId = [NSString stringWithFormat:@"aospace:%@", [docModel pIdHash]];
    
    ESSpaceAccountKeyItem *mainKeyItem1 = [ESSpaceAccountKeyItem new];
    mainKeyItem1.title = NSLocalizedString(@"account_serverkey", @"傲空间服务器凭证");
    mainKeyItem1.style = ESSpaceAccountKeyCellStyle_Top;
    mainKeyItem1.isSetted = YES;
    mainKeyItem1.hasNextStep = YES;
    mainKeyItem1.actionTag = ESSpaceAccountKeyCellActionTag_MainKey1;
    
    ESSpaceAccountKeyItem *mainKeyItem2 = [ESSpaceAccountKeyItem new];
    mainKeyItem2.title = NSLocalizedString(@"account_boundphonekey", @"绑定手机凭证");
    mainKeyItem2.style = ESSpaceAccountKeyCellStyle_Bottom;
    mainKeyItem2.isSetted = YES;
    mainKeyItem2.hasNextStep = YES;
    mainKeyItem2.actionTag = ESSpaceAccountKeyCellActionTag_MainKey2;

    ESVerificationBaseMethod *method = [docModel getVerificationMethodByType:@"passwordondevice"];
    ESVerificationBaseMethod *method2 = [docModel getVerificationMethodByType:@"passwordonbinder"];

    ESSpaceAccountKeyItem *secondaryKeyItem1 = [ESSpaceAccountKeyItem new];
    secondaryKeyItem1.title = NSLocalizedString(@"account_securepasswordkey" ,@"安全密码凭证");
    secondaryKeyItem1.style = ESSpaceAccountKeyCellStyle_Single;
    secondaryKeyItem1.isSetted =  (method != nil || method2 != nil);
    secondaryKeyItem1.hasNextStep = YES;
    secondaryKeyItem1.actionTag = ESSpaceAccountKeyCellActionTag_SecondaryKey1;
    
    return @[spaceIdItem, mainKeyItem1, mainKeyItem2, secondaryKeyItem1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.listData.count ==  1) {
        return 1;
    }
    if (self.listData.count > 1 && self.listData.count <=3) {
        return 2;
    }
    
    if (self.listData.count > 3) {
        return 3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    if (section == 1) {
        return 2;
    }
    
    if (section == 2) {
        return self.listData.count - 3;
    }
    return 0;
}

- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.listData[indexPath.row];
    }
    
    if (indexPath.section == 1 && self.listData.count > indexPath.row + 1) {
        return self.listData[indexPath.row + 1];
    }
    
    if (indexPath.section == 2 && self.listData.count > indexPath.row + 3) {
        return self.listData[indexPath.row + 3];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 45 + 24;
    }
    
    if (indexPath.section == 1) {
        return 58;
    }
    
    if ( (indexPath.section == 2 && indexPath.row == 0) || (indexPath.section == 2 && self.listData.count >= 4 &&   indexPath.row == self.listData.count - 4) ) {
        return 58;
    }
    
    return 52;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewSection = [[UIView alloc] init];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 200 , 26)];
    title.textColor = ESColor.secondaryLabelColor;
    title.font = ESFontPingFangRegular(14) ;
    title.textAlignment = NSTextAlignmentLeft;
    [viewSection addSubview:title];

    if(section == 0){
        title.font =ESFontPingFangMedium(18);
        title.textColor = ESColor.labelColor;
        title.text = NSLocalizedString(@"account_DID", @"分布式身份标识");
        title.textAlignment = NSTextAlignmentCenter;
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(26);
            make.centerY.mas_equalTo(viewSection.mas_centerY);
            make.centerX.mas_equalTo(viewSection.mas_centerX);
        }];
    } else {
        NSString *titleStr;
        if(section == 1){
            titleStr = NSLocalizedString(@"account_master", @"主凭证");
        } else if(section == 2){
            titleStr = NSLocalizedString(@"account_secondary", @"辅助凭证");
        }
        title.text = titleStr;
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(26);
            make.left.mas_equalTo(viewSection.mas_left).inset(16);
            make.bottom.mas_equalTo(viewSection.mas_bottom).inset(10);
        }];
    }

    return viewSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 65;
    }
    
    if (section == 1) {
        return 66;
    }
    return 56.0f;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [ESSpaceIdCell class];
    }
    return [ESSpaceAccountKeyCell class];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    ESSpaceAccountKeyItem *item;
    if (indexPath.section == 1 && self.listData.count > indexPath.row + 1) {
        item = self.listData[indexPath.row + 1];
    }
    if (indexPath.section == 2 && self.listData.count > indexPath.row + 3) {
        item = self.listData[indexPath.row + 3];
    }
    ESSpaceAccountKeyTypeTag actionTag = item.actionTag;
    if (actionTag == ESSpaceAccountKeyCellActionTag_MainKey1 ||
        actionTag == ESSpaceAccountKeyCellActionTag_MainKey2 ||
        actionTag == ESSpaceAccountKeyCellActionTag_SecondaryKey1) {
        ESSpaceMainKeyVC *vc = [[ESSpaceMainKeyVC alloc] init];
        vc.keyTye = actionTag;
        [self.tableVC.navigationController pushViewController:vc animated:YES];
        return;
    }
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        return YES;
    }
    
    if (indexPath.section == 2 ) {
        if (self.listData.count <= 4) {
            return NO;
        } else if (indexPath.row == 0 || indexPath.row == 1) {
            return YES;
        }
    }
    return NO;
}

@end
