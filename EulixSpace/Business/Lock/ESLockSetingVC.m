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
//  ESLockSetingVC.m
//  EulixSpace
//
//  Created by qu on 2022/9/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESLockSetingVC.h"
#import "ESAccountManager.h"
#import "ESFormCell.h"
#import "ESNetworking.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "NSObject+LocalAuthentication.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "NSObject+LocalAuthentication.h"
#import "ESCommonToolManager.h"

typedef NS_ENUM(NSInteger, LAContextSupportType) {
    LAContextSupportTypeNone,              // 不支持指纹或者faceID
    LAContextSupportTypeTouchID,           // 指纹识别
    LAContextSupportTypeFaceID,            // faceid
    LAContextSupportTypeTouchIDNotEnrolled,      // 支持指纹没有设置指纹
    LAContextSupportTypeFaceIDNotEnrolled        // 支持faceid没有设置faceid
};

typedef NS_ENUM(NSUInteger, ESSyncNewsType) {
    ESSyncSettingTypeSystemNews,
    ESSyncSettingBusinessTypeNews
};

@interface ESLockSetingVC()
@property (strong,nonatomic) UILabel *titleLable;

@property (strong,nonatomic) UISwitch *systemNews;

@property (strong,nonatomic) UILabel *systemNewsTitle;

@property (strong,nonatomic) UILabel *systemNewsPointOut;

@property (strong,nonatomic) UISwitch *businessNews;

@property (strong,nonatomic) UILabel *businessNewsTitle;

@property (strong,nonatomic) UILabel *businessNewsPointOut;

@end

@implementation ESLockSetingVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"security_lock", @"应用锁");
    self.cellClass = [ESFormCell class];
    self.section = @[@(0)];
    self.tableView.scrollEnabled = NO;
    //后台进前台通知 UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self addSwitch];
}

#pragma mark - UI

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30 + 30 + 20 + 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //CGFloat tableHeaderHeight = [self tableView:tableView heightForHeaderInSection:section];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0,ScreenWidth, 30 + 30)];
    return header;
}


- (void)titleLabelClickedWithGes:(UITapGestureRecognizer *)ges {
    if (UIApplicationOpenSettingsURLString != NULL) {
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:URL options:@{} completionHandler:nil];
            [self loadData];
        }
    }
}

- (void)didBecomeActive:(NSNotification *)notification {
    if (@available(iOS 10.0, *)) {
        
    }
}

- (void)addSwitch {
    
    self.systemNewsTitle = [UILabel new];
    [self.view addSubview:self.systemNewsTitle];
    self.systemNewsTitle.textColor = ESColor.labelColor;
    self.systemNewsTitle.textAlignment = NSTextAlignmentLeft;
    self.systemNewsTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    LAContext *context = [[LAContext alloc] init];
    NSError*error =nil;
    LABiometryType type;
    if (@available(iOS 11.0, *)) {
        [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        type = context.biometryType;
        if(type == LABiometryTypeFaceID){
            self.systemNewsTitle.text = NSLocalizedString(@"face_unlock", @"面容解锁");
        }else{
            self.systemNewsTitle.text = NSLocalizedString(@"fingerprint_unlock", @"指纹解锁");
        }
    }

    [self.systemNewsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(self.view.mas_top).offset(40.0);
        make.height.mas_equalTo(22.0);
    }];
    
    
    self.systemNews = [[UISwitch alloc] init];
    [self.view addSubview:self.systemNews];
    [self.systemNews addTarget:self
                  action:@selector(systemSwitched:)
        forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.systemNews];
    [self.systemNews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-28.0);
        make.centerY.mas_equalTo(self.systemNewsTitle);
        make.height.mas_equalTo(30.0);
        make.width.mas_equalTo(50.0);
    }];
    
   // NSString *isOpenLock = [[NSUserDefaults standardUserDefaults] objectForKey:@"isOpenLock"];
    NSString *isOpenLock = [[ESCommonToolManager manager] getLockSwitchOpenLock:@""];

    if ([isOpenLock isEqual:@"YES"]) {
        [self.systemNews setOn:YES];
    }else {
        [self.systemNews setOn:NO];
    }
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    [self.view addSubview:bgView];
    
    if ([ESCommonToolManager isEnglish]) {
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.systemNewsTitle.mas_bottom).offset(20.0);
            make.right.mas_equalTo(self.view.mas_right).offset(0.0);
            make.left.mas_equalTo(self.view.mas_left).offset(0.0);
            make.height.mas_equalTo(160.0);
        }];
        
        UILabel *pointLabel = [UILabel new];
        pointLabel.text =  NSLocalizedString(@"application_lock_hint", @"1.打开傲空间App需要验证指纹或面容ID2.面容ID、指纹仅对本机有效3.傲空间不会存储您的指纹/面容ID，如需修改，请在系统设置中操作。");
        pointLabel.numberOfLines = 0;
        pointLabel.textColor = ESColor.secondaryLabelColor;
        pointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.view addSubview:pointLabel];
        [pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(20.0);
            make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
            make.left.mas_equalTo(self.view.mas_left).offset(26.0);
            make.height.mas_equalTo(120.0);
        }];
    }else{
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.systemNewsTitle.mas_bottom).offset(20.0);
            make.right.mas_equalTo(self.view.mas_right).offset(0.0);
            make.left.mas_equalTo(self.view.mas_left).offset(0.0);
            make.height.mas_equalTo(120.0);
        }];
        
        UILabel *pointLabel = [UILabel new];
        pointLabel.text =  NSLocalizedString(@"application_lock_hint", @"1.打开傲空间App需要验证指纹或面容ID2.面容ID、指纹仅对本机有效3.傲空间不会存储您的指纹/面容ID，如需修改，请在系统设置中操作。");
        pointLabel.numberOfLines = 0;
        pointLabel.textColor = ESColor.secondaryLabelColor;
        pointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.view addSubview:pointLabel];
        [pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(20.0);
            make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
            make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        }];
    }

    if (@available(iOS 11.0, *)) {
        [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        type = context.biometryType;
        if(error){
            self.systemNews.on = NO;
            [[ESCommonToolManager manager] savelockSwitchOpenLock:@"NO"];
        }
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
                [ESToast toastError:NSLocalizedString(@"no_password_set", @"未设置本地密码")];
                break;
            }
            case LAErrorBiometryNotAvailable:
            {
                if(context.biometryType == LAContextSupportTypeFaceID){
                    [ESToast toastError:NSLocalizedString(@"face_permission", @"未开启面部权限，请前往设置去开启")];
                }else if(context.biometryType == LABiometryTypeTouchID){
                    [ESToast toastError:NSLocalizedString(@"Fingerprint_permission", @"未开启指纹权限，请前往设置去开启")];
                 }
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
            break;
            }
        }
    }
}


