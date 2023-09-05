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
//  ESV2InstallApp.m
//  EulixSpace
//
//  Created by qu on 2023/1/5.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESV2InstallApp.h"
#import "ESGradientButton.h"
#import "ESInstallSettingV2VC.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"
#import "ESFileDefine.h"
#import "ESCellModel.h"
#import "ESDeveloInfo.h"
#import "ESToast.h"
#import "ESAgreementWebVC.h"
#import "ESPlatformClient.h"
#import "ESLocalizableDefine.h"
#import "ESWebContainerViewController.h"
#import "ESFeedbackViewController.h"
#import "ESDeveloperVC.h"
#import "ESCellMoelKFZ.h"
#import "ESCommonToolManager.h"

#import <SDWebImage/SDWebImage.h>

@interface ESV2InstallApp ()


@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *titleText;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UILabel *size;

@property (nonatomic, strong) UILabel *sizeText;

@property (nonatomic, strong) UILabel *source;

@property (nonatomic, strong) UILabel *sourceText;


@property (nonatomic, strong) UILabel *appDesc;

@property (nonatomic, strong) UILabel *searchDesc;

@property (nonatomic, strong) NSString *tid;

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) UIButton *downline;

@property (nonatomic, strong) UIButton *compleBtn;


@property (nonatomic, strong) ESGradientButton *bindBox;

@property (nonatomic, strong) dispatch_source_t timer;


@property (nonatomic, strong) UIImageView *appResultImageView;

@property (nonatomic, strong) UILabel *appResult;

@property (nonatomic, strong) UILabel *appResultDesc;

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, assign) BOOL isShiBai;

@property (nonatomic, strong) NSString *appid;

@property (nonatomic, strong) UIView *line;

@end

@implementation ESV2InstallApp

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"install_mirror", @"安装镜像");
  //  [self initUI];
  
}

- (void)initUI {
    self.isShiBai = NO;
    self.iconImageView.image = [UIImage imageNamed:@"docker"];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(80);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];

    [self.titleText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.right.mas_equalTo(self.view.mas_right).offset(-26);
    }];
    
    [self.source mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleText.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view.mas_left).offset(55);
        make.height.mas_equalTo(22);
    }];

    self.sourceText.text = NSLocalizedString(@"source", @"来源");
    [self.sourceText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.source.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.source.mas_centerX);
        make.height.mas_equalTo(22);
    }];
    [self.size mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleText.mas_bottom).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-68);
        make.height.mas_equalTo(22);
    }];

    self.sizeText.text =  NSLocalizedString(@"size", @"大小");
    [self.sizeText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.size.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.size.mas_centerX);
        make.height.mas_equalTo(22);
    }];

    [self.bindBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-93-kBottomHeight);
    }];
    
    [self.downline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-93-kBottomHeight);
    }];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Ensure_that_the_image_package", @"*确保镜像包支持ARM64架构，否则可能会导致安装失败或不可用")];
    if ([ESCommonToolManager isEnglish]) {
        [attStr addAttribute:NSForegroundColorAttributeName value:[ESColor primaryColor] range:NSMakeRange(44, 5)];
    }else{
        [attStr addAttribute:NSForegroundColorAttributeName value:[ESColor primaryColor] range:NSMakeRange(10, 5)];
    }

    self.searchDesc.attributedText = attStr;

    [self.searchDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-26);
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(self.bindBox.mas_bottom).offset(20);
    }];
    self.actionButton.hidden = YES;
    self.searchDesc.hidden = NO;
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.bindBox.mas_bottom).offset(20);
    }];
    
    [self.appDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-26);
        make.left.mas_equalTo(self.view.mas_left).offset(26);
        make.top.mas_equalTo(self.sizeText.mas_bottom).offset(20);
    }];

    [self.appResultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.width.mas_equalTo(30);
        make.top.mas_equalTo(self.appDesc.mas_bottom).offset(10);
    }];
    
    [self.appResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(112);
        make.top.mas_equalTo(self.appResultImageView.mas_bottom).offset(10);
    }];
    
    [self.appResultDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(112);
        make.top.mas_equalTo(self.appResult.mas_bottom).offset(10);
    }];
    
    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    self.navigationItem.rightBarButtonItem = confirmItem;
}


