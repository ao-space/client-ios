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
//  ESAppWelcome.m
//  EulixSpace
//
//  Created by qu on 2023/6/30.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESAppWelcome.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESNetworkRequestManager.h"
#import "ESGradientButton.h"
#import "ESAppStoreModel.h"
#import "ESFormView.h"
#import "ESAppStoreManage.h"
#import "ESCache.h"
#import "ESAgreementWebVC.h"
#import "UIColor+ESHEXTransform.h"
#import <Masonry/Masonry.h>
#import "NSError+ESTool.h"
#import "ESAppInstalledModel.h"
#import "ESCommonToolManager.h"

@interface ESAppWelcome()

@property(nonatomic,strong) UILabel *titleText;
@property(nonatomic,strong) UILabel *name;
@property(nonatomic,strong) UILabel *link;
@property(nonatomic,strong) UILabel *linkText;
@property(nonatomic,strong) UIImageView *headImageViewBg;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) ESGradientButton *openBtn;

@property(nonatomic,strong) UIButton *selectedBtn;
@property(nonatomic,strong) UILabel *selectedText;
@property (strong, nonatomic) NSMutableArray *dataList;

@property(nonatomic,strong) UIView *maskView;

@property(nonatomic,strong) UIImageView *loadingImageView;

@property(nonatomic,strong) UILabel *loadingText;

@property (nonatomic, strong) dispatch_source_t timer;

@property(nonatomic,strong) UIImageView *installFailImageView;
@property(nonatomic,strong) UILabel *failLabel;
@property(nonatomic,strong) UILabel *failLabelPointOut;

@property(nonatomic,strong) ESGradientButton *uninstallBtn;

@property(nonatomic,strong) UIImageView *selectImageView;



@end

@implementation ESAppWelcome

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    
    [self.headImageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(200); // 设置顶部距离为 40
        make.centerX.equalTo(self.view); // 水平居中对齐
        make.width.height.equalTo(@50); // 设置宽度和高度为 50
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headImageViewBg);
        make.centerY.mas_equalTo(self.headImageViewBg);
        make.height.width.mas_equalTo(@50);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.headImageViewBg);
        
    }];
    
    if (self.item.iconUrl.length > 0) {
        [self.headImageView es_setImageWithURL:self.item.iconUrl placeholderImageName:nil];
    }
    
    if(self.item.state < 1){
        self.titleText.hidden = YES;
        self.link.hidden = YES;
        self.linkText.hidden = YES;
        self.linkText.hidden = YES;
        self.selectedBtn.hidden = YES;
        self.openBtn.hidden = YES;
        self.selectedText.hidden = YES;
        self.selectedBtn.hidden = YES;
        self.loadingImageView.hidden = NO;
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.centerY.mas_equalTo(self.view);
            make.width.mas_equalTo(24);
            make.height.mas_equalTo(24);
        }];
        
        [self.loadingText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loadingImageView.mas_bottom).offset(10); // 设置顶部距离为 40
            make.centerX.equalTo(self.view); // 水平居中对齐
        }];
        [self creatTimer];
        
    }else if(self.item.state == ESINSTALLFAIL){
        [self installFail];
    }else{
        [self installSuccess];
    }
    self.name.text = self.item.title;
}

- (UILabel *)titleText {
    if (!_titleText) {
        _titleText = [[UILabel alloc] init];
        _titleText.text =NSLocalizedString(@"application_guide", @"欢迎使用");
        _titleText.textColor = [UIColor blackColor];
        _titleText.textAlignment = NSTextAlignmentCenter;
        _titleText.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
        [self.view addSubview:_titleText];
    }
    return _titleText;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.textColor = ESColor.labelColor;
        _name.textAlignment = NSTextAlignmentCenter;
        _name.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.view addSubview:_name];
    }
    return _name;
}

- (UILabel *)link {
    if (!_link) {
        _link = [[UILabel alloc] init];
        _link.text = NSLocalizedString(@"page_link", @"网页链接");
        _link.textColor = [UIColor blackColor];
        _link.textAlignment = NSTextAlignmentLeft;
        _link.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:_link];
    }
    return _link;
}

