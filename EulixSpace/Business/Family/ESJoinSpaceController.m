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
//  ESJoinSpaceController.m
//  EulixSpace
//
//  Created by dazhou on 2023/4/3.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESJoinSpaceController.h"
#import "AAPLCustomPresentationController.h"
#import "UIColor+ESHEXTransform.h"
#import "UILabel+ESTool.h"
#import "UIButton+Extension.h"
#import "ESGradientButton.h"
#import <YYModel/YYModel.h>
#import "ESRSACenter.h"
#import "ESApiClient.h"
#import "ESCreateMemberInfo.h"
#import "ESSpaceGatewayMemberAuthingServiceApi.h"
#import "ESToast.h"
#import "ESCommonToolManager.h"
#import "ESBoxManager.h"
#import "ESAES.h"
//#import "ESPushManager.h"
#import "UIViewController+ESTool.h"
#import "UIView+ESTool.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESBindSetSecurityPasswordVC.h"
#import "ESSpaceInfoEditeVC.h"
#import "ESSecurityPasswordVerifyVC.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESSpaceInfoEditeVC.h"


@implementation ESInviteInfoManage

+ (ESInviteInfoManage *)Instance {
    static ESInviteInfoManage * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end

@implementation ESMemberInviteModel
- (NSString *)getSubdomain {
    if (!self.inviteparam) {
        return nil;
    }
    return [self.inviteparam componentsSeparatedByString:@"subdomain="].lastObject;
}
@end
