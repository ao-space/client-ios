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
//  ESAppStoreVC.m
//  EulixSpace
//
//  Created by qu on 2022/11/14.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppStoreVC.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESTryListCell.h"
#import "ESWebTryPageVC.h"
#import <Masonry/Masonry.h>
#import "ESAppStoreCell.h"
#import "ESAppStoreModel.h"
#import "ESNetworkRequestManager.h"
#import <YYModel/YYModel.h>
#import "ESAppInstallPageVC.h"
#import "ESAppletManager.h"
#import "ESAppletInfoModel.h"
#import "ESAppletManager+ESCache.h"
#import "ESSmarPhotoCacheManager.h"
#import "ESAppletViewController.h"
#import "ESEmptyView.h"
#import "ESAgreementWebVC.h"
#import "ESToast.h"
#import "NSError+ESTool.h"

#import "ESCache.h"
#import "ESCommonToolManager.h"
#import "ESFormItem.h"
#import "ESAppWelcome.h"


typedef void (^ESMPBaseModuleCompletionBlock)(BOOL success, NSError * _Nullable error);
typedef void (^ESMPBaseModuleDownloadCompletionBlock)(BOOL success, NSString * _Nullable filePath, NSError * _Nullable error);


@interface ESAppStoreVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataList;

@property (strong, nonatomic) NSMutableDictionary *installDic;

@property (strong, nonatomic) NSMutableArray *dataResponse;

@property (assign, nonatomic) int num;

@property (nonatomic, readonly) ESAppletInfoModel *appletInfo;

@property (strong, nonatomic) ESEmptyView *blankSpaceView;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) NSString *btnTitle;
@end

@implementation ESAppStoreVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.btnTitle = @"";
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    [self getManagementServiceApi];
    self.navigationBarBackgroundColor = ESColor.secondarySystemBackgroundColor;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Application Center", @"应用中心");
    self.view.backgroundColor = ESColor.secondarySystemBackgroundColor;
    [self initUI];
    self.installDic = [NSMutableDictionary new];
    self.navigationBarBackgroundColor = ESColor.secondarySystemBackgroundColor;
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
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataResponse.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataResponse[section];
    NSArray *array = dic[@"appStoreResList"];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESAppStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                         @"ESAppStoreCellID"];
    if (cell == nil) {
        cell = [[ESAppStoreCell alloc] initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESAppStoreCellID"];
    }
    NSDictionary *dic = self.dataResponse[indexPath.section];
    NSArray *array = dic[@"appStoreResList"];
    cell.appStoreModel = array[indexPath.row];
    cell.actionBlock = ^(ESAppStoreModel * item, NSString *str,ESAppBtnTextStuts btnType) {
        self.btnTitle = str;
        if(btnType == Install || btnType == Installing){
            [self.installDic setValue:@(Installing) forKey:item.appId];
        }else if(btnType == Update || btnType == Updating){
            [self.installDic setValue:@(Updating) forKey:item.appId];
        }
        if(item.stateCode == ESUNINSTALL || item.stateCode == ESINSTALLFAIL || item.stateCode == ESUPDATEFAIL){
            [self getManagementServiceDownApi:item];
        }else if(item.stateCode == ESINSTALLED){
            NSDictionary *dicApp = [[ESCache defaultCache] objectForKey:@"v2_app_sel_status"];
            NSString *key = [ESCommonToolManager miniAppKey:item.appId];
            NSString *appStatus = dicApp[key];
        
            if([appStatus isEqual:@"YES"]){
                
            if([item.deployMode isEqual:@"service"]){
                ESAgreementWebVC *vc = [ESAgreementWebVC new];
                vc.agreementType = ESAppOpen;
                vc.name = item.name;
                vc.urlStr = item.containerWebUrl;
                ESAppletInfoModel *info = [ESAppletInfoModel new];
                info.appletId =item.appId;
                info.name = item.name;
                info.iconUrl =item.iconUrl;
                info.type = @"dockApp";
                info.appletVersion = item.version;
                info.deployMode = item.deployMode;
                info.installSource = item.installSource;
                vc.appletInfo =info;
       
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                if([item.curVersion isEqual:item.version]){
                    ESAppletViewController *appletVC = [[ESAppletViewController alloc] init];
                    ESAppletInfoModel *viewModel =  [ESAppletInfoModel new];
                    viewModel.name = item.name;
                    viewModel.appletId = item.appId;
                    viewModel.appletVersion = item.version;
                    viewModel.installedAppletVersion = item.version;
                    viewModel.iconUrl = item.iconUrl;
                    viewModel.source = @"StoteVC";
                    NSFileManager *file = [NSFileManager new];
                    NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:item.appId];
                    NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
                    if([file fileExistsAtPath:path]){
                        viewModel.localCacheUrl = path;
                        [appletVC loadWithAppletInfo:viewModel];
                        [self.navigationController pushViewController:appletVC animated:YES];
                    }else {
                        [self down:item];
                    }
                }else{
                    // 更新
                    [self getManagementServiceUpdeApi:item];
                }
            }
            }else{
                ESAppWelcome *vc = [ESAppWelcome new];
                ESFormItem *info = [self infoToFormItem:item];
                vc.stateCode = item.stateCode;
                vc.item = info;
                [self.navigationController pushViewController:vc animated:YES];
            }
         
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self getManagementServiceApi];
    NSDictionary *dic = self.dataResponse[indexPath.section];
    NSArray *array = dic[@"appStoreResList"];
    ESAppInstallPageVC *vc =[[ESAppInstallPageVC alloc] init];
    vc.appStoreModel = array[indexPath.row];
    vc.btnStr = self.btnTitle;
    [self.navigationController pushViewController:vc animated:YES];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, 0, CGRectGetWidth(self.view.frame) - kESViewDefaultMargin, 20)];
    NSDictionary *dic = self.dataResponse[section];
    label.text = dic[@"type"];
    label.textColor = ESColor.labelColor;
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    [header addSubview:label];
    return header;
}

