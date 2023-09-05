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
//  ESSwitchoverEnvironmentPointVC.m
//  EulixSpace
//
//  Created by qu on 2022/11/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSwitchoverEnvironmentPointVC.h"
#import "ESGradientButton.h"
#import "ESCommentCachePlistData.h"
#import "ESToast.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "ESAuthenticationTypeController.h"
#import "ESInfoEditViewController.h"
#import "ESPlatformClient.h"
#import "ESBoxManager.h"
#import "SVProgressHUD.h"
#import "ESSetting8ackd00rItem.h"
#import "ESLocalPath.h"
#import "ESGatewayClient.h"
#import "ESApiClient.h"
#import "ESPlatformServiceStatusApi.h"
#import "ESPlatformClient.h"
#import "ESCommonToolManager.h"

@interface ESSwitchoverEnvironmentPointVC ()<ESBoxBindViewModelDelegate>

@property(nonatomic,strong) UIImageView *iconEnvironment;

@property(nonatomic,strong) UILabel *environmentTitle;

@property(nonatomic,strong) UIImageView *addressIcon;

@property(nonatomic,strong) UILabel *addressTitle;

@property(nonatomic,strong) UILabel *destTitle;

@property(nonatomic,strong) UILabel *destTitleText;

@property(nonatomic,strong) UILabel *destChange;

@property(nonatomic,strong) UILabel *destChangeText;

@property(nonatomic,strong) UILabel *destChangeText2;

@property(nonatomic,strong) UILabel *note;

@property(nonatomic,strong) UILabel *noteText;

@property(nonatomic,strong) UIButton *copyBtn;

@property (nonatomic, strong) ESGradientButton *retryButton;

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, assign)  BOOL isOfficial;


@end

@implementation ESSwitchoverEnvironmentPointVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Switch_Space_Platform_Environment", @"切换空间平台环境");
    
//    NSString *str =[[NSUserDefaults standardUserDefaults] objectForKey:@"official"];
//    if([str isEqual:@"YES"]){
//        self.isOfficial = YES;
//    }else{
//        self.isOfficial = NO;
//    }
    self.viewModel.delegate = self;
    //S[self initUI];
}

