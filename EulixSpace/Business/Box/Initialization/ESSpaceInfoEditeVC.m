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
//  ESSpaceInfoEditeVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceInfoEditeVC.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>
#import <YCEasyTool/NSArray+YCTools.h>
#import <YYModel/YYModel.h>
#import "UIViewController+ESTool.h"
#import "ESDeviceStartupDiskEncryptionController.h"
#import "ESSpaceCountryAndLanguageListModule.h"
#import "ESCommListHeaderView.h"
#import "ESToast.h"
#import "ESBindSetSecurityPasswordVC.h"
#import "ESRSACenter.h"
#import "ESApiClient.h"
#import "ESCreateMemberInfo.h"
#import "ESSpaceGatewayMemberAuthingServiceApi.h"
#import "ESToast.h"
#import "ESCommonToolManager.h"
#import "ESBoxManager.h"
#import "ESAES.h"
//#import "ESPushManager.h"
#import "UIView+Status.h"
#import "ESSapceWelcomeVC.h"

@interface ESSpaceInfoEditeVC () <ESBoxBindViewModelDelegate,  UITextFieldDelegate>

@property (nonatomic, strong) ESGradientButton *enterSpace;
@property (nonatomic, strong) ESCommListHeaderView *headerView;

@property (nonatomic, strong) UIView *inputContaierView;
@property (nonatomic, strong) UITextField *input;
@property (nonatomic, strong) UILabel *prompt;
@property (nonatomic, strong) UILabel *dominLabel;
@property (nonatomic, strong) UILabel *pointOutLabel;
@property (nonatomic, strong) UILabel *recommendLabel;

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *dominStr;
@property (nonatomic, assign) NSUInteger limit;

@property (nonatomic, copy) NSString *tmpBoxUUID;
@property (nonatomic, copy) NSString *boxPublicKey;
@property (nonatomic, strong) NSString *authKey;
@property (nonatomic, strong) NSString *boxUUID;
@property (nonatomic, strong) ESSpaceGatewayMemberAuthingServiceApi *memberAuthApi;
@property (nonatomic, strong) ESSpaceGatewayMemberAuthingServiceApi *api;
@end

@implementation ESSpaceInfoEditeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    [self setupViews];
    
    self.viewModel.delegate = self;
    self.limit = 24;
    self.showBackBt = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
//    [self.input becomeFirstResponder];
    self.input.text = @"我的空间";
}


- (void)setupViews {
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(174);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).inset(kTopHeight);
        make.left.right.mas_equalTo(self.view);
    }];
    
    [self setupInputContainerView];
    
    [self.view addSubview:self.enterSpace];
    [_enterSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(40 + kBottomHeight);
    }];
}

- (void)setupInputContainerView {
    self.inputContaierView = [UIView new];
    self.inputContaierView.layer.cornerRadius = 10.0f;
    self.inputContaierView.clipsToBounds = YES;
    self.inputContaierView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    
    [self.view addSubview:self.inputContaierView];
    [_inputContaierView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view).inset(26);
        make.top.mas_equalTo(self.headerView.mas_bottom).inset(20);
        make.height.mas_equalTo(174);
    }];
    
    
    [self.inputContaierView addSubview:self.dominLabel];
    [self.dominLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.inputContaierView).inset(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.inputContaierView addSubview:self.input];
    [_input mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.inputContaierView).inset(20);
        make.top.mas_equalTo(self.dominLabel.mas_bottom).inset(20);
        make.height.mas_equalTo(32);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [ESColor colorWithHex:0xE5E6EC];
    [self.inputContaierView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.inputContaierView).inset(20);
        make.top.mas_equalTo(self.input.mas_bottom).inset(4);
        make.height.mas_equalTo(1);
    }];
   
    [self.inputContaierView addSubview:self.prompt];
    [self.prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.inputContaierView).inset(20);
        make.top.mas_equalTo(line.mas_bottom).inset(20);
        make.height.mas_equalTo(40);
    }];
}

