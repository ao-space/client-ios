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
//  ESChangeVC.m
//  EulixSpace
//
//  Created by qu on 2023/2/15.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESChangeVC.h"
#import "ESGradientButton.h"
#import "SVProgressHUD.h"
#import "ESToast.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESSetting8ackd00rItem.h"
#import "UIColor+ESHEXTransform.h"

@interface ESChangeVC()<ESBoxBindViewModelDelegate>

@property (nonatomic, strong) UILabel *title1;

@property (nonatomic, strong) UILabel *title2;

@property (nonatomic, strong) ESGradientButton *retryButton;

@property (nonatomic, strong) UIButton *returnBtn;

@property (nonatomic, strong) UIImageView * headImageView;

@end

@implementation ESChangeVC


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        for (UIGestureRecognizer *popGesture in self.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers)    {
            popGesture.enabled = NO;
        }
    }
    [self.navigationItem setHidesBackButton:YES];
}
 
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        for (UIGestureRecognizer *popGesture in self.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = YES;
        }
    }
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initLayout];
    self.viewModel.delegate = self;
    
    self.title2.text = [NSString stringWithFormat:@"%@空间平台不可用", self.dic[@"sspUrl"]];

}

-(void)initLayout{
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(120.0+44);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(88.0f);
        make.width.mas_equalTo(90.0f);
    }];
    
    [self.title1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headImageView.mas_bottom).offset(40.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(25.0f);
        make.width.mas_equalTo(200.0f);
    }];
    
    [self.title2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title1.mas_bottom).offset(10.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
//        make.height.mas_equalTo(25.0f);
//        make.width.mas_equalTo(200.0f);
    }];
    
    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_bottom).offset(-140.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(200.0f);
    }];
    
    [self.returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.retryButton.mas_bottom).offset(20.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(200.0f);
    }];
    
}

- (ESGradientButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_retryButton setCornerRadius:10];
    
        [_retryButton setTitle:@"切换到官方平台绑定" forState:UIControlStateNormal];
  
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_retryButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_retryButton];
    }
    return _retryButton;
}

- (UIButton *)returnBtn {
    if (nil == _returnBtn) {
        _returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];

        [_returnBtn addTarget:self action:@selector(didClickReturnBtn) forControlEvents:UIControlEventTouchUpInside];
        [_returnBtn setTitleColor: [UIColor es_colorWithHexString:@"#85899C"] forState:UIControlStateNormal];
        [_returnBtn setTitle:NSLocalizedString(@"common_back", @"返回") forState:UIControlStateNormal];
        [self.view addSubview:_returnBtn];
    }
    return _returnBtn;
}



-(void)didClickReturnBtn{
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        [self.view addSubview:_headImageView];
        _headImageView.image = [UIImage imageNamed:@"change_shibai"];
    }
    return _headImageView;
}

-(void)action{
    ESSetting8ackd00rItem *item = [ESSetting8ackd00rItem current];
    if (item.envType == ESSettingEnvTypeDevEnv) {
        [self installDomin:@"dev.eulix.xyz"];
    } else if(item.envType == ESSettingEnvTypeSitEnv){
        [self installDomin:@"sit.eulix.xyz"];
    } else if(item.envType == ESSettingEnvTypeRCTOPEnv){
        [self installDomin:@"eulix.top"];
    } else if(item.envType == ESSettingEnvTypeRCXYZEnv){
        [self installDomin:@"eulix.xyz"];
    } else{
        [self installDomin:@"ao.space"];
    }
}


-(void)installDomin:(NSString *)str{
    if(self.viewModel){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"空间平台切换中 \n预计等待10秒钟"];
        [self.viewModel sendV2Domin:str];
    }
}


-(void)viewModelUpdateDomin:(NSDictionary *)rspDict{
    [SVProgressHUD dismiss];
    if(rspDict && rspDict.count > 0){
        if([rspDict[@"code"] isEqual:@"AG-200"]){
            NSDictionary *dic =rspDict[@"results"];
            [self getSuccessView:dic[@"userDomain"]];
        }else{
            NSString *code =rspDict[@"code"];
            if([code isEqual:@"AG-402"]){
                [ESToast toastError:@"切换失败，新域名不可与当前域名一样"];
            }else if([code isEqual:@"AG-581"]){
                [ESToast toastError:@"输入的空间平台域名暂时无法建立连接，请确认域名是否正确"];
            }else{
                NSString *str = [NSString stringWithFormat:@"切换失败（错误码%@）",code];
                [ESToast toastError:str];
            }
        }
    }
}

// 社区
- (void)getSuccessView:(NSString *)domin {
    NSString *str = [NSString stringWithFormat:@"已成功切换到新的空间平台\n%@",domin];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换成功" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"确定")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
        ESBoxManager.activeBox.info.userDomain = domin;
        [ESBoxManager.manager onActive:ESBoxManager.activeBox];
        [self.navigationController popToRootViewControllerAnimated:YES];
          
        }];
    //3.将动作按钮 添加到控制器中
    [alert addAction:conform];
    //4.显示弹框
    [self presentViewController:alert animated:YES completion:nil];
}

- (UILabel *)title1 {
    if (!_title1) {
        _title1 = [[UILabel alloc] init];
        _title1.text = @"设备绑定失败";
        _title1.textColor = ESColor.labelColor;
        _title1.textAlignment = NSTextAlignmentCenter;
        _title1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:19];
        [self.view addSubview:_title1];
    }
    return _title1;
}

- (UILabel *)title2 {
    if (!_title2) {
        _title2 = [[UILabel alloc] init];
        _title2.textColor = ESColor.secondaryLabelColor;
        _title2.textAlignment = NSTextAlignmentCenter;
        _title2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.view addSubview:_title2];
        _title2.text = [NSString stringWithFormat:@"空间平台不可用"];
    }
    return _title2;
}

-(void)goBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
