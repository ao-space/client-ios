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
//  ESMeNewListVC1.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMeNewListVC1.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESNewListCell1.h"
#import "ESWebTryPageVC.h"
#import "ESSpaceGatewayNotificationServiceApi.h"
#import "ESMessageIdInfo.h"
#import "ESBoxListViewController.h"
#import <Masonry/Masonry.h>
#import "ESEmptyView.h"
#import "ESLoginTerminalVC.h"
//#import "ESFamilyListVC.h"
#import "MJRefresh.h"
#import "ESUpgradeVC.h"
#import "ESFileDefine.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"
#import "NSString+ESTool.h"
#import "NSDate+Format.h"
#import "ESSecuritySettimgController.h"
#import "NSArray+ESTool.h"
#import "ESBoxBindViewModel.h"
#import "ESMJHeader.h"
#import "ESInvitationActivityVC.h"
#import "ESOptTypeHeader.h"
#import "ESNotifiManager.h"
#import "ESNetworkRequestManager.h"
#import "ESNotificationPageInfoModel.h"


@interface ESMeNewListVC1 ()<UITableViewDelegate, UITableViewDataSource, ESSecuritySettingJumpDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *notificationOptypeFilterList;

@property (nonatomic, strong) ESEmptyView *emptyView;

@property (nonatomic, assign) NSUInteger page;
@property (strong, nonatomic) NSMutableArray<ESNewsModel *> *dataList1;
@property (nonatomic, strong) NSDateFormatter * formatter;
@end

@implementation ESMeNewListVC1

- (void)dealloc {
    
}

- (int)viewModelJump {
    return 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isHaveNews"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ESColor.newsListBg;
    self.navigationItem.title = NSLocalizedString(@"message_center", @"消息中心");
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"清空") style:UIBarButtonItemStylePlain target:self action:@selector(clearClickedOKbtn)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];

    self.page = 1;
    [self addRefresh];
    self.notificationOptypeFilterList = @[@"login",
                                          @"upgrade_success",
                                          @"login_confirm",
                                          @"member_delete",
                                          @"member_self_delete",
                                          @"revoke",
                                          @"member_join",
                                          @"logout",
                                          @"restore_success",
                                          ESSecurityPasswordModifyApply,
                                          ESSecurityPasswordResetApply,
                                          @"security_passwd_mod_succ",
                                          @"security_passwd_reset_succ",
                                          @"security_email_set_succ",
                                          @"security_email_mod_succ",
                                          @"upgrade_download_success",
                                          @"upgrade_installing",
                                          @"applet_operator",
                                          @"upgrade_restart",
                                          @"invite_reward",
                                          @"feedback_reward",
    ];
    
    [self getManagementServiceApi];
    
    /*
     2022-10-09
     新增消息需遵循以下3步：
     1. 在数组 notificationOptypeFilterList 中新增要展示的消息类型；
     2. 在函数 - (ESNewsModel *)transferData:(ESNotificationEntityModel *)entity 中，对相应类型的消息进行展示内容的赋值，其中属性onClick表示是否有“查看详情”的功能，具体可以参考已有的示例。
     3. 自我验证
     */
}

