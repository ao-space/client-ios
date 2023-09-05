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
//  ESEadvancedVC.m
//  EulixSpace
//
//  Created by qu on 2022/01/09.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESEadvancedVC.h"
#import "ESKFZSettingCell.h"
#import <Masonry/Masonry.h>
#import "NSArray+ESTool.h"
#import "ESCacheCleanTools.h"
#import "ESToast.h"
#import "ESBoxManager.h"
#import "ESLocalizableDefine.h"
#import "ESPushNewsSettingVC.h"
#import "ESAboutViewController.h"
#import "ESSecuritySettimgController.h"
#import "ESAccountInfoStorage.h"
#import "ESSettingCacheManagerVC.h"
#import "ESCacheCleanTools+ESBusiness.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "ESSecurityEmailMamager.h"
#import "ESV2PowerVC.h"
#import "ESLanguageVC.h"
#import "ESInputSettingVC.h"
#import "ESDeveloInfo.h"
#import "ESKFZSettingDelCell.h"
#import "ESPostSettingCell.h"
#import "ESMeSettingCell.h"
#import "ESKFZSettingVariableCell.h"
#import "ESNetWorkSettingCell.h"
#import "ESDevelopSettingView.h"

@interface ESEadvancedVC ()<UITableViewDelegate,UITableViewDataSource,ESDevelopSettingViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) ESDeveloInfo * cacheModel;
@property (nonatomic, strong) ESDeveloInfo * securitySettingModel;

@property (nonatomic, strong) ESSecurityEmailSetModel * emailInfo;

@property (nonatomic, strong) ESDevelopSettingView * sortView;

@property (nonatomic, strong) NSString * domin;

@property (nonatomic, assign) BOOL isLastCell;

@property (nonatomic, assign) BOOL isLastCell1;

@property (nonatomic, assign) BOOL isLastCell3;

@property (nonatomic, strong) NSMutableArray * volumes;

@property (nonatomic, strong) NSMutableArray * environments;
@end