- (void)nextStep {
    if (self.input.text.length <= 0) {
        [ESToast toastError: @"空间名称不能为空，请输入"]; //NSLocalizedString(@"domain_format_error", @"空间名称不能为空，请输入")
        return;
    }
    
    if (![self checkDomin:self.input.text]) {
        [ESToast toastError: @"空间名称不合法，请重新输入"]; //NSLocalizedString(@"domain_format_error", @"空间名称不能为空，请输入")
        return;
    }
    
    //邀请成员流程
    if (self.inviteModel != nil) {
        [self.view showLoading:YES];
        [self reqAcceptMemberInvite];
        return;
    }
    self.viewModel.spaceName = self.input.text;
    ESBindSetSecurityPasswordVC *next = [ESBindSetSecurityPasswordVC new];
    next.viewModel = self.viewModel;
    [self.navigationController pushViewController:next animated:YES];
}

- (void)reqAcceptMemberInvite {
    self.tmpBoxUUID = NSUUID.UUID.UUIDString.lowercaseString;

    NSURL *requesetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", [self.inviteModel getSubdomain]]];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    _api = [[ESSpaceGatewayMemberAuthingServiceApi alloc] initWithApiClient:client];
    weakfy(self)
    [_api spaceV1ApiGatewayAuthMemberAcceptGetWithInviteCode:self.inviteModel.invitecode
                                          completionHandler:^(ESInviteResult *output, NSError *error) {
        strongfy(self)
        if (error) {
            ESDLog(@"[成员加入] reqAcceptMemberInvite:%@",error);
        } else {
            ESDLog(@"[成员加入] reqAcceptMemberInvite:code:%@, msg:%@", output.code, output.message);
        }
        if (!error && [output.code isEqualToString:@"GW-200"]) {
            self.boxPublicKey = output.boxPublicKey;
            ///公钥存储到临时boxUUID中
            [ESRSACenter.defaultCenter addBoxPublicPem:self.boxPublicKey boxUUID:self.tmpBoxUUID];
            [self reqCreateMember];
        } else if ([output.code isEqualToString:@"GW-4033"]){
            [self.view showLoading:NO];
            [ESToast toastError:NSLocalizedString(@"join_fail_invalid_invite_code", @"链接已失效，请联系管理员重新邀请")];
        } else {
            [self.view showLoading:NO];
            [ESToast toastError:NSLocalizedString(@"Join Fail", @"加入失败")];
        }
    }];
}

