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
//  ESInvitationActivityVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESInvitationActivityVC.h"
#import "ESSetting8ackd00rItem.h"
#import "ESPlatformClient.h"
#import "ESCommonToolManager.h"
#import "ESGatewayManager.h"
#import "ESAccountManager.h"
#import "ESBoxManager.h"

static  NSString * const TRIAL_ONLINE_API = @"/space/index.html";
static  NSString * const EN_TRIAL_ONLINE_API = @"/space/index.html";

@interface ESInvitationActivityVC ()

@end

@implementation ESInvitationActivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlHost = ESBoxManager.activeBox.prettyDomain;
    NSString *path =  [ESCommonToolManager isEnglish] ? EN_TRIAL_ONLINE_API : TRIAL_ONLINE_API;
    NSString *baseUrl = [urlHost stringByAppendingPathComponent:path];
    self.style = ESWebVCShowStyle_FullScreen;

    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        if (token != nil) {
            NSString *tokenValue = token.accessToken;
            NSString *personalName = ESAccountManager.manager.userInfo.personalName;
            if (personalName.length <= 0) {
                NSDictionary *dic = [ESBoxManager cacheInfoForBox:ESBoxManager.activeBox];
                personalName = dic[@"personalName"];
            }
            NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
            NSString *encodedPersonName = [personalName stringByAddingPercentEncodingWithAllowedCharacters:set];

            NSString *url = [NSString stringWithFormat:@"%@?token=%@&name=%@&type=%@#/activityList", baseUrl, tokenValue, encodedPersonName, [self activtiyTypeMap:self.activityType]];
            ESDLog(@"[loadWithURL] %@", url);
            [self loadWithURL:url];
        }}];
}

- (NSString *)activtiyTypeMap:(ESInvitationActivityType)type {
    if (self.activityType == ESInvitationActivityType_Trail) {
        return @"trial";
    }
    if (self.activityType == ESInvitationActivityType_Proposal) {
        return @"proposal";
    }
    return @"";
}

- (NSArray<NSString *> *)registerCommandClassList {
    return @[@"ESSetNativeTitleJSBCommand",
             @"ESShareJSBCommand",
             @"ESExitWebviewJSBCommand",
            ];
}

@end
