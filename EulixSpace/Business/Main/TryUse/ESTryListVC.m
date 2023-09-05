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
//  ESTryListVC.m
//  EulixSpace
//
//  Created by qu on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTryListVC.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESTryListCell.h"
#import "ESWebTryPageVC.h"
#import "ESPlatformQuestionnaireManagementServiceApi.h"
#import <Masonry/Masonry.h>

@interface ESTryListVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray<ESQuestionnaireRes *> *dataList;

@property (assign, nonatomic) int num;
@end

@implementation ESTryListVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.num = 0;
    [self getManagementServiceApi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"试用反馈列表";
    [self initUI];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.tableView.backgroundColor = ESColor.systemBackgroundColor;
    self.dataList = nil;

}

- (void)initUI {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(0.0f);
        make.left.mas_equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.view).offset(-kBottomHeight);
        make.right.mas_equalTo(self.view).offset(0);
    }];
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 84) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESTryListCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                         @"ESTryListCellCellID"];
    if (cell == nil) {
        cell = [[ESTryListCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESTryListCellCellID"];
    }
    if (self.dataList.count > indexPath.row) {
        cell.model = self.dataList[indexPath.row];
    }
    if (indexPath.row != self.dataList.count - 1) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25, 79, ScreenWidth - 50, 1)];
        lineView.backgroundColor = ESColor.separatorColor;
        [cell.contentView addSubview:lineView];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESWebTryPageVC *webVC = [ESWebTryPageVC new];
    webVC.actionBlock = ^() {
        [self initUI];
    };
    ESQuestionnaireRes *model = self.dataList[indexPath.row];
    if ([model.state isEqual:@"completed"]) {
        [ESToast toastError:@"反馈已提交，感谢您的支持"];
        return;
    } else if ([model.state isEqual:@"not_start"]) {
        [ESToast toastError:@"未到开始时间，暂不支持填写"];
        return;
    } else if ([model.state isEqual:@"in_process"]) {
    } else if ([model.state isEqual:@"has_end"]) {
        return;
    }
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *userId = dic[@"aoId"];
    NSString *openID = [NSString stringWithFormat:@"%@,%@",ESBoxManager.activeBox.boxUUID,userId];
    NSString *baseOpenID = [self base64encode:openID];
    webVC.contentUrl = [NSString stringWithFormat:@"%@?openid=%@", model.content, baseOpenID];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)getManagementServiceApi {
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    ///112
    NSString *userId = dic[@"aoId"];
    NSURL *requesetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",  ESPlatformClient.platformClient.platformUrl]];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    ESPlatformQuestionnaireManagementServiceApi *api = [[ESPlatformQuestionnaireManagementServiceApi alloc] initWithApiClient:client];
    [api questionnaireListWithCurrentPage:@(1)
                                 pageSize:@(100)
                                 userId:  userId
                                 boxUuid: ESBoxManager.activeBox.boxUUID
                        completionHandler:^(ESPageListResultQuestionnaireRes *output, NSError *error) {
        if(error){
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
                            self.dataList = output.list;
                            int num = 0;
                            for (int i = 0; i < self.dataList.count; i++) {
                                ESQuestionnaireRes *model = self.dataList[i];
                                if([model.state isEqual:@"in_process"]){
                                    int inProcessNum = 0;
                                    for (ESQuestionnaireRes *questionnaireRes in self.dataList) {
                                        NSDate *now = [NSDate date];
                                        NSComparisonResult result = [questionnaireRes.endAt compare:now];
                                        if (result != NSOrderedDescending && [questionnaireRes.state isEqual:@"in_process"]) {
                                            num = num + 1;
                                        }
                                        if([questionnaireRes.state isEqual:@"in_process"]){
                                            inProcessNum =  inProcessNum + 1;
                                        }
                                    }
                                    if(ESBoxManager.activeBox.boxType == ESBoxTypePairing){
                                        if (num > 0) {
                                            self.navigationItem.hidesBackButton = YES;
                                        } else {
                                            self.navigationItem.hidesBackButton = NO;
                                        }
                                    }else{
                                        self.navigationItem.hidesBackButton = NO;
                                    }
                                }
                            }
                            if(num == 0){
                                self.navigationItem.hidesBackButton = NO;
                            }
                            [self.tableView reloadData];
                        }];
}


- (NSString*)base64encode:(NSString*)str {

    // 1.把字符串转成二进制数据
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];

}

@end