- (void)showClearMsgBtn:(BOOL)show {
    ESPerformBlockOnMainThread(^{
        self.navigationItem.rightBarButtonItem.enabled = show;
        if (show) {
            [self.navigationItem.rightBarButtonItem setTintColor:ESColor.primaryColor];
        } else {
            [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
        }
    });
}

- (ESNewsModel *)transferData:(ESNotificationEntityModel *)entity {
    ESNewsModel * newsModel = [[ESNewsModel alloc] init];
    newsModel.data = entity;
    newsModel.timeStr = [self getTimeStr:entity];
    
    NSDictionary *dic = [self dictionaryWithJsonString:entity.data];
    NSString *optType = entity.optType;
    
    weakfy(self);
    if([optType isEqual:@"login"]){
        newsModel.typeTitle = @"登录提醒";
        newsModel.desTitle = [NSString stringWithFormat:@"您的空间已在 %@ 终端登录。",dic[@"terminalMode"]];
        newsModel.content = @"若非本人操作，请点击“查看详情”，并对终端进行下线操作。";
        newsModel.onClick = ^(ESNotificationEntityModel * _Nonnull data) {
            ESLoginTerminalVC *vc =  [ESLoginTerminalVC new];
            [weak_self.navigationController pushViewController:vc animated:YES];
        };
    }
    else if ([optType isEqual:@"upgrade_success"]) {
        newsModel.typeTitle = NSLocalizedString(@"system_upgrade_notification_title", @"系统升级提醒");
        newsModel.desTitle = @"傲空间系统已经升级到最新版本啦";
        newsModel.content = @"点击“查看详情”，查看更多信息";
        newsModel.onClick = ^(ESNotificationEntityModel * _Nonnull data) {
            ESUpgradeVC *vc = [ESUpgradeVC new];
            [weak_self.navigationController pushViewController:vc animated:YES];
        };
    }
    else if ([optType isEqual:@"login_confirm"]) {
        newsModel.typeTitle = @"免扫码登录提醒";
        NSString *aoId = dic[@"aoid"];
        NSDictionary *aoId_userDomainDic =[[NSUserDefaults standardUserDefaults] objectForKey:@"aoId_userDomain"];
        NSString *aoId_userDomain;
        if (aoId.length > 0) {
            aoId_userDomain = aoId_userDomainDic[aoId];
        }
        newsModel.desTitle = [NSString stringWithFormat:@"%@ 申请登录您的傲空间 (%@)，请及时确认",dic[@"terminalMode"],aoId_userDomain];
        newsModel.content = @"请注意保护空间内的数据安全";
    }
    else if ([optType isEqual:@"member_delete"]) {
        newsModel.typeTitle = @"空间注销提醒";
        newsModel.desTitle = @"您的傲空间已被注销";
        newsModel.content = @"若有疑问，请联系管理员";
    }
    else if ([optType isEqual:@"member_self_delete"]) {
        newsModel.typeTitle = @"空间注销提醒";
        newsModel.desTitle = @"您的傲空间已注销，将无法继续使用";
        newsModel.content = @"若有疑问，请联系管理员";
    }
    else if ([optType isEqual:@"revoke"]) {
        newsModel.typeTitle = @"空间注销提醒";
        newsModel.desTitle = @"您的傲空间已被注销";
        newsModel.content = @"若有疑问，请联系管理员";
    }
    else if ([optType isEqual:@"member_join"]) {
        newsModel.typeTitle = @"成员加入提醒";
        newsModel.desTitle = [NSString stringWithFormat:@"%@ 接受了您的邀请并创建了傲空间",dic[@"nickName"]];
//        newsModel.content = @"点击“查看详情”，查看更多信息";
//        newsModel.onClick = ^(ESNotificationEntity * _Nonnull data) {
//            ESFamilyListVC *vc =  [ESFamilyListVC new];
//            vc.category = TEXT_ME_MEMBER;
//            [weak_self.navigationController pushViewController:vc animated:YES];
//        };
    }
    else if ([optType isEqual:@"logout"]) {
        newsModel.typeTitle = @"下线提醒";
        newsModel.desTitle = @"您登录的空间已失效";
        newsModel.content = @"若要继续使用，请重新进行扫码授权";
    }
    /// 账户安全提醒：", "您正在终端 %s 上进行安全密码相关操作，请及时确认
    else if ([optType isEqual:ESSecurityPasswordModifyApply] || [optType isEqual:ESSecurityPasswordResetApply]) {
        newsModel.typeTitle = @"账户安全提醒";
        NSString *terminalMode = dic[@"authDeviceInfo"];
        if (terminalMode.length > 0){
            newsModel.desTitle = [NSString stringWithFormat:@"您正在终端 %@ 上进行安全密码相关操作，请及时确认",terminalMode];
        } else{
            newsModel.desTitle = [NSString stringWithFormat:@"您正在终端上进行安全密码相关操作，请及时确认"];
        }
        
        newsModel.content = @"请注意保护空间内的数据安全";
    }
    else if ([optType isEqual:@"security_passwd_mod_succ"]) {
        newsModel.typeTitle = @"账户安全提醒";
        newsModel.desTitle = @"安全密码修改成功，请知晓！";
        newsModel.content = @"若非本人操作，请在【我的-设置-安全设置】里重置安全密码";
        newsModel.onClick = ^(ESNotificationEntityModel * _Nonnull data) {
            ESSecuritySettimgController * ctl = [[ESSecuritySettimgController alloc] init];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
    }
    /// 里重置安全密码
    else if ([optType isEqual:@"security_passwd_reset_succ"]) {
        newsModel.typeTitle = @"账户安全提醒";
        newsModel.desTitle = @"安全密码重置成功，请知晓！";
        newsModel.content = @"若非本人操作，请在【我的-设置-安全设置】里重置安全密码";
        newsModel.onClick = ^(ESNotificationEntityModel * _Nonnull data) {
            ESSecuritySettimgController * ctl = [[ESSecuritySettimgController alloc] init];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
    }
    else if ([optType isEqual:@"upgrade_download_success"]) {
        NSData *jsonData = [entity.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *versionInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
        NSString *version = versionInfo[@"version"];
        version = [version stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        newsModel.typeTitle = NSLocalizedString(@"system_upgrade_notification_title", @"系统升级提醒");
        newsModel.desTitle = [NSString stringWithFormat: @"“傲空间 %@”可用于您的设备，且已经可以安装", ESSafeString(version)] ;
        newsModel.content = @"点击“查看详情”，查看更多信息";
        newsModel.onClick = ^(ESNotificationEntityModel * _Nonnull data) {
            ESUpgradeVC *vc = [ESUpgradeVC new];
            [weak_self.navigationController pushViewController:vc animated:YES];
        };
    }
    else if ([optType isEqual:@"upgrade_installing"]) {
        newsModel.typeTitle = NSLocalizedString(@"system_upgrade_notification_title", @"系统升级提醒");
        newsModel.desTitle = @"正在安装系统更新，傲空间设备可能无法正常访问，升级完成后将自动恢复使用";
    }
    else if ([optType isEqual:@"restore_success"]) {
        newsModel.typeTitle = @"数据恢复提醒";
        newsModel.desTitle = @"您的空间数据已完成恢复操作，如有疑问，请联系管理员";
    }
    //傲应用卸载
    else if ([ optType isEqual:@"applet_operator"] || [optType.lowercaseString isEqual:@"uninstall"] ) {
        NSDictionary *appletInfo = dic[@"appletInfoRes"];
        newsModel.typeTitle = ESSafeString(appletInfo[@"name"]);
        newsModel.desTitle = [NSString stringWithFormat:@"管理员已卸载傲空间应用【%@】，您将无法继续使用，如有疑问，请联系管理员", appletInfo[@"name"]];
    } else if ([ optType isEqual:@"upgrade_restart"] ) {
        newsModel.typeTitle = NSLocalizedString(@"system_upgrade_notification_title", @"系统升级提醒");
        newsModel.desTitle = NSLocalizedString(@"message_systemRestart", @"正在重启设备，请在重启完成后使用");
    } else if ([ optType isEqual:@"invite_reward"] ) {
        newsModel.typeTitle = @"邀请有礼"; //NSLocalizedString(@"album_memories", @"回忆");
        newsModel.desTitle = @"恭喜您在邀请有礼活动中，获得精美礼品一份，查看详情";
        newsModel.onClick = ^(ESNotificationEntityModel * _Nonnull data) {
            ESInvitationActivityVC *vc = [[ESInvitationActivityVC alloc] init];
            vc.activityType = ESInvitationActivityType_Trail;
            [self.navigationController pushViewController:vc animated:YES];
        };
    } else if ([ optType isEqual:@"feedback_reward"] ) {
        newsModel.typeTitle = @"反馈有礼"; //NSLocalizedString(@"album_memories", @"回忆");
        newsModel.desTitle = @"恭喜您在反馈有礼活动中，获得精美礼品一份，查看详情";
        newsModel.onClick = ^(ESNotificationEntityModel * _Nonnull data) {
            ESInvitationActivityVC *vc = [[ESInvitationActivityVC alloc] init];
            vc.activityType = ESInvitationActivityType_Proposal;
            [self.navigationController pushViewController:vc animated:YES];
        };
    }

    return newsModel;
}

- (void)addRefresh {
    weakfy(self);
    // 下拉刷新
    self.tableView.mj_header = [ESMJHeader headerWithRefreshingBlock:^{
        [weak_self getManagementServiceApi];
    }];

    // 上拉加载
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weak_self getManagementServiceApiMoreLoad];
    }];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList1.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESNewListCell1 * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    ESNewsModel * model = [self.dataList1 getObject:indexPath.row];
    cell.model1 = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESNewsModel * model = [self.dataList1 getObject:indexPath.row];
    if (model.onClick) {
        model.onClick(model.data);
    }
}

- (BOOL)shouldShowNotificationInfoWith:(ESNotificationEntityModel *)item {
    NSString *optType = item.optType;
    if ([self shouldCheckNotificationInfo:item]) {
        return [self shouldShowNotificationInfo:item];
    }
    return [self.notificationOptypeFilterList containsObject:ESSafeString(optType)];
}

- (BOOL)shouldCheckNotificationInfo:(ESNotificationEntityModel *)item {
    NSString *optType = item.optType;
    return [self.notificationInfoOptList.allKeys containsObject:ESSafeString(optType)];
}

- (BOOL)shouldShowNotificationInfo:(ESNotificationEntityModel *)item {
    NSString *optType = item.optType;
    NSData *jsonData = [item.data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *notificationInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&err];
    if (err) {
        return NO;
    }
    return [self.notificationInfoOptList[optType] containsObject:ESSafeString(notificationInfo[@"appletOperatorType"])];
}

- (NSDictionary *)notificationInfoOptList {
    return @{@"applet_operator" : @[ @"UNINSTALL"] };
}

- (void)getManagementServiceApi {
    self.page = 1;
    [self.tableView.mj_footer setHidden:NO];
    
    NSDictionary * query = @{@"AccessToken-clientUUID":ESBoxManager.clientUUID};
    NSDictionary * body = @{@"page":@(1), @"pageSize":@(50)};
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-account-service" apiName:@"notification_get_all" queryParams:query header:nil body:body modelName:@"ESNotificationPageInfoModel" successBlock:^(NSInteger requestId, ESNotificationPageInfoModel * response) {
        self.dataList1 = [NSMutableArray new];
        NSArray *ary =  response.notification;
        [self showClearMsgBtn:(ary.count > 0)];

        if (ary.count > 0) {
            for (int i = 0; i < ary.count; i++) {
                ESNotificationEntityModel *entity =ary[i];
                if ([self shouldShowNotificationInfoWith:entity]) {
                    [self.dataList1 addObject:[self transferData:entity]];
                }
            }
        }
        if(self.dataList1.count < 1){
            self.emptyView.hidden = NO;
        }else{
            self.emptyView.hidden = YES;
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)getManagementServiceApiMoreLoad {
    self.page ++;
    
    NSDictionary * query = @{@"AccessToken-clientUUID":ESBoxManager.clientUUID};
    NSDictionary * body = @{@"page":@(self.page), @"pageSize":@(50)};
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-account-service" apiName:@"notification_get_all" queryParams:query header:nil body:body modelName:@"ESNotificationPageInfoModel" successBlock:^(NSInteger requestId, ESNotificationPageInfoModel * response) {
        if (response.pageInfo.total >= self.page) {
            NSArray *ary =  response.notification;
            self.page = response.pageInfo.page;
            if (ary.count > 0) {
                for (int i = 0; i < ary.count; i++) {
                    ESNotificationEntityModel *entity =ary[i];
                    if ([self shouldShowNotificationInfoWith:entity]) {
                        [self.dataList1 addObject:[self transferData:entity]];
                    }
                }
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
            }
        }else{
            self.tableView.mj_footer.state  = MJRefreshStateNoMoreData;
            [self.tableView.mj_footer setHidden:NO];
        }
        
        if(self.dataList1.count < 1){
            self.emptyView.hidden = NO;
        }else{
            self.emptyView.hidden = YES;
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.tableView.mj_footer endRefreshing];
        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
    }];
}

-(void)clearClickedOKbtn {
    ESSpaceGatewayNotificationServiceApi *api = [[ESSpaceGatewayNotificationServiceApi alloc] init];
    [api spaceV1ApiNotificationAllDeletePostWithAccessTokenClientUUID:ESBoxManager.clientUUID body:nil completionHandler:^(ESResponseBaseLong *output, NSError *error) {
        if (error) {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        } else {
            [self showClearMsgBtn:NO];
            [self.tableView reloadData];
            self.emptyView.hidden = NO;
            [ESToast toastSuccess:NSLocalizedString(@"message_clearAll", @"已清空所有消息")];
        }
    }];
}

- (ESEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[ESEmptyView alloc] initWithFrame:self.tableView.bounds];
        ESEmptyItem *item = [ESEmptyItem new];
        item.icon = IMAGE_EMPTY_NO_NEWS;
        item.content = NSLocalizedString(@"message_none", @"暂无消息");
        [_emptyView reloadWithData:item];
        [self.view addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.tableView);
        }];
    }
    return _emptyView;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
        _formatter = formatter;
    }
    return _formatter;
}

