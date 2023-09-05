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
//  ESAppForceUpgradeViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/15.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAppForceUpgradeViewController.h"
#import "ESFileDefine.h"
#import "ESFormItem.h"
#import "ESMemberManager.h"
#import "ESThemeDefine.h"
#import "ESUpgradeVC.h"
#import "ESVersionInfoView.h"
#import "NSString+ESTool.h"
#import "ESCompatibleCheckRes.h"
#import "ESSapceUpgradeInfoModel.h"

@interface ESAppForceUpgradeViewController ()

@property (nonatomic, strong) ESVersionInfoView *versionInfo;

@end

@implementation ESAppForceUpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hideNavigationBar = YES;
    self.view.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.5];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.info.isAppForceUpdate.boolValue) {
        [self showVersionInfo];
        return;
    }
    if (self.info.isBoxForceUpdate.boolValue) {
        BOOL isAdmin = [ESMemberManager isAdmin];
        if (isAdmin) {
            [self showUncompatibleAdmin];
        } else {
            [self showUncompatibleMember];
        }
    }
}

- (void)showVersionInfo {
    ESCompatibleCheckRes *info = self.info;
    self.versionInfo.force = YES;
    self.versionInfo.hidden = NO;
    ESFormItem *item = [ESFormItem new];
    item.title = TEXT_ME_FOUND_NEW_VERSION;
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:TEXT_ME_LATEST_VERSION, info.lastestAppPkg.pkgVersion];
    [content appendString:@"\n"];
    [content appendFormat:TEXT_ME_VERSION_DESC, info.lastestAppPkg.updateDesc];
    item.content = content;
    [self.versionInfo reloadWithData:item];
    weakfy(self);
    self.versionInfo.actionBlock = ^(id action) {
        strongfy(self);
        self.versionInfo.hidden = YES;
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:info.lastestAppPkg.downloadUrl]
                                         options:@{}
                               completionHandler:^(BOOL success) {
                                   exit(0);
                               }];
    };
}

- (void)showUncompatibleAdmin {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TEXT_ME_UNCOMPATIBLE_TITLE
                                                                   message:TEXT_ME_UNCOMPATIBLE_ADMIN_PROMPT
                                                            preferredStyle:UIAlertControllerStyleAlert];

    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    paragraphStyle.minimumLineHeight = 22;
    paragraphStyle.maximumLineHeight = 22;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attributedMessage = [TEXT_ME_UNCOMPATIBLE_ADMIN_PROMPT es_toAttr:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName: ESColor.labelColor,
        NSParagraphStyleAttributeName: paragraphStyle,

    }];
    [alert setValue:attributedMessage forKey:@"attributedMessage"];
    UIAlertAction *repair = [UIAlertAction actionWithTitle:TEXT_ME_REPAIR_NOW
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       [self upgradeBox];
                                                   }];

    [alert addAction:repair];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)upgradeBox {
    ESUpgradeVC *next = [ESUpgradeVC new];
    ESSapceUpgradeInfoModel *info = [ESSapceUpgradeInfoModel new];
    info.appVersion = self.info.lastestAppPkg.pkgVersion;
    info.pkgSize = FileSizeString(self.info.lastestBoxPkg.pkgSize.floatValue, YES);
    info.packName = self.info.lastestBoxPkg.pkgName;
    info.pckVersion = self.info.lastestBoxPkg.pkgVersion;
    info.desc = self.info.lastestBoxPkg.updateDesc;
    if (self.info.lastestBoxPkg) {
        info.isVarNewVersionExist = YES;
    } else {
        info.isVarNewVersionExist = NO;
    }

    info.desc = self.info.lastestBoxPkg.updateDesc;
    info.upgradeType = ESBoxUpgradeTypeForcexUpgrade;

    [next loadWithUpgradeInfo:info];
    self.killWhenPushed = YES;
    [self.navigationController pushViewController:next animated:YES];
}

- (void)showUncompatibleMember {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TEXT_ME_UNCOMPATIBLE_TITLE
                                                                   message:TEXT_ME_UNCOMPATIBLE_MEMBER_PROMPT
                                                            preferredStyle:UIAlertControllerStyleAlert];

    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    paragraphStyle.minimumLineHeight = 22;
    paragraphStyle.maximumLineHeight = 22;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attributedMessage = [TEXT_ME_UNCOMPATIBLE_MEMBER_PROMPT es_toAttr:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName: ESColor.labelColor,
        NSParagraphStyleAttributeName: paragraphStyle,

    }];
    [alert setValue:attributedMessage forKey:@"attributedMessage"];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_GOT_IT
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       exit(0);
                                                   }];

    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Lazy Load

- (ESVersionInfoView *)versionInfo {
    if (!_versionInfo) {
        _versionInfo = [[ESVersionInfoView alloc] initWithFrame:self.view.window.bounds];
        [self.view.window addSubview:_versionInfo];
    }
    return _versionInfo;
}

@end
