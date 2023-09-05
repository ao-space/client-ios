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
//  ESDeviceOfflineController.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeviceOfflineController.h"
#import "AAPLCustomPresentationController.h"
#import "ESBoxItem.h"
#import "ESQRCodeScanViewController.h"
#import "ESGradientButton.h"
#import "UIColor+ESHEXTransform.h"
#import "ESAccountInfoStorage.h"
#import "ESHomeCoordinator.h"
#import "UIButton+ESTouchArea.h"
#import "ESBoxManager.h"

@interface ESDeviceOfflineController () <UITextViewDelegate>
@property (nonatomic, weak) UIViewController * srcCtl;
@property (nonatomic, strong) ESBoxItem * box;
@property (nonatomic, weak) UIView * mConView;
@property (nonatomic, strong) ESGradientButton * offlineUseBtn;

@end

@implementation ESDeviceOfflineController

+ (void)showDeviceOfflineHintView:(UIViewController *)srcCtl box:(ESBoxItem *)box {
    ESDeviceOfflineController * dstCtl = [[ESDeviceOfflineController alloc] init];
    ESDLog(@"[离线使用] boxuuid:%@, boxType:%lu", box.boxUUID, (unsigned long)box.boxType);
    dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    dstCtl.srcCtl = srcCtl;
    dstCtl.box = box;
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

- (void)onOfflineUseBtn {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [ESBoxManager onActive:self.box];
        [ESHomeCoordinator showHome];
    }];
}

- (void)setupViews {
    UIView * mConView = self.mConView;
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"device_offline_hint"]];
    [mConView addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(mConView).offset(20);
        make.centerX.mas_equalTo(mConView);
    }];
    
    UIButton * closeBtn = [[UIButton alloc] init];
    [closeBtn setEnlargeEdge:UIEdgeInsetsMake(10, 10, 10, 10)];
    [closeBtn setImage:[UIImage imageNamed:@"common_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [mConView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(mConView).offset(20);
        make.right.mas_equalTo(mConView).offset(-20);
        make.width.height.mas_equalTo(16);
    }];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"device offline", @"设备已离线");
    label.font = ESFontPingFangMedium(18);
    label.textColor = [UIColor es_colorWithHexString:@"#333333"];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [mConView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iv.mas_bottom).offset(12);
        make.left.mas_equalTo(mConView).offset(30);
        make.right.mas_equalTo(mConView).offset(-30);
    }];
    
    UILabel * label1 = [[UILabel alloc] init];
    label1.text = NSLocalizedString(@"es_check_net_is_working", @"请检查设备的网络是否正常。");
    label1.font = ESFontPingFangRegular(14);
    label1.textColor = [UIColor es_colorWithHexString:@"#333333"];
    label1.numberOfLines = 0;
    [mConView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom).offset(16);
        make.left.mas_equalTo(mConView).offset(30);
        make.right.mas_equalTo(mConView).offset(-30);
    }];
    
    [self.offlineUseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(mConView).offset(35);
        make.right.mas_equalTo(mConView).offset(-35);
        make.top.mas_equalTo(label1.mas_bottom).offset(30);
        make.height.mas_equalTo(44);
    }];
    
    UILabel * label2 = [[UILabel alloc] init];
    label2.text = NSLocalizedString(@"es_check_net_offline_hint", @"* 离线访问已下载或缓存的数据");
    label2.font = ESFontPingFangRegular(14);
    label2.textColor = [UIColor es_colorWithHexString:@"#333333"];
    label2.numberOfLines = 0;
    [mConView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.offlineUseBtn.mas_bottom).offset(16);
        make.left.mas_equalTo(mConView).offset(30);
        make.right.mas_equalTo(mConView).offset(-30);
        make.bottom.mas_equalTo(mConView).offset(-30);
    }];
}

- (ESGradientButton *)offlineUseBtn {
    if (!_offlineUseBtn) {
        ESGradientButton * netSetBtn = [[ESGradientButton alloc] init];
        [netSetBtn addTarget:self action:@selector(onOfflineUseBtn) forControlEvents:UIControlEventTouchUpInside];
        [netSetBtn setCornerRadius:10];
        [netSetBtn setTitle:NSLocalizedString(@"offline use", @"离线使用") forState:UIControlStateNormal];
        [self.mConView addSubview:netSetBtn];
        _offlineUseBtn = netSetBtn;
    }
    return _offlineUseBtn;
}


- (UIView *)mConView {
    if (!_mConView) {
        UIView * mConView = [[UIView alloc] init];
        mConView.layer.masksToBounds = YES;
        mConView.layer.cornerRadius = 10;
        mConView.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:mConView];
        [mConView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(53);
            make.right.mas_equalTo(self.view).offset(-53);
            make.center.mas_equalTo(self.view);
        }];
        _mConView = mConView;
    }
    return _mConView;
}


- (void)dealloc {
    
}


@end
