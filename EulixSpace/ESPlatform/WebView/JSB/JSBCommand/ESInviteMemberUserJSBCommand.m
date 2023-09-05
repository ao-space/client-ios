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
//  ESInviteMemberUserJSBCommand.m
//  EulixSpace
//
//  Created by KongBo on 2023/3/30.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESInviteMemberUserJSBCommand.h"
#import "ESApiClient.h"
#import "ESApiClient.h"
#import "ESCreateMemberInfo.h"
#import "ESSpaceGatewayMemberAuthingServiceApi.h"
#import "ESCommonToolManager.h"
#import "ESRSAPair.h"
#import "ESRSACenter.h"
#import "ESBoxManager.h"
#import "ESAES.h"
#import "UIView+Status.h"
#import "ESToast.h"

@interface ESInviteMemberUserJSBCommand ()

@property (nonatomic, copy) NSString *shareUrlStr;
@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSString *userDomain;
@property (nonatomic, copy) NSString *inviteCode;
@property (nonatomic, copy) NSString *aoId;
@property (nonatomic, copy) NSString *boxPublicKey;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *tmpBoxUUID;


@property (nonatomic, copy) NSString *authKey;
@property (nonatomic, copy) NSString *boxUUID;

@end

#import "ESJoinSpaceController.h"

@implementation ESInviteMemberUserJSBCommand

/**
{
 参数：setInviteUrl({inviteUrl:''}
}*/

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        if (![data isKindOfClass:[NSDictionary class]] && ![data isKindOfClass:[NSString class]]) {
            ESDLog(@"[ESInviteMemberUserJSBCommand]   参数错误");
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        NSDictionary *params = (NSDictionary *)data;
        NSString *inviteUrl;
        NSString *email;
        ESDLog(@"[ESInviteMemberUserJSBCommand]   params: %@", params);

        if ([data isKindOfClass:[NSDictionary class]]) {
            inviteUrl = params[@"inviteUrl"];
            email = params[@"email"];
        } else if ([data isKindOfClass:[NSString class]]) {
            inviteUrl = data;
        }
        
        [self.context.webVC.view showLoading:YES];
        self.shareUrlStr = inviteUrl;
        self.email = email;
        [self memberAccept:responseCallback];

    };
    return _commandHander;
}

/// 接受邀请
- (void)memberAccept:(ESJBResponseCallback)responseCallback {
    NSString *url = [self.shareUrlStr stringByRemovingPercentEncoding];
    ESDLog(@"邀请成员连接地址%@  email:%@",url, self.email);
    NSURLComponents *components = [NSURLComponents componentsWithString:ESSafeString(url)];
   
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj,
                                                        NSUInteger idx,
                                                        BOOL *_Nonnull stop) {
        if ([obj.name isEqualToString:@"subdomain"]) {
            self.userDomain = obj.value;
        } else if ([obj.name isEqualToString:@"invitecode"]) {
            self.inviteCode = obj.value;
        } else if ([obj.name isEqualToString:@"aoid"]) {
            self.aoId = obj.value;
        } else if ([obj.name isEqualToString:@"member"]) {
            self.nickName = obj.value;
        }
    }];
    
    self.tmpBoxUUID = NSUUID.UUID.UUIDString.lowercaseString;

    NSURL *requesetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", self.userDomain]];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    ESSpaceGatewayMemberAuthingServiceApi *api = [[ESSpaceGatewayMemberAuthingServiceApi alloc] initWithApiClient:client];
    [api spaceV1ApiGatewayAuthMemberAcceptGetWithInviteCode:self.inviteCode
                                          completionHandler:^(ESInviteResult *output, NSError *error) {
                                              if (!error && [output.code isEqualToString:@"GW-200"]) {
                                                  self.boxPublicKey = output.boxPublicKey;
                                                  ///公钥存储到临时boxUUID中
                                                  [ESRSACenter.defaultCenter addBoxPublicPem:self.boxPublicKey boxUUID:self.tmpBoxUUID];
                                                  [self creareFamilyMumber:responseCallback];
                                                  return;
                                              }
        
                                                [self.context.webVC.view showLoading:NO];
                                                if (responseCallback == nil) {
                                                    return;
                                                }
                                                if ([output.code isEqualToString:@"GW-4033"]){
                                                  [ESToast toastError:@"链接已失效，请联系管理员重新邀请"];
                                                    responseCallback(@{ @"code" : @([output.code intValue]),
                                                                        @"data" : @{},
                                                                        @"msg" : @"链接已失效，请联系管理员重新邀请"
                                                                     });
                                              } else {
                                                  ESDLog(@"邀请成员连接地址%@",error);
                                                  [ESToast toastError:NSLocalizedString(@"Join Fail", @"加入失败")];
                                                  responseCallback(@{ @"code" : @([output.code intValue]),
                                                                      @"data" : @{},
                                                                      @"msg" : @"加入失败"
                                                                   });
                                              }
                                          }];
}