-(void)initUI{
    
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0.0f);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.height.mas_equalTo(ScreenHeight);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    [self.iconEnvironment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainScrollView.mas_top).offset(30.0f);
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26);
        make.height.mas_equalTo(16.0f);
        make.width.mas_equalTo(16.0f);
    }];

    [self.environmentTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainScrollView.mas_top).offset(30.0f);
        make.left.mas_equalTo(self.iconEnvironment.mas_right).offset(10);
        make.width.mas_equalTo(300.0f);
        make.height.mas_equalTo(22.0f);

    }];
    [self.addressIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconEnvironment.mas_bottom).offset(20.0f);
        make.left.mas_equalTo(self.mainScrollView).offset(26);
        make.height.mas_equalTo(16.0f);
        make.width.mas_equalTo(16.0f);
    }];

    [self.addressTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.addressIcon.mas_centerY);
        make.left.mas_equalTo(self.iconEnvironment.mas_right).offset(10);
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ESColor.separatorColor;
    [self.mainScrollView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-24.0);
        make.bottom.mas_equalTo(self.addressTitle.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view.mas_left).offset(24.0);
        make.height.equalTo(@(1.0f));
    }];

    UIView *iconView = [UIView new];
    iconView.backgroundColor = ESColor.primaryColor;
    [self.mainScrollView addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
        make.top.mas_equalTo(lineView.mas_bottom).offset(24);
        make.height.equalTo(@(12.0f));
        make.width.equalTo(@(4.0f));
    }];

    [self.destTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(38.0);
        make.top.mas_equalTo(lineView.mas_bottom).offset(19);
        make.height.equalTo(@(22.0f));
    }];

    [self.destTitleText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(51);
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
    }];

    UIView *iconView2 = [UIView new];
    iconView2.backgroundColor = ESColor.primaryColor;
    [self.mainScrollView addSubview:iconView2];
    [iconView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
        make.top.mas_equalTo(self.destTitleText.mas_bottom).offset(15);
        make.height.equalTo(@(12.0f));
        make.width.equalTo(@(4.0f));
    }];

    [self.destChange mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(38.0);
        make.top.mas_equalTo(self.destTitleText.mas_bottom).offset(10);
        make.height.equalTo(@(22.0f));
    }];

    [self.destChangeText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.destChange.mas_bottom).offset(10);
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
    }];

    [self.copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
        make.top.mas_equalTo(self.destChangeText.mas_bottom).offset(5);
        make.height.equalTo(@(22.0f));
    }];

    [self.destChangeText2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.copyBtn.mas_bottom).offset(5);
        make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
    }];

    if(self.isOfficial){
        UIView *iconView3 = [UIView new];
        iconView3.backgroundColor = ESColor.primaryColor;
        [self.mainScrollView addSubview:iconView3];
        [iconView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
            make.top.mas_equalTo(self.destChangeText2.mas_bottom).offset(15);
            make.height.equalTo(@(12.0f));
            make.width.equalTo(@(4.0f));
        }];

        [self.note mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mainScrollView.mas_left).offset(38.0);
            make.centerY.mas_equalTo(iconView3.mas_centerY);
            make.height.equalTo(@(22.0f));
        }];

        [self.noteText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.note.mas_bottom).offset(5);
            make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
            make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        }];
    }else{
        UIView *iconView3 = [UIView new];
        iconView3.backgroundColor = ESColor.primaryColor;
        [self.mainScrollView addSubview:iconView3];
        [iconView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
            make.top.mas_equalTo(self.destChangeText.mas_bottom).offset(15);
            make.height.equalTo(@(12.0f));
            make.width.equalTo(@(4.0f));
        }];

        [self.note mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mainScrollView.mas_left).offset(38.0);
            make.centerY.mas_equalTo(iconView3.mas_centerY);
            make.height.equalTo(@(22.0f));
        }];

        [self.noteText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.note.mas_bottom).offset(5);
            make.left.mas_equalTo(self.mainScrollView.mas_left).offset(26.0);
            make.right.mas_equalTo(self.view.mas_right).offset(-26.0);
        }];
    }

    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
        make.centerX.mas_equalTo(self.view);
    }];
    
    if(self.isOfficial){
        [self.mainScrollView setUserInteractionEnabled:YES];
    }else{
        [self.mainScrollView setUserInteractionEnabled:YES];
    }


    
    if ([ESCommonToolManager isEnglish]) {
        if(self.isOfficial){
            [self.mainScrollView setUserInteractionEnabled:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               self.mainScrollView.contentSize = CGSizeMake(ScreenWidth,ScreenHeight + 250);
            });
        }else{
            [self.mainScrollView setUserInteractionEnabled:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               self.mainScrollView.contentSize = CGSizeMake(ScreenWidth,ScreenHeight + 200);
            });
        }
 
    }else{
        if(self.isOfficial){
            [self.mainScrollView setUserInteractionEnabled:YES];
        }else{
            [self.mainScrollView setUserInteractionEnabled:NO];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           self.mainScrollView.contentSize = CGSizeMake(ScreenWidth,ScreenHeight + 150);
        });
    }
}

- (ESGradientButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_retryButton setCornerRadius:10];
        if(self.isOfficial){
            [_retryButton setTitle:NSLocalizedString(@"private_space_platform_address", @"私有空间平台地址") forState:UIControlStateNormal];
        }else{
            [_retryButton setTitle:NSLocalizedString(@"switch_official_space_platform", @"切换到官方空间平台") forState:UIControlStateNormal];
        }
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_retryButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_retryButton];
    }
    return _retryButton;
}
- (UIImageView *)iconEnvironment {
    if (!_iconEnvironment) {
        _iconEnvironment = [[UIImageView alloc] init];
        [self.mainScrollView addSubview:_iconEnvironment];
        _iconEnvironment.image = [UIImage imageNamed:@"environment_point_env"];
    }
    return _iconEnvironment;
}

- (UIImageView *)addressIcon {
    if (!_addressIcon) {
        _addressIcon = [[UIImageView alloc] init];
        [self.mainScrollView addSubview:_addressIcon];
        _addressIcon.image = [UIImage imageNamed:@"environment_point_address"];
    }
    return _addressIcon;
}

- (UILabel *)environmentTitle {
    if (!_environmentTitle) {
        _environmentTitle = [[UILabel alloc] init];
        if(self.isOfficial){
            _environmentTitle.text = NSLocalizedString(@"Current Environment:AO.space Official Space Platform", @"当前环境：傲空间官方空间平台");
          
        }else{
           // _environmentTitle.text = @"当前环境：私有空间平台";
            _environmentTitle.text = NSLocalizedString(@"Current Environment:Private Space Platform", @"当前环境：私有空间平台");
        }
        _environmentTitle.textColor = ESColor.labelColor;
        _environmentTitle.textAlignment = NSTextAlignmentLeft;
        _environmentTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.mainScrollView addSubview:_environmentTitle];
    }
    return _environmentTitle;
}