- (void)reqCreateMember {
    NSURL *requesetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", [self.inviteModel getSubdomain]]];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    _memberAuthApi = [[ESSpaceGatewayMemberAuthingServiceApi alloc] initWithApiClient:client];
    ESCreateMemberInfo *info = [ESCreateMemberInfo new];
    info.phoneModel = [ESCommonToolManager judgeIphoneType:@""];
    NSString *arcRandom16Str = [ESCommonToolManager arcRandom16Str];
    ///公钥存储到临时boxUUID中
    ESRSAPair *pair = [ESRSACenter boxPair:self.tmpBoxUUID];
    if (!pair.publicKey) {
        return;
    }
    
    info.clientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
    info.inviteCode = [pair publicEncrypt:self.inviteModel.invitecode];
    info.tempEncryptedSecret = [pair publicEncrypt:arcRandom16Str];
    info.nickName = self.input.text.length > 0 ? self.input.text : self.inviteModel.member;
    info.phoneType = @"ios";
    [_memberAuthApi spaceV1ApiGatewayAuthMemberCreatePostWithAoId:self.inviteModel.aoid
                                                  body:info
                                     completionHandler:^(ESCreateMemberResult *output, NSError *error) {
        [self.view showLoading:NO];
        if (error) {
            ESDLog(@"[成员加入] reqCreateMember:%@",error);
        } else {
            ESDLog(@"[成员加入] reqCreateMember:code:%@, msg:%@", output.code, output.message);
        }
        
        if (!error && [output.code isEqualToString:@"GW-200"]) {
            ESCreateMemberResult *result = output;
            self.authKey = [result.authKey aes_cbc_decryptWithKey:arcRandom16Str iv:output.algorithmConfig.transportation.initializationVector];
            self.boxUUID = [result.boxUUID aes_cbc_decryptWithKey:arcRandom16Str iv:output.algorithmConfig.transportation.initializationVector];
            [ESRSACenter.defaultCenter removeBoxPublicPem:self.tmpBoxUUID];
            ///存储真正的公钥对
            [ESRSACenter.defaultCenter addBoxPublicPem:self.boxPublicKey boxUUID:self.boxUUID];
            ESBoxItem *boxItem = [ESBoxManager onJustInviteMember:[ESBoxItem fromInviteMemberWithBoxUUID:self.boxUUID authKey:self.authKey userDomain:output.userDomain aoid:self.inviteModel.aoid]];
            
            ESSapceWelcomeVC *vc = [[ESSapceWelcomeVC alloc] init];
            vc.paringBoxItem = boxItem;
            [self.navigationController pushViewController:vc animated:YES];
//            [ESPushManager.manager registerDevice:nil];
        } else if ([output.code isEqualToString:@"GW-4031"]){
            [ESToast toastError:NSLocalizedString(@"join_fail_member_duplicate", @"您已绑定设备上的其他账号，请勿重复绑定")];
        } else if ([output.code isEqualToString:@"GW-4032"]){
            [ESToast toastWarning:NSLocalizedString(@"join_fail_spaceId_illegal", @"空间标识不合法，请重新输入")];
        } else if ([output.code isEqualToString:@"GW-4033"]){
            [ESToast toastError:NSLocalizedString(@"join_fail_invalid_invite_code", @"链接已失效，请联系管理员重新邀请")];
        } else if ([output.code isEqualToString:@"GW-4034"]){
            [ESToast toastError:NSLocalizedString(@"join_fail_member_full", @"加入失败，成员数量已达上限")];
        } else if ([output.code isEqualToString:@"GW-5005"]) {
            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
        } else if ([output.code isEqualToString:@"GW-400"]) {
            [ESToast toastWarning:NSLocalizedString(@"me_duplicatespaceidentify", @"空间标识重复，请重新输入")];
        }
        else {
            [ESToast toastError:NSLocalizedString(@"Join Fail", @"加入失败")];
        }
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.pointOutLabel.hidden = YES;
   
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (position) {
            return YES;
        }
    }
    
    if (textField.text.length >= 24 && string.length > 0) {
        return NO;
    }
    return YES;
}
#pragma mark - Lazy Load

- (UITextField *)input {
    if (!_input) {
        _input = [UITextField new];
        _input.textColor = ESColor.labelColor;
        _input.font = ESFontPingFangMedium(22);
        _input.delegate = self;
        _input.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _input;
}

- (UILabel *)dominLabel {
    if (!_dominLabel) {
        _dominLabel = [UILabel new];
        _dominLabel.textColor = ESColor.labelColor;
        _dominLabel.font = ESFontPingFangMedium(14);
        _dominLabel.text = NSLocalizedString(@"binding_yourspacename", @"您的空间名称");
    }
    return _dominLabel;
}

- (UILabel *)prompt {
    if (!_prompt) {
        _prompt = [UILabel new];
        _prompt.textColor = ESColor.secondaryLabelColor;
        _prompt.font = ESFontPingFangRegular(12);
        _prompt.textAlignment = NSTextAlignmentLeft;
        _prompt.numberOfLines = 0;
        _prompt.text = NSLocalizedString(@"binding_spacenamerules", @"1-24个字符，支持中英文、数字及部分特殊符号。同一个傲空间设备上，空间名称不可重复。");
    }
    return _prompt;
}


- (BOOL)checkDomin:(NSString *)dominTitle {
    NSString *regular = @"^[a-zA-Z0-9\\u4e00-\\u9fa5\\`~!@#$%^&*()-_+=|{}':;',\\\\[\\\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]*$";
    return [dominTitle ifMatchRegex:regular];
}
- (ESCommListHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ESCommListHeaderView alloc] initWithFrame:CGRectMake(0, 0, 400, 152)];
        _headerView.iconImageView.image = [UIImage imageNamed:@"kj"];
        _headerView.titleLabel.text = NSLocalizedString(@"binding_spatialinformation", @"空间信息");
        _headerView.detailLabel.text = NSLocalizedString(@"binding_spacename1", @"设置空间名称，创建个人数字空间");

    }
    return _headerView;
}

- (ESGradientButton *)enterSpace {
    if (!_enterSpace) {
        _enterSpace = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_enterSpace setCornerRadius:10];
        [_enterSpace setTitle:NSLocalizedString(@"box_bind_step_next", @"继续") forState:UIControlStateNormal];
        _enterSpace.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_enterSpace setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_enterSpace setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [_enterSpace addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterSpace;
}

- (BOOL)showBackBtIfNeed {
    return NO;
}
@end

