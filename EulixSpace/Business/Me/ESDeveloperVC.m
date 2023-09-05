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
//  ESDeveloperVC.m
//  EulixSpace
//
//  Created by qu on 2022/9/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeveloperVC.h"
#import "ESAccountManager.h"
#import "ESFormCell.h"
#import "ESNetworking.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "NSObject+LocalAuthentication.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "NSObject+LocalAuthentication.h"
#import "ESCommonToolManager.h"
#import "ESSwitchoverEnvironmentPointVC.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "ESAuthenticationTypeController.h"
#import "ESSwitchoverEnvironmentPointVC.h"
#import "ESBoxBindViewModel.h"
#import "ESSecurityPasswordInputViewController.h"
#import "ESPassWordCheckVC.h"
#import "ESBoxManager.h"
#import "ESHardwareVerificationForDockerBoxController.h"
#import "UILabel+ESTool.h"

@interface ESDeveloperVC()

@property (strong,nonatomic) UISwitch *systemNews;

@property (strong,nonatomic) UIView *cellView;

@property (strong,nonatomic) UIView *cellViewKFZ;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UILabel * mSwitchPlatformLabel;
@property (nonatomic, strong) UILabel * openInternetHintLabel;

@end

@implementation ESDeveloperVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"me_developer", @"开发者选项");
    self.cellClass = [ESFormCell class];
    self.section = @[@(0)];
    self.tableView.scrollEnabled = NO;

    self.cellView.hidden = YES;
    self.cellViewKFZ.hidden = YES;
    
    //后台进前台通知 UIApplicationDidBecomeActiveNotification
    [self addSwitch];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-account-service"
                                                apiName:@"admin_get_dev-options_switch"                                                queryParams:@{}
                                                 header:@{}
                                                   body:@{}
                                              modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        NSDictionary *dic = response;
        if([dic[@"status"] isEqual:@"on"]){
            self.isOn = YES;
        }else{
            self.isOn = NO;
        }
  }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",response);
        self.isOn = NO;

 }];
}


#pragma mark - UI

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30 + 30 + 20 + 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //CGFloat tableHeaderHeight = [self tableView:tableView heightForHeaderInSection:section];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0,ScreenWidth, 30 + 30)];
    return header;
}


- (void)titleLabelClickedWithGes:(UITapGestureRecognizer *)ges {
    if (UIApplicationOpenSettingsURLString != NULL) {
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:URL options:@{} completionHandler:nil];
            [self loadData];
        }
    }
}

- (void)didBecomeActive:(NSNotification *)notification {
    
}

- (void)addSwitch {

    self.systemNews = [[UISwitch alloc] init];
    [self.view addSubview:self.systemNews];
    [self.systemNews addTarget:self
                  action:@selector(systemSwitched:)
        forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.systemNews];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(26, 20, 200, 22)];
    title.text = NSLocalizedString(@"me_developer", @"开发者选项");
    [self.view addSubview:title];
    title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];

    [self.systemNews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-28.0);
        make.top.mas_equalTo(self.view.mas_top).offset(10.0);
        make.height.mas_equalTo(30.0);
        make.width.mas_equalTo(50.0);
    }];
    
   
    
    if(ESBoxManager.activeBox.boxType == ESBoxTypeAuth){
        self.systemNews.enabled = NO;
        self.cellView.hidden = YES;
        [self.cellViewKFZ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).offset(0.0);
            make.right.mas_equalTo(self.view.mas_right).offset(0.0);
            make.top.mas_equalTo(self.systemNews.mas_bottom).offset(10.0);
            make.height.mas_equalTo(44.0);
        }];
    } else {
        self.cellView = [self cellViewWithTitleStr:NSLocalizedString(@"Switch_Space_Platform_Environment", @"切换空间平台环境")];
        [self.view addSubview: self.cellView];
        [self.cellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).offset(0.0);
            make.right.mas_equalTo(self.view.mas_right).offset(0.0);
            make.top.mas_equalTo(self.systemNews.mas_bottom).offset(10.0);
            make.height.mas_equalTo(44.0);
        }];
        self.cellView.hidden = NO;
        UITapGestureRecognizer *cellViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap)];
        [self.cellView addGestureRecognizer:cellViewTap];
        
        self.cellView.hidden = NO;
        
        if (!ESBoxManager.activeBox.enableInternetAccess) {
            self.mSwitchPlatformLabel.textColor = [UIColor es_colorWithHexString:@"#BCBFCD"];
            [self.openInternetHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(self.view).inset(26);
                make.top.mas_equalTo(self.cellView.mas_bottom).offset(10);
            }];
        }
        
    }
}