- (UILabel *)addressTitle {
    if (!_addressTitle) {
        _addressTitle = [[UILabel alloc] init];
        if(self.isOfficial){
            _addressTitle.text = [NSString stringWithFormat:NSLocalizedString(@"server_url_is", @"服务器地址："),ESPlatformClient.platformClient.baseURL.absoluteString];
        }else{
            _addressTitle.text = [NSString stringWithFormat:NSLocalizedString(@"server_url_is", @"服务器地址："),ESPlatformClient.platformClient.baseURL.absoluteString];
        }
        _addressTitle.textColor = ESColor.labelColor;
        _addressTitle.textAlignment = NSTextAlignmentLeft;
        _addressTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.mainScrollView addSubview:_addressTitle];
    }
    return _addressTitle;
}

- (UILabel *)destTitle {
    if (!_destTitle) {
        _destTitle = [[UILabel alloc] init];
        if(self.isOfficial){
            
            _destTitle.text =  NSLocalizedString(@"Advantages of private space platform", @"私有空间平台的优势");
        }else{
            _destTitle.text =  NSLocalizedString(@"Advantages of private space platform", @"傲空间官方空间平台的优势");
        }

        _destTitle.textColor = ESColor.labelColor;
        _destTitle.textAlignment = NSTextAlignmentLeft;
        _destTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.mainScrollView addSubview:_destTitle];
    }
    return _destTitle;
}

- (UILabel *)destTitleText {
    if (!_destTitleText) {
        _destTitleText = [[UILabel alloc] init];
        if(self.isOfficial){
            _destTitleText.text = NSLocalizedString(@"Public cloud, private cloud", @"私有空间平台的优势详细");;
        }else{
            _destTitleText.text = NSLocalizedString(@"switch_private_space_platform_what_benefit_content", @"1.更灵活：公有云、私有云、混合云、本地服务器等多种部署方式。switch_official_space_platform_what_benefit_content");
            
        }
        _destTitleText.textColor = ESColor.labelColor;
        _destTitleText.numberOfLines = 0;
        _destTitleText.textAlignment = NSTextAlignmentLeft;
        _destTitleText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.mainScrollView addSubview:_destTitleText];
    }
    return _destTitleText;
}

- (UILabel *)destChange{
    if (!_destChange) {
        _destChange = [[UILabel alloc] init];
        if(self.isOfficial){
            _destChange.text =  NSLocalizedString(@"How to switch to a private platform", @"如何切换到私有平台");
        }else{
            _destChange.text = NSLocalizedString(@"switch_official_space_platform_how", @"如何切换到傲空间官方空间平台");
        }
    
        _destChange.textColor = ESColor.labelColor;
        _destChange.textAlignment = NSTextAlignmentLeft;
        _destChange.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.mainScrollView addSubview:_destChange];
    }
    return _destChange;
}

- (UILabel *)destChangeText {
    if (!_destChangeText) {
        _destChangeText = [[UILabel alloc] init];
        if(self.isOfficial){
        
            BOOL result = [ESPlatformClient.platformClient.baseURL.absoluteString hasSuffix:@"/"];
            if(result){
                if ([ESCommonToolManager isEnglish]) {
                    _destChangeText.text = [NSString stringWithFormat:@"1. Download the private space platform package and install and deploy it according to the operation manual。\nDownload address: ：%@download/platform",ESPlatformClient.platformClient.baseURL.absoluteString];
                }else{
                    _destChangeText.text = [NSString stringWithFormat:@"1.下载私有空间平台软件包并按照操作手册进行安装部署。\n下载地址：%@download/platform",ESPlatformClient.platformClient.baseURL.absoluteString];
                }
            
            }else{
                if ([ESCommonToolManager isEnglish]) {
                    _destChangeText.text = [NSString stringWithFormat:@"1. Download the private space platform package and install and deploy it according to the operation manual。\nDownload address: ：%@download/platform",ESPlatformClient.platformClient.baseURL.absoluteString];
                }else{
                    _destChangeText.text = [NSString stringWithFormat:@"1.下载私有空间平台软件包并按照操作手册进行安装部署。\n下载地址：%@download/platform",ESPlatformClient.platformClient.baseURL.absoluteString];
                }
          
            }
  
          //  @"1.下载私有空间平台软件包并按照操作手册进行安装部署。\n下载地址：https://ao.space/download/platform";
        }else{
            _destChangeText.text = NSLocalizedString(@"switch_official_space_platform_how_content", @"1.点击【切换到官方空间平台】按钮，等待约10秒钟，收到切换成功提醒即代表切换成功。\n2. 切换环境傲空间设备的数据不会丢失，可以支持多个环境来回切换，请放心使用。");
        }
        _destChangeText.textColor = ESColor.labelColor;
        _destChangeText.numberOfLines = 0;
        _destChangeText.textAlignment = NSTextAlignmentLeft;
        _destChangeText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.mainScrollView addSubview:_destChangeText];
    }
    return _destChangeText;
}