@implementation ESEadvancedVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.volumes = [[NSMutableArray alloc] init];
    self.environments = [[NSMutableArray alloc] init];
    
    self.actionInstallBlock = ^(NSMutableArray *array,NSMutableArray *array2,NSMutableArray *array3,NSMutableArray *array4) {
            NSMutableArray *list = [NSMutableArray new];
            for(int i = 0; i< self.dataArr.count; i++){
                if(i == 0 && array.count > 0){
                        NSMutableArray *array1 = [NSMutableArray new];
                        NSArray *data1 = self.dataArr[0];
                        for(int j = 0; j< data1.count; j++){
                            ESDeveloInfo * model = data1[j];
                            for (NSNumber *z in array) {
                                if(z.intValue == j){
                                    model.isHaveError = YES;
                                }
                            }
                            [array1 addObject:model];
                        }
                        [list addObject:array1];
                }else if(i == 0 && array.count <1 ){
                    NSMutableArray *array1 = [NSMutableArray new];
                    NSArray *data1 = self.dataArr[0];
                    for(int j = 0; j< data1.count; j++){
                        ESDeveloInfo * model = data1[j];
                        model.isHaveError = NO;
                        [array1 addObject:model];
                    }
                    [list addObject:array1];
                }
                else if(i == 1 && array2.count > 0){
                        NSMutableArray *array = [NSMutableArray new];
                        NSArray *data1 = self.dataArr[1];
                        for(int j = 0; j< data1.count ; j++){
                            ESDeveloInfo * model = data1[j];
                            model.errorDic = array3[j];
                            [array addObject:model];
                        }
                        [list addObject:array];
                }else if(i == 1 && array2.count < 1){
                    NSMutableArray *array = [NSMutableArray new];
                    NSArray *data1 = self.dataArr[1];
                    for(int j = 0; j< data1.count ; j++){
                        ESDeveloInfo * model = data1[j];
                        model.errorDic = [NSMutableDictionary new];
                        [array addObject:model];
                    }
                    [list addObject:array];
                }
                else {
                    if(array4.count > 0 && i == 3){
                        NSMutableArray *arrayModel3 = [NSMutableArray new];
                        NSArray *data3 = self.dataArr[3];
                        for(int i = 0; i< data3.count; i++){
                            ESDeveloInfo * model = data3[i];
                            if(i != data3.count - 1){
                                model.isHaveError = YES;
                                if([array4 containsObject:@(i)]){
                                    model.errorArray = array4;
                                }else{
                                    model.errorArray = [NSArray new];
                                }
                                [arrayModel3 addObject:model];
                            }else{
                                [arrayModel3 addObject:model];
                            }
                        }
                        [list addObject:arrayModel3];
                    }else{
                        NSMutableArray *arrayModel3 = [NSMutableArray new];
                        NSArray *data3 = self.dataArr[3];
                        for(int i = 0; i< data3.count; i++){
                            ESDeveloInfo * model = data3[i];
                            model.errorArray = [NSArray new];
                            [arrayModel3 addObject:model];
                        }
                        [list addObject:self.dataArr[i]];
                    }
                }
            }
            
            self.dataArr = list;
            [self.tableView reloadData];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    NSMutableArray *type1 = [NSMutableArray array];
    weakfy(self)
//    {
//        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
//        model.title = @"容器内部路径  /";
//        //        model.value = self.dicData[@"imageName"];
//        model.hasArrow = YES;
//        model.lastCell = NO;
//        model.onClick = ^{
//            ESLanguageVC * ctl = [ESLanguageVC new];
//            [weak_self.navigationController pushViewController:ctl animated:YES];
//        };
//        [type1 addObject:model];
//        self.securitySettingModel = model;
//
//    }
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.lastCell = YES;
        model.hasArrow = YES;
        self.isLastCell1 = YES;
        model.onClick = ^{
        
        };
        [type1 addObject:model];
        self.securitySettingModel = model;
        
    }
    [self.dataArr addObject:type1];
    
    NSMutableArray *type2 = [NSMutableArray array];
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.title = NSLocalizedString(@"container_publish_port", @"容器发布端口");
        model.isFirst  = YES;
        model.value = @"8000";
        model.value1 = NSLocalizedString(@"internal_port", @"内部端口");;
        model.value2 = NSLocalizedString(@"http_request_forward", @"http请求转发");
        model.hasArrow = YES;
        model.lastCell = NO;
        model.onClick = ^{
            ESLanguageVC * ctl = [ESLanguageVC new];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [type2 addObject:model];
        self.securitySettingModel = model;
    }
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.lastCell = YES;
        model.hasArrow = YES;
        self.isLastCell = YES;
        model.onClick = ^{
        };
        [type2 addObject:model];
        self.securitySettingModel = model;
    }
    [self.dataArr addObject:type2];
    
    NSMutableArray *type3 = [NSMutableArray array];
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.title = NSLocalizedString(@"box_network_setup", @"网络设置");
        model.value = @"bridge";
        model.isSelected = NO;
        //        model.value = self.dicData[@"imageName"];
        model.hasArrow = NO;
        model.lastCell = NO;
        model.onClick = ^{
            ESLanguageVC * ctl = [ESLanguageVC new];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [type3 addObject:model];
        self.securitySettingModel = model;
    }
  
    [self.dataArr addObject:type3];
    
    NSMutableArray *type4 = [NSMutableArray array];
//    {
//        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
//        model.title = @"容器内部路径  /";
//        //        model.value = self.dicData[@"imageName"];
//        model.hasArrow = YES;
//        model.lastCell = NO;
//        model.onClick = ^{
//            ESLanguageVC * ctl = [ESLanguageVC new];
//            [weak_self.navigationController pushViewController:ctl animated:YES];
//        };
//        [type4 addObject:model];
//        self.securitySettingModel = model;
//    }
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.lastCell = YES;
        model.hasArrow = YES;
        model.onClick = ^{
            
        };
        [type4 addObject:model];
        self.securitySettingModel = model;
    }
    [self.dataArr addObject:type4];

    [self.tableView reloadData];
}

