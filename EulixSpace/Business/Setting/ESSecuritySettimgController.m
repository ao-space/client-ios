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
//  ESSecuritySettimgController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecuritySettimgController.h"
#import <Masonry/Masonry.h>
#import "NSArray+ESTool.h"
#import "ESBoxManager.h"
#import "UIColor+ESHEXTransform.h"
#import "UIFont+ESSize.h"
#import "ESAccountInfoStorage.h"
#import "ESLockSetingVC.h"
#import "ESSecurityPasswordModifyController.h"
#import "ESAccountInfoStorage.h"
#import "UIColor+ESHEXTransform.h"
#import "ESAuthenticationTypeController.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "ESSecurityEmailMamager.h"
#import "ESAuthenticationApplyController.h"
#import "ESReTransmissionManager.h"
#import "ESToast.h"
#import "ESBoxManager.h"
#import "ESSecurityCell.h"
#import "UIViewController+ESTool.h"
#import "ESSpaceKeyInfoVC.h"

@interface ESSecuritySettimgController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, strong) ESCellModel * emailModel;
// 身份验证器对应的 model
@property (nonatomic, strong) ESCellModel * authenticatorModel;
@end

@implementation ESSecuritySettimgController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"security setting", @"安全");
    [self initData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    weakfy(self);
    if ([ESAccountInfoStorage isAdminOrAuthAccount]) {
        [ESSecurityEmailMamager reqSecurityEmailInfo:^(ESSecurityEmailSetModel * _Nonnull model) {
            weak_self.emailInfo = model;
            weak_self.emailModel.value = @"";
            [weak_self.tableView reloadData];
        } notSet:^{
            weak_self.emailInfo = nil;
            weak_self.emailModel.value = NSLocalizedString(@"Unbound", @"未绑定");
            weak_self.emailModel.valueColor = [UIColor es_colorWithHexString:@"#F6222D"];
            [weak_self.tableView reloadData];
        }];
    }
    
    if ([ESAccountInfoStorage isAdminAccount] || [ESAccountInfoStorage isMemberAccount]) {
        [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspaceAccountService apiName:@"auth_totp_authenticator_status" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
            BOOL isSet = [response boolValue];
            if (isSet) {
                weak_self.authenticatorModel.value = @"";
                [weak_self.tableView reloadData];
            } else {
                weak_self.authenticatorModel.value = NSLocalizedString(@"Not set", @"未设置");
                weak_self.authenticatorModel.valueColor = [UIColor es_colorWithHexString:@"#F6222D"];
                [weak_self.tableView reloadData];
            }
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            weak_self.authenticatorModel.value = NSLocalizedString(@"Not set", @"未设置");
            weak_self.authenticatorModel.valueColor = [UIColor es_colorWithHexString:@"#F6222D"];
            [weak_self.tableView reloadData];
        }];
    }
}

#pragma -mark viewmodel jump delegate
- (int)viewModelJump {
    return 1;
}

- (BOOL)needShowSpaceAccount {
    return ESBoxManager.activeBox.supportNewBindProcess &&
    [ESAccountInfoStorage isAdminAccount] ; // 并且带有公私钥 暂时屏蔽成员
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    weakfy(self)
    BOOL showAuthSetting = [ESAccountInfoStorage isAdminAccount] || [ESAccountInfoStorage isMemberAccount];
    if ([self needShowSpaceAccount]) {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"space_account", @"空间账号");
        model.hasArrow = YES;
        weakfy(self)
        model.onClick = ^{
            strongfy(self)
            ESSpaceKeyInfoVC *vc = [[ESSpaceKeyInfoVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
        [self.dataArr addObject:model];
    }
    if ([ESAccountInfoStorage isAdminOrAuthAccount]) {
        {
            ESCellModel * model = [[ESCellModel alloc] init];
            model.title = NSLocalizedString(@"security_password", @"安全密码");
            model.hasArrow = YES;
            model.lastCell = NO;
            model.onClick = ^{
                if ([ESAccountInfoStorage isAuthAccount]) {
                    [weak_self applyAuth:ESAuthenticationTypeAutherModifyPassword];
                    return;
                }
                [weak_self gotoModifyPasswordView:nil type:ESAuthenticationTypeBinderModifyPassword];
            };
            [self.dataArr addObject:model];
        }
    }

    {
        if (ESBoxManager.activeBox.boxType !=ESBoxTypeAuth) {
            ESCellModel * model = [[ESCellModel alloc] init];
            model.title = NSLocalizedString(@"security_lock", @"应用锁");
            model.hasArrow = YES;
            model.lastCell = !showAuthSetting;
            model.onClick = ^{
                ESLockSetingVC * vc = [ESLockSetingVC new];
                [weak_self.navigationController pushViewController:vc animated:YES];
            };
            [self.dataArr addObject:model];
        }
    }
}

- (void)applyAuth:(ESAuthenticationType)authType {
    NSString * key = [[NSString alloc] initWithFormat:@"ESAutherApplyModifyPs_%lu", (unsigned long)authType];
    if ([[ESReTransmissionManager Instance] failedEventIsResume:key distance:60 * 10] == NO) {
        ESToast.networkError(NSLocalizedString(@"retry 10 min later", @"请10分钟后重试")).show();
        return;
    }
    
    weakfy(self);
    [ESAuthenticationApplyController showAuthApplyView:self type:authType block:^(ESAuthApplyRsp * applyRsp) {
        if (applyRsp.accept) {
            [weak_self gotoModifyPasswordView:applyRsp type:authType];
        }
    } cancel:^{
        [[ESReTransmissionManager Instance] addFailedEvent:key distance:60 * 10 max:3];
    }];
}

- (void)gotoModifyPasswordView:(ESAuthApplyRsp *)applyRsp type:(ESAuthenticationType)authType {
    ESDLog(@"[安保功能] 执行跳转到修改密码的页面 %@", self.navigationController);

    ESSecurityPasswordModifyController * ctl = [[ESSecurityPasswordModifyController alloc] init];
    ctl.authType = authType;
    ctl.applyRsp = applyRsp;
    ctl.emailInfo = self.emailInfo;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    if ([ESAccountInfoStorage isAdminOrAuthAccount]) {
//        UIView * v = [[UIView alloc] init];
//        v.backgroundColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
//        UILabel * label = [[UILabel alloc] init];
//        label.numberOfLines = 0;
//        label.textColor = [UIColor es_colorWithHexString:@"#85899C"];
//        /*
//         这些信息可用于验证确实是您本人在操作，保障您的数据安全。傲空间不会存储您的密保邮箱密码，仅用于登录验证。\n以下场景需要验证是否为管理员本人操作：\n1.重置安全密码；\n2.解绑设备；\n3.数据恢复；\n4.其他更多需要身份验证的场景。
//         */
//        label.text = NSLocalizedString(@"modify security password hint", @"");
//        label.font = ESFontPingFangRegular(12);
//        [v addSubview:label];
//
//        [label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(v).offset(26);
//            make.right.mas_equalTo(v).offset(-26);
//            make.top.mas_equalTo(v).offset(20);
//            make.bottom.mas_equalTo(v).offset(-20);
//        }];
//        return v;
//    }
//
//    return [UIView new];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESSecurityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    ESCellModel * model = [self.dataArr getObject:indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellModel * model = [self.dataArr getObject:indexPath.row];
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
        [tableView registerClass:[ESSecurityCell class] forCellReuseIdentifier:@"cell"];
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