- (UIButton *)copyBtn {
    if (nil == _copyBtn) {
        _copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_copyBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [_copyBtn addTarget:self action:@selector(didClickCopyBtn) forControlEvents:UIControlEventTouchUpInside];
        [_copyBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_copyBtn setTitle:NSLocalizedString(@"click_copy", @"点击复制") forState:UIControlStateNormal];
        UIView *line = [[UIView alloc] init];
        [_copyBtn addSubview:line];
        [self.mainScrollView addSubview:_copyBtn];
        if(self.isOfficial){
            _copyBtn.hidden = NO;
        }else{
            _copyBtn.hidden = YES;
        }
    }
    return _copyBtn;
}

-(void)didClickCopyBtn{
    [ESToast toastSuccess:NSLocalizedString(@"me_webpage_copy", @"已复制到剪切板，请使用浏览器打开")];
    BOOL result = [ESPlatformClient.platformClient.baseURL.absoluteString hasSuffix:@"/"];
              if(result){
                  UIPasteboard.generalPasteboard.string = [NSString stringWithFormat:@"%@download/platform",ESPlatformClient.platformClient.baseURL.absoluteString];
              }else{
                  UIPasteboard.generalPasteboard.string = [NSString stringWithFormat:@"%@/download/platform",ESPlatformClient.platformClient.baseURL.absoluteString];
              }
  
    //UIPasteboard.generalPasteboard.string = @"https://ao.space/download/platform";
}

- (UILabel *)destChangeText2 {
    if (!_destChangeText2) {
        _destChangeText2 = [[UILabel alloc] init];
        _destChangeText2.text =NSLocalizedString(@"Click the Switch to privat",  @"2. 点击【切换到私有空间平台】按钮，输入私有空间平台的域名，且该平台上已安装好软件服务包，点击【确认】按钮。\n3. 切换到私有空间平台后设备上所有的用户数据不会丢失，首次切换到私有平台需向私有平台注册并验证平台的合法性，可支持多个平台间切换，请放心使用。");
        _destChangeText2.textColor = ESColor.labelColor;
        _destChangeText2.numberOfLines = 0;
        _destChangeText2.textAlignment = NSTextAlignmentLeft;
        _destChangeText2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.mainScrollView addSubview:_destChangeText2];
        if(self.isOfficial){
            _destChangeText2.hidden = NO;
        }else{
            _destChangeText2.hidden = YES;
        }
    }
    return _destChangeText2;
}

- (UILabel *)note {
    if (!_note) {
        _note = [[UILabel alloc] init];
        if(self.isOfficial){
            _note.text = NSLocalizedString(@"other_precautions", @"其他注意事项");
        }else{
            _note.text = NSLocalizedString(@"other_precautions", @"其他注意事项");
        }
        _note.textColor = ESColor.labelColor;
        _note.numberOfLines = 0;
        _note.textAlignment = NSTextAlignmentLeft;
        _note.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        //_note.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.mainScrollView addSubview:_note];
    }
    return _note;
}