- (UILabel *)linkText {
    if (!_linkText) {
        _linkText = [[UILabel alloc] init];
        _linkText.textColor = [UIColor es_colorWithHexString:@"#85899C"];
        _linkText.numberOfLines = 0;
        _linkText.textAlignment = NSTextAlignmentLeft;
        _linkText.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_linkText];
    }
    return _linkText;
}

//- (UILabel *)selectedText {
//    if (!_selectedText) {
//        _selectedText = [[UILabel alloc] init];
//        _selectedText.textColor = [UIColor es_colorWithHexString:@"#85899C"];
//        _selectedText.textAlignment = NSTextAlignmentLeft;
//        _selectedText.font = [UIFont systemFontOfSize:14];
//        [self.view addSubview:_selectedText];
//    }
//    return _selectedText;
//}


- (UIImageView *)headImageViewBg {
    if (!_headImageViewBg) {
        _headImageViewBg = [[UIImageView alloc] init];
        _headImageViewBg.backgroundColor = ESColor.iconBg;
        _headImageViewBg.layer.cornerRadius = 6.0;
        _headImageViewBg.layer.masksToBounds = YES;
        [self.view addSubview:_headImageViewBg];
    }
    return _headImageViewBg;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [UIImageView new];
        _headImageView.image = [UIImage imageNamed:@"app_docker"];
        [self.headImageViewBg addSubview:_headImageView];

    }
    return _headImageView;
}

- (ESGradientButton *)openBtn {
    if (!_openBtn) {
        _openBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_openBtn setCornerRadius:10];
        _openBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_openBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_openBtn];
        _openBtn.alpha = 1;
        [_openBtn addTarget:self action:@selector(openBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openBtn;
}

- (UIButton *)selectedBtn {
    if (nil == _selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.selected = YES;
        
        // 设置按钮的图像和标题
        [_selectedBtn setImage:[UIImage imageNamed:@"V2_app_sel"] forState:UIControlStateNormal];
        [_selectedBtn setTitle:NSLocalizedString(@"application_guideclose", @"关闭后不再提示") forState:UIControlStateNormal];
        _selectedBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [_selectedBtn setTitleColor:[UIColor es_colorWithHexString:@"#85899C"] forState:UIControlStateNormal];
        
        // 设置图片和标题的间距
        CGFloat spacing = 10.0; // 自定义间距
        CGSize imageSize = _selectedBtn.imageView.image.size;
        CGSize titleSize = [_selectedBtn.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: _selectedBtn.titleLabel.font }];
        
        // 调整图片和标题的偏移
        _selectedBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, spacing/2.0, 0.0, -spacing/2.0);
        _selectedBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0, -spacing/2.0, 0.0, spacing/2.0);
        
        // 设置按钮的内容布局为左对齐
        _selectedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [self.view addSubview:_selectedBtn];
    }
    return _selectedBtn;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.image = [UIImage imageNamed:@"V2_app_sel"];
        _selectImageView.hidden = YES;
        [self.view addSubview:_selectImageView];
    }
    return _selectImageView;
}

-(void)didClickSelectedBtn:(UIButton *)btn{

    if(self.selectedBtn.selected){
//        self.selectImageView.image=[UIImage imageNamed:@"V2_app_no_sel"];
        [self.selectedBtn setImage:[UIImage imageNamed:@"V2_app_no_sel"] forState:UIControlStateNormal];
        self.selectedBtn.selected = NO;
    }else{
//        self.selectImageView.image = [UIImage imageNamed:@"V2_app_sel"];
        [self.selectedBtn setImage:[UIImage imageNamed:@"V2_app_sel"] forState:UIControlStateNormal];
        self.selectedBtn.selected = YES;
    }

}