- (void)getManagementServiceApi {

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_sort_list"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
                                                    self.blankSpaceView.hidden = YES;
                                                     [ESToast dismiss];
                                                    if([response isKindOfClass:[NSArray class]]){
                                                        self.dataResponse = [[NSMutableArray alloc] init];
                                                        for (NSDictionary *dictData in response) {
                                                            self.dataList = [[NSMutableArray alloc] init];
                                                            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                                                            NSArray *arrayAppDate= dictData[@"appStoreResList"];
                                                            for (NSDictionary *dict in arrayAppDate) {
                                                                ESAppStoreModel *model = [ESAppStoreModel yy_modelWithJSON:dict];
                                                                [self.dataList addObject:model];
                                                                NSNumber *isDowning = self.installDic[model.appId];
                                                                
                                                                if(isDowning > 0){
                                                                    if(model.stateCode == ESINSTALLED){
                                                                        self.btnTitle = NSLocalizedString(@"appstore_state_launch", @"打开");
                                                                        if(isDowning.intValue == Installing){
                                                                            [ESToast toastSuccess:NSLocalizedString(@"app_install_success", @"安装成功")];
                                                                        }else if(isDowning.intValue == Updating){
                                                                            [ESToast toastSuccess:NSLocalizedString(@"app_update_success", @"更新成功")];
                                                                            NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:model.appId];
                                                                            [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:nil];
                                                                        }
                                                                        [self.installDic removeObjectForKey:model.appId];
                                                                    }else if(model.stateCode == ESINSTALLFAIL){
                                                                        [self.installDic removeObjectForKey:model.appId];
                                                                        [ESToast toastError:NSLocalizedString(@"app_install_failed", @"安装失败")];
                                                                        self.btnTitle = NSLocalizedString(@"appstore_state_install", @"安装");
                                                                        [self timerStop];
                                                                    }else if(model.stateCode == ESUPDATEFAIL){
                                                                        self.btnTitle = NSLocalizedString(@"me_upgrade", @"更新");
                                                                        [ESToast toastError:NSLocalizedString(@"applet_update_fail", @"更新失败")];
                                                                        [self.installDic removeObjectForKey:model.appId];
                                                                        [self timerStop];
                                                                    }
                                                                 
                                                                }
                                                            }
                                                           
                                                            [dic setValue:dictData[@"type"] forKey:@"type"];
                                                            [dic setValue:self.dataList forKey:@"appStoreResList"];
                                                            [self.dataResponse addObject:dic];
                                                        }
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                            [self.tableView reloadData];
                                                        });
                                                    }
                                                }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
     
        if ([[error codeString] isEqualToString:@"GW-5006"])  {
            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
        }else{
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
        
        self.blankSpaceView.hidden = NO;
        [self timerStop];
        
        }];
}