- (UILabel *)noteText {
    if (!_noteText) {
        _noteText = [[UILabel alloc] init];
        if(self.isOfficial){
            _noteText.text = NSLocalizedString(@"other_precautions_private_space_platform_content", @"1.切换到私有空间平台后，设备上所有成员均会切换到私有空间平台。other_precautions_official_space_platform_content");
        }else{
            _noteText.text = NSLocalizedString(@"other_precautions_private_space_platform_content", @"1.切换到私有空间平台后，设备上所有成员均会切换到私有空间平台。other_precautions_official_space_platform_content");
        }
        //_noteText.text = @"1. 切换到私有空间平台后，设备上所有成员均会切换到私有空间平台。\n2. 设备上成员在重定向有效期180天内会自动连接到新的空间平台，超过有效期无法重定向需让管理员重新邀请再使用。\n3. 用户原先分享出去的链接可以继续访问。\n4. 用户安装的傲空间应用旧空间平台对外的授权将失效，需使用新的空间平台重新对外授权。";
        _noteText.textColor = ESColor.labelColor;
        _noteText.numberOfLines = 0;
        _noteText.textAlignment = NSTextAlignmentLeft;
        _noteText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.mainScrollView addSubview:_noteText];
    }
    return _noteText;
}

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.showsVerticalScrollIndicator = FALSE;
        _mainScrollView.showsHorizontalScrollIndicator = FALSE;
        [self.view addSubview:_mainScrollView];
    }
    return _mainScrollView;
}

- (UIView *)cellViewWithTitleStr:(NSString *)titleStr valueText:(NSString *)valueText {
    UIView *cellView = [[UIView alloc] init];
    UIView *icon = [[UIView alloc] init];
    icon.backgroundColor = ESColor.pushTitleColor;
    [cellView addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cellView.mas_top).offset(24);
        make.left.mas_equalTo(cellView.mas_left).offset(26);
        make.height.mas_equalTo(4.0f);
        make.width.mas_equalTo(12.0f);
    }];
    
    UILabel *title = [[UILabel alloc]init];
    title.text = titleStr;
    title.textColor = ESColor.labelColor;
    title.textAlignment = NSTextAlignmentLeft;
    title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    [cellView addSubview:title];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cellView.mas_top).offset(24);
        make.left.mas_equalTo(cellView.mas_left).offset(38);
        make.height.mas_equalTo(22.0f);
    }];
    
    UILabel *point = [[UILabel alloc]init];
    point.text = titleStr;
    point.textColor = ESColor.labelColor;
    point.textAlignment = NSTextAlignmentLeft;
    point.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    [cellView addSubview:point];
    
    [point mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cellView.mas_top).offset(51);
        make.left.mas_equalTo(cellView.mas_left).offset(26);
        make.right.mas_equalTo(cellView.mas_right).offset(-25);
    }];
    
    return cellView;
}

- (void)action {
   
    __weak typeof (self) weakSelf = self;
    if([self.retryButton.titleLabel.text isEqual:NSLocalizedString(@"private_space_platform_address", @"私有空间平台地址")]){
        ESInfoEditViewController *vc =[ESInfoEditViewController new];
        vc.isAuthority =self.isOfficial;
        vc.type = ESInfoEditTypeV2Domin;
        vc.updateName = ^(NSString *name) {
            __strong typeof(weakSelf) self = weakSelf;
            NSString *urlStrEncode = name.URLEncode;
            NSURL *url = [NSURL URLWithString:urlStrEncode];
            NSString *domain = url.host;
            [self installDomin:domain];
        };
        //dev.eulix.xyz
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        ESSetting8ackd00rItem *item = [ESSetting8ackd00rItem current];
        if (item.envType == ESSettingEnvTypeDevEnv) {
            [self installDomin:@"dev.eulix.xyz"];
        } else if(item.envType == ESSettingEnvTypeSitEnv){
            [self installDomin:@"sit.eulix.xyz"];
        } else if(item.envType == ESSettingEnvTypeRCTOPEnv){
            [self installDomin:@"eulix.top"];
        } else if(item.envType == ESSettingEnvTypeRCXYZEnv){
            [self installDomin:@"eulix.xyz"];
        }else if(item.envType == ESSettingEnvTypeQAEnv){
            [self installDomin:@"qa.eulix.xyz"];
        }
        else{
            [self installDomin:@"ao.space"];
        }
    }
}

-(void)installDomin:(NSString *)str{
    if(self.viewModel){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"switch_space_platform_hint", @"空间平台切换中预计等待10秒钟")];
        [self.viewModel sendV2Domin:str];
    }
}

