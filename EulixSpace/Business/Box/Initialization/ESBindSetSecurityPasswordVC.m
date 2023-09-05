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
//  ESBindSetSecurityPasswordVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/4.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBindSetSecurityPasswordVC.h"
#import "ESPinCodeTextField.h"
#import "ESCommListHeaderView.h"
#import "UIColor+ESHEXTransform.h"
#import "ESToast.h"
#import "ESSpaceChannelInfoVC.h"
//#import <ESClient/ESApiClient.h>
//#import <ESClient/ESCreateMemberInfo.h>
//#import <ESClient/ESSpaceGatewayMemberAuthingServiceApi.h>
#import "ESSapceWelcomeVC.h"

@interface ESBindSetSecurityPasswordVC ()
@property (nonatomic, strong) ESCommListHeaderView *headerView;
@property (nonatomic, strong) ESPinCodeTextField *pinCodeTextField;
@property (nonatomic, copy) NSString *firstCode;

@end

@implementation ESBindSetSecurityPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
//    self.showBackBt = NO;

    [self setupViews];
    [self.pinCodeTextField becomeFirstResponder];

}

- (void)setupViews {
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(198);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).inset(kTopHeight);
        make.left.right.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.pinCodeTextField];
    [self.pinCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).inset(55);
        make.leading.trailing.mas_equalTo(self.view).inset(26 + 6);
        make.height.mas_equalTo(70);
    }];
}

- (ESCommListHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ESCommListHeaderView alloc] initWithFrame:CGRectMake(0, 0, 400, 180)];
        _headerView.iconImageView.image = [UIImage imageNamed:@"mm"];
        _headerView.titleLabel.text = NSLocalizedString(@"security_password", @"安全密码");
        _headerView.detailLabel.text = NSLocalizedString(@"binding_securitypassword", @"安全密码可保护你的数据安全，也可验证空间所有者\n身份，请慎重保管此密码");

    }
    return _headerView;
}

