
/*
 * Copyright (c) 2023 Institute of Software, Chinese Academy of Sciences (ISCAS)
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
//  ESAppV2SettingVC.m
//  EulixSpace
//
//  Created by qu on 2023/7/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//
#import "ESAppV2SettingVC.h"
#import "UIColor+ESHEXTransform.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESInstallSettingV2VC.h"
#import "NSObject+YYModel.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESAppV2SettingCell.h"
#import "ESAlertViewController.h"
#import "UIView+Status.h"
#import "ESWebTryPageVC.h"
#import "ESV2SettingModel.h"
#import "ESV2InstallApp.h"
#import "ESAuthConfirmVC.h"
#import "ESContainerInfo.h"
#import "ESContaineStatsInfo.h"
#import "ESAppMiniStopServiceCell.h"
#import "ESEmptyView.h"
#import "ESESAppV2SettingPostCell.h"

#import <SDWebImage/SDWebImage.h>
#import "ESPlatformQuestionnaireManagementServiceApi.h"
#import <Masonry/Masonry.h>

@interface ESAppV2SettingVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *dataList;

@property (assign, nonatomic) BOOL isOpen;

@property (assign, nonatomic) BOOL isHavePower;

@property (assign, nonatomic) BOOL isService;

@property (nonatomic, strong) ESAuthConfirmVC *authConfirmVC;

@property (nonatomic, strong) ESContainerInfo *info;


@property (nonatomic, strong) ESEmptyView *blankSpaceView;

@property (nonatomic, strong) ESContaineStatsInfo *statsInfo;

@property (nonatomic, strong) dispatch_source_t timer;

@property (assign, nonatomic) int num;
@end

@implementation ESAppV2SettingVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.num = 0;
 
    if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
        self.isService = YES;
        [self getManagementServiceApi];
        [self getManagementServiceApiStats];
    }else {
        self.isService = NO;
        [self getInfo];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"application_settings", @"应用设置");
    [self initUI];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.tableView.backgroundColor = ESColor.systemBackgroundColor;
    self.dataList = nil;

    self.isHavePower = NO;
   // NSString *versionStr =  NSLocalizedString(@"versionp", @"版本");
    

    NSString *versionStr = [NSString stringWithFormat:NSLocalizedString(@"versionp", @"版本"),self.item.version];
    self.tableView.tableHeaderView = [self createViewWithImage:self.item.iconUrl title:self.item.title subtitle:versionStr];

    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, 20)];
    self.tableView.tableFooterView = footView;
    
    NSArray *array = [self createDictionaryArray];
    
    NSMutableArray *array3 = [NSMutableArray new];
    for (NSDictionary *dic in array) {
        NSArray *array1 = dic[@"通讯录"];
        
        NSMutableArray *array2 = [NSMutableArray new];
        if(array1.count > 0){
            for (NSString *str in array1) {
                ESV2SettingModel *item = [ESV2SettingModel new];
                item.titleStr = str;
                [array2 addObject:item];
            }
            [array3 addObject:array2];
        }
        
        if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
            NSArray *array4 = dic[@"服务"];
            if(array4.count > 0){
                NSMutableArray *array5 = [NSMutableArray new];
                for (NSString *str in array4) {
                    ESV2SettingModel *item = [ESV2SettingModel new];
                    item.titleStr = str;
                    [array5 addObject:item];
                }
                [array3 addObject:array5];
            }
      
        NSArray *array6 = dic[@"时间"];
     
        if(array6.count > 0){
            NSMutableArray *array7 = [NSMutableArray new];
            for (NSString *str in array6) {
                ESV2SettingModel *item = [ESV2SettingModel new];
                item.titleStr = str;
                [array7 addObject:item];
            }
            [array3 addObject:array7];
        }
        
        
        NSArray *array8 = dic[@"设置"];
        if(array8.count > 0){
            NSMutableArray *array9 = [NSMutableArray new];
            for (NSString *str in array8) {
                ESV2SettingModel *item = [ESV2SettingModel new];
                item.titleStr = str;
                [array9 addObject:item];
            }
            [array3 addObject:array9];
        }
        }
    }
    
    if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
        [self creatTimer];
        NSMutableArray *array10 = [NSMutableArray new];
        ESV2SettingModel *item1 = [ESV2SettingModel new];
        item1.btn1Str = @"强制停止";
        item1.btn2Str = @"重新启动";
        [array10 addObject:item1];
        [array3 addObject:array10];

    }
    self.dataList = array3;
    [self.tableView reloadData];
    

}


- (NSArray *)createDictionaryArray {
    // 定义一个随机字符串生成函数
    // 创建包含 4 个字典的数组
    NSMutableArray *array = [NSMutableArray array];
    

    if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
        // 第二个字典
        NSMutableArray *servicesArray = [NSMutableArray array];
        [servicesArray addObject:NSLocalizedString(@"application_servicename", @"服务名称")];
        [servicesArray addObject:@"ID"];
        [servicesArray addObject:NSLocalizedString(@"application_Createtime", @"创建时间")];
        [servicesArray addObject:NSLocalizedString(@"application_starttime", @"启动时间")];
        [servicesArray addObject:NSLocalizedString(@"developer_webLink", @"网页链接")];
        [servicesArray addObject:NSLocalizedString(@"developer_port", @"端口")];
        NSDictionary *dict2 = @{
            @"服务":servicesArray
        };
        [array addObject:dict2];
        // 第三个字典

        
        NSMutableArray *timeArray = [NSMutableArray array];
        [timeArray addObject:NSLocalizedString(@"application_operationhour", @"运行时间")];
        [timeArray addObject:NSLocalizedString(@"application_cpuusage", @"CPU 使用率"])];
        [timeArray addObject:NSLocalizedString(@"application_memoryusage",@"内存使用率（MB）")];
        [timeArray addObject:NSLocalizedString(@"application_disk",@"磁盘读/写")];
        [timeArray addObject:NSLocalizedString(@"application_network", @"网络 I/O")];

        NSDictionary *dict3 = @{
            @"时间": timeArray
        };
        [array addObject:dict3];
    }else{
   
        NSMutableArray *powerArray = [NSMutableArray array];
        [powerArray addObject:NSLocalizedString(@"application_spaceinfo", @"傲空间头像，昵称，域名，通讯录")];
        // 第一个字典
        NSDictionary *dict1 = @{
            @"通讯录": powerArray
        };
        [array addObject:dict1];
    }


    return [NSArray arrayWithArray:array];
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
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.allowsSelection = YES;
     
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataList[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.info.status isEqual:@"exited"] && indexPath.section == 1){
        return 120;
    }else if(indexPath.section == 0 && indexPath.row == 5){
        if(self.info.ports.count <= 2){
            return 57;
        }else{
            return self.info.ports.count * 25;
        }
    }
    else{
        return 57;
    }
   // return 57;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
        if([self.info.status isEqual:@"exited"] && indexPath.section == 1){
            ESAppMiniStopServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                 @"ESAppMiniStopServiceCellID"];
            if (cell == nil) {
                cell = [[ESAppMiniStopServiceCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"ESAppMiniStopServiceCellID"];
                
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if(indexPath.section == 0 && indexPath.row == 5 ){
            ESESAppV2SettingPostCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                 @"ESESAppV2SettingPostCellID"];
            if (cell == nil) {
                cell = [[ESESAppV2SettingPostCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"ESESAppV2SettingPostCellID"];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            ESV2SettingModel * model = [ESV2SettingModel new];
            NSArray *array = self.dataList[indexPath.section];
            model = array[indexPath.row];
            cell.statsInfo = self.statsInfo;
            cell.containerInfo = self.info;
            cell.item = model;
            UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            CGFloat cornerRadius = 10.0;

            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bgView.bounds
                                                           byRoundingCorners:corner
                                                                 cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];

            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = maskPath.CGPath;

            cell.bgView.layer.mask = maskLayer;
            cell.separatorView.hidden = YES;
            return cell;
        }
        
        else{
            ESAppV2SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                 @"ESAppV2SettingCellID"];

            
            if (cell == nil) {
                cell = [[ESAppV2SettingCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"ESAppV2SettingCellID"];
                
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
         

            ESV2SettingModel * model = [ESV2SettingModel new];
            NSArray *array = self.dataList[indexPath.section];
            cell.separatorView.hidden = NO;
            
            if(array.count == 1){
                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bgView.bounds
                                                               cornerRadius:10.0];

                // 创建一个形状图层
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                maskLayer.path = maskPath.CGPath;

                // 设置视图的遮罩图层
                cell.bgView.layer.mask = maskLayer;
            }else if(array.count > 1){
                if(indexPath.row == 0){
                    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
                    CGFloat cornerRadius = 10.0;

                    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bgView.bounds
                                                                   byRoundingCorners:corner
                                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];

                    CAShapeLayer *maskLayer = [CAShapeLayer layer];
                    maskLayer.path = maskPath.CGPath;

                    cell.bgView.layer.mask = maskLayer;
                }else if(indexPath.row == array.count -1){
                    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
                    CGFloat cornerRadius = 10.0;

                    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bgView.bounds
                                                                   byRoundingCorners:corner
                                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];

                    CAShapeLayer *maskLayer = [CAShapeLayer layer];
                    maskLayer.path = maskPath.CGPath;

                    cell.bgView.layer.mask = maskLayer;
                    cell.separatorView.hidden = YES;
                }else{
                    cell.bgView.layer.mask = nil;
                }
            }
            model = array[indexPath.row];
            if(self.isHavePower){
                model.type =  indexPath.section;
            }else {
                model.type =  indexPath.section + 1;
            }
         
            model.indexPath = indexPath;
            model.isOpen = self.isOpen;
            cell.statsInfo = self.statsInfo;
            cell.containerInfo = self.info;
            cell.item = model;


            cell.actionSwitchBlock = ^(id action)  {
                [self delectPower];
            };
            
            cell.actionReSetBlock = ^(id action)  {
                [self actionReSetBlock];
            };
            
            
            cell.actionStoptBtnBlock = ^(id action)  {
                [self actionStoptBtnBlock];
            };
            
            cell.actionStartBlock = ^(id action)  {
                [self actionReSetBlock];
            };
            
            return cell;
        }
    }else{
        ESAppV2SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                             @"ESAppV2SettingCellID"];

        
        if (cell == nil) {
            cell = [[ESAppV2SettingCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"ESAppV2SettingCellID"];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
     

        ESV2SettingModel * model = [ESV2SettingModel new];
        NSArray *array = self.dataList[indexPath.section];
        cell.separatorView.hidden = NO;
        if(array.count == 1){
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bgView.bounds
                                                           cornerRadius:10.0];

            // 创建一个形状图层
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = maskPath.CGPath;

            // 设置视图的遮罩图层
            cell.bgView.layer.mask = maskLayer;
            
       
        }else if(array.count > 1){
            if(indexPath.row == 0){

            }else if(indexPath.row == array.count -1){

                cell.separatorView.hidden = YES;
            }else{
            //    cell.bgView.layer.mask = nil;
            }
        }
        model = array[indexPath.row];
        if(self.isHavePower){
            model.type =  indexPath.section;
        }else {
            model.type =  indexPath.section + 1;
        }
     
        model.indexPath = indexPath;
        model.isOpen = self.isOpen;
        cell.statsInfo = self.statsInfo;
        cell.containerInfo = self.info;
        cell.item = model;


        cell.actionSwitchBlock = ^(id action)  {
            [self delectPower];
        };
        
        cell.actionReSetBlock = ^(id action)  {
            [self actionReSetBlock];
        };
        
        
        cell.actionStoptBtnBlock = ^(id action)  {
            [self actionStoptBtnBlock];
        };
        
        cell.actionStartBlock = ^(id action)  {
            [self actionReSetBlock];
        };
        
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
        if(section == 0){
            return 57;
        }else{
            return 1;
        }
    }else{
        return 57;
    }

    return 57;
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


- (UIView *)createViewWithImage:(NSString *)imageUrl title:(NSString *)title subtitle:(NSString *)subtitle {
    // 创建UIView
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 90)];
   
    // 创建UIImageView
    UIImageView *imageViewBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    imageViewBg.contentMode = UIViewContentModeScaleAspectFit;
    imageViewBg.backgroundColor = ESColor.iconBg;
    imageViewBg.layer.cornerRadius = 6.0;
    imageViewBg.layer.masksToBounds = YES;
    [view addSubview:imageViewBg];
    [imageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view.mas_top).offset(30);
        make.left.mas_equalTo(view).offset(26);
        make.width.height.mas_equalTo(@(50));
    }];


    // 创建UIImageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"app_docker"]];
    [imageViewBg addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(imageViewBg.mas_centerX);
        make.centerY.mas_equalTo(imageViewBg.mas_centerY);
        make.width.height.mas_equalTo(@(50));
    }];
    
  
    // 创建第一个UILabel
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 80, 30)];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    titleLabel.textColor = ESColor.labelColor;
    [view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view.mas_top).offset(30);
        make.left.mas_equalTo(imageView.mas_right).offset(20);
    }];
    
    // 创建第二个UILabel
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 40, 80, 30)];
    subtitleLabel.text = subtitle;
    subtitleLabel.font = [UIFont systemFontOfSize:14.0];
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.textColor = [UIColor es_colorWithHexString:@"#85899C"];
    [view addSubview:subtitleLabel];
    
    
    if([self.item.installSource isEqual:@"dev-options"] || subtitle.length < 1){
        subtitleLabel.hidden = YES;
    }else{
        subtitleLabel.hidden = NO;
    }
    
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(imageView.mas_right).offset(20);
    }];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 创建一个UIView对象
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    headerView.backgroundColor = [UIColor whiteColor];

    // 添加一个UILabel到headerView中
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(26, 10, tableView.bounds.size.width - 20, 30)];
    label.textColor =[UIColor es_colorWithHexString:@"#85899C"];
    label.font = [UIFont systemFontOfSize:14.0];
    [headerView addSubview:label];
    
    if(self.isService){
        if(section == 0){
            // 添加一个UILabel到headerView中
                
            UILabel *labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 100, 10, 100, 30)];
            labelStatus.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0];
            [headerView addSubview:labelStatus];
            [labelStatus mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(headerView.mas_top).offset(10);
                make.right.mas_equalTo(headerView.mas_right).offset(-26);
            }];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(headerView.mas_top).offset(10);
                make.left.mas_equalTo(headerView.mas_left).offset(26);
            }];
            
            if([self.info.status isEqual:@"exited"]){
                labelStatus.text = NSLocalizedString(@"application_stopped", @"已停止");
                labelStatus.textColor = [UIColor es_colorWithHexString:@"#F6222D"];

            }else{
                labelStatus.text = NSLocalizedString(@"application_running", @"进行中");
                labelStatus.textColor = [UIColor es_colorWithHexString:@"#43D9AF"];
            }

            label.text = NSLocalizedString(@"Service", @"服务");
            
        }
    }else{
        if(section == 0){
            label.textColor =[UIColor es_colorWithHexString:@"#85899C"];
            label.font = [UIFont systemFontOfSize:14.0];
            [headerView addSubview:label];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(headerView.mas_top).offset(10);
                make.left.mas_equalTo(headerView.mas_left).offset(26);
            }];
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"application_permissions",@"允许“%@”访问"), self.item.title];
            label.text = str;
        }
    }

    return headerView;
}

-(void)getInfo{
    if(self.item.appId.length > 0){

        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-openapi-service"
                                                        apiName:@"get_auth_data"                                                queryParams:@{@"aoid" :ESBoxManager.activeBox.aoid,@"applet_id":self.item.appId,
                                                                                                                                              @"applet_version":self.item.version,
                                                                                                                                                
                                                                                                                                            }
                                                         header:@{}
                                                           body:@{}
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
            [ESToast dismiss];
            self.blankSpaceView.hidden = YES;
            self.isHavePower = YES;
            NSDictionary *dic = response;
            NSDictionary *cataDic = dic[@"categories"];
            NSArray *array = cataDic[@"addressbook"];
            if(array.count> 0){
                self.isOpen = YES;
            }else{
                self.isOpen = NO;
            }
            [self.tableView reloadData];
        }
                                                      failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error)  {
            [ESToast dismiss];
            if (error) {
                self.blankSpaceView.hidden = YES;
                self.isHavePower = YES;
                NSDictionary *userInfo = error.userInfo;
                NSString *codeValue = userInfo[@"code"];
                if([codeValue isEqual:@"GW-401"] && [codeValue isEqual:@"GW-403"]){
                    self.isOpen = NO;
                    [self.tableView reloadData];
                }
            }else{
                self.dataList = nil;
                [self.blankSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.view.mas_left).offset(0);
                    make.right.mas_equalTo(self.view.mas_right).offset(0);
                    make.top.mas_equalTo(self.view.mas_top).offset(180);
                    make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
                }];
                self.blankSpaceView.hidden = NO;
                [self.tableView reloadData];
      
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
           
        }];
    }
}


- (void)getManagementServiceApi {

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                    apiName:@"applet_get_container_info"
                                                queryParams:@{@"appId":self.item.appId}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        
        
        self.blankSpaceView.hidden = YES;
        if([response isKindOfClass:[NSDictionary class]]){
            ESContainerInfo *model = [ESContainerInfo yy_modelWithJSON:response];
            self.info = model;
            if ([self.info.status isEqual:@"exited"]){
                NSArray *exitedArray = self.dataList[1];
                if(exitedArray.count > 1){
                    NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataList];
                    NSMutableArray *array1 = [NSMutableArray new];

                    [array removeObjectAtIndex:1];
                    ESV2SettingModel *item = [ESV2SettingModel new];
                    [array1 addObject:item];
                    [array insertObject:array1 atIndex:1];
                    item.titleStr = @"exited";

                    self.dataList = array;
                }
            }else{
                [self viewDidLoad];
            }
    
            [self.tableView reloadData];
        
        }
    }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        self.dataList = nil;
        [self.blankSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).offset(0);
            make.right.mas_equalTo(self.view.mas_right).offset(0);
            make.top.mas_equalTo(self.view.mas_top).offset(180);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        }];
        self.blankSpaceView.hidden = NO;
        [self.tableView reloadData];
         [ESToast dismiss];
         [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        
        [ESToast dismiss];
    }];
}

- (void)getManagementServiceApiStats {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                    apiName:@"applet_get_container_stats"
                                                queryParams:@{@"appId":self.item.appId}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        
        
        self.blankSpaceView.hidden = YES;
        if([response isKindOfClass:[NSDictionary class]]){
            ESContaineStatsInfo *model = [ESContaineStatsInfo yy_modelWithJSON:response];
            self.statsInfo = model;
            [self.tableView reloadData];
        
        }
    }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
    }];
 
}



- (void)delectPower {

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-openapi-service"
                                                    apiName:@"delete_auth_data"
                                                queryParams:@{@"aoid" :ESBoxManager.activeBox.aoid,@"applet_id":self.item.appId,
                                                              @"applet_version":self.item.version,
                                                                
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        
        [self getInfo];
     
    }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
        [ESToast dismiss];
    }];
}

- (ESAuthConfirmVC *)authConfirmVC {
    if (!_authConfirmVC) {
        _authConfirmVC = [[ESAuthConfirmVC alloc] initWithAppletInfo:self.item];
        _authConfirmVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return _authConfirmVC;
}


-(void)actionReSetBlock{
    if(self.item.appId.length > 0){
        [self.view showLoading:YES message:NSLocalizedString(@"application_starting", @"正在启动服务")];
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                        apiName:@"applet_restart_container"
                                                    queryParams:@{@"appId":self.item.appId}
                                                         header:@{}
                                                           body:@{}
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
            [ESToast dismiss];
        }
                                                      failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [ESToast dismiss];
        }];
    }
}

-(void)actionStoptBtnBlock{
    [self showStopDialog];
}

    

- (void)timerStop {
    @synchronized (self){
        if (self.timer) {
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
    }
}

- (void)creatTimer {
    //0.创建队列
    if(!self.timer){
        dispatch_queue_t queue = dispatch_get_main_queue();

        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC, 3 * NSEC_PER_SEC);

        //3.要调用的任务
        dispatch_source_set_event_handler(self.timer, ^{
            [self getManagementServiceApi];
            [self getManagementServiceApiStats];
        });
        //4.开始执行
        dispatch_resume(self.timer);
    }
}

-(void)dealloc{
    [self timerStop];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self timerStop];
}


- (void)showStopDialog {
    NSString * title =NSLocalizedString(@"application_stop",@"强制停止");
    NSString * msg = NSLocalizedString(@"application_stoptip",@"是否确定要强制停止服务?所有未保存的数据将会丢失");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"application_stop",@"强制停止")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
                [self.view showLoading:YES message: NSLocalizedString(@"application_stopprompt",@"正在停止服务")];
                [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                                apiName:@"applet_stop_container"
                                                            queryParams:@{@"appId":self.item.appId}
                                                                 header:@{}
                                                                   body:@{}
                                                              modelName:nil
                                                           successBlock:^(NSInteger requestId, id  _Nullable response) {
                    [ESToast dismiss];
                    
                    [self.tableView reloadData];
        
                }
                                                              failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
                    [ESToast dismiss];
                }];
    }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}



- (ESEmptyView *)blankSpaceView {
    if (!_blankSpaceView) {
        _blankSpaceView = [ESEmptyView new];
        _blankSpaceView.hidden = YES;
        ESEmptyItem *item = [ESEmptyItem new];
        item.icon = [UIImage imageNamed:@"app_setting_error"];
        item.content = NSLocalizedString(@"application_nosetting",@"暂无设置项");
        [self.view addSubview:_blankSpaceView];
        [_blankSpaceView reloadWithData:item];
    }
    return _blankSpaceView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat sectionHeaderHeight = 50;

    if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {

        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0,0);

    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {

        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
 
    
}


@end