- (NSString *)getTimeStr:(ESNotificationEntityModel *)model {
    if (model == nil || model.createAt == nil) {
        return @"";
    }
    
    NSString *time;
    NSDate * date = [self.formatter dateFromString:model.createAt];
    NSString *timeStr = [self compareDate:date];
    if ([timeStr isEqual:@"今天"]) {
        time = [date stringFromFormat:@"HH:mm"];
    } else if([timeStr isEqual:@"昨天"]) {
        time = [date stringFromFormat:@"HH:mm"];
        time = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ES_Yesterday", @"昨天"), time];
    } else {
        time = [date stringFromFormat:@"YYYY-MM-dd HH:mm"];
    }
    return time;
}


- (NSString *)compareDate:(NSDate *)date{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;

    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];

// 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];

    NSString * dateString = [[date description] substringToIndex:10];

    if ([dateString isEqualToString:todayString])
    {
        return @"今天";
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return @"昨天";
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return dateString;
    }
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
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

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.backgroundColor = ESColor.newsListBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESNewListCell1 class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(0.0f);
            make.left.mas_equalTo(self.view).offset(0);
            make.bottom.mas_equalTo(self.view).offset(-kBottomHeight);
            make.right.mas_equalTo(self.view).offset(0);
        }];
    }
    return _tableView;
}


@end