- (ESPinCodeTextField *)pinCodeTextField {
    if (!_pinCodeTextField) {
        _pinCodeTextField = [ESPinCodeTextField new];
        _pinCodeTextField.digitsCount = 6;
        _pinCodeTextField.tfStyle = ESPinCodeTextFieldStyle_Dot;
        _pinCodeTextField.font = ESFontPingFangMedium(30);
        _pinCodeTextField.emptyDigitBorderColor = [UIColor es_colorWithHexString:@"#333333"];
        _pinCodeTextField.filledDigitBorderColor = [UIColor es_colorWithHexString:@"#333333"];
        _pinCodeTextField.keyboardType = UIKeyboardTypePhonePad;
        [_pinCodeTextField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _pinCodeTextField;
}

- (void)editingChanged:(UITextField *)sender {
    if (sender.text.length < 6) {
        return;
    }
    
    if (self.firstCode.length <= 0) {
        self.firstCode = sender.text;
        _headerView.detailLabel.text = NSLocalizedString(@"binding_enterpassword", @"再次输入密码");
        [self.pinCodeTextField clearText];
        return;
    }
    
    if (![self.firstCode isEqualToString:sender.text]) {
        self.firstCode = nil;
        [self.pinCodeTextField clearText];
        _headerView.detailLabel.text = NSLocalizedString(@"binding_securitypassword", @"安全密码可保护你的数据安全，也可验证空间所有者\n身份，请慎重保管此密码");
        
        [ESToast toastWarning:NSLocalizedString(@"binding_reenterpassword", @"两次输入的内容不一致，\n请重新输入")];
        return;
    }
    
    //走成员绑定流程
    if (self.inviteModel) {
        self.inviteModel.password = self.firstCode;
        [self reqMemberSpaceID];
        return;
    }
    
    self.viewModel.securityPassword = self.firstCode;
    ESSpaceChannelInfoVC *next = [ESSpaceChannelInfoVC new];
    next.viewModel = self.viewModel;
    [self.navigationController pushViewController:next animated:YES];
}

- (void)reqMemberSpaceID {
    // 获取傲空间ID
    
    ESSapceWelcomeVC *vc = [[ESSapceWelcomeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reqAcceptMemberInvite {
//    NSString *tmpBoxUUID = NSUUID.UUID.UUIDString.lowercaseString;
//
//    NSURL *requesetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", [self.inviteModel getSubdomain]]];
//    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
//    ESSpaceGatewayMemberAuthingServiceApi *api = [[ESSpaceGatewayMemberAuthingServiceApi alloc] initWithApiClient:client];
//    [api spaceV1ApiGatewayAuthMemberAcceptGetWithInviteCode:self.inviteModel.invitecode
//                                          completionHandler:^(ESInviteResult *output, NSError *error) {
//        if (error) {
//            ESDLog(@"[成员加入] reqAcceptMemberInvite:%@",error);
//        } else {
//            ESDLog(@"[成员加入] reqAcceptMemberInvite:code:%@, msg:%@", output.code, output.message);
//        }
//        if (!error && [output.code isEqualToString:@"GW-200"]) {
//            self.boxPublicKey = output.boxPublicKey;
//            ///公钥存储到临时boxUUID中
//            [ESRSACenter.defaultCenter addBoxPublicPem:self.boxPublicKey boxUUID:self.tmpBoxUUID];
//            [self reqCreateMember];
//        } else if ([output.code isEqualToString:@"GW-4033"]){
//            [ESToast toastError:NSLocalizedString(@"join_fail_invalid_invite_code", @"链接已失效，请联系管理员重新邀请")];
//            [self.joinBtn stopLoading:@"创建" ];
//        } else {
//            [ESToast toastError:NSLocalizedString(@"Join Fail", @"加入失败")];
//            [self.joinBtn stopLoading:@"创建"];
//        }
//    }];
}

- (void)reqCreateMember {
//    NSURL *requesetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", [self.inviteModel getSubdomain]]];
//    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
//    ESSpaceGatewayMemberAuthingServiceApi *api = [[ESSpaceGatewayMemberAuthingServiceApi alloc] initWithApiClient:client];
//    ESCreateMemberInfo *info = [ESCreateMemberInfo new];
//    info.phoneModel = [ESCommonToolManager judgeIphoneType:@""];
//    NSString *arcRandom16Str = [ESCommonToolManager arcRandom16Str];
//    ///公钥存储到临时boxUUID中
//    ESRSAPair *pair = [ESRSACenter boxPair:self.tmpBoxUUID];
//    if (!pair.publicKey) {
//        [self.joinBtn stopLoading:NSLocalizedString(@"Join Space", @"确认加入")];
//        return;
//    }
//
//    info.clientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
//    info.inviteCode = [pair publicEncrypt:self.inviteModel.invitecode];
//    info.tempEncryptedSecret = [pair publicEncrypt:arcRandom16Str];
//    info.nickName = self.spaceIdTF.text;
//    info.phoneType = @"ios";
//    [api spaceV1ApiGatewayAuthMemberCreatePostWithAoId:self.inviteModel.aoid
//                                                  body:info
//                                     completionHandler:^(ESCreateMemberResult *output, NSError *error) {
//        [self.joinBtn stopLoading:NSLocalizedString(@"Join Space", @"确认加入")];
//        if (error) {
//            ESDLog(@"[成员加入] reqCreateMember:%@",error);
//        } else {
//            ESDLog(@"[成员加入] reqCreateMember:code:%@, msg:%@", output.code, output.message);
//        }
//
//        if (!error && [output.code isEqualToString:@"GW-200"]) {
//            ESCreateMemberResult *result = output;
//            self.authKey = [result.authKey aes_cbc_decryptWithKey:arcRandom16Str iv:output.algorithmConfig.transportation.initializationVector];
//            self.boxUUID = [result.boxUUID aes_cbc_decryptWithKey:arcRandom16Str iv:output.algorithmConfig.transportation.initializationVector];
//            [ESRSACenter.defaultCenter removeBoxPublicPem:self.tmpBoxUUID];
//            ///存储真正的公钥对
//            [ESRSACenter.defaultCenter addBoxPublicPem:self.boxPublicKey boxUUID:self.boxUUID];
//            [ESBoxManager onInviteMember:[ESBoxItem fromInviteMemberWithBoxUUID:self.boxUUID authKey:self.authKey userDomain:output.userDomain aoid:self.inviteModel.aoid]];
//            [ESToast toastSuccess:NSLocalizedString(@"Create_member_success", @"创建成员成功")];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"createMemberNSNotification" object:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"loopUrlChangeNSNotification" object: output.userDomain];
//            });
//
//            [ESPushManager.manager registerDevice:nil];
//            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//        } else if ([output.code isEqualToString:@"GW-4031"]){
//            [ESToast toastError:NSLocalizedString(@"join_fail_member_duplicate", @"您已绑定设备上的其他账号，请勿重复绑定")];
//        } else if ([output.code isEqualToString:@"GW-4032"]){
//            [ESToast toastWarning:NSLocalizedString(@"join_fail_spaceId_illegal", @"空间标识不合法，请重新输入")];
//        } else if ([output.code isEqualToString:@"GW-4033"]){
//            [ESToast toastError:NSLocalizedString(@"join_fail_invalid_invite_code", @"链接已失效，请联系管理员重新邀请")];
//        } else if ([output.code isEqualToString:@"GW-4034"]){
//            [ESToast toastError:NSLocalizedString(@"join_fail_member_full", @"加入失败，成员数量已达上限")];
//        } else if ([output.code isEqualToString:@"GW-5005"]) {
//            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
//        } else if ([output.code isEqualToString:@"GW-400"]) {
//            [ESToast toastWarning:NSLocalizedString(@"me_duplicatespaceidentify", @"空间标识重复，请重新输入")];
//        }
//        else {
//            [ESToast toastError:NSLocalizedString(@"Join Fail", @"加入失败")];
//        }
//    }];
}
@end
