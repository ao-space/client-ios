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
//  ESAuthenticationTypeController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthenticationTypeController.h"
#import <Masonry/Masonry.h>
#import "UIColor+ESHEXTransform.h"
#import "UIFont+ESSize.h"
#import "ESHardwareVerificationController.h"
#import "ESToast.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "ESAuthenticationTypeCell.h"
#import "NSArray+ESTool.h"
#import "ESSecurityPasswordInputForEmailController.h"
#import "ESReTransmissionManager.h"
#import "ESBindSecurityEmailBySecurityCodeController.h"
#import "ESVerifySecurityEmailController.h"
#import "ESBindSecurityEmailByEmailController.h"
#import "ESSecurityPasswordResetController.h"
#import "ESSecurityPasswordResetByEmailController.h"
#import "ESBindSecurityEmailByHardwareController.h"
#import "ESHardwareVerificationForDockerBoxController.h"

@implementation ESBtidModel

@end

@interface ESAuthenticationTypeController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ESAuthenticationTypeModel *> * dataArr;

@end

@implementation ESAuthenticationTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Authentication", @"身份验证");
    [self initData];
    [self.tableView reloadData];
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    if (self.authType == ESAuthenticationTypeBinderResetPassword
        || self.authType == ESAuthenticationTypeAutherResetPassword) {
        [self initDataForBinderResetPassword];
    } else if (self.authType == ESAuthenticationTypeBinderSetEmail || self.authType == ESAuthenticationTypeAutherSetEmail) {
        [self initDataForSetEmail];
    } else if (self.authType == ESAuthenticationTypeBinderModifyEmail || self.authType == ESAuthenticationTypeAutherModifyEmail) {
        [self initDataForModifyEmail];
    }
}

- (void)initDataForBinderResetPassword {
    weakfy(self);
    NSString * title = NSLocalizedString(@"Mode 1", @"方式一");
    
    ESAuthenticationTypeModel * model = [[ESAuthenticationTypeModel alloc] init];
    model.title = title;
    model.content = NSLocalizedString(@"Hardware device verification", @"硬件设备验证");
    model.imageName = @"auth_by_hardware";
    model.onClick = ^{
        [self onHardwareAuth];
    };
    [self.dataArr addObject:model];
}

- (void)initDataForSetEmail {
    weakfy(self);
    {
        ESAuthenticationTypeModel * model = [[ESAuthenticationTypeModel alloc] init];
        model.title = NSLocalizedString(@"Mode 1", @"方式一");
        model.content = NSLocalizedString(@"Secure Password Authentication", @"安全密码验证");
        model.imageName = @"auth_by_securitypassword";
        model.onClick = ^{
            [weak_self onSecurityPasswordAuth];
        };
        [self.dataArr addObject:model];
    }
    {
        ESAuthenticationTypeModel * model = [[ESAuthenticationTypeModel alloc] init];
        model.title = NSLocalizedString(@"Mode 2", @"方式二");
        model.content = NSLocalizedString(@"Hardware device verification", @"硬件设备验证");
        model.imageName = @"auth_by_hardware";
        model.onClick = ^{
            [weak_self onHardwareAuth];
        };
        [self.dataArr addObject:model];
    }
}