- (void)clearCache {
    weakfy(self);
    [ESCacheCleanTools clearAllCache];
    [ESToast toastSuccess:TEXT_ME_ALREADY_CLEARED_CACHE];
    [ESCacheCleanTools cacheSizeWithCompletion:^(NSString *size) {
        [weak_self initData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        NSMutableArray *array;
        if(self.dataArr.count > 0){
            array = self.dataArr[0];
            if(array.count > 0){
                return array.count;
            }
        }
    }else if(section == 1){
        NSMutableArray *array;
        if(self.dataArr.count > 1){
            array = self.dataArr[1];
            if(array.count > 0){
                return array.count;
            }
        }
    }
    else if(section == 3){
        if(self.dataArr.count > 3){
            NSArray *array = self.dataArr[3];
            return array.count;
        }
    }
    else {
        return 1;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.section == 0){
        NSString *cellID = [NSString stringWithFormat:@"ESKFZSettingCell%ld%ld",indexPath.section,indexPath.row];
        ESKFZSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
      
        if (cell == nil) {
            cell = [[ESKFZSettingCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellID];
        }
        
        cell.actionDelBlock =^(NSString *str)  {
            if(self.dataArr.count > 0){
                NSArray *array = self.dataArr[0];
                ESDeveloInfo * model = array[array.count - 1];
                if(indexPath.row == array.count - 1 && model.lastCell){
                   [self addCell];
                }else{
                    [self delCell:indexPath];
                }
                [self.tableView reloadData];
            }
        };
        
        cell.actionBlock = ^(NSString* path)  {
            [self.volumes addObject:[NSString stringWithFormat:@"/%@",path]];
            NSMutableArray *list = [NSMutableArray new];
            for(int i = 0; i< self.dataArr.count; i++){
                if(i == 0){
                    NSMutableArray *array = [NSMutableArray new];
                    NSArray *data1 = self.dataArr[0];
                    for(int i = 0; i< data1.count; i++){
                        ESDeveloInfo * model  = data1[i];
                        if(indexPath.row == i){
                            model.value = path;
                        }
                        if(i == 0){
                            model.volumes = self.volumes;
                            [array addObject:model];
                        }else{
                            [array addObject:model];
                        }
                    }
                    [list addObject:array];
                }else{
                    [list addObject:self.dataArr[i]];
                }
            }
            self.dataArr = list;
            [self.tableView reloadData];
        };

        if(self.dataArr.count > 0){
            NSArray *array = self.dataArr[0];
            ESDeveloInfo * model = [array getObject:indexPath.row];
            cell.model = model;
            return cell;
        }
    }else if(indexPath.section == 1) {
        NSString *cellID = [NSString stringWithFormat:@"ESPostSettingCell%ld%ld",indexPath.section,indexPath.row];
        ESPostSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[ESPostSettingCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellID];
        }
        cell.actionBlockPort =^(NSString *str)  {
            self.sortView.type = @"port";
            self.sortView.tag  = indexPath.row;
            self.sortView.value = str;
            self.sortView.hidden = NO;
        };
        
        cell.actionBlockHttp =^(NSString *str)  {
            self.sortView.type = @"http";
            self.sortView.value = str;
            self.sortView.tag  = indexPath.row;
            self.sortView.hidden = NO;
        };
        
        cell.actionDel =^(NSString *str)  {
            if(indexPath.row == 0){
                return;
            }
            if(self.dataArr.count > 1){
                NSArray *array = self.dataArr[1];
                if(self.isLastCell == YES){
                    if(indexPath.row == array.count - 1){
                          [self addCell2];
                    }else{
                        if(array.count > 2){
                            [self delCell2:indexPath];
                        }
                    }
                }else{
                    if(indexPath.row == array.count - 1){
                        [self delCell2:indexPath];
                    }else{
                        if(array.count > 2){
                            [self delCell2:indexPath];
                        }
                    }
                }
            }
            [self.tableView reloadData];
        };
        
        cell.actionBlock = ^(NSString *post)  {
            NSMutableArray *list = [NSMutableArray new];
            for(int i = 0; i< self.dataArr.count; i++){
                if(i == 1){
                    NSMutableArray *array = [NSMutableArray new];
                    NSArray *data1 = self.dataArr[1];
                    for(int i = 0; i< data1.count; i++){
                        ESDeveloInfo * model  = data1[i];
                        if(i == indexPath.row){
                            model.value = post;
                            [array addObject:model];
                        }else{
                            [array addObject:model];
                        }

                    }
                    [list addObject:array];
                }else{
                    [list addObject:self.dataArr[i]];
                }
            }
            self.dataArr = list;
            [self.tableView reloadData];
        };
        
        if(self.dataArr.count > 1){
            NSArray *array = self.dataArr[1];
            ESDeveloInfo * model = [array getObject:indexPath.row];
            cell.model = model;
            return cell;
        }
    }else if(indexPath.section == 2) {
        NSString *cellID = [NSString stringWithFormat:@"ESNetWorkSettingCell%ld%ld",indexPath.section,indexPath.row];
        ESNetWorkSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[ESNetWorkSettingCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellID];
        }
        return cell;
  
    }else if(indexPath.section == 3){
            NSString *cellID = [NSString stringWithFormat:@"ESKFZSettingVariableCell%ld%ld",indexPath.section,indexPath.row];
        ESKFZSettingVariableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
          
            if (cell == nil) {
                cell = [[ESKFZSettingVariableCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cellID];
            }
        
        cell.row = indexPath.row;
        NSArray *array = self.dataArr[3];
        ESDeveloInfo * model = [array getObject:indexPath.row];
//        ESDeveloInfo * model =array[0];
        cell.model = model;
        cell.actionBlock = ^(NSDictionary *dic )  {
            [self.environments addObject:dic];
            NSMutableArray *list = [NSMutableArray new];
            for(int i = 0; i< self.dataArr.count; i++){
                if(i == 3){
                    NSMutableArray *array = [NSMutableArray new];
                    NSArray *data1 = self.dataArr[3];
                    for(int i = 0; i< data1.count; i++){
                        ESDeveloInfo * model = data1[i];
                        if(i == indexPath.row){
                            model.environments = self.environments;
                            model.dicParameter = dic;
                            [array addObject:model];
                        }else{
                            [array addObject:model];
                        }
                    }
                    [list addObject:array];
                }else{
                    [list addObject:self.dataArr[i]];
                }
            }
            self.dataArr = list;
            [self.tableView reloadData];
        };
            if(self.dataArr.count > 3){
                NSArray *array = self.dataArr[3];
                ESDeveloInfo * model = [array getObject:indexPath.row];
                cell.model = model;
                return cell;
            }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        if(self.dataArr.count > 0){
            return 60;
        }
    }else if(indexPath.section == 1){
        if(self.dataArr.count > 1){
            NSArray *array = self.dataArr[indexPath.section];
            if(indexPath.row == array.count - 1 && self.isLastCell == YES){
                return 60;
            }else{
                return 185;
            }
        }
    }else  if(indexPath.section == 2){
        return 62;
    }
    return 60;
}
//577
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        NSArray *array = self.dataArr[0];
        ESDeveloInfo * model = array[array.count - 1];
        if(indexPath.row == array.count - 1 && model.lastCell){
            [self addCell];
        }else{
//            [self delCell:indexPath];
        }
    }else if(indexPath.section == 3){
        if(self.dataArr.count > 3){
            NSArray *array = self.dataArr[3];
            if(indexPath.row == array.count - 1){
                [self addCell3];
            }else{
                [self delCell3:indexPath];
            }
        }
    }else if(indexPath.section == 1){
        if(self.dataArr.count > 1){
            NSArray *array = self.dataArr[1];
            if(self.isLastCell == YES){
                if(indexPath.row == array.count - 1){
                    [self addCell2];
                }else{
                    if(array.count > 2){
                       // [self delCell2:indexPath];
                    }
                }
            }else{
                if(indexPath.row == array.count - 1){
                  //  [self delCell2:indexPath];
                }else{
                    if(array.count > 2){
                      //  [self delCell2:indexPath];
                    }
                }
            }
        }
    }
    [self.tableView reloadData];
}