-(void)openBtnAct:(UIButton *)btn{
    NSMutableDictionary *dicMutable;
    NSDictionary *dicApp = [[ESCache defaultCache] objectForKey:@"v2_app_sel_status"];
    if(dicApp){
        dicMutable = [NSMutableDictionary dictionaryWithDictionary:dicApp];
    }else{
        dicMutable = [NSMutableDictionary new];
    }
    NSString *key = [ESCommonToolManager miniAppKey:self.item.appId];
    if(self.selectedBtn.selected){
        [dicMutable setValue:@"YES" forKey:key];
        [[ESCache defaultCache] setObject:dicMutable forKey:@"v2_app_sel_status"];
    }else{
        [dicMutable setValue:@"NO" forKey:key];
        [[ESCache defaultCache] setObject:dicMutable forKey:@"v2_app_sel_status"];
    }
    
    if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            ESAgreementWebVC *vc = [ESAgreementWebVC new];
            vc.agreementType = ESAppOpen;
            vc.name = self.item.title;
            vc.urlStr = self.item.containerWebUrl;
            vc.source = @"Welcome";
            ESAppletInfoModel *info = [ESAppletInfoModel new];
            info.appletId =self.item.appId;
            info.name = self.item.title;
            info.iconUrl =self.item.iconUrl;
            info.appletVersion =self.item.version;
            info.deployMode =self.item.deployMode;
            info.installSource =self.item.installSource;
            info.type = @"dockApp";
            vc.appletInfo =info;
            [self.navigationController pushViewController:vc animated:YES];

        });
    }else{
        [self onSetting:self.item action:0];
    }
}

- (void)onSetting:(ESFormItem *)item action:(ESFormViewAction)action {
    
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    if(item.appId.length > 0){
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                        apiName:@"appstore_sort_list"
                                                    queryParams:@{}
                                                         header:@{}
                                                           body:@{}
                                                      modelName:@""
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
            ESAppStoreModel *model = [ESAppStoreModel new];
            self.dataList = [NSMutableArray new];
            
            if([response isKindOfClass:[NSArray class]]){
                for (NSDictionary *dictData in response) {
                    NSArray *arrayAppDate= dictData[@"appStoreResList"];
                    for (NSDictionary *dict in arrayAppDate) {
                        model = [ESAppStoreModel yy_modelWithJSON:dict];
                        [self.dataList addObject:model];
                        if([item.appId isEqual:model.appId]){
                            if([model.curVersion isEqual:model.version]){
                                item.isNewVersion = NO;
                            }else{
                                item.isNewVersion = YES;
                            }
                            item.source = @"ESAppWelcome";
                            [[ESAppStoreManage shared] down:item completionBlock:^(BOOL success, NSError * _Nullable error) {
                                [ESToast dismiss];
                            }];
                        }
                    }
                }
            }
        }
                                                      failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([[error codeString] isEqualToString:@"GW-5006"])  {
                [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
            }
            item.isNewVersion = NO;
            [[ESAppStoreManage shared] down:item completionBlock:^(BOOL success, NSError * _Nullable error) {
                [ESToast dismiss];
            }];
        }];
        
    }
}


-(void)setItem:(ESFormItem *)item{
    _item = item;
  
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

- (void)getManagementServiceApi {

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_get_local_apps"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        
        
        if([response isKindOfClass:[NSArray class]]){
 
            [self loadDataInstalled:response];
        }
    }
                                                  failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *data = [NSArray new];
        [self loadDataInstalled:data];
        [ESToast dismiss];
    }];
}

- (UIImageView *)loadingImageView {
    if (!_loadingImageView) {
        _loadingImageView = [UIImageView new];
        _loadingImageView.image = [UIImage imageNamed:@"v2_app_loading"];
        [self.view addSubview:_loadingImageView];
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
        rotationAnimation.duration = 1.0;
        rotationAnimation.repeatCount = HUGE_VALF;
        CALayer *layer = _loadingImageView.layer;
        [layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

        [_loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.centerY.mas_equalTo(self.view);
            make.width.height.mas_equalTo(24);
        }];
    }
    return _loadingImageView;
}