- (void)initDataForModifyEmail {
    weakfy(self);
    {
        ESAuthenticationTypeModel * model = [[ESAuthenticationTypeModel alloc] init];
        model.title = NSLocalizedString(@"Mode 1", @"方式一");
        model.content = NSLocalizedString(@"Confidential email verification", @"密保邮箱验证");
        model.imageName = @"auth_by_email";
        model.onClick = ^{
            ESVerifySecurityEmailController * ctl = [[ESVerifySecurityEmailController alloc] init];
            ctl.oldEmailAccount = weak_self.emailInfo.emailAccount;
            ctl.verifySecurityEmailBlock = ^(int code, NSString * _Nonnull expiredAt, NSString * _Nonnull securityToken) {
                [weak_self.navigationController popToViewController:weak_self animated:NO];
                if (code == 0) {
                    ESBindSecurityEmailByEmailController * ctl = [[ESBindSecurityEmailByEmailController alloc] init];
                    ctl.authType = weak_self.authType;
                    ctl.expiredAt = expiredAt;
                    ctl.securityToken = securityToken;
                    [weak_self.navigationController pushViewController:ctl animated:YES];
                }
            };
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [self.dataArr addObject:model];
    }
    {
        ESAuthenticationTypeModel * model = [[ESAuthenticationTypeModel alloc] init];
        model.title = NSLocalizedString(@"Mode 2", @"方式二");
        model.content = NSLocalizedString(@"Secure Password Authentication", @"安全密码验证");
        model.imageName = @"auth_by_securitypassword";
        model.onClick = ^{
            [self onSecurityPasswordAuth];
        };
        [self.dataArr addObject:model];
    }
    {
        ESAuthenticationTypeModel * model = [[ESAuthenticationTypeModel alloc] init];
        model.title = NSLocalizedString(@"Mode 3", @"方式三");
        model.content = NSLocalizedString(@"Hardware device verification", @"硬件设备验证");
        model.imageName = @"auth_by_hardware";
        model.onClick = ^{
            [self onHardwareAuth];
        };
        [self.dataArr addObject:model];
    }
}

- (void)onSecurityPasswordAuth {
    if ([[ESReTransmissionManager Instance] failedEventIsResume:ESSecurityPasswordInputFailedTimes distance:60] == NO) {
        ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        return;
    }
    ESSecurityPasswordInputForEmailController * ctl = [[ESSecurityPasswordInputForEmailController alloc] init];
    ctl.authType = self.authType;
    ctl.emailInfo = self.emailInfo;
    weakfy(self);
    ctl.securityPasswordBlock = ^(int code, NSString *expiredAt, NSString *securityToken) {
        [weak_self.navigationController popToViewController:weak_self animated:NO];
        if (code == 0) {
            ESBindSecurityEmailBySecurityCodeController * ctl = [[ESBindSecurityEmailBySecurityCodeController alloc] init];
            ctl.expiredAt = expiredAt;
            ctl.securityToken = securityToken;
            ctl.authType = weak_self.authType;
            [weak_self.navigationController pushViewController:ctl animated:YES];
        } else if (code == 1) {
            ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        }
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)onHardwareAuth {
//    [self reqBtid];
    weakfy(self)
    ESHardwareVerificationForDockerBoxController * ctl = [[ESHardwareVerificationForDockerBoxController alloc] init];
    ctl.authType = self.authType;
    ctl.applyRsp = self.applyRsp;
    ctl.searchedBlock = ^(ESAuthenticationType authType, ESBoxBindViewModel * _Nonnull viewModel, ESAuthApplyRsp * _Nonnull applyRsp) {
        [weak_self.navigationController popToViewController:weak_self animated:NO];

        ESSecurityPasswordResetController * ctl = [[ESSecurityPasswordResetController alloc] init];
        ctl.viewModel = viewModel;
        ctl.authType = self.authType;
        ctl.applyRsp = applyRsp;
        [weak_self.navigationController pushViewController:ctl animated:YES];
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)reqBtid {
    weakfy(self);
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    [ESNetworkRequestManager sendCallRequest:@{ServiceName : eulixspaceAccountService,
                                               ApiName : device_hardware_info
                                             } queryParams:nil header:nil body:nil modelName:@"ESBtidModel" successBlock:^(NSInteger requestId, ESBtidModel * response) {
        [ESToast dismiss];
        if (response.btid.length > 0) {
            ESHardwareVerificationController * ctl = [[ESHardwareVerificationController alloc] init];
            ctl.applyRsp = weak_self.applyRsp;
            ctl.authType = weak_self.authType;
            ctl.btid = response.btid;
            [weak_self.navigationController pushViewController:ctl animated:YES];

            
            ctl.searchedBlock = ^(ESAuthenticationType authType, ESBoxBindViewModel * _Nonnull viewModel, ESAuthApplyRsp * _Nonnull applyRsp) {
                [weak_self.navigationController popToViewController:weak_self animated:NO];
                
                if (self.authType == ESAuthenticationTypeBinderResetPassword
                    || self.authType == ESAuthenticationTypeAutherResetPassword) {
                    ESSecurityPasswordResetController * ctl = [[ESSecurityPasswordResetController alloc] init];
                    ctl.authType = authType;
                    ctl.viewModel = viewModel;
                    ctl.applyRsp = applyRsp;
                    [weak_self.navigationController pushViewController:ctl animated:YES];
                } else if (self.authType == ESAuthenticationTypeBinderSetEmail
                           || self.authType == ESAuthenticationTypeBinderModifyEmail
                           || self.authType == ESAuthenticationTypeAutherModifyEmail
                           || self.authType == ESAuthenticationTypeAutherSetEmail) {
                    ESBindSecurityEmailByHardwareController * ctl = [[ESBindSecurityEmailByHardwareController alloc] init];
                    ctl.viewModel = viewModel;
                    ctl.authType = authType;
                    [weak_self.navigationController pushViewController:ctl animated:YES];
                }
            };
            return;
        }

       [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
       [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESAuthenticationTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESAuthenticationTypeCell"];
    ESAuthenticationTypeModel * model = [self.dataArr getObject:indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESAuthenticationTypeModel * model = [self.dataArr getObject:indexPath.row];
    if (model.onClick) {
        model.onClick();
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESAuthenticationTypeCell class] forCellReuseIdentifier:@"ESAuthenticationTypeCell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _tableView;
}

- (void)dealloc {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
