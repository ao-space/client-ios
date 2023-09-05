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
//  NSObject+LocalAuthentication.m
//
//
//  Created by qu on 2022/10/9.
//

#import "NSObject+LocalAuthentication.h"
#import "ESToast.h"
#import "ESCommonToolManager.h"
#import "ESBoxManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation NSObject (LocalAuthentication)

- (void)getLocalAuthentication:(void (^)(BOOL success, NSError * __nullable error))reply boxUUID:(NSString *)boxUUID typeInt:(NSUInteger)typeInt{
    LABiometryType type;
    if (typeInt == 4) {
        if (ESBoxManager.activeBox.boxType == ESBoxTypeAuth) {
            return;
        }
    }

    NSString *lockStr;
   
    if (boxUUID.length < 1) {
        lockStr = [[ESCommonToolManager manager] getLockSwitchOpenLock:ESBoxManager.activeBox.boxUUID]; 
    }else{
        lockStr = [[ESCommonToolManager manager] getLockSwitchOpenLock:boxUUID];
    }
    if([lockStr isEqual:@"YES"]){
        LAContext *context = [[LAContext alloc] init];
        NSError*error =nil;
        if (@available(iOS 11.0, *)) {
            
            [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
            type = context.biometryType;
        }
        // 判断设备是否支持指纹识别 （如果iPhone支持并设置了面容/指纹，canEvaluatePolicy:会判断成功，进入内部逻辑，否则执行else语句，输出打印error）
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
   
            if (@available(iOS 11.0, *)) {
                LABiometryType type = context.biometryType;
                NSLog(@"已进入：%ld", (long)type);
            }
            //支持 localizedReason为alert弹框的message内容
            context.localizedFallbackTitle =@"";
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请验证已有指纹" reply:^(BOOL success, NSError * _Nullable error) {
                if(success) {
                    NSLog(@"面容/指纹验证通过");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        reply(success,error);
                    });
                    //在这里登录操作
                }else{
                    switch(error.code) {
                        case LAErrorSystemCancel:
                        {
                            NSLog(@"系统取消授权，如其他APP切入");
                            break;
                        }
                        case LAErrorUserCancel:
                        {
                            NSLog(@"用户取消验证Touch ID");
                        }
                        case LAErrorAuthenticationFailed:
                        {
                            NSLog(@"授权失败");
                            break;
                        }
                        case LAErrorPasscodeNotSet:
                        {
                            NSLog(@"系统未设置密码");
                            [ESToast toastError:@"本地密码"];
                            break;
                        }
                        case LAErrorBiometryNotAvailable:
                        {
                            NSLog(@"设备Touch ID不可用，例如未打开");
                            [ESToast toastError:@"请前往设置权限，开启"];
                            break;
                        }
                        case LAErrorBiometryNotEnrolled:
                        {
                            NSLog(@"设备Touch ID不可用，用户未录入");
                            break;
                        }
                        case LAErrorUserFallback:
                        {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                NSLog(@"用户选择输入密码，切换主线程处理");
                            }];
                            break;
                        }
                        default:
                        {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"其他情况，切换主线程处理");
                            }];
                        break;
                        }
                    }
                }
            }];
        }else{
            if (@available(iOS 11.0, *)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(error.code == -8){
                        [ESToast toastError:@"验证错误次数过多，请稍后重试"];
                        reply(NO,error);
                    }else if(error.code == -7){
                        reply(YES,error);
                    }else if(error.code == -6){
                        reply(YES,error);
                    }else{
                        reply(YES,error);
                    }
                });
            }
        }
    }else{
        reply(YES,nil);
    }
}

- (void)getLocalSwitch:(void (^)(BOOL success, NSError * __nullable error))reply boxUUID:(NSString *)boxUUID{
    LABiometryType type;
    NSString *lockStr;
   
    if (boxUUID.length < 1) {
        lockStr = [[ESCommonToolManager manager] getLockSwitchOpenLock:ESBoxManager.activeBox.boxUUID];
    }else{
        lockStr = [[ESCommonToolManager manager] getLockSwitchOpenLock:boxUUID];
    }
    if([lockStr isEqual:@"YES"]){
        LAContext *context = [[LAContext alloc] init];
        NSError*error =nil;
        if (@available(iOS 11.0, *)) {
            
            [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
            type = context.biometryType;
        }
        // 判断设备是否支持指纹识别 （如果iPhone支持并设置了面容/指纹，canEvaluatePolicy:会判断成功，进入内部逻辑，否则执行else语句，输出打印error）
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
            if (@available(iOS 11.0, *)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(error.code == -8){
                        [ESToast toastError:@"验证错误次数过多，请稍后重试"];
                        reply(NO,error);
                    }else if(error.code == -7){
                        reply(YES,error);
                    }else{
                        reply(YES,error);
                    }
                });
            }
            NSLog(@"error : %@",error.description);
    }else{
        // 没有开启应用锁
        reply(YES,nil);
    }

}
@end
