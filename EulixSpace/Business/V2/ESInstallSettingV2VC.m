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
//  ESInstallSettingV2VC.m
//  EulixSpace
//
//  Created by qu on 2023/1/5.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESInstallSettingV2VC.h"
#import "ESFilePageTitleView.h"
#import "ESFilePageContentView.h"
#import "ESInstallSetting1GeneralVC.h"
#import "ESEadvancedVC.h"
#import "ESDeveloInfo.h"
#import "ESToast.h"
#import "ESCellModel.h"
#import "ESNetworkRequestManager.h"


#define kPhoneInfoH (CGFloat)64
#define kTitleViewH (CGFloat)56

@interface ESInstallSettingV2VC ()<ESPageContentViewDelegate,ESPageTitleViewDelegate>
// 标题栏
@property (nonatomic, strong) ESFilePageTitleView *pageTitleView;

@property (nonatomic, strong) ESFilePageContentView *pageContentView;

@property (nonatomic, strong) ESInstallSetting1GeneralVC *setVC1;

@property (nonatomic, strong) ESEadvancedVC *setVC2;

@property (assign, nonatomic) NSInteger targetIndex;

/// 确定按钮
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) NSMutableArray *dataArreEad;



@end

@implementation ESInstallSettingV2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageContentView.hidden = NO;
    self.navigationItem.title = NSLocalizedString(@"install_mirror", @"安装镜像");
}

- (void)pageContentView:(id)contentView progress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
    self.targetIndex = targetIndex;
    [self.pageTitleView setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
}

- (void)pageTitletView:(id)contentView selectedIndex:(NSInteger)targetIndex {
    [self.pageContentView setCurrentIndex:targetIndex];
 
}


- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.frame = CGRectMake(0, 0, 80, 45);
        _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_confirmButton setTitle:NSLocalizedString(@"Install", @"安装") forState:UIControlStateNormal];
        [_confirmButton setTitle:NSLocalizedString(@"Install", @"安装") forState:UIControlStateSelected];
        [_confirmButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    }
    return _confirmButton;
}

#pragma mark - Lazy Load

//- (ESFilePageTitleView *)pageTitleView {
//    CGRect frame = CGRectMake(0, kPhoneInfoH, ScreenWidth, kTitleViewH);
//    NSArray *titles = @[@"常规设置", @"高级设置"];
//    if (!_pageTitleView) {
//        __weak typeof(self) weakSelf = self;
//        CGFloat space = (ScreenWidth - 80 * 2) / 3;
//        _pageTitleView = [ESFilePageTitleView initWithFrame:frame titles:titles titleW:80 titleH:20 leftDistance:space titleSpacing:space fontOfSize:14];
//        _pageTitleView.delegate = weakSelf;
//        _pageTitleView.backgroundColor = ESColor.systemBackgroundColor;
//        _pageTitleView.layer.cornerRadius = 10;
//        _pageTitleView.layer.masksToBounds = YES;
//
//        [self.view addSubview:_pageTitleView];
//        UIView *line = [UIView new];
//        line.backgroundColor = ESColor.separatorColor;
//        [self.view addSubview:line];
//        [line mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.mas_equalTo(_pageTitleView);
//            make.bottom.mas_equalTo(_pageTitleView.mas_bottom);
//            make.height.mas_equalTo(1);
//        }];
//    }
//    return _pageTitleView;
//}

- (ESFilePageTitleView *)pageTitleView {
    CGRect frame = CGRectMake(0, kStatusBarHeight, ScreenWidth, kTitleViewH);
    NSArray *titles = @[NSLocalizedString(@"general_setting", @"常规设置"), NSLocalizedString(@"advance_setting", @"高级设置")];
    if (!_pageTitleView) {
        __weak typeof(self) weakSelf = self;
        CGFloat space = (ScreenWidth - 150 * 2) / 3;
        _pageTitleView = [ESFilePageTitleView initWithFrame:frame titles:titles titleW:150 titleH:20 leftDistance:space titleSpacing:space fontOfSize:14];
        _pageTitleView.delegate = weakSelf;
        [self.view addSubview:_pageTitleView];
    }
    return _pageTitleView;
}

- (ESFilePageContentView *)pageContentView {
    if (!_pageContentView) {
        NSMutableArray *childVcs = [NSMutableArray array];
        CGFloat contentH = ScreenHeight - kTopHeight - kTitleViewH -20;
        CGRect contentFrame = CGRectMake(0, 100, ScreenWidth, contentH);
     
        self.setVC1 = [[ESInstallSetting1GeneralVC alloc] init];
        self.setVC1.dicData = self.dicData;
        self.setVC2 = [[ESEadvancedVC alloc] init];
        [self.setVC2 initData];
//        self.setVC2.dataArr = self.dataArreEad;
        [childVcs addObject:self.setVC1];
        [childVcs addObject:self.setVC2];

        __weak typeof(self) weakSelf = self;
        _pageContentView = [ESFilePageContentView initWithFrame:contentFrame ChildViewControllers:childVcs parentViewController:self];
        _pageContentView.delegate = weakSelf;
        [self.view addSubview:self.pageContentView];
    }
    return _pageContentView;
}