-(void)setDataDic:(NSDictionary *)dataDic{
    [self initUI];
    _dataDic = dataDic;
    self.titleText.text = dataDic[@"imageName"];
    if(!dataDic[@"source"]){
        self.source.text = NSLocalizedString(@"private_library", @"私有库");
    }else{
        self.source.text = dataDic[@"source"];
    }
    
    NSNumber *size = dataDic[@"size"];
    if(!size){
        self.size.text = NSLocalizedString(@"unknown", @"未知");
    }else{
        self.size.text = CapacitySizeString(size.longLongValue,1024, YES);
    }

    self.appDesc.text = dataDic[@"description"];
    NSString *str = dataDic[@"iconUrl"];
    if(str.length > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *imageurl = [NSURL URLWithString:str];
            [ self.iconImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"app_docker"]];
        });
    }
}

-(void)installApp:(NSArray *)array1 array2:(NSArray *)array{
    
    NSMutableArray *volumes = [[NSMutableArray alloc] init];
    NSArray *volumesArray = array[0];
    for (ESDeveloInfo *volumesInfo in volumesArray) {
        if(!volumesInfo.lastCell){
            [volumes addObject:[NSString stringWithFormat:@"/%@",volumesInfo.value]];
        }
        
    }
    //    ESDeveloInfo *volumesInfo = volumesArray[0];
    
    NSMutableArray *ports = [[NSMutableArray alloc] init];
    
    ESCellModel *modeName1 = array1[0];
    NSString *appName = modeName1.value;
    
    ESCellModel *modeName2 = array1[1];
    NSString *serviceName = modeName2.value;
    
    ESCellModel *modeName3 = array1[2];
    NSString *appDomainPrefix = modeName3.value;
    
    NSArray *array2 = array[1];
    
    for(int i=0; i < array2.count ; i++){
        ESDeveloInfo *info = array2[i];
        if(!info.lastCell){
            NSMutableDictionary *dic = [NSMutableDictionary new];
            NSString *port =info.value;
            
            [dic setObject:@(port.intValue) forKey:@"number"];
            if([info.value1 isEqual:NSLocalizedString(@"internal_port", @"内部端口")]){
                [dic setObject:@"internal" forKey:@"type"];
            }else{
                [dic setObject:@"intranet" forKey:@"type"];
            }
            
            if([info.value2 isEqual:NSLocalizedString(@"http_request_forward", @"http请求转发")]){
                [dic setObject:@"http" forKey:@"usage"];
            }else{
                [dic setObject:@"other" forKey:@"usage"];
            }
            
            [dic setObject:@"tcp" forKey:@"protocol"];
            //        [dic setObject:@"http" forKey:@"usage"];
            [dic setObject:@"bridge" forKey:@"networkType"];
            
            [ports addObject:dic];
        }
    }
    
    NSDictionary *dicData = [ESBoxManager cacheInfoForBox:ESBoxManager.activeBox];
    NSString *userDomain = dicData[@"userDomain"];
    NSString *webUrl = [NSString stringWithFormat:@"%@-%@",appDomainPrefix,userDomain];
    
    NSMutableArray *environments = [[NSMutableArray alloc] init];
    if(array.count > 3){
        NSArray *environmentsArray = array[3];
        for (ESDeveloInfo *info in environmentsArray) {
            if(info.dicParameter && !info.lastCell ){
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                
                [dic setValue:info.dicParameter.allKeys[0] forKey:@"key"];
                [dic setValue:info.dicParameter.allValues[0] forKey:@"value"];
                [environments addObject:dic];
            }
        }
    }
    
    if(appName.length < 1){
        appName = @"";
    }
    if(serviceName.length < 1){
        serviceName = @"";
    }
    if(appDomainPrefix.length < 1){
        appDomainPrefix = @"";
    }
    
    NSArray *appNameArray = [self.dataDic[@"imageName"] componentsSeparatedByString:@"/"];
    NSString *imageName;
    if(appNameArray.count > 1){
        imageName = appNameArray[appNameArray.count-1];
    }else{
        imageName = self.dataDic[@"imageName"];
    }
    
    ESCellMoelKFZ *model = array1[0];
    NSString *name = model.value;
    NSString *dataDicImageName = self.dataDic[@"imageName"];
    if(dataDicImageName.length < 1){
        dataDicImageName = @"";
    }else{
        dataDicImageName = self.dataDic[@"imageName"];
    }
    
    if(imageName.length < 1){
        imageName = @"";
    }
    NSString *iconUrl = self.dataDic[@"iconUrl"];
    if(iconUrl.length < 1){
        iconUrl = @"";
    }else{
        iconUrl = self.dataDic[@"iconUrl"];;
    }
    
    if(volumes.count > 0 && environments > 0){
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                        apiName:@"applet_deploy_image"                                                queryParams:@{}
                                                         header:@{}
                                                           body:@{
                //@"imageName" : self.address,
                                                                  @"imageAddress":dataDicImageName,
                                                                  @"imageName":dataDicImageName,
                                                                  @"appName" : name,
                                                                  @"serviceName" : serviceName,
                                                                  @"appDomainPrefix":appDomainPrefix,
                                                                  @"limitType": @"unlimited",
                                                                  @"webUrl":  webUrl,
                                                                  @"selfStart": @(true),
                                                                  @"ports": ports,
                                                                  @"volumes": volumes,
                                                                  @"environments": environments,
                                                                  @"iconUrl": iconUrl,
                                                           
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {

            self.tid = response[@"tid"];
            [self creatTimer];

          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@",error);
//            [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
            [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
            self.bindBox.hidden = YES;
            self.compleBtn.hidden = YES;
            self.downline.hidden = NO;
            self.isShiBai = YES;
            self.appResult.text = NSLocalizedString(@"applet_install_fail", @"安装失败");
            self.appResultDesc.text = NSLocalizedString(@"unknown_reason", @"未知原因");
            self.appResultImageView.image = [UIImage imageNamed:@"shibai"];
            
            [self.bindBox stopLoading:NSLocalizedString(@"next", @"下一步")];
            [self timerStop];
         }];
    }else if(volumes.count > 0 && environments.count < 1){
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                        apiName:@"applet_deploy_image"                                                queryParams:@{}
                                                         header:@{}
                                                           body:@{
                //@"imageName" : self.address,
                                                                  @"imageAddress":dataDicImageName,
                                                                  @"imageName":dataDicImageName,
                                                                  @"appName" : imageName,
                                                                  @"serviceName" : serviceName,
                                                                  @"appDomainPrefix":appDomainPrefix,
                                                                  @"limitType": @"unlimited",
                                                                  @"webUrl":  webUrl,
                                                                  @"selfStart": @(true),
                                                                  @"ports": ports,
                                                                  @"volumes": volumes,
                                                                  @"iconUrl": iconUrl,
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {

            self.tid = response[@"tid"];
            [self creatTimer];

          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@",error);
            [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
            self.bindBox.hidden = YES;
            self.compleBtn.hidden = YES;
            self.downline.hidden = NO;
            self.appResult.text =NSLocalizedString(@"applet_install_fail", @"安装失败");
            self.appResultDesc.text = NSLocalizedString(@"unknown_reason", @"未知原因");
            self.appResultImageView.image = [UIImage imageNamed:@"shibai"];
            [self timerStop];
            [self.bindBox stopLoading:NSLocalizedString(@"next", @"下一步")];
            [self timerStop];
         }];
        
    }else if(volumes.count < 1 && environments.count < 0){
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                        apiName:@"applet_deploy_image"                                                queryParams:@{}
                                                         header:@{}
                                                           body:@{
                //@"imageName" : self.address,
                                                                  @"imageAddress":dataDicImageName,
                                                                  @"imageName":dataDicImageName,
                                                                  @"appName" : imageName,
                                                                  @"serviceName" : serviceName,
                                                                  @"appDomainPrefix":appDomainPrefix,
                                                                  @"limitType": @"unlimited",
                                                                  @"webUrl":  webUrl,
                                                                  @"selfStart": @(true),
                                                                  @"ports": ports,
                                                                  @"environments": environments,
                                                                  @"iconUrl": iconUrl,
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {

            self.tid = response[@"tid"];
            [self creatTimer];

          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@",error);
            [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
            self.bindBox.hidden = YES;
            self.compleBtn.hidden = YES;
            self.downline.hidden = NO;
            self.appResult.text = NSLocalizedString(@"applet_install_fail", @"安装失败");
            self.appResultDesc.text = NSLocalizedString(@"unknown_reason", @"未知原因");
            self.isShiBai = YES;
            self.appResultImageView.image = [UIImage imageNamed:@"shibai"];
            [self timerStop];
            [self.bindBox stopLoading:NSLocalizedString(@"next", @"下一步")];
            [self timerStop];
         }];
    }else if(volumes.count > 0 && environments.count < 1){
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                        apiName:@"applet_deploy_image"                                                queryParams:@{}
                                                         header:@{}
                                                           body:@{
                //@"imageName" : self.address,
                                                                  @"imageAddress":imageName,
                                                                  @"imageName":imageName,
                                                                  @"appName" : imageName,
                                                                  @"serviceName" : imageName,
                                                                  @"appDomainPrefix":appDomainPrefix,
                                                                  @"limitType": @"unlimited",
                                                                  @"webUrl":  webUrl,
                                                                  @"selfStart": @(true),
                                                                  @"ports": ports,
                                                                  @"volumes": volumes,
                                                                  @"iconUrl": iconUrl,
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {

            self.tid = response[@"tid"];
            [self creatTimer];

          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@",error);
            [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
            self.bindBox.hidden = YES;
            self.compleBtn.hidden = YES;
            self.downline.hidden = NO;
            self.appResult.text =NSLocalizedString(@"applet_install_fail", @"安装失败");
            self.isShiBai = YES;
            self.appResultDesc.text = NSLocalizedString(@"unknown_reason", @"未知原因");
            self.appResultImageView.image = [UIImage imageNamed:@"shibai"];
            [self timerStop];
            [self.bindBox stopLoading:NSLocalizedString(@"next", @"下一步")];
            [self timerStop];
         }];
    }else {
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                        apiName:@"applet_deploy_image"                                                queryParams:@{}
                                                         header:@{}
                                                           body:@{
                //@"imageName" : self.address,
                                                                  @"imageAddress":dataDicImageName,
                                                                  @"imageName":imageName,
                                                                  @"appName" : appName,
                                                                  @"serviceName" : serviceName,
                                                                  @"appDomainPrefix":appDomainPrefix,
                                                                  @"limitType": @"unlimited",
                                                                  @"webUrl":  webUrl,
                                                                  @"selfStart": @(true),
                                                                  @"ports": ports,
                                                                  @"iconUrl": iconUrl,
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {

            self.tid = response[@"tid"];
            [self creatTimer];

          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@",error);
            [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
            
            self.bindBox.hidden = YES;
            self.compleBtn.hidden = YES;
            self.downline.hidden = NO;
            self.appResult.text =NSLocalizedString(@"applet_install_fail", @"安装失败");
            self.isShiBai = YES;
            self.appResultDesc.text = NSLocalizedString(@"unknown_reason", @"未知原因");
            self.appResultImageView.image = [UIImage imageNamed:@"shibai"];
            [self timerStop];
            [self.bindBox stopLoading:NSLocalizedString(@"next", @"下一步")];
            [self timerStop];
         }];
    }
}


- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        [self.view addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)appResultImageView {
    if (!_appResultImageView) {
        _appResultImageView = [[UIImageView alloc] init];
        _appResultImageView.contentMode = UIViewContentModeScaleAspectFill;
        _appResultImageView.clipsToBounds = YES;
        [self.view addSubview:_appResultImageView];
    }
    return _appResultImageView;
}


- (UILabel *)appResult {
    if (!_appResult) {
        _appResult = [[UILabel alloc] init];
        _appResult.textColor = ESColor.labelColor;
        _appResult.textAlignment = NSTextAlignmentCenter;
        _appResult.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_appResult];
    }
    return _appResult;
}

- (UILabel *)appResultDesc {
    if (!_appResultDesc) {
        _appResultDesc = [[UILabel alloc] init];
        _appResultDesc.textColor = ESColor.secondaryLabelColor;
        _appResultDesc.textAlignment = NSTextAlignmentCenter;
        _appResultDesc.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_appResultDesc];
    }
    return _appResultDesc;
}
-(void)setAddress:(NSString *)address{
    _address = address;
}

- (UILabel *)titleText {
    if (!_titleText) {
        _titleText = [[UILabel alloc] init];
        _titleText.textColor = ESColor.labelColor;
        _titleText.textAlignment = NSTextAlignmentCenter;
        _titleText.numberOfLines = 0;
        //_titleText.font = [UIFont systemFontOfSize:16];
        _titleText.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.view addSubview:_titleText];
    }
    return _titleText;
}

- (UILabel *)size {
    if (!_size) {
        _size = [[UILabel alloc] init];
        _size.textColor = ESColor.labelColor;
        _size.textAlignment = NSTextAlignmentLeft;
        _size.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _size.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:_size];
    }
    return _size;
}

- (UILabel *)sizeText {
    if (!_sizeText) {
        _sizeText = [[UILabel alloc] init];
        _sizeText.textColor = ESColor.secondaryLabelColor;
        _sizeText.textAlignment = NSTextAlignmentLeft;
        _sizeText.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:_sizeText];
    }
    return _sizeText;
}