/// 创建成员
- (void)creareFamilyMumber:(ESJBResponseCallback)responseCallback {
    NSURL *requesetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", self.userDomain]];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    ESSpaceGatewayMemberAuthingServiceApi *api = [[ESSpaceGatewayMemberAuthingServiceApi alloc] initWithApiClient:client];
    ESCreateMemberInfo *info = [ESCreateMemberInfo new];
    info.phoneModel = [ESCommonToolManager judgeIphoneType:@""];
    NSString *arcRandom16Str = [ESCommonToolManager arcRandom16Str];
    ///公钥存储到临时boxUUID中
    ESRSAPair *pair = [ESRSACenter boxPair:self.tmpBoxUUID];
    if (!pair.publicKey) {
        return;
    }

    info.clientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
    info.inviteCode = [pair publicEncrypt:self.inviteCode];
    info.tempEncryptedSecret = [pair publicEncrypt:arcRandom16Str];
    info.nickName = self.nickName;
    info.phoneType = @"ios";
    info.applyEmail = self.email;
    weakfy(self)
    [api spaceV1ApiGatewayAuthMemberCreatePostWithAoId:self.aoId
                                                  body:info
                                     completionHandler:^(ESCreateMemberResult *output, NSError *error) {
                                            strongfy(self)
                                         if (!error && [output.code isEqualToString:@"GW-200"]) {
                                             ESCreateMemberResult *result = output;
                                             self.authKey = [result.authKey aes_cbc_decryptWithKey:arcRandom16Str iv:output.algorithmConfig.transportation.initializationVector];
                                             self.boxUUID = [result.boxUUID aes_cbc_decryptWithKey:arcRandom16Str iv:output.algorithmConfig.transportation.initializationVector];
                                             [ESRSACenter.defaultCenter removeBoxPublicPem:self.tmpBoxUUID];
                                             ///存储真正的公钥对
                                             [ESRSACenter.defaultCenter addBoxPublicPem:self.boxPublicKey boxUUID:self.boxUUID];
                                             [ESBoxManager onInviteMember:[ESBoxItem fromInviteMemberWithBoxUUID:self.boxUUID authKey:self.authKey userDomain:output.userDomain aoid:self.aoId]];
//
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                 [self.context.webVC.view showLoading:NO];

                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"createMemberNSNotification" object:nil];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"loopUrlChangeNSNotification" object: output.userDomain];
                                                 
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                     [ESToast toastSuccess:@"恭喜您可以开始在线体验"];
                                                 });
                                             });
                         
                                             return;
                                         }
        
                                        [self.context.webVC.view showLoading:NO];
                                        if (responseCallback == nil) {
                                            return;
                                        }
                                        NSString *errorMsg;
                                         if ([output.code isEqualToString:@"GW-4031"]){
                                             errorMsg = @"已是成员，请勿重复绑定";
                                         } else if ([output.code isEqualToString:@"GW-4032"]){
                                             errorMsg = @"昵称不合法，请重新输入";
                                         } else if ([output.code isEqualToString:@"GW-4033"]){
                                             errorMsg = @"链接已失效，请联系管理员重新邀请";
                                         } else if ([output.code isEqualToString:@"GW-4034"]){
                                             errorMsg = @"加入失败，成员数量已达上限";
                                         } else {
                                             ESDLog(@"邀请成员连接地址%@",error);
                                             errorMsg = NSLocalizedString(@"Join Fail", @"加入失败");
                                         }
                                        [ESToast toastError:ESSafeString(errorMsg)];
                                        responseCallback(@{ @"code" : @([output.code intValue]),
                                                            @"data" : @{},
                                                            @"msg" : ESSafeString(errorMsg)
                                                         });
                                                                     }];
}

- (NSString *)commandName {
    return @"setInviteUrl";
}
@end