- (BOOL)needShowSwitchPlatformItem {
//    if (!ESBoxManager.activeBox.enableInternetAccess) {
//        return NO;
//    }
//    if (ESBoxManager.activeBox.deviceAbilityModel.aospaceSwitchPlatformSupport != nil) {
//        return [ESBoxManager.activeBox.deviceAbilityModel.aospaceSwitchPlatformSupport boolValue];
//    }
//
//    if ([ESBoxManager.activeBox.deviceAbilityModel isOnlineTrialBox]) {
//        return NO;
//    }
    return YES;
}

- (void)systemSwitched:(UISwitch *)sender {
   
    NSString *onStr;
    if(sender.on){
        onStr = @"on";
        [self.systemNews setOn:NO];
        ESPassWordCheckVC *next = [ESPassWordCheckVC new];
        next.authType = ESAuthenticationTypeBinderResetPassword;
        weakfy(self);
        next.securityPasswordBlock = ^(int code, NSString *expiredAt, NSString *securityToken) {
            [weak_self.navigationController popToViewController:weak_self animated:NO];
            if (code == 0) {
                [ESToast toastSuccess:@"已开启开发者选项"];
                [self.systemNews setOn:YES];
                self.cellView.hidden = NO;
                self.cellViewKFZ.hidden = NO;
                self.lineView.hidden = NO;
            } else if (code == 1) {
                ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
                [self.systemNews setOn:NO];
                [ESToast toastError:@"开启失败"];
                self.cellView.hidden = YES;
                self.cellViewKFZ.hidden = YES;
                self.lineView.hidden = YES;
            }
        };

        [self.navigationController pushViewController:next animated:YES];
        
    }else{
        onStr = @"off";
        [ESToast toastSuccess:@"已关闭开发者选项"];
        [self.systemNews setOn:NO];
        self.cellView.hidden = YES;
        self.cellViewKFZ.hidden = YES;
        self.lineView.hidden = YES;
    }

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-account-service"
                                                apiName:@"admin_update_dev-options_switch"                                                queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                 header:@{}
                                                       body:@{@"status":onStr}
                                              modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
      
  }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",response);
 }];
    

}

- (UIView *)cellViewWithTitleStr:(NSString *)titleStr {
    UIView *cellView = [[UIView alloc] init];
    
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 19, 16, 16)];
    headImageView.image = [UIImage imageNamed:@"me_arrow"];
    [cellView addSubview:headImageView];
    
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cellView.mas_right).offset(-26.0);
        make.top.mas_equalTo(cellView.mas_top).offset(10.0);
        make.height.mas_equalTo(16.0);
        make.width.mas_equalTo(16.0);
    }];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(58, 20, 200, 22)];
    title.text = titleStr;
    [cellView addSubview:title];
    title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.mSwitchPlatformLabel = title;
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cellView.mas_left).offset(26.0);
        make.top.mas_equalTo(cellView.mas_top).offset(10.0);
        make.height.mas_equalTo(22);
    }];
    
    
    return cellView;
}

//社区版
- (void)cellViewTap {
    if (!ESBoxManager.activeBox.enableInternetAccess) {
        return;
    }
    
    weakfy(self)
    ESHardwareVerificationForDockerBoxController * ctl = [[ESHardwareVerificationForDockerBoxController alloc] init];
    ctl.searchedBlock = ^(ESAuthenticationType authType, ESBoxBindViewModel * _Nonnull viewModel, ESAuthApplyRsp * _Nonnull applyRsp) {
        [weak_self.navigationController popToViewController:weak_self animated:NO];
        
        ESSwitchoverEnvironmentPointVC * ctl = [[ESSwitchoverEnvironmentPointVC alloc] init];
        ctl.viewModel = viewModel;
        [weak_self.navigationController pushViewController:ctl animated:YES];
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

 - (void)setIsOn:(BOOL)isOn{
        _isOn = isOn;
        if (isOn) {
            [self.systemNews setOn:YES];
            self.cellView.hidden = NO;
            self.cellViewKFZ.hidden = NO;
            self.lineView.hidden = NO;
        }else {
            [self.systemNews setOn:NO];
            self.cellView.hidden = YES;
            self.cellViewKFZ.hidden = YES;
            self.lineView.hidden = YES;
        }
 }

- (UILabel *)openInternetHintLabel {
    if (!_openInternetHintLabel) {
        //前往【空间访问通道】页面，打开互联网通道即可使用
        NSString * text = NSLocalizedString(@"es_open_internet_hint", @"");
        UILabel * label = [UILabel createLabel:text font:ESFontPingFangRegular(12) color:@"#333333"];
        [self.view addSubview:label];
        _openInternetHintLabel = label;
    }
    return _openInternetHintLabel;
}
@end
