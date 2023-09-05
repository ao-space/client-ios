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
//  ESV2FileListVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESV2FileListVC.h"
#import "ESRecycledApi.h"
#import "ESBoxManager.h"
#import "ESNetworkRequestManager.h"

@interface ESV2FileListVC()

@end

@implementation ESV2FileListVC

- (void)loadView {
    [super loadView];
    self.category = @"v2FileListVC";
    self.blankSpaceView.hidden = YES;
    [self getFileRequestStart];

}

- (void)viewDidLoad {
    [super viewDidLoad];
   
}


- (void)getFileRequestStart {
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                    apiName:@"history_record_detail"                                                queryParams:@{@"userId" : ESBoxManager.clientUUID,
                                                                                                                                                  @"recordId" :self.recordid}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        [ESToast dismiss];
        NSMutableArray * dataList = [NSMutableArray new];
        NSDictionary * dic = response;
        for (NSDictionary *dic1 in dic[@"recordList"]) {
            ESFileInfoPub *model = [ESFileInfoPub yy_modelWithJSON:dic1];
            [dataList addObject:model];
        }
        self.children = dataList;
        if(self.children.count > 0){
            self.blankSpaceView.hidden = YES;
        }else{
            self.blankSpaceView.hidden = NO;
        }
        self.current.children = self.children;
        [self.current reloadData];
        [self.listView reloadData];
    }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
         [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        self.blankSpaceView.hidden = NO;
    }];
}

- (void)addRefresh {
    
}
- (void)getFileRequestMoreStart:(NSString *)fileUUID {
    
}



@end