- (UILabel *)source {
    if (!_source) {
        _source = [[UILabel alloc] init];
        _source.textColor = ESColor.labelColor;
        _source.textAlignment = NSTextAlignmentLeft;
        _source.font = [UIFont systemFontOfSize:16];
        _source.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.view addSubview:_source];
    }
    return _source;
}

- (UILabel *)sourceText {
    if (!_sourceText) {
        _sourceText = [[UILabel alloc] init];
        _sourceText.textColor = ESColor.secondaryLabelColor;
        _sourceText.textAlignment = NSTextAlignmentLeft;
        _sourceText.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:_sourceText];
    }
    return _sourceText;
}


- (ESGradientButton *)bindBox {
    if (!_bindBox) {
        _bindBox = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
        [_bindBox setCornerRadius:10];
        [_bindBox setTitle:NSLocalizedString(@"next", @"下一步") forState:UIControlStateNormal];
        _bindBox.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_bindBox setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_bindBox];
        [_bindBox addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindBox;
}


-(void)next{
    self.actionButton.hidden = YES;
    self.searchDesc.hidden = NO;
    if([_bindBox.titleLabel.text isEqual:NSLocalizedString(@"Open", @"打开")]){
        ESAgreementWebVC *vc =  [ESAgreementWebVC new];
        vc.agreementType = ESAppOpen;
        vc.name = self.titleText.text;
        vc.urlStr = self.urlStr;
        ESAppletInfoModel *info =  [ESAppletInfoModel new];
        info.appletId = self.appid;
        vc.appletInfo =info;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        ESInstallSettingV2VC *vc = [ESInstallSettingV2VC new];
        vc.dicData = self.dataDic;
        weakfy(self);
        vc.install= ^(NSArray *array1,NSArray *array2){
            strongfy(self);
            [self.bindBox startLoading:NSLocalizedString(@"installing", @"安装中")];
            self.actionButton.hidden = NO;
            self.searchDesc.hidden = YES;
            [self installApp:array1 array2:array2];

        };
        [self.navigationController pushViewController:vc animated:YES];
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

- (void)getManagementServiceApi {
    if(self.tid.length < 1){
        self.tid = @"";
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-applet-service"
                                                    apiName:@"applet_get_deploy_transaction"
                                                queryParams:@{@"tid":self.tid}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        NSDictionary *dic = response;
        NSDictionary *conText = dic[@"context"];
        NSString *appid = conText[@"appId"];
        self.appid = appid;
        self.urlStr = conText[@"webUrl"];
        if(appid.length < 1){
            appid =@"1";
        }
     
        if([dic[@"status"] isEqual:@"DONE"]){
            self.actionButton.hidden = YES;
            [self timerStop];
            [self.bindBox stopLoading:NSLocalizedString(@"Open", @"打开")];
            self.compleBtn.hidden = NO;
            self.appResultDesc.hidden = YES;
            self.appResult.text = NSLocalizedString(@"install_success_text", @"安装成功");
            self.isShiBai = NO;
            self.appResultImageView.image = [UIImage imageNamed:@"result_success"];
            [self.compleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(140);
                make.height.mas_equalTo(44);
                make.left.mas_equalTo(self.view.mas_left).offset(37);
                make.bottom.mas_equalTo(self.view.mas_bottom).offset(-93-kBottomHeight);
            }];
            
            [self.bindBox mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(44);
                make.right.mas_equalTo(self.view.mas_right).offset(-37);
                make.bottom.mas_equalTo(self.view.mas_bottom).offset(-93-kBottomHeight);
                make.width.mas_equalTo(140);
            }];
            [self.view layoutIfNeeded];
            
        }else if([dic[@"status"] isEqual:@"ERROR"]){
            self.actionButton.hidden = YES;
            [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
            self.bindBox.hidden = YES;
            self.compleBtn.hidden = YES;
            self.downline.hidden = NO;
            self.isShiBai = YES;
            self.appResult.text =NSLocalizedString(@"applet_install_fail", @"安装失败");
            self.appResultDesc.text = NSLocalizedString(@"unknown_reason", @"未知原因");
            self.appResultImageView.image = [UIImage imageNamed:@"shibai"];
            [self timerStop];
            [self.bindBox stopLoading:NSLocalizedString(@"next", @"下一步")];
            [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                            apiName:@"appstore_uninstall"
                                                        queryParams:@{ @"appid" : appid
                                                                    }
                                                             header:@{}
                                                               body:@{}
                                                          modelName:nil
                                                       successBlock:^(NSInteger requestId, id  _Nullable response) {
            
                } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                 //   __strong typeof(weakSelf) self = weakSelf;
                    if (error) {
                     NSLog(@"%@",error);
                       return;
                   }
                }];
        }
    }
       failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                      
        [self timerStop];
        }];

}