- (void)delCell:(NSIndexPath *)indexPath {
    NSMutableArray *list = [NSMutableArray new];
    for(int i = 0; i < self.dataArr.count; i++){
        if(i == 0){
            NSMutableArray *array = [NSMutableArray new];
            NSArray *data1 = self.dataArr[0];
            BOOL isLastCell = NO;
            for(int i = 0; i< data1.count; i++){
                if(i != indexPath.row){
                    ESDeveloInfo * model = data1[i];
                    if(model.lastCell){
                        isLastCell  = YES;
                    }
                    [array addObject:model];
                }
            }
            if(!isLastCell){
                ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
                model.lastCell = YES;
                model.hasArrow = YES;
                self.isLastCell = YES;
                [array addObject:model];
            }
            [list addObject:array];
        }else{
            [list addObject:self.dataArr[i]];
        }
    }
    self.dataArr = list;
}

- (void)delCell2:(NSIndexPath *)indexPath {
    NSMutableArray *list = [NSMutableArray new];
    for(int i = 0; i < self.dataArr.count; i++){
        if(i == 1){
            NSMutableArray *array = [NSMutableArray new];
            NSArray *data1 = self.dataArr[1];
            BOOL isLastCell = NO;
            for(int i = 0; i< data1.count; i++){
                if(i != indexPath.row){
                    ESDeveloInfo * model = data1[i];
                    if(model.lastCell){
                        isLastCell  = YES;
                    }
                    [array addObject:model];
                }
            }
            if(!isLastCell){
                ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
                model.lastCell = YES;
                model.hasArrow = YES;
                self.isLastCell = YES;
                model.onClick = ^{
                    
                };
                [array addObject:model];
            }
            [list addObject:array];
          
        }else{
            [list addObject:self.dataArr[i]];
        }
    }
    
    self.dataArr = list;
}


