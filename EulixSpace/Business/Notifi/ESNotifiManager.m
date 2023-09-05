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
//  ESNotifiManager.m
//  EulixSpace
//
//  Created by dazhou on 2022/7/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNotifiManager.h"
#import <YYModel/YYModel.h>
#import "ESAuthenticationController.h"
#import "ESUpgradeNotificationManager.h"
#import "ESSpaceGatewayNotificationServiceApi.h"
#import "ESUpgradeVC.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESInvitationActivityVC.h"
#import "ESTopNotificationVC.h"
#import "ESMeNewListVC1.h"
#import "UIWindow+ESVisibleVC.h"

//FOUNDATION_EXPORT  NSNotificationName ESAppletDataChangedNotification;

@implementation ESNotifiModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"alertTitle"  : @"aps.alert.title",
             @"alertBody"  : @"aps.alert.body"};
}

@end

@interface ESNotifiManager()

@end

@implementation ESNotifiManager

+ (BOOL)processNotifi:(NSDictionary *)userInfo {
    ESDLog(@"[ESNotifiManager] [processNotifi] userInfo: %@", userInfo);
    if (userInfo.allKeys.count <= 0) {
        return NO;
    }
    
    if ([self needNotificationDetailInfo:userInfo]) {
        [self handleNotificationInfo:userInfo];
        return YES;
    }
    
    if ([ESUpgradeNotificationManager isUpgradNotiticationInfo:userInfo]) {
        [ESUpgradeNotificationManager handlerRemoteNotificationInfo:userInfo];
        return YES;
    }
    
    ESNotifiModel * model = [ESNotifiModel yy_modelWithJSON:userInfo];
    if ([model.optType isEqualToString:ESSecurityPasswordModifyApply]
        || [model.optType isEqualToString:ESSecurityPasswordResetApply]) {
        [self showSecurityPSModifyView:model];
        return YES;
    }
    
//    if ([model.optType isEqualToString:@"applet_operator"]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:ESAppletDataChangedNotification object:nil] ;
//        return YES;
//    }
    
    if([model.optType isEqualToString:@"upgrade_restart"]){
        ESUpgradeVC *vc =  (ESUpgradeVC *)[UIWindow getCurrentVC];
        ESDLog(@"[UIWindow getCurrentVC] %@", vc);
        if ([vc isKindOfClass:[ESUpgradeVC class]]) {
            [vc showRestartBoxProcessing];
        }
        return YES;
    }
    
    if([model.optType isEqualToString:@"invite_reward"] || [model.optType isEqualToString:@"feedback_reward"]){
        ESInvitationActivityVC *vc = [[ESInvitationActivityVC alloc] init];
        vc.activityType = [model.optType isEqualToString:@"invite_reward"] ? ESInvitationActivityType_Trail :ESInvitationActivityType_Proposal;
        [[UIWindow visibleViewController].navigationController pushViewController:vc animated:YES];
        return YES;
    }
    
    return NO;
}


+ (BOOL)needShowAlertWhenPresentNotification:(NSDictionary *)userInfo {
    ESDLog(@"[ESNotifiManager] [needShowAlertWhenPresentNotification] userInfo: %@", userInfo);
    if (userInfo.allKeys.count <= 0) {
        return NO;
    }
    ESNotifiModel * model = [ESNotifiModel yy_modelWithJSON:userInfo];
    if ([model.optType isEqualToString:@"memories"]) {
        return YES;
    }
    
    if ([model.optType isEqualToString:@"today_in_his"]) {
        return YES;
    }
    
    if ([model.optType isEqualToString:@"invite_reward"] || [model.optType isEqualToString:@"feedback_reward"]) {
        return YES;
    }

    return NO;
}