- (UIButton *)downline {
    if (nil == _downline) {
        _downline = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downline.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_downline addTarget:self action:@selector(returnClick) forControlEvents:UIControlEventTouchUpInside];
        [_downline setTitle:NSLocalizedString(@"common_back", @"返回") forState:UIControlStateNormal];
        _downline.backgroundColor = [ESColor.secondarySystemBackgroundColor colorWithAlphaComponent:1];
       // [_downline setBackgroundColor:ESColor.secondarySystemBackgroundColor forState:UIControlStateNormal];
        [_downline setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [self.view addSubview:_downline];
        [_downline.layer setCornerRadius:10.0]; //设置矩圆角半径
        _downline.layer.masksToBounds = YES;
        _downline.hidden = YES;
    }
    return _downline;
}

- (UIButton *)compleBtn {
    if (nil == _compleBtn) {
        _compleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_compleBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_compleBtn addTarget:self action:@selector(downlineClick) forControlEvents:UIControlEventTouchUpInside];
        [_compleBtn setTitle:NSLocalizedString(@"done", @"完成") forState:UIControlStateNormal];
        _compleBtn.backgroundColor = [ESColor.secondarySystemBackgroundColor colorWithAlphaComponent:1];
       // [_downline setBackgroundColor:ESColor.secondarySystemBackgroundColor forState:UIControlStateNormal];
        [_compleBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [self.view addSubview:_compleBtn];
        [_compleBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
        _compleBtn.layer.masksToBounds = YES;
        _compleBtn.hidden = NO;
    }
    return _compleBtn;
}

-(void)downlineClick{
//    if(self.isShiBai){
        for (UIViewController *controller in self.navigationController.viewControllers) {

            if ([controller isKindOfClass:[ESDeveloperVC class]]) {

                ESDeveloperVC *A =(ESDeveloperVC *)controller;

                [self.navigationController popToViewController:A animated:YES];
                
            }

        }
   // }
}

-(void)returnClick{

        for (UIViewController *controller in self.navigationController.viewControllers) {

            if ([controller isKindOfClass:[ESDeveloperVC class]]) {

                ESDeveloperVC *A =(ESDeveloperVC *)controller;

                [self.navigationController popToViewController:A animated:YES];
                
            }
        }
}



- (UILabel *)searchDesc {
    if (!_searchDesc) {
        _searchDesc = [[UILabel alloc] init];
        _searchDesc.textColor = ESColor.secondaryLabelColor;
        _searchDesc.textAlignment = NSTextAlignmentLeft;
        _searchDesc.numberOfLines = 0;
        _searchDesc.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        
        [self.view addSubview:_searchDesc];
    }
    return _searchDesc;
}

- (UILabel *)appDesc {
    if (!_appDesc) {
        _appDesc = [[UILabel alloc] init];
        _appDesc.textColor = ESColor.labelColor;
        _appDesc.textAlignment = NSTextAlignmentLeft;
        _appDesc.numberOfLines = 0;
        _appDesc.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.view addSubview:_appDesc];
    }
    return _appDesc;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] init];
        _rightBtn.backgroundColor = ESColor.clearColor;
        _rightBtn.frame = CGRectMake(0, 0, 45, 45);
        [_rightBtn setImage:[UIImage imageNamed:@"searchRight"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_rightBtn];
    }
    return _rightBtn;
}