-(void)loadDataInstalled:(NSArray *)array{
    NSMutableArray<ESFormItem *> *data = NSMutableArray.array;

    for (NSDictionary *dict in array) {
        ESAppInstalledModel *model = [ESAppInstalledModel yy_modelWithJSON:dict];
        ESFormItem *item = [ESFormItem new];
        item.title = model.name;
        item.appId = model.appId;
        item.packageId = model.packageId;
        item.version = model.appletVersion;
        item.deployMode = model.deployMode;
        item.state = model.stateCode.intValue;
        if(model.containerWebUrl.length > 0 ){
            if ([model.containerWebUrl containsString:@"https:"]) {
                item.containerWebUrl = model.containerWebUrl;
            } else {
                item.containerWebUrl =  [NSString stringWithFormat:@"https://%@", model.containerWebUrl];
            }
        }
        item.installedAppletVersion = model.appletVersion;
        item.uninstallType =  model.uninstallType;
        item.iconUrl = model.iconUrl;
        [data addObject:item];
        if([item.appId isEqual:self.item.appId]){
            if(item.state !=ESINSTALLING){
                [self timerStop];
            }
            if(item.state== ESINSTALLED){
                [self installSuccess];
            }else if(item.state== ESINSTALLFAIL){
                [self installFail];
            }
        }
    }
}


- (UIImageView *)installFailImageView {
    if (!_installFailImageView) {
        _installFailImageView = [UIImageView new];
        _installFailImageView.image = [UIImage imageNamed:@"V2_app_fail"];
        [self.view addSubview:_installFailImageView];
    }
    return _installFailImageView;
}

  
  
- (UILabel *)loadingText {
    if (!_loadingText) {
        _loadingText = [[UILabel alloc] init];
        _loadingText.textColor = ESColor.labelColor;
        _loadingText.text =  NSLocalizedString(@"applet_installing", @"正在安装...");
        _loadingText.textAlignment = NSTextAlignmentLeft;
        _loadingText.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_loadingText];
    }
    return _loadingText;
}
- (UILabel *)failLabel {
    if (!_failLabel) {
        _failLabel = [[UILabel alloc] init];
        _failLabel.textColor = ESColor.labelColor;
        _failLabel.text = NSLocalizedString(@"applet_install_fail", @"安装失败");
        _failLabel.textAlignment = NSTextAlignmentLeft;
        _failLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:_failLabel];
    }
    return _failLabel;
}

- (UILabel *)failLabelPointOut {
    if (!_failLabelPointOut) {
        _failLabelPointOut = [[UILabel alloc] init];
        _failLabelPointOut.textColor = ESColor.labelColor;
        _failLabelPointOut.text = NSLocalizedString(@"unknown_reason", @"未知原因");
        _failLabelPointOut.textAlignment = NSTextAlignmentLeft;
        _failLabelPointOut.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_failLabelPointOut];
    }
    return _failLabelPointOut;
}


-(void)installSuccess{
    
    self.failLabelPointOut.hidden = YES;
    self.failLabel.hidden = YES;
    self.installFailImageView.hidden = YES;
    self.titleText.hidden = NO;
    self.link.hidden = NO;
    self.linkText.hidden = NO;
    self.linkText.hidden = NO;
    self.selectedBtn.hidden = NO;
    self.openBtn.hidden = NO;
    self.selectedText.hidden = NO;
    self.selectedBtn.hidden = NO;
    
    self.loadingImageView.hidden = YES;
    self.loadingText.hidden = YES;
    
    [self.titleText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(96); // 设置顶部距离为 96
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    
    [self.link mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20); // 左侧与 link 对齐，距离为 20
        make.top.equalTo(self.name.mas_bottom).offset(40); // 设置顶部距离为 40
        make.width.equalTo(@(70));
    }];
    
    [self.linkText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-26); // 距离右边缘距离为 26
        make.left.equalTo(self.link.mas_right).offset(20); // 左侧与 link 对齐，距离为 20
        make.top.equalTo(self.link.mas_top); // 垂直居中对齐
    }];
    
    
    [self.openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_bottom).offset(-200);
    }];
    
    
    if([ESCommonToolManager isEnglish]){
        [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.openBtn.mas_bottom).offset(5);
        }];
        
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(14);
            make.height.mas_equalTo(14);
            make.left.mas_equalTo(self.openBtn.mas_left).offset(20);
            make.top.mas_equalTo(self.openBtn.mas_bottom).offset(30);
        }];
        
//        [self.selectedText mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(self.selectImageView.mas_right).offset(10);
//            make.centerY.mas_equalTo(self.selectImageView.mas_centerY);
//        }];
    }else{
        [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.left.mas_equalTo(self.openBtn.mas_left).offset(20);
            make.top.mas_equalTo(self.openBtn.mas_bottom).offset(5);
        }];
        
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(14);
            make.height.mas_equalTo(14);
            make.left.mas_equalTo(self.openBtn.mas_left).offset(46);
            make.top.mas_equalTo(self.openBtn.mas_bottom).offset(30);
        }];
