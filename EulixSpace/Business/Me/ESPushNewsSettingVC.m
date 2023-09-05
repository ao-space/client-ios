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
//  ESPushNewsSettingVC.m
//  EulixSpace
//
//  Created by qu on 2022/5/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPushNewsSettingVC.h"
#import "ESAccountManager.h"
#import "ESFormCell.h"
#import "ESNetworking.h"
#import "ESThemeDefine.h"
#import "UIColor+ESHEXTransform.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>
#import "ESLoopPollManager.h"

typedef NS_ENUM(NSUInteger, ESSyncNewsType) {
    ESSyncSettingTypeSystemNews,
    ESSyncSettingBusinessTypeNews
};

@interface ESPushNewsSettingVC()
@property (strong,nonatomic) UILabel *titleLable;

@property (strong,nonatomic) UISwitch *systemNews;

@property (strong,nonatomic) UILabel *systemNewsTitle;

@property (strong,nonatomic) UILabel *systemNewsPointOut;

@property (strong,nonatomic) UISwitch *businessNews;

@property (strong,nonatomic) UILabel *businessNewsTitle;

@property (strong,nonatomic) UILabel *businessNewsPointOut;

@end

@implementation ESPushNewsSettingVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =  NSLocalizedString(@"Notifications", @"通知");;
    self.cellClass = [ESFormCell class];
    self.section = @[@(0)];
    self.tableView.scrollEnabled = NO;
    //后台进前台通知 UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self addSwitch];
}


- (void)onSyncSettingChanged {
    
}

#pragma mark - Action

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    if (!action) {
        return;
    }
  
    ESFormItem *item = [self objectAtIndexPath:indexPath];
    switch (item.row) {
        case ESSyncSettingTypeSystemNews: {
            if (@available(iOS 10.0, *)) {
                
            }
            if (UIApplicationOpenSettingsURLString != NULL) {
                UIApplication *application = [UIApplication sharedApplication];
                NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                    [application openURL:URL options:@{} completionHandler:nil];
                    [self loadData];
                }
            }
        } break;
        case ESSyncSettingBusinessTypeNews: {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"downingAllStartBtnNotification" object:@(1)];
        } break;
        default:
            break;
    }
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

- (void)didBecomeActive:(NSNotification *)notification {
    if (@available(iOS 10.0, *)) {
        
    }
}

- (void)addSwitch {
    UIView *labelBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0 ,ScreenWidth, 30)];
    labelBg.backgroundColor = ESColor.secondarySystemBackgroundColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(28, 8, 100, 14)];
    label.text = NSLocalizedString(@"accept_notification_message_type", @"接收通知消息类型");
    label.textColor = ESColor.secondaryLabelColor;
    label.font = [UIFont systemFontOfSize:12];
    [labelBg addSubview:label];
    [self.view  addSubview:labelBg];


    self.systemNewsTitle = [UILabel new];
    [self.view addSubview:self.systemNewsTitle];
    self.systemNewsTitle.textColor = ESColor.labelColor;
    self.systemNewsTitle.textAlignment = NSTextAlignmentLeft;
    self.systemNewsTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.systemNewsTitle.text = NSLocalizedString(@"system_message", @"系统消息");
    [self.systemNewsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(labelBg.mas_bottom).offset(20.0);
        make.height.mas_equalTo(22.0);

    }];
    
    self.systemNewsPointOut = [UILabel new];
    [self.view addSubview: self.systemNewsPointOut];
    self.systemNewsPointOut.text = NSLocalizedString(@"system_message_hint", @"系统通知、系统升级消息");
    self.systemNewsPointOut.textColor = ESColor.secondaryLabelColor;
    self.systemNewsPointOut.textAlignment = NSTextAlignmentLeft;
    self.systemNewsPointOut.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    [self.systemNewsPointOut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(self.systemNewsTitle.mas_bottom).offset(2.0);
        make.height.mas_equalTo(22.0);
      
    }];
    
    self.systemNews = [[UISwitch alloc] init];
    [self.systemNews setOn:[[ESLoopPollManager Instance] isReceiveSystemInfo]];

    [self.view addSubview:self.systemNews ];
    [self.systemNews addTarget:self
                  action:@selector(systemSwitched:)
        forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.systemNews];
    [self.systemNews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-28.0);
        make.centerY.mas_equalTo(self.systemNewsTitle);
        make.height.mas_equalTo(30.0);

    }];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.right.mas_equalTo(self.view.mas_right).offset(-26);
        make.top.mas_equalTo(self.systemNewsPointOut.mas_bottom).offset(20);
        make.height.mas_equalTo(1);
    }];
    
    
    self.businessNewsTitle = [UILabel new];
    [self.view addSubview:self.businessNewsTitle];
    self.businessNewsTitle.textColor = ESColor.labelColor;
    self.businessNewsTitle.textAlignment = NSTextAlignmentLeft;
    self.businessNewsTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.businessNewsTitle.text = NSLocalizedString(@"business_message", @"业务消息");
    [self.businessNewsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(self.systemNewsPointOut.mas_bottom).offset(40.0);
        make.height.mas_equalTo(22.0);

    }];
    
    self.businessNewsPointOut = [UILabel new];
    [self.view addSubview: self.businessNewsPointOut];
    self.businessNewsPointOut.text = NSLocalizedString(@"business_message_hint", @"登录、文件更新、成员管理等消息");
    self.businessNewsPointOut.textColor = ESColor.secondaryLabelColor;
    self.businessNewsPointOut.textAlignment = NSTextAlignmentLeft;
    self.businessNewsPointOut.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
 
    [self.businessNewsPointOut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0);
        make.top.mas_equalTo(self.businessNewsTitle.mas_bottom).offset(2.0);
        make.height.mas_equalTo(22.0);

    }];
    

    
    self.businessNews = [UISwitch new];
    [self.businessNews setOn:[[ESLoopPollManager Instance] isReceiveBusinessInfo]];
    [self.view addSubview:self.businessNews];
    [self.businessNews addTarget:self
                  action:@selector(businessSwitched:)
        forControlEvents:UIControlEventValueChanged];


    [self.view addSubview:self.businessNews];
    [self.businessNews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-28.0);
        make.centerY.mas_equalTo(self.businessNewsTitle);
        make.height.mas_equalTo(30.0);

    }];
}

- (void)businessSwitched:(UISwitch *)sender {
    [[ESLoopPollManager Instance] setBusinessInfo:sender.on];
}

- (void)systemSwitched:(UISwitch *)sender {
    [[ESLoopPollManager Instance] setSystemInfo:sender.on];
}
@end