+ (BOOL)needProcessAlertWhenPresentNotification:(NSDictionary *)userInfo {
    ESDLog(@"[ESNotifiManager] [needProcessAlertWhenPresentNotification] userInfo: %@", userInfo);
    if (userInfo.allKeys.count <= 0) {
        return NO;
    }
    ESNotifiModel * model = [ESNotifiModel yy_modelWithJSON:userInfo];
    if ([model.optType isEqualToString:@"upgrade_restart"]) {
        return YES;
    }
    
    return NO;
}

//poll接口info带data数据
+ (BOOL)processNotifiWithDetailInfo:(NSDictionary *)userInfo {
    ESDLog(@"[ESNotifiManager] [processNotifiWithDetailInfo] userInfo: %@", userInfo);
    if (userInfo.allKeys.count <= 0) {
        return NO;
    }
    NSDictionary *dataInfo = [self dictionaryWithJsonString:userInfo[@"data"]];
    ESNotifiModel * model = [ESNotifiModel yy_modelWithJSON:userInfo];
    
    
    
    return NO;
}

//系统推送，需走getNotification获取详情
+ (BOOL)processNotifiWithDetailInfo:(NSDictionary *)userInfo dataInfo:(NSDictionary *)dataInfo  {
    ESDLog(@"[ESNotifiManager] [processNotifiWithDetailInfo dataInfo] userInfo: %@", userInfo);
    if (userInfo.allKeys.count <= 0) {
        return NO;
    }
    ESNotifiModel * model = [ESNotifiModel yy_modelWithJSON:userInfo];

    
    
    return NO;
}


+ (BOOL)needNotificationDetailInfo:(NSDictionary *)info {
    ESNotifiModel * model = [ESNotifiModel yy_modelWithJSON:info];
    if ([self.needNotificationDetailOptTypeList containsObject:ESSafeString(model.optType)]) {
        return YES;
    }
    
    return NO;
}

+ (NSArray *)needNotificationDetailOptTypeList {
    return @[ @"memories", @"today_in_his"];
}

+ (void)handleNotificationInfo:(NSDictionary *)info {
    NSDictionary *dataInfo = [self dictionaryWithJsonString:info[@"data"]];
    if (dataInfo.count > 0) {
        [self processNotifiWithDetailInfo:info];
        return;
    }

    weakfy(self)
    NSString *messageIdStr = info[@"messageId"];
    ESSpaceGatewayNotificationServiceApi *api = [ESSpaceGatewayNotificationServiceApi new];
        [api spaceV1ApiNotificationGetWithMessageId:messageIdStr completionHandler:^(ESResponseBaseNotificationEntity *output, NSError *error) {
            strongfy(self)
            if (error == nil && output.results.data.length > 0) {
                NSDictionary *dataInfo = [self dictionaryWithJsonString:output.results.data];
                [self processNotifiWithDetailInfo:info dataInfo:dataInfo];
            }
        }];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (void)showSecurityPSModifyView:(ESNotifiModel *)model {
    ESAuthenticationController * desCtl = [[ESAuthenticationController alloc] init];
    desCtl.messageId = model.messageId;
    desCtl.optType = model.optType;
    UIViewController * srcCtl = [self getTopviewControler];
    desCtl.modalPresentationStyle = UIModalPresentationFullScreen;
    if(![srcCtl isKindOfClass:[ESAuthenticationController class]]){
        [srcCtl presentViewController:desCtl animated:YES completion:nil];
    }
}


//获取当前所展示的控制器
+ (UIViewController *)getTopviewControler{
    //获取根控制器
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    UIViewController *parent = rootVC;
    //遍历 如果是presentViewController
    while ((parent = rootVC.presentedViewController) != nil ) {
        rootVC = parent;
    }
   
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    return rootVC;
}

+ (void)toNewsListVC {
    ESMeNewListVC1 * ctl = [[ESMeNewListVC1 alloc] init];
    UIViewController * srcVC = [UIWindow getCurrentVC];
    [srcVC.navigationController pushViewController:ctl animated:YES];
}

@end


@implementation ESNotiHardwareModel

- (NSString *)getTimeString {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:self.eventTime];
    return [formatter stringFromDate:date];
}

@end