// 577
- (void)confirmAction {
    
    self.confirmButton.enabled = NO;
    
    NSMutableArray *error1 =  [NSMutableArray new];
    NSArray *array1 =self.setVC2.dataArr[0];
    for (int i = 0; i<array1.count - 1; i++) {
        for (int j = 0; j<array1.count - 1; j++) {
            ESDeveloInfo *info1 = array1[i];
            ESDeveloInfo *info2 = array1[j];
            if(i!=j){
                if([info1.value isEqual:info2.value] && ![info2.value isEqual:@""]){
                    if(![error1 containsObject:@(i)]){
                        [error1 addObject:@(i)];
                    }
                    if(![error1 containsObject:@(j)]){
                        [error1 addObject:@(j)];
                    }
                }
            }
        }
    }
    
    NSArray *array =self.setVC2.dataArr[1];
    NSMutableArray *error2 =  [NSMutableArray new];
    NSMutableArray *errordec =  [NSMutableArray new];
    
    for(int z = 0; z< 5; z++){
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [errordec addObject:dic];
    }
    
    NSString *errorStr2;
    BOOL isError1 = NO;
    BOOL isError2 = NO;
    int error3 = 0;
    for (int i = 0; i<array.count - 1; i++) {
        ESDeveloInfo *info1 = array[i];
        if([info1.value intValue] < 1 || [info1.value intValue] > 65535 || [info1.value containsString:@"."]){
            NSMutableDictionary *dic = errordec[i];
            [dic setValue:NSLocalizedString(@"port_exception_port_number_illegal", @"端口号不合法，范围：1~65535") forKey:@"error1"];
            errordec[i] = dic;
            [error2 addObject:@(1)];
        }
    
        for (int j = 0; j<array.count - 1; j++) {
            ESDeveloInfo *info1 = array[i];
            ESDeveloInfo *info2 = array[j];
            if(i!=j){
                if([info1.value1 isEqual:info2.value1] && [info1.value2 isEqual:info2.value2] && [info1.value isEqual:info2.value]){
                    isError1 = YES;
                    if(![error2 containsObject:@(2)]){
                        [error2 addObject:@(2)];
                    }
                    
                    NSMutableDictionary *dic = errordec[i];
                    [dic setValue:NSLocalizedString(@"port_exception_settings_same", @"端口配置重复，请重新输入") forKey:@"error2"];
                    errordec[i] = dic;
                    
                    NSMutableDictionary *dic1 = errordec[j];
                    [dic1 setValue:NSLocalizedString(@"port_exception_settings_same", @"端口配置重复，请重新输入") forKey:@"error2"];
                    errordec[j] = dic1;
                }
                if([info1.value2 isEqual:info2.value2] && [info1.value2 isEqual:NSLocalizedString(@"http_request_forward", @"http请求转发")]){
                    isError2 = YES;
                    if(![error2 containsObject:@(3)]){
                        [error2 addObject:@(3)];
                    }
                    NSMutableDictionary *dic = errordec[i];
                    [dic setValue:NSLocalizedString(@"port_exception_purpose_http_multiple", @"不支持配置多个用途为“http请求转发”的端口") forKey:@"error3"];
                    errordec[i] = dic;
                    
                    NSMutableDictionary *dic1 = errordec[j];
                    [dic1 setValue:NSLocalizedString(@"port_exception_purpose_http_multiple", @"不支持配置多个用途为“http请求转发”的端口") forKey:@"error3"];
                    errordec[j] = dic1;
        
                }
            }
        }
    }
    
    NSArray *array3 = self.setVC2.dataArr[3];
    NSMutableArray *error3Array = [NSMutableArray new];
//    NSArray *env = info1.environments;
    for (int i = 0; i<array3.count; i++) {
    
        ESDeveloInfo *info1 = array3[i];
        if(!info1.lastCell){
            NSString *str = info1.dicParameter.allKeys[0];
            if([str isEqual:@"nil"]){
                [error3Array addObject:@(100)];
            }
            for (int j = 0; j<array3.count; j++) {
                ESDeveloInfo *info2 = array3[j];
                if(!info2.lastCell){
                    if(i!=j){
                        if([info1.dicParameter.allKeys[0] isEqual:info2.dicParameter.allKeys[0]] && ![info2.dicParameter.allKeys[0] isEqual:@"nil"]){
                            if(![error3Array containsObject:@(i)]){
                                [error3Array addObject:@(i)];
                            }
                            if(![error3Array containsObject:@(j)]){
                                [error3Array addObject:@(j)];
                            }
                        }
                    }
                }
            }
        }
       
    }
    

    ESCellModel *modeName2 = self.setVC1.dataArr[1];
    NSString *serviceName = modeName2.value;

    ESCellModel *modeName3 = self.setVC1.dataArr[2];
    NSString *appDomainPrefix = modeName3.value;

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                    apiName:@"applet_params_check"                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{
            //@"imageName" : self.address,
                                                              @"imageAddress":@"",
                                                              @"imageName":@"",
                                                              @"appName" : @"",
                                                              @"serviceName" : serviceName,
                                                              @"appDomainPrefix":appDomainPrefix,

                                                            }
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        
        NSDictionary *dic = response;
        self.confirmButton.enabled = YES;
        if([response isEqual:@"success"]){
            //        if([dic[@"code"] isEqual:@"GW-200"]){
            
            if(error1.count > 0 || error2.count > 0 || error3Array.count > 0){
                NSArray *newArray = [NSArray new];
                self.setVC1.actionInstallBlock(newArray);
                [ESToast toastError:NSLocalizedString(@"param_illegal_hint", @"参数设置不符合规范请点击查看原因")];
                self.setVC2.actionInstallBlock(error1,error2,errordec,error3Array);
            }else{
                self.install(self.setVC1.dataArr, self.setVC2.dataArr);
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            
        }else{
            [ESToast toastError:NSLocalizedString(@"param_illegal_hint", @"参数设置不符合规范请点击查看原因")];
            NSMutableArray *array = dic[@"context"];
            if(array.count > 0){
                self.setVC1.actionInstallBlock(array);
            }
            self.setVC2.actionInstallBlock(error1,error2,errordec,error3Array);

        }
      }
        failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [ESToast toastError:NSLocalizedString(@"param_illegal_hint", @"参数设置不符合规范请点击查看原因")];
        self.confirmButton.enabled = YES;
        if(error1.count > 0 || error2.count > 0 || error3Array.count > 0){
            
                self.setVC2.actionInstallBlock(error1,error2,errordec,error3Array);
                return;
            }else{
//                self.install(self.setVC1.dataArr, self.setVC2.dataArr);
//                [self.navigationController popViewControllerAnimated:YES];
            }

     }];
    
}