-(void)viewModelUpdateDomin:(NSDictionary *)rspDict{
    [SVProgressHUD dismiss];
    if(rspDict && rspDict.count > 0){
        if([rspDict[@"code"] isEqual:@"AG-200"]){
            NSDictionary *dic =rspDict[@"results"];
          
            ESApiClient *apiClient = [ESApiClient es_box:ESBoxManager.activeBox];
            apiClient.timeoutInterval = 30;
            ESPlatformServiceStatusApi *api = [[ESPlatformServiceStatusApi alloc] initWithApiClient:apiClient];
            [api setDefaultHeaderValue:@"no-cache" forKey:@"Cache-Control"];
            [self getSuccessView:dic[@"userDomain"]];
       
            [[NSNotificationCenter defaultCenter] postNotificationName:@"esSwitchPlatformUrlSuccessNoti" object:nil];
        }else{
            NSString *code =rspDict[@"code"];
            if([code isEqual:@"AG-402"]){
                [ESToast toastError:NSLocalizedString(@"switch_space_platform_resource_busy_error_content", @"切换失败，新域名不可与当前域名一样")];
            }else if([code isEqual:@"AG-581"]){
                [ESToast toastError:NSLocalizedString(@"switch_space_platform_connect_error_content", @"输入的空间平台域名暂时无法建立连接，请确认域名是否正确")];
            }else{
                NSString *str = [NSString stringWithFormat:NSLocalizedString(@"switch_fail_hint_part_1", @"切换失败（错误码 %@"),code];
                [ESToast toastError:str];
            }
        }
    }
}
// 社区
- (void)getSuccessView:(NSString *)domin {
    NSString *str = [NSString stringWithFormat:NSLocalizedString(@"switch_private_space_platform_hint", @"已成功切换到新的空间平台"),domin];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SwitchSuccess", @"切换成功") message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"确定")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
        ESBoxManager.activeBox.info.userDomain = domin;
        
        [ESBoxManager.manager onActive:ESBoxManager.activeBox];
        [self.navigationController popToRootViewControllerAnimated:YES];
       
        [ESBoxManager.manager loadCurrentBoxOnlineState:^(BOOL offline) {
            if(!offline){
                [self getAbility];
            }
        }];
        
    }];
    //3.将动作按钮 添加到控制器中
    [alert addAction:conform];
    //4.显示弹框
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //1.确定请求路径getAbility
    ESApiClient *apiClient = [ESApiClient es_box:ESBoxManager.activeBox];
    apiClient.timeoutInterval = 30;
    ESPlatformServiceStatusApi *api = [[ESPlatformServiceStatusApi alloc] initWithApiClient:apiClient];
    [api setDefaultHeaderValue:@"no-cache" forKey:@"Cache-Control"];
    [api spaceStatusGetWithCompletionHandler:^(ESStatusResult *output, NSError *error) {
           if(output.platformInfo.count > 0){
               NSNumber *isBool = output.platformInfo[@"official"];
               if(isBool.boolValue){
                   NSString *str = output.platformInfo[@"platformUrl"];
                   if(str.length > 0){
                       [ESPlatformClient setHost:output.platformInfo[@"platformUrl"]];
                       self.addressTitle.text = output.platformInfo[@"platformUrl"];
                   }
                   [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"official"];
                   self.isOfficial = YES;
               }else{
                   NSString *str = output.platformInfo[@"platformUrl"];
                   if(str.length > 0){
                       [ESPlatformClient setHost:output.platformInfo[@"platformUrl"]];
                       self.addressTitle.text = output.platformInfo[@"platformUrl"];
                   }
                   [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"official"];
                   self.isOfficial = NO;
               }
           }else{
               [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"official"];
               self.isOfficial = YES;
           }
           }];
}


-(void)setIsOfficial:(BOOL)isOfficial{
    _isOfficial = isOfficial;
    [self initUI];
}

-(void)getAbility{
    NSMutableDictionary *dic =  [NSMutableDictionary new];

    NSString *str =[[NSUserDefaults standardUserDefaults] objectForKey:@"platformUrl"];
    NSString *urlStr = [NSString stringWithFormat:@"%@/v2/platform/ability",str];
    [ESNetworkRequestManager sendRequest:urlStr path:@"" method:@"GET" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        ESDLog(@"space/status error : [%@]",response);
        NSDictionary *apis= response;
        NSArray *array = apis[@"platformApis"];
        for (NSDictionary *dic1 in array) {
            [dic setValue:@"1" forKey:dic1[@"uri"]];
        }
        [[ESCommentCachePlistData manager] plistWriteDate:dic plistName:@"platformApis_list"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"platformApisListNotification" object:@(1)];
        
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"space/status error : [%@]",response);
    }];
}

@end