- (void)systemSwitched:(UISwitch *)sender {
    [ESToast dismiss];
    LAContext *context = [[LAContext alloc] init];
    NSError*error =nil;
 
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (@available(iOS 11.0, *)) {
        if (error) {
            self.systemNews.on = NO;
            if (error.code == kLAErrorTouchIDNotEnrolled) {
                if(context.biometryType == LAContextSupportTypeFaceID){
                    [ESToast toastError:NSLocalizedString(@"No_facial_features", @"本地未录入面容,无法开启面容解锁")];
                }else if(context.biometryType == LABiometryTypeTouchID){
                    [ESToast toastError:NSLocalizedString(@"No_fingerprint_features", @"本地未录入指纹,无法开启指纹解锁")];
                 }
                return;
            }
            else if (error.code == kLAErrorTouchIDNotAvailable) {
                    if(context.biometryType == LAContextSupportTypeFaceID){
                        [ESToast toastError:NSLocalizedString(@"face_permission", @"未开启面部权限，请前往设置去开启")];
                    }else if(context.biometryType == LABiometryTypeTouchID){
                        [ESToast toastError:NSLocalizedString(@"Fingerprint_permission", @"未开启指纹权限，请前往设置去开启")];
                     }
                    return;
             }else{
                   [ESToast toastError:NSLocalizedString(@"common_unkown_error", @"未知错误")];
                   [[ESCommonToolManager manager] savelockSwitchOpenLock:@"NO"];
                   return;
           }
        }
    }
    if (sender.on) {
        if (@available(iOS 11.0, *)) {
            if (error) {
                [[ESCommonToolManager manager] savelockSwitchOpenLock:@"NO"];
                self.systemNews.on = NO;
                if (error.code == kLAErrorTouchIDNotEnrolled) {
                    return;
                }
                else if (error.code == kLAErrorTouchIDNotAvailable) {
                    self.systemNews.on = NO;
                    if(context.biometryType == LAContextSupportTypeFaceID){
                        [ESToast toastError:NSLocalizedString(@"face_permission", @"未开启面部权限，请前往设置去开启")];
                    }else if(context.biometryType == LABiometryTypeTouchID){
                        [ESToast toastError:NSLocalizedString(@"Fingerprint_permission", @"未开启指纹权限，请前往设置去开启")];
                     }
                    return;
                }else{
                   [ESToast toastError:NSLocalizedString(@"common_unkown_error", @"未知错误")];
                   [[ESCommonToolManager manager] savelockSwitchOpenLock:@"NO"];
                   return;
                }
           }else{
                if(context.biometryType == LABiometryTypeFaceID){
                    [ESToast toastSuccess:NSLocalizedString(@"face_unlock_on_success", @"已开启面容解锁")];
                }else if(context.biometryType == LABiometryTypeTouchID){
                    [ESToast toastSuccess:NSLocalizedString(@"fingerprint_unlock_on_success", @"已开启指纹解锁")];
                }
            }
        }
        [[ESCommonToolManager manager] savelockSwitchOpenLock:@"YES"];
      
    }else{
        
        [self getLocalAuthentication:^(BOOL success, NSError * _Nullable error) {
            if(success){
                if (@available(iOS 11.0, *)) {
                    if (error) {
                        if (error.code == kLAErrorTouchIDNotEnrolled) {
                            self.systemNews.on = NO;
                            return;
                        }
                    }
                    else{
                        if(context.biometryType == LABiometryTypeFaceID){
                            [ESToast toastSuccess:NSLocalizedString(@"face_unlock_off_success", @"已关闭面容解锁")];
                        }else if(context.biometryType == LABiometryTypeTouchID){
                            [ESToast toastSuccess:NSLocalizedString(@"fingerprint_unlock_off_success", @"已关闭指纹解锁")];
                         }
                    }
                }
                [[ESCommonToolManager manager] savelockSwitchOpenLock:@"NO"];
            }else{
                self.systemNews.on = YES;
            }
        }boxUUID:@"" typeInt:4];
      //  [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isPushLoopPauseStr"];
    }
    
}


@end
