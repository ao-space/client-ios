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
//  ESMeSettingV2.m
//  EulixSpace
//
//  Created by qu on 2021/5/21.
//

#import "ESMeSettingV2.h"
#import "ESMemberManager.h"

#import "EBDropdownListView.h"
#import "ESHomeCoordinator.h"
#import "ESThemeDefine.h"
#import "ESFormItem.h"
#import "ESSettingItemView.h"
#import <CoreTelephony/CTCellularData.h>
#import <Masonry/Masonry.h>
#import "ESSecuritySettimgController.h"
#import "ESLoginTerminalVC.h"
#import "ESPushNewsSettingVC.h"
#import "ESSecretVC.h"
#import "ESCommentVC.h"
#import "ESBoxListViewController.h"
#import "ESDeveloperVC.h"
#import "ESCellModel.h"
#import "ESCacheCleanTools.h"
#import "ESSecurityEmailMamager.h"
#import "ESBoxManager.h"
#import "ESAccountInfoStorage.h"
#import "ESV2InstallApp.h"
#import "ESNetworkRequestManager.h"


typedef NS_ENUM(NSUInteger, ESSettingViewType) {
    ESSettingCellTypesecurity,
    ESSettingCellTypeEquipment,
    ESSettingCellTypeTZ,
    ESSettingCellTypeYS,
    ESSettingCellTypeTY,
    ESSettingCellTypeKFZ,
};
@interface ESMeSettingV2 ()

@property (nonatomic, strong) ESSettingItemView *settingItemView;

@property (nonatomic, strong) ESSettingItemView *kFZView;

@property (nonatomic, strong) UIButton *qhzhBtn;

@property (nonatomic, strong) ESCellModel * cacheModel;

@property (nonatomic, strong) ESCellModel * securitySettingModel;

@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, strong) NSMutableArray *dataMutableArray;

@end

@implementation ESMeSettingV2


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if(ESBoxManager.activeBox.boxType == ESBoxTypeMember){
        
    }else{
        if(ESBoxManager.activeBox.boxType == ESBoxTypeAuth){
            [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-account-service"
                                                        apiName:@"admin_get_dev-options_switch"                                                queryParams:@{}
                                                         header:@{}
                                                           body:@{}
                                                      modelName:nil
                                                       successBlock:^(NSInteger requestId, id  _Nullable response) {
                NSDictionary *dic = response;
                if([dic[@"status"] isEqual:@"on"]){
                    self.isOn = YES;
                    [self reloadKFZ];
                    self.kFZView.hidden = NO;
                    if(![ESMemberManager isMemberAuth]){
                        [self.settingItemView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.top.equalTo(self.view.mas_top).offset(30.0f);
                            make.left.equalTo(self.view.mas_left).offset(0.0f);
                            make.right.equalTo(self.view.mas_right).offset(0.0f);
                            make.height.equalTo(@(306.0f));
                        }];
                    }
                
                    [self.kFZView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.settingItemView.mas_bottom).offset(5.0f);
                        make.left.equalTo(self.view.mas_left).offset(0.0f);
                        make.right.equalTo(self.view.mas_right).offset(0.0f);
                        make.height.equalTo([self needShowDeveloperItem] ? @(62.0f) : @(0));
                    }];
                    
                    [self.qhzhBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.kFZView.mas_bottom).offset(5.0f);
                        make.left.equalTo(self.view.mas_left).offset(10.0f);
                        make.right.equalTo(self.view.mas_right).offset(-10.0f);
                        make.height.equalTo(@(62.0f));
                    }];
                    
                    [self loadViewIfNeeded];
                }
            }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
         }];
        }else{
            [self reloadKFZ];
        }
    }
}


- (BOOL)needShowDeveloperItem {
    if (ESBoxManager.activeBox.deviceAbilityModel != nil) {
        return ESBoxManager.activeBox.deviceAbilityModel.aospaceDevOptionSupport &&
        [ESAccountInfoStorage currentAccountIsAdminType];
    }
    return [ESAccountInfoStorage currentAccountIsAdminType];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ESColor.secondarySystemBackgroundColor;
    self.navigationBarBackgroundColor = ESColor.secondarySystemBackgroundColor;
    self.navigationItem.title = TEXT_COMMON_SETTING;
    [self updateConstraints];
    [self loadData];


}

- (void)updateConstraints {

    if(ESBoxManager.activeBox.boxType == ESBoxTypePairing){
        [self.settingItemView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(30.0f);
            make.left.equalTo(self.view.mas_left).offset(0.0f);
            make.right.equalTo(self.view.mas_right).offset(0.0f);
            make.height.equalTo(@(306.0f));
        }];

        [self.kFZView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.settingItemView.mas_bottom).offset(10.0f);
            make.left.equalTo(self.view.mas_left).offset(0.0f);
            make.right.equalTo(self.view.mas_right).offset(0.0f);
            make.height.equalTo([self needShowDeveloperItem] ? @(62.0f) : @(0));
        }];
        
        [self.qhzhBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.kFZView.mas_bottom).offset(10.0f);
            make.left.equalTo(self.view.mas_left).offset(10.0f);
            make.right.equalTo(self.view.mas_right).offset(-10.0f);
            make.height.equalTo(@(62.0f));
        }];
    }else {
        [self.settingItemView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(30.0f);
            make.left.equalTo(self.view.mas_left).offset(0.0f);
            make.right.equalTo(self.view.mas_right).offset(0.0f);
            make.height.equalTo(@(306.0f));
        }];
        self.kFZView.hidden = YES;
        
        [self.qhzhBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.settingItemView.mas_bottom).offset(10.0f);
            make.left.equalTo(self.view.mas_left).offset(10.0f);
            make.right.equalTo(self.view.mas_right).offset(-10.0f);
            make.height.equalTo(@(62.0f));
        }];
    }

}