- (ESEmptyView *)blankSpaceView {
    if (!_blankSpaceView) {
        _blankSpaceView = [ESEmptyView new];
        ESEmptyItem *item = [ESEmptyItem new];
        item.icon = [UIImage imageNamed:@"app_yingyong"];
        item.content = NSLocalizedString(@"no_data_appstore_center_list", @"暂无任何应用");
        [self.view addSubview:_blankSpaceView];
        [_blankSpaceView reloadWithData:item];
        _blankSpaceView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _blankSpaceView.hidden = YES;
        [_blankSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _blankSpaceView;
}

- (void)getManagementServiceUpdeApi:(ESAppStoreModel *)item{
  //  ESAppStoreModel *model  = self.dataList[0];
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_update"
                                                queryParams:@{@"appid" : item.appId,
                                                              @"packageid":item.packageId
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self creatTimer];
    }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.btnTitle = NSLocalizedString(@"me_upgrade", @"更新");
            if ([[error codeString] isEqualToString:@"GW-5006"]) {
                [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
            } else {
                [ESToast toastError:NSLocalizedString(@"applet_update_fail" ,@"更新失败")];
            }
        });
    }];
}

- (void)getManagementServiceDownApi:(ESAppStoreModel *)item{
  //  ESAppStoreModel *model  = self.dataList[0];

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_install_local_apps"
                                                queryParams:@{@"appid" : item.appId,
                                                              @"packageid":item.packageId
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self creatTimer];
    }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];

            if ([[error codeString] isEqualToString:@"GW-5006"]) {
                [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
            } else {
                [ESToast toastError:NSLocalizedString(@"app_install_failed", @"安装失败")];
            }
            self.btnTitle = NSLocalizedString(@"appstore_state_install", @"安装");

        });
    }];
}

-(void)down:(ESAppStoreModel *)model{
    
    NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:model.appId];
    NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
    NSFileManager *file = [NSFileManager new];
    if([file fileExistsAtPath:path]){
        ESAppletViewController *appletVC = [[ESAppletViewController alloc] init];
        ESAppletInfoModel *viewModel =  [ESAppletInfoModel new];
        viewModel.name = model.name;
        viewModel.appletId = model.appId;
        viewModel.installedAppletVersion = model.version;
        NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:model.appId];
        NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
        viewModel.localCacheUrl = path;
        [appletVC loadWithAppletInfo:viewModel];
        [self.navigationController pushViewController:appletVC animated:YES];
    }else{
        ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
        NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:model.appId];
        [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:nil];
        NSString *picZipCachePath = [ESSmarPhotoCacheManager cacheZipPathWithDate:@"12"];
        [ESNetworkRequestManager sendCallDownloadRequest:@{ @"serviceName" : @"eulixspace-appstore-service",
                                                              @"apiName" : @"appstore_down"}
                                                queryParams:@{@"appid" : model.appId
                                                             }
                                                  header:@{}
                                                    body:@{}
                                              targetPath:picZipCachePath
                                                  status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                                   }
                                            successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {
            BOOL unZipSuccess = [ESAppletManager.shared addAppletCacheWithId:model.appId
                                                                appletVerion:model.version
                                                            downloadFilePath:picZipCachePath];
         
            dispatch_async(dispatch_get_main_queue(), ^{
                [ESToast dismiss];
                [self.tableView reloadData];
                if(unZipSuccess){
                    [self down:model];
                }else{
                    [ESToast toastError:NSLocalizedString(@"open_failed", @"打开失败")];
                }
            });
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
           [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ESToast dismiss];
                [self.tableView reloadData];
            });
        }];
    }
}



- (void)creatTimer {
    //0.创建队列
    if(!self.timer){
        dispatch_queue_t queue = dispatch_get_main_queue();

        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);

        //3.要调用的任务
        dispatch_source_set_event_handler(self.timer, ^{
            [self getManagementServiceApi];
        });
        //4.开始执行
        dispatch_resume(self.timer);
    }
}
   
- (void)timerStop {
    @synchronized (self){
        if (self.timer) {
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
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


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat sectionHeaderHeight = 50;

    if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {

        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0,0);

    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {

        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


-(ESFormItem *)infoToFormItem:(ESAppStoreModel *)item{
    ESFormItem *info = [ESFormItem new];
    info.appId = item.appId;
    info.title= item.name ;
    info.iconUrl = item.iconUrl;
    info.containerWebUrl = item.containerWebUrl;
    info.deployMode = item.deployMode;
    info.webUrl = item.webUrl;
    info.type = @"dockApp";
    return info;
}

@end
