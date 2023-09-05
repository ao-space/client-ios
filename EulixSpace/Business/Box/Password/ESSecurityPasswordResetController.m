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
//  ESSecurityPasswordResetController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityPasswordResetController.h"
#import "ESSecurityPasswordModifyCell.h"
#import "ESAccountInfoStorage.h"
#import <Masonry/Masonry.h>
#import "NSArray+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "UIFont+ESSize.h"
#import "ESNetworkRequestManager.h"
#import <YYModel/YYModel.h>
#import "UIViewController+ESTool.h"
#import "UIViewController+ESTool.h"
#import "ESGatewayManager.h"
#import "ESSecurityEmailMamager.h"

@interface ESSecurityPasswordResetController ()<UITableViewDelegate,UITableViewDataSource, ESBoxBindViewModelDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ESCellModel *> * dataArr;
@property (nonatomic, weak, getter=theNewPsModel) ESCellModel * newPsModel;
@property (nonatomic, weak) ESCellModel * confirmPsModel;
@end

@implementation ESSecurityPasswordResetController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"security_password_setup", @"设置安全密码");
    NSString * text = [NSString stringWithFormat:@"%@  ", NSLocalizedString(@"done", @"完成")];
    UIBarButtonItem * doneBtn = [self barItemWithTitle:text selector:@selector(onDoneBtn)];
    doneBtn.tintColor = ESColor.primaryColor;
    self.navigationItem.rightBarButtonItem = doneBtn;
    self.viewModel.delegate = self;
    [self initData];
    [self.tableView reloadData];
}


- (void)dealloc {
    
}

- (NSString *)getNewPassword {
    return [self.dataArr firstObject].inputValue;
}

- (NSString *)getConfirmPassword {
    return [self.dataArr lastObject].inputValue;
}

- (void)onDoneBtn {
    NSString * nPs = [self getNewPassword];
    NSString * cPs = [self getConfirmPassword];
    if ([self checkInput:nPs cPs:cPs] == NO) {
        return;
    }
    
    [self.view endEditing:YES];
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);

    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        if (token && token.accessToken.length > 0) {
            [self sendReq:token.accessToken ps:nPs];
            return;
        }
        [ESToast dismiss];
        [ESToast toastError:@"req failed and retry later"];
    }];
}

- (void)sendReq:(NSString *)accessToken ps:(NSString *)ps {
    ESSecurityPasswordResetBinderReq * req = [[ESSecurityPasswordResetBinderReq alloc] init];
    req.serviceName = eulixspace_gateway;
    req.entity.newPasswd = ps;
    req.entity.accessToken = accessToken;
    
    if (self.authType == ESAuthenticationTypeBinderResetPassword) {
        req.apiName = api_security_passwd_reset_binder_local;
        req.apiPath = api_security_passwd_reset_binder_local;
    } else if (self.authType == ESAuthenticationTypeAutherResetPassword) {
        req.apiName = api_security_passwd_reset_auther_local;
        req.apiPath = api_security_passwd_reset_auther_local;
        req.entity.acceptSecurityToken = self.applyRsp.securityToken;
        req.entity.clientUuid = self.applyRsp.clientUuid;
        req.entity.applyId = self.applyRsp.applyId;
    } else {
        [ESToast toastInfo:@"类型不对"];
    }
    
    [self.viewModel sendPassthrough:[req yy_modelToJSONString]];
}

#pragma -mark viewmodel delegate
- (void)viewModelPassthrough:(NSDictionary *)rspDict {
    ESSecurityPasswordResetBinderRsp * rsp = [ESSecurityPasswordResetBinderRsp.class yy_modelWithJSON:rspDict];
    ESBaseResp * realRsp = rsp.results;
    if ([rsp isOK] && [realRsp isOK]) {
        [self resetResult:0];
        return;
    }
    
    [ESToast dismiss];
    long code = [realRsp codeValue];
    [self resetResult:code];
}

- (void)resetResult:(long)code {
    weakfy(self);
    [ESToast dismiss];

    if (code == 0) {
        [ESToast toastSuccess:NSLocalizedString(@"Modified successfully", @"修改成功") handle:^{
            [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(viewModelJump)]) {
                    [weak_self.navigationController popToViewController:obj animated:NO];
                    *stop = YES;
                }
            }];
        }];
        return;
    }
    
    if (code == ESSecurityEmailResult_SECURITY_TOKEN_EXPIRE) {
        // 超时
        [self showAlert:NSLocalizedString(@"operation failed", @"操作失败") message:NSLocalizedString(@"timeout, start again", @"操作超时，请重新开始")];
        return;
    }
    [ESToast toastError:@"req failed and retry later"];
}

- (BOOL)checkInput:(NSString *)nPs cPs:(NSString *)cPs {
    if (nPs.length != 6 || cPs.length != 6) {
        [self showAlert:NSLocalizedString(@"operation failed", @"操作失败") message:NSLocalizedString(@"The security password must be 6 digits", @"安全密码必须是6位纯数字")];
        return NO;
    }
    
    if (![nPs isEqualToString:cPs]) {
        [self showAlert:NSLocalizedString(@"operation failed", @"操作失败") message:NSLocalizedString(@"The two password entries are inconsistent, please re-enter", @"两次密码输入不一致，请重新输入")];
        self.newPsModel.inputValue = @"";
        self.confirmPsModel.inputValue = @"";
        [self.tableView reloadData];
        return NO;
    }
    return YES;
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.valueType = ESCellModelValueType_TextField;
        model.title = NSLocalizedString(@"New security password", @"新安全密码");
        model.placeholderValue = NSLocalizedString(@"security_password_input_prompt", @"6位数字安全密码");
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        [self.dataArr addObject:model];
        self.newPsModel = model;
        model.isCipher = YES;
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.valueType = ESCellModelValueType_TextField;
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        model.title = NSLocalizedString(@"Repeat new security password", @"重复新安全密码");
        model.placeholderValue = NSLocalizedString(@"Please fill in and confirm again", @"请再次填写确认");
        [self.dataArr addObject:model];
        self.confirmPsModel = model;
        model.isCipher = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESSecurityPasswordModifyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESModifySecurityPasswordCell"];
    ESCellModel * model = [self.dataArr getObject:indexPath.row];
    cell.model = model;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    UILabel * label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textColor = [UIColor es_colorWithHexString:@"#85899C"];
    label.text = NSLocalizedString(@"modify security password input hint", @"安全密码为6位数字，只能由管理员设置和修改，请慎重保管此密码。");
    label.font = ESFontPingFangRegular(10);
    [v addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(v).offset(26);
        make.right.mas_equalTo(v).offset(-26);
        make.top.mas_equalTo(v).offset(20);
        make.bottom.mas_equalTo(v).offset(-20);
    }];
    
    return v;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESSecurityPasswordModifyCell class] forCellReuseIdentifier:@"ESModifySecurityPasswordCell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _tableView;
}


@end
