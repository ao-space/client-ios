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
//  ESSecurityPasswordModifyController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityPasswordModifyController.h"
#import "ESSecurityPasswordModifyCell.h"
#import "ESAccountInfoStorage.h"
#import <Masonry/Masonry.h>
#import "NSArray+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "UIFont+ESSize.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import <YYModel/YYModel.h>
#import "NSError+ESTool.h"
#import "ESToast.h"
#import "ESAuthenticationTypeController.h"
#import "ESBoxManager.h"
#import "ESDIDDocManager.h"

@interface ESSecurityPasswordModifyController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ESCellModel *> * dataArr;
@property (nonatomic, strong) UIButton * forgetPasswordBtn;

@property (nonatomic, weak) ESCellModel * oldPsModel;
@property (nonatomic, weak, getter=theNewPsModel) ESCellModel * newPsModel;
@property (nonatomic, weak) ESCellModel * confirmPsModel;

@end

@implementation ESSecurityPasswordModifyController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"modify security password", @"修改安全密码");
    NSString * text = [NSString stringWithFormat:@"%@  ", NSLocalizedString(@"done", @"完成")];
    UIBarButtonItem * doneBtn = [self barItemWithTitle:text selector:@selector(onDoneBtn)];
    doneBtn.tintColor = ESColor.primaryColor;
    self.navigationItem.rightBarButtonItem = doneBtn;
    [self initData];
    [self.tableView reloadData];
}

- (void)dealloc {
    
}

- (void)onDoneBtn {
    NSString * orignalPs = [self.dataArr firstObject].inputValue;
    ESCellModel * model = [self.dataArr getObject:1];
    NSString * nPs = model.inputValue;
    NSString * cPs = [self.dataArr lastObject].inputValue;
    if ([self checkInput:orignalPs nPs:nPs cPs:cPs] == NO) {
        return;
    }
    
    weakfy(self);
    [self.view endEditing:YES];
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"oldPasswd"] = orignalPs;
    params[@"newPasswd"] = nPs;
    
    NSString * apiName = @"";
    if (self.authType == ESAuthenticationTypeBinderModifyPassword) {
        apiName = security_passwd_modify_binder;
    } else if (self.authType == ESAuthenticationTypeAutherModifyPassword) {
        apiName = security_passwd_modify_auther;
        params[@"securityToken"] = self.applyRsp.securityToken;
        params[@"clientUuid"] = self.applyRsp.clientUuid;
        params[@"applyId"] = [NSString stringWithFormat:@"applyId_%f", [[NSDate date] timeIntervalSince1970]];
    } else {
        ESDLog(@"[安保功能] 修改安保密码的类型不对");
    }
    
    [ESNetworkRequestManager sendCallRequest:@{ServiceName : eulixspaceAccountService,
                                               ApiName : apiName
                                             } queryParams:nil header:nil body:params modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        [ESToast dismiss];
        [ESToast toastSuccess:NSLocalizedString(@"Modified successfully", @"修改成功") handle:^{
            [weak_self.navigationController popViewControllerAnimated:YES];
        }];
        [weak_self updateDIDDocInfo];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
        long code = [error errorCode];
        if (code == 403) {
            [ESToast toastError:NSLocalizedString(@"The original password is incorrect", @"原密码错误")];
            weak_self.oldPsModel.inputValue = @"";
            [weak_self.tableView reloadData];
            return;
        }
        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
//        NSString * text = [error errorMessage];
//        [ESToast toastError:text];
    }];
}

- (void)updateDIDDocInfo {
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-agent-service"
                                                    apiName:@"get_did_document"
                                                queryParams:@{@"clientUUID" : ESSafeString(ESBoxManager.clientUUID),
                                                              @"aoId" : ESSafeString(dic[@"aoId"])
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, NSDictionary *_Nullable response) {
        [[ESDIDDocManager shareInstance] saveOrUpdateDIDDocBase64Str:response[@"didDoc"]
                                                encryptedPriKeyBytes:response[@"encryptedPriKeyBytes"]
                                                                 box:box];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
    }];
}

- (BOOL)checkInput:(NSString *)orignalPs nPs:(NSString *)nPs cPs:(NSString *)cPs {
    if (nPs.length != 6 || cPs.length != 6 || orignalPs.length != 6) {
        [ESToast toastError:NSLocalizedString(@"The security password must be 6 digits", @"安全密码必须是6位纯数字")];
        return NO;
    }
    
    if (![nPs isEqualToString:cPs]) {
        [ESToast toastError:NSLocalizedString(@"The contents entered twice are inconsistent, please re-enter", @"两次输入的内容不一致，请重新输入")];
        self.newPsModel.inputValue = @"";
        self.confirmPsModel.inputValue = @"";
        [self.tableView reloadData];
        return NO;
    }
    
    if ([orignalPs isEqualToString:nPs]) {
        [ESToast toastError:NSLocalizedString(@"The new password cannot be the same as the original password, please re-enter", @"新密码不能与原密码相同，请重新输入")];
        return NO;
    }
    return YES;
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.valueType = ESCellModelValueType_TextField;
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        model.title = NSLocalizedString(@"Original password", @"原密码");
        model.placeholderValue = NSLocalizedString(@"security_password_input_prompt", @"6位数字安全密码");
        model.inputValue = @"";
        self.oldPsModel = model;
        [self.dataArr addObject:model];
        model.isCipher = YES;
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.valueType = ESCellModelValueType_TextField;
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        model.title = NSLocalizedString(@"New security password", @"新安全密码");
        model.placeholderValue = NSLocalizedString(@"security_password_input_prompt", @"6位数字安全密码");
        model.inputValue = @"";
        self.newPsModel = model;
        [self.dataArr addObject:model];
        model.isCipher = YES;
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.valueType = ESCellModelValueType_TextField;
        model.valueColor = [UIColor es_colorWithHexString:@"#333333"];
        model.title = NSLocalizedString(@"Repeat new security password", @"重复新安全密码");
        model.placeholderValue = NSLocalizedString(@"Please fill in and confirm again", @"请再次填写确认");
        model.inputValue = @"";
        self.confirmPsModel = model;
        [self.dataArr addObject:model];
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
    }];
    
    if ([ESAccountInfoStorage isAdminOrAuthAccount]) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setTitle:NSLocalizedString(@"Forgot password", @"忘记密码") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor es_colorWithHexString:@"#337AFF"] forState:UIControlStateNormal];
        btn.titleLabel.font = ESFontPingFangRegular(14);
        [v addSubview:btn];
        [btn addTarget:self action:@selector(onForgetPasswordBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(v).offset(26);
            make.top.mas_equalTo(label.mas_bottom).offset(20);
            make.bottom.mas_equalTo(v).offset(-20);
        }];
    }
    
    return v;
}

- (void)onForgetPasswordBtn {
    ESAuthenticationTypeController * ctl = [[ESAuthenticationTypeController alloc] init];
    ctl.emailInfo = self.emailInfo;
    ctl.applyRsp = self.applyRsp;
    if (self.authType == ESAuthenticationTypeBinderModifyPassword) {
        ctl.authType = ESAuthenticationTypeBinderResetPassword;
    } else if (self.authType == ESAuthenticationTypeAutherModifyPassword) {
        // 授权端修改密码时，已经经过授权了，所以进入重置密码的页面时，不需要再授权
        ctl.authType = ESAuthenticationTypeAutherResetPassword;
    } else {
        [ESToast toastInfo:@"类型不对"];
    }
    [self.navigationController pushViewController:ctl animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
