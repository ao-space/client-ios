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
//  ESV2PowerBulletVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESV2PowerBulletVC.h"
#import "ESColor.h"
#import "ESCommentCreateFolder.h"
#import "ESFileSelectPhotoListVC.h"
#import "ESFolderList.h"
#import "ESLocalPath.h"
#import "ESTransferManager.h"
#import "ESUploadMetadata.h"
#import "UIButton+Extension.h"
#import "ESCommonToolManager.h"
#import "ESFolderApi.h"
#import<Photos/Photos.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <UserNotifications/UserNotifications.h>

@interface ESV2PowerBulletVC ()


@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIButton *delectBtn;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation ESV2PowerBulletVC


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
        self.programView.hidden = NO;
        [self initUI];
    }
    return self;
}


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.programView.hidden = hidden;
    if(hidden){
        [self removeFromSuperview];
    }else{
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
    }
}
/// 取消
- (void)didClickDelectBtn:(UIButton *)delectBtn {
    if (self.actionBlock) {
        self.actionBlock(@"delect");
    }
}

- (void)cancelView {
    if (self.actionBlock) {
        self.actionBlock(@"delect");
    }
}


- (void)initUI {
    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        make.left.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(300.0f);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.programView.mas_top).offset(20);
       
    }];
 
    [self.pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(26);
        make.right.mas_equalTo(self).offset(-26);
        make.top.mas_equalTo(self.programView.mas_top).offset(75);
    }];

    [self.delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(5);
        make.right.mas_equalTo(self.mas_right).offset(-23);
        make.height.mas_equalTo(52.0f);
        make.width.mas_equalTo(52.0f);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(26);
        make.right.mas_equalTo(self).offset(-26);
        make.top.mas_equalTo(self.programView.mas_top).offset(159);
        make.height.mas_equalTo(70.0f);
    }];
    
    [self.pointOutLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(20);
        make.top.mas_equalTo(self.bgView.mas_top).offset(24);
    }];
}

#pragma mark - Lazy Load

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 550.0f, ScreenWidth, 550.0f)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_programView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _programView.bounds;
        maskLayer.path = maskPath.CGPath;
        _programView.layer.mask = maskLayer;
        [self addSubview:_programView];
    }
    return _programView;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(didClickDelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
        [self.programView addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [[UILabel alloc] init];
        _pointOutLabel.textColor = ESColor.grayColor;
        _pointOutLabel.numberOfLines = 0;
        _pointOutLabel.textAlignment = NSTextAlignmentCenter;
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.programView addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}


- (UILabel *)pointOutLabel2 {
    if (!_pointOutLabel2) {
        _pointOutLabel2 = [[UILabel alloc] init];
        _pointOutLabel2.textColor = ESColor.labelColor;
        _pointOutLabel2.numberOfLines = 0;
        _pointOutLabel2.textAlignment = NSTextAlignmentCenter;
        _pointOutLabel2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.bgView addSubview:_pointOutLabel2];
    }
    return _pointOutLabel2;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _bgView.layer.cornerRadius = 10.0;
        _bgView.layer.masksToBounds = YES;
        [self addSubview:_bgView];
        self.powerSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth - 50 - 30 - 60 , 20, 50, 30)];
        [self.powerSwitch addTarget:self
                      action:@selector(switched:)
            forControlEvents:UIControlEventValueChanged];
       // [self.powerSwitch setOn:NO];
        [_bgView addSubview:self.powerSwitch];
    }
    return _bgView;
}


-(void)setType:(ESPowerType)type{
    if(type == ESPowerTypeContacts){
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.powerSwitch setOn:NO];
            });
        }else{
            [self.powerSwitch setOn:YES];
        }
    }
    
    else  if(type == ESPowerTypePhoto){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {//开启
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.powerSwitch setOn:YES];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.powerSwitch setOn:NO];
                });
            }
        }];
    }else if(type == ESPowerTypeCamera){
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.powerSwitch setOn:NO];
            });
        }else{
            [self.powerSwitch setOn:YES];
        }
      
    }
    else if(type ==ESPowerTypeNotifications){
        if (@available(iOS 10.0, *)) {
            
        }
    }
}
-(void)switched:(UISwitch *)sender{
    if(!sender.isOn){
        [self.powerSwitch setOn:YES];
    }else {
        [self.powerSwitch setOn:NO];
    }
  
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        }];
    }
}

- (void)didHiddeSelf:(NSNotification *)notifi {
    [self didClickDelectBtn:nil];
}

/**
 校验通讯录权限
 */
- (void)checkAddressBookAuth:(void (^)(BOOL auth))result {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusNotDetermined:    //用户还没有选择(第一次)
        {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {  //授权
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (result) {
                            result(YES);
                        }
                    });
                }else {         //拒绝
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (result) {
                            result(NO);
                        }
                    });
                }
            });
        }
            break;
        case kABAuthorizationStatusRestricted:       //家长控制
        {
            if (result) {
                result(NO);
            }
        }
            break;
        case kABAuthorizationStatusDenied:           //用户拒绝
        {
            if (result) {
                result(NO);
            }
        }
            break;
        case kABAuthorizationStatusAuthorized:       //已授权
        {
            if (result) {
                result(YES);
            }
        }
            break;
        default:
            break;
    }
#else
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusNotDetermined:    //用户还没有选择(第一次)
        {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts
                                   completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                       if (granted) {  //授权
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (result) {
                                                   result(YES);
                                               }
                                           });
                                       }else {         //拒绝
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (result) {
                                                   result(NO);
                                               }
                                           });
                                       }
                                   }];
        }
            break;
        case CNAuthorizationStatusRestricted:       //家长控制
        {
            if (result) {
                result(NO);
            }
        }
            break;
        case CNAuthorizationStatusDenied:           //用户拒绝
        {
            if (result) {
                result(NO);
            }
        }
            break;
        case CNAuthorizationStatusAuthorized:       //已授权
        {
            if (result) {
                result(YES);
            }
        }
            break;
        default:
            break;
    }
#endif
}

@end