//        [self.selectedText mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(self.selectImageView.mas_right).offset(10);
//            make.centerY.mas_equalTo(self.selectImageView.mas_centerY);
//        }];
    }
    
    
    self.link.text =  NSLocalizedString(@"page_link", @"网页链接");
    if([self.item.deployMode isEqual:@"service"] || [self.item.deployMode isEqual:@"frontService"]){
        if(![self.item.containerWebUrl containsString:@"http"]){
            self.item.containerWebUrl  =  [NSString stringWithFormat:@"https://%@", self.item.containerWebUrl];
        }
        
        NSURL *url = [NSURL URLWithString:self.item.containerWebUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url] && ![self.item.containerWebUrl containsString:@"null"]) {
            self.linkText.text = self.item.containerWebUrl;
        }else{
            self.link.hidden = YES;
        }
    }else{
        if(![self.item.webUrl containsString:@"http"]){
            self.item.webUrl  =  [NSString stringWithFormat:@"https://%@", self.item.webUrl];
        }
        
        NSURL *url = [NSURL URLWithString:self.item.webUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url] && ![self.item.webUrl containsString:@"null"]) {
            self.linkText.text = self.item.webUrl;
        }else{
            self.link.hidden = YES;
        }
    }
    
    [self.openBtn setTitle:NSLocalizedString(@"applet_v2_open", @"进入应用") forState:UIControlStateNormal];
    
   // self.selectedText.text = NSLocalizedString(@"application_guideclose", @"关闭后不再提示");
  
}

-(void)installFail{
    self.failLabelPointOut.hidden = NO;
    self.failLabel.hidden = NO;
    self.installFailImageView.hidden = NO;
    self.titleText.hidden = YES;
    self.link.hidden = YES;
    self.linkText.hidden = YES;
    self.linkText.hidden = YES;
    self.selectedBtn.hidden = YES;
    self.openBtn.hidden = YES;
    //self.selectedText.hidden = YES;
    
    self.loadingImageView.hidden = YES;
    self.loadingText.hidden = YES;

    
    [self.installFailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name.mas_bottom).offset(40);
        make.centerX.mas_equalTo(self.view);
        make.width.height.mas_equalTo(30);
    }];
    
    
    [self.failLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.installFailImageView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
        
    }];
    [self.failLabelPointOut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.failLabel.mas_bottom).offset(4);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.uninstallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_bottom).offset(-150);
    }];
    
    [self.uninstallBtn setTitle:NSLocalizedString(@"uninstall_applet_v2", @"卸载应用") forState:UIControlStateNormal];
    self.loadingImageView.hidden = YES;
    
}

- (ESGradientButton *)uninstallBtn {
    if (!_uninstallBtn) {
        _uninstallBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_uninstallBtn setCornerRadius:10];
        _uninstallBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_uninstallBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_uninstallBtn];
        _uninstallBtn.alpha = 1;
        [_uninstallBtn addTarget:self action:@selector(uninstallBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uninstallBtn;
}

-(void)uninstallBtn:(UIButton *)btn{
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_uninstall"
                                                queryParams:@{ @"appid" : self.item.appId
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
            [ESToast dismiss];
            [ESToast toastSuccess:NSLocalizedString(@"applet_uninstall_success", @"卸载成功")];
            NSDictionary *dicApp = [[ESCache defaultCache] objectForKey:@"v2_app_sel_status"];
            NSMutableDictionary *dicMutable = [NSMutableDictionary dictionaryWithDictionary:dicApp];
            NSString *key = [ESCommonToolManager miniAppKey:self.item.appId];
            [dicMutable setObject:@"NO" forKey:key];
            [[ESCache defaultCache] setObject:dicMutable forKey:@"v2_app_sel_status"];
            [self.navigationController popViewControllerAnimated:YES];
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         //   __strong typeof(weakSelf) self = weakSelf;
             [ESToast dismiss];
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }];
}
@end