- (void)addCell{
    NSMutableArray *list = [NSMutableArray new];
    NSArray *data1 = self.dataArr[0];
    self.isLastCell1 = YES;
    if(data1.count > 10){
        return;
    }
    for(int i = 0; i< self.dataArr.count; i++){
        if(i == 0){
            NSMutableArray *array = [NSMutableArray new];
            NSArray *data1 = self.dataArr[0];
        
            for(int i = 0; i< data1.count + 1 ; i++){
                if(i == data1.count - 1){
                    ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
                    model.title = @"容器内部路径";
                    model.hasArrow = YES;
                    model.lastCell = NO;
                    model.value = @"";
                    self.securitySettingModel = model;
                    [array addObject:model];
                }else if(i == data1.count){
                    ESDeveloInfo * model  = data1[i-1];
                    [array addObject:model];
                }else{
                    ESDeveloInfo * model  = data1[i];
                    [array addObject:model];
                }
            }
            
            if(array.count == 11){
                self.isLastCell1 = NO;
                [array removeLastObject];
            }
            
            [list addObject:array];
        }else{
            [list addObject:self.dataArr[i]];
        }
    }
    self.dataArr = list;
}


- (void)addCell2{
    NSMutableArray *list = [NSMutableArray new];
    NSArray *data1 = self.dataArr[1];
    self.isLastCell = YES;
    if(data1.count > 5){
        return;
    }
    
    for(int i = 0; i< self.dataArr.count; i++){
        if(i == 1){
            NSMutableArray *array = [NSMutableArray new];
            NSArray *data1 = self.dataArr[1];
            for(int i = 0; i< data1.count + 1; i++){
                if(i == data1.count - 1){
                        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
                        model.title = NSLocalizedString(@"container_publish_port", @"容器发布端口");
                        model.value = @"8000";
                        model.value1 = NSLocalizedString(@"internal_port", @"内部端口");
                        model.value2 = NSLocalizedString(@"http_request_forward", @"http请求转发");
                        //        model.value = self.dicData[@"imageName"];
                        model.hasArrow = YES;
                        model.isFirst  = NO;
                        model.lastCell = NO;
                    [array addObject:model];
                }else if(i == data1.count){
                    ESDeveloInfo * model  = data1[i-1];
                    [array addObject:model];
                }else{
                    ESDeveloInfo * model  = data1[i];
                    [array addObject:model];
                }
            }
            if(array.count == 6){
                self.isLastCell = NO;
                [array removeLastObject];
            }
            [list addObject:array];
        }else{
            [list addObject:self.dataArr[i]];
        }
    }
    
    self.dataArr = list;
}

- (void)addCell3{
    NSMutableArray *list = [NSMutableArray new];
    for(int i = 0; i< self.dataArr.count; i++){
        if(i == 3){
            NSMutableArray *array = [NSMutableArray new];
            NSArray *data1 = self.dataArr[3];
            for(int i = 0; i< data1.count + 1; i++){
                if(i == data1.count - 1){
                    ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
                    model.hasArrow = YES;
                    model.lastCell = NO;
                    model.errorInt = 0;
                    model.value = @"";
                    model.title = @"";
                    self.securitySettingModel = model;
                    [array addObject:model];
                }else if(i == data1.count){
                    ESDeveloInfo * model  = data1[i-1];
                    model.errorInt = 0;
                    [array addObject:model];
                }else{
                    ESDeveloInfo * model  = data1[i];
                    [array addObject:model];
                }
            }
            if(array.count == 21){
                self.isLastCell = NO;
                [array removeLastObject];
            }
            [list addObject:array];
        }else{
            [list addObject:self.dataArr[i]];
        }
    }
    self.dataArr = list;
}


