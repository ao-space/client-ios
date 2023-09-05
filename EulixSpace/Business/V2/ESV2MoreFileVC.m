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
//  ESV2MoreFileVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESV2MoreFileVC.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESNetworkRequestManager.h"
#import "ESToast.h"
#import "ESV2MoreCell.h"
#import "ESWebTryPageVC.h"
#import "ESFileInfoPub.h"
#import "NSObject+YYModel.h"
#import "ESPlatformQuestionnaireManagementServiceApi.h"
#import <Masonry/Masonry.h>


@interface ESV2MoreFileVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray<ESQuestionnaireRes *> *dataList;


@property (assign, nonatomic) int num;
@end

@implementation ESV2MoreFileVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.num = 0;
  //  [self getManagementServiceApi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.name;
    [self initUI];
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
    ESV2MoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                         @"ESV2MoreCellID"];
    if (cell == nil) {
        cell = [[ESV2MoreCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESV2MoreCellID"];
    }

    //cell.model = self.dataList[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (NSString*)base64encode:(NSString*)str {
    // 1.把字符串转成二进制数据
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (void)getFileRequestStart {

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                apiName:@"history_record_detail"                                                queryParams:@{@"userId" : ESBoxManager.clientUUID,
                                                                  @"recordId" :self.recordid}
                                                 header:@{}
                                                   body:@{}
                                              modelName:nil
                                           successBlock:^(NSInteger requestId, id  _Nullable response) {
        NSMutableArray * dataList = [NSMutableArray new];
        NSDictionary * dic = response;
        for (NSDictionary *dic1 in dic[@"recordList"]) {
            ESFileInfoPub *model = [ESFileInfoPub yy_modelWithJSON:dic1];
            [dataList addObject:model];
        }
  }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
      //  self.blankSpaceView.hidden = NO;
 }];
}

@end