-(void)selectBtnAction{
  
    ///帮助与反馈
    ESWebContainerViewController *next = [ESWebContainerViewController new];
    NSString *baseUrl = ESPlatformClient.platformClient.platformUrl;
    NSString *s_help = [NSString stringWithFormat:@"%@/support/help/004001", baseUrl];
    next.webUrl = s_help;
    next.webTitle = TEXT_HOME_HELP;
    next.hideNavigationBar = NO;
//            next.insets = UIEdgeInsetsMake(-kTopHeight, 0, 0, 0);
    [next registerAction:@"onClickExit"
                callback:^(id body) {
                    [self goBack];
                }];
    [next registerAction:@"onClickFeedback"
                callback:^(id body) {
                    ESFeedbackViewController *next = [ESFeedbackViewController new];
                    [self.navigationController pushViewController:next animated:YES];
                }];
    [self.navigationController pushViewController:next animated:YES];
}

-(void)goBack{
    [super goBack];
    
    if(self.isShiBai){
        for (UIViewController *controller in self.navigationController.viewControllers) {

            if ([controller isKindOfClass:[ESDeveloperVC class]]) {
                ESDeveloperVC *A =(ESDeveloperVC *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }

        }
    }
}


- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_actionButton setTitle:NSLocalizedString(@"run_background", @"后台执行") forState:UIControlStateNormal];
        [_actionButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_actionButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(actionButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_actionButton];
        self.line = [UIView new];
        self.line.backgroundColor = ESColor.primaryColor;
        [_actionButton addSubview:self.line];
        

        [_actionButton sizeToFit];
        if ([ESCommonToolManager isEnglish]) {
            [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(150);
                make.height.mas_equalTo(1);
                make.centerX.mas_equalTo(_actionButton);
                make.bottom.mas_equalTo(_actionButton.mas_bottom).offset(0);
            }];
        }else{
            [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(70);
                make.height.mas_equalTo(1);
                make.centerX.mas_equalTo(_actionButton);
                make.bottom.mas_equalTo(_actionButton.mas_bottom).offset(0);
            }];
        }
    }
    return _actionButton;
}

- (void)actionButtonClick {
    [self timerStop];
    for (UIViewController *temp in self.navigationController.viewControllers) {
        [self.navigationController popToViewController:temp animated:YES];
//          if ([temp isKindOfClass:[ESBackUpVC class]]) {
//             [self.navigationController popToViewController:temp animated:YES];
//          }
    }
}
@end