//2.O
- (void)reloadSetting {
    NSMutableArray<ESFormItem *> *data = NSMutableArray.array;
    //设置
    {
        if(![ESMemberManager isMemberAuth]){
            ESFormItem *item = [ESFormItem new];
            item.row = ESSettingCellTypesecurity;
            item.title = NSLocalizedString(@"security", @"安全");
            item.arrowRight = 16;
            item.contentColor = ESColor.redColor;
            item.content = self.safeStr;
            [data addObject:item];
        }
    }
 
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeEquipment;
        item.title = TEXT_ME_DEVICE_MANAGER;
        item.arrowRight = 16;
        [data addObject:item];
    }
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeTZ;
        item.title = NSLocalizedString(@"Notifications", @"通知");
        item.arrowRight = 16;
        [data addObject:item];
    }
  
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeYS;
        item.title = TEXT_PRIVACY;
        item.arrowRight = 16;
        [data addObject:item];
    }
    
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeTY;
        item.title = TEXT_GENERAL;
        item.arrowRight = 16;
        [data addObject:item];
    }
    data.lastObject.hideLine = YES;
    self.dataMutableArray = data;
    [self.settingItemView reloadWithData:data];
    
    [self.settingItemView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(30.0f);
        make.left.equalTo(self.view.mas_left).offset(0.0f);
        make.right.equalTo(self.view.mas_right).offset(0.0f);
        make.height.equalTo(@(data.count * 60));
    }];
}

- (void)reloadKFZ{
    NSMutableArray<ESFormItem *> *data = NSMutableArray.array;
    //设置
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeKFZ;
        item.title = TEXT_DEVELOPER_OPTIONS;
        item.arrowRight = 16;
        [data addObject:item];
    }

    data.lastObject.hideLine = YES;
    [self.kFZView reloadWithData:data];
}

- (ESSettingItemView *)settingItemView {
    if (!_settingItemView) {
        _settingItemView = [ESSettingItemView new];
        [self.view addSubview:_settingItemView];
        weakfy(self);
        _settingItemView.actionBlock = ^(ESFormItem *item, NSNumber *action) {
            strongfy(self);
            [self onSetting:item action:action.integerValue];
        };
    }
    return _settingItemView;
}

- (ESSettingItemView *)kFZView {
    if (!_kFZView) {
        _kFZView = [ESSettingItemView new];
        [self.view addSubview:_kFZView];
        weakfy(self);
        _kFZView.actionBlock = ^(ESFormItem *item, NSNumber *action) {
            strongfy(self);
            [self onSetting:item action:action.integerValue];
        };
    }
    return _kFZView;
}

- (UIButton *)qhzhBtn {
    if (!_qhzhBtn) {
        UIButton * btn = [[UIButton alloc] init];
        //[btn setTitle:NSLocalizedString(@" password", @"忘记密码") forState:UIControlStateNormal];
        [btn setTitle:TEXT_SWITCHING_ACCOUNT forState:UIControlStateNormal];
        btn.titleLabel.font = ESFontPingFangRegular(16);
        [btn setBackgroundColor:ESColor.systemBackgroundColor];
        [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [btn.layer setCornerRadius:10]; //设置矩圆角半径
        [btn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        btn.layer.masksToBounds = YES;
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(onForgetqhzhBtn) forControlEvents:UIControlEventTouchUpInside];
        _qhzhBtn = btn;
    }
    return _qhzhBtn;
}

- (void)onSetting:(ESFormItem *)item action:(ESSettingViewType)action {
    switch (item.row) {
        case ESSettingCellTypesecurity:{
            ESSecuritySettimgController * ctl = [[ESSecuritySettimgController alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        case ESSettingCellTypeEquipment: {
            ESLoginTerminalVC *ctl = [[ESLoginTerminalVC alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
        } break;

        case ESSettingCellTypeTZ: {
            ESPushNewsSettingVC *ctl = [[ESPushNewsSettingVC alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
        } break;
            
        case ESSettingCellTypeYS: {
            ESSecretVC *ctl = [[ESSecretVC alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
            
        } break;
            
        case ESSettingCellTypeTY: {
            ESCommentVC *ctl = [[ESCommentVC alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
        } break;
            
        case ESSettingCellTypeKFZ: {
            ESDeveloperVC *vc = [[ESDeveloperVC alloc] init];
            vc.isOn = self.isOn;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        
        default:
            break;
    }
}

- (void)loadData {
    [self reloadSetting];
}

-(void)onForgetqhzhBtn{
    ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
    [self.navigationController pushViewController:boxVC animated:NO];
}
@end