-(void)setDicData:(NSDictionary *)dicData{
    _dicData = dicData;
    
    [self.pageTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(30);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(56);
    }];
    
    [self.pageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pageTitleView.mas_bottom).offset(5);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
    }];

    [self.pageContentView.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pageContentView.mas_top).offset(0);
        make.left.mas_equalTo(self.pageContentView.mas_left).offset(0);
        make.right.mas_equalTo(self.pageContentView.mas_right).offset(0);
        make.bottom.mas_equalTo(self.pageContentView.mas_bottom).offset(0);
    }];
    
    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    self.navigationItem.rightBarButtonItem = confirmItem;
}


- (void)initData {
    self.dataArreEad = [NSMutableArray array];
    NSMutableArray *type1 = [NSMutableArray array];

    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.title =NSLocalizedString(@"container_internal_path", @"容器内部路径");
        //        model.value = self.dicData[@"imageName"];
        model.hasArrow = YES;
        model.lastCell = NO;
        model.onClick = ^{
        };
        [type1 addObject:model];
    }
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.lastCell = YES;
        model.hasArrow = YES;
        model.onClick = ^{
            
        };
        [type1 addObject:model];
    
    }
    [self.dataArreEad addObject:type1];
    
    NSMutableArray *type2 = [NSMutableArray array];
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.title =NSLocalizedString(@"container_internal_path", @"容器内部路径");
        model.value = @"8000";
        model.value1 = NSLocalizedString(@"internal_port", @"内部端口");
        model.value2 = NSLocalizedString(@"http_request_forward", @"http请求转发");
        //        model.value = self.dicData[@"imageName"];
        model.hasArrow = YES;
        model.lastCell = NO;
        model.onClick = ^{
          
        };
        [type2 addObject:model];

    }
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.lastCell = YES;
        model.hasArrow = YES;
        model.onClick = ^{
            
        };
        [type2 addObject:model];
  
    }
    [self.dataArreEad addObject:type2];
    
    NSMutableArray *type3 = [NSMutableArray array];
    {
        ESDeveloInfo * model = [[ESDeveloInfo alloc] init];
        model.title = NSLocalizedString(@"network_type", @"网络类型");
        model.value = @"bridge";
        model.isSelected = NO;
        //        model.value = self.dicData[@"imageName"];
        model.hasArrow = NO;
        model.lastCell = NO;
        model.onClick = ^{
        };
        [type3 addObject:model];
    }
  
    [self.dataArreEad addObject:type3];
  
}
@end