- (void)delCell3:(NSIndexPath *)indexPath {
    NSMutableArray *list = [NSMutableArray new];
    for(int i = 0; i < self.dataArr.count; i++){
        if(i == 3){
            NSMutableArray *array = [NSMutableArray new];
            NSArray *data1 = self.dataArr[3];
            BOOL isLastCell = NO;
            for(int i = 0; i< data1.count; i++){
                if(i != indexPath.row){
                    ESDeveloInfo * model = data1[i];
                    model.errorInt = 0;
                    if(model.lastCell){
                        isLastCell  = YES;
                    }
                    [array addObject:model];

                }
            }
            if(!isLastCell){
                ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
                model.lastCell = YES;
                model.hasArrow = YES;
                self.isLastCell = YES;
                model.onClick = ^{
                    
                };
                [array addObject:model];
            }
            [list addObject:array];
        }else{
            [list addObject:self.dataArr[i]];
        }
    }
    self.dataArr = list;
}


- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
       // [tableView registerClass:[ESKFZSettingCell class] forCellReuseIdentifier:@"ESKFZSettingCell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(0);
            make.left.mas_equalTo(self.view.mas_left).offset(0);
            make.right.mas_equalTo(self.view.mas_right).offset(0);
            make.bottom.mas_equalTo(self.view).offset(kBottomHeight);
        }];
    }
    return _tableView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewSection = [[UIView alloc] init];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];

    bgView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    [viewSection addSubview:bgView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200 , 22)];
    title.textColor = ESColor.secondaryLabelColor;
    title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
    if(section == 0){
        title.text = NSLocalizedString(@"storage", @"存储");
    }else if(section == 1){
        title.text = NSLocalizedString(@"Port", @"端口");
    }else if(section == 2){
        title.text = NSLocalizedString(@"network", @"网络");
    }else if(section == 3){
        title.text = NSLocalizedString(@"environment", @"环境");
    }

    [bgView addSubview:title];

    return viewSection;
}

-(void)setDicData:(NSDictionary *)dicData{
    _dicData = dicData;
    [self initData];
    [self.tableView reloadData];
}

- (ESDevelopSettingView *)sortView {
    if (!_sortView) {
        _sortView = [[ESDevelopSettingView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _sortView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _sortView.delegate = self;
        weakfy(self);
        _sortView.actionPostBlock = ^(NSString *str,int tag) {
            strongfy(self);
            self.sortView.hidden = YES;
            NSMutableArray *list = [NSMutableArray new];
        
            for(int i = 0; i< self.dataArr.count; i++){
                if(i == 1){
                    NSMutableArray *array = [NSMutableArray new];
                    NSArray *data1 = self.dataArr[1];
                    for(int i = 0; i< data1.count; i++){
                        if(i == tag){
                            ESDeveloInfo * model = data1[i];
                            model.hasArrow = YES;
                            model.lastCell = NO;
                            model.value1 = str;
                        }else if(i == data1.count){
                            // 最后一个
                            ESDeveloInfo * model  = data1[i-1];
                            [array addObject:model];
                        }else{
                            ESDeveloInfo * model  = data1[i];
                            [array addObject:model];
                        }
                    }
                    [list addObject:array];
                }else{
                    [list addObject:self.dataArr[i]];
                }
            }
            [self.tableView reloadData];
        };
        _sortView.actionHttpBlock = ^(NSString *str,int tag) {
            strongfy(self);
            self.sortView.hidden = YES;
            NSMutableArray *list = [NSMutableArray new];
            for(int i = 0; i< self.dataArr.count; i++){
                if(i == 1){
                    NSMutableArray *array = [NSMutableArray new];
                    NSArray *data1 = self.dataArr[1];
                    for(int i = 0; i< data1.count + 1; i++){
                        if(i == tag){
                            ESDeveloInfo * model = data1[i];
                            model.hasArrow = YES;
                            model.lastCell = NO;
                            model.value2 = str;
                            [array addObject:model];
                        }else if(i == data1.count){
                            ESDeveloInfo * model  = data1[i-1];
                            [array addObject:model];
                        }else{
                            ESDeveloInfo * model  = data1[i];
                            [array addObject:model];
                        }
                    }
                    [list addObject:array];
                }else{
                    [list addObject:self.dataArr[i]];
                }
            }
            [self.tableView reloadData];
        };
        
        [self.view.window addSubview:_sortView];
    }
    return _sortView;
}

- (void)fileSortView:(ESDevelopSettingView *_Nullable)fileSortView didClicCancelBtn:(UIButton *_Nullable)button{
    self.sortView.hidden = YES;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self.tableView reloadData];
//}
@end
