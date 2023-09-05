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
//  ESPermissionController.m
//  EulixSpace
//
//  Created by dazhou on 2023/5/4.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESPermissionController.h"
#import "AAPLCustomPresentationController.h"
#import "UIColor+ESHEXTransform.h"
#import "UILabel+ESTool.h"
#import "UIButton+Extension.h"
#import "ESGradientButton.h"
#import "UIViewController+ESTool.h"
#import "UIView+ESTool.h"

@interface ESPermissionController ()
@property (nonatomic, assign) ESPermissionType permissionType;
@property (nonatomic, copy) void (^settingBlock)(void);
@end

@implementation ESPermissionController

+ (void)showPermissionView:(ESPermissionType)type {
    [ESPermissionController showPermissionView:type setting:nil];
}

+ (void)showPermissionView:(ESPermissionType)type setting:(void(^)(void))settingBlock {
    ESPermissionController * dstCtl = [[ESPermissionController alloc] init];
    dstCtl.permissionType = type;
    dstCtl.settingBlock = settingBlock;
    dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    UIViewController * srcCtl = [UIViewController es_getTopViewControler];
    AAPLCustomPresentationController *presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:dstCtl presentingViewController:srcCtl];
    dstCtl.transitioningDelegate = presentationController;
    [srcCtl presentViewController:dstCtl animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor es_colorWithHexString:@"#00000050"];
    
    [self setupViews];
}

- (void)onCloseBtn {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSettingBtn {
    if (self.settingBlock) {
        self.settingBlock();
        return;
    }
    
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)setupViews {
    UIView * conView = [UIView es_create:@"#FFFFFF" radius:10];
    [self.view addSubview:conView];
    [conView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.leading.trailing.mas_equalTo(self.view).inset(52);
    }];
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:[self getHintImage]];
    [conView addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(conView);
    }];
    
    UIButton * closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"permissionClose"] forState:UIControlStateNormal];
    [conView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(conView).offset(10);
        make.trailing.mas_equalTo(conView).offset(-10);
        make.width.height.mas_equalTo(24);
    }];
    [closeBtn addTarget:self action:@selector(onCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * text = NSLocalizedString(@"tip_permissions", @"傲空间需要你授予以下权限：");
    UILabel * label = [UILabel createLabel:text font:ESFontPingFangMedium(14) color:@"#333333"];
    [conView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(conView).offset(35);
        make.trailing.mas_equalTo(conView).offset(-35);
        make.top.mas_equalTo(iv.mas_bottom).offset(20);
    }];
    
    UILabel * label1 = [UILabel createLabel:[self getHintContent] font:ESFontPingFangRegular(14) color:@"#85899C"];
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(conView).offset(35);
        make.trailing.mas_equalTo(conView).offset(-35);
        make.top.mas_equalTo(label.mas_bottom).offset(10);
    }];
    
    ESGradientButton * btn = [[ESGradientButton alloc] init];
    [conView addSubview:btn];
    text = NSLocalizedString(@"to set security email", @"去设置");
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    [btn setCornerRadius:10];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(conView).offset(35);
        make.trailing.mas_equalTo(conView).offset(-35);
        make.top.mas_equalTo(label1.mas_bottom).offset(30);
        make.bottom.mas_equalTo(conView).offset(-30);
        make.height.mas_equalTo(44);
    }];
}

- (UIImage *)getHintImage {
    switch (self.permissionType) {
        case ESPermissionTypeBluetooth:
            return [UIImage imageNamed:@"permissionBluetooth"];
        case ESPermissionTypeAlbum:
            return [UIImage imageNamed:@"permissionAlbum"];
        case ESPermissionTypeCamera:
            return [UIImage imageNamed:@"permissionCamera"];
        case ESPermissionTypeAddressBook:
            return [UIImage imageNamed:@"permissionAddressBook"];
        case ESPermissionTypeLocation:
            return [UIImage imageNamed:@"permissionLocation"];
        default:
            return nil;
    }
}

- (NSString *)getHintContent {
    switch (self.permissionType) {
        case ESPermissionTypeBluetooth:
            //蓝牙权限：需要获取蓝牙权限，用于绑定设备、网络设置功能。通过蓝牙来确认您在硬件设备附近，并将配网数据传输给设备。
            return NSLocalizedString(@"tip_bluetoothpermissions", @"");
        case ESPermissionTypeAlbum:
            //照片权限：允许访问所有照片，用于照片上传/下载、相册同步、上传头像、意见反馈功能。
            return NSLocalizedString(@"tip_photopermissions", @"");
        case ESPermissionTypeCamera:
            //相机权限：需要获取相机权限，用于绑定设备、网络设置、扫一扫授权登录、拍照上传头像功能。
            return NSLocalizedString(@"tip_camerapermissions", @"");
        case ESPermissionTypeAddressBook:
            //通讯录权限：需要获取通讯录权限，用于导入联系人功能。
            return NSLocalizedString(@"tip_addressbookpermissions", @"");
        case ESPermissionTypeLocation:
            return NSLocalizedString(@"tip_locationpermissions", @"");
        default:
            return @"";
    }
}

@end
