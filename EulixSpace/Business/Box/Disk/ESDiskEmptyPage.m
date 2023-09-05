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
//  ESDiskEmptyPage.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDiskEmptyPage.h"
#import "ESDiskInitStartPageModule.h"
#import "ESCommListHeaderView.h"
#import "ESDiskEmptyPageModule.h"
#import "ESGradientButton.h"
#import "ESToast.h"

@interface ESDiskEmptyPage ()

@property (nonatomic, strong) ESSpaceReadyCheckResultModel * spaceReadyCheckModel;
@property (nonatomic, strong) ESDiskImagesView * diskImageView;
@property (nonatomic, strong) UIButton * configBtn;
@property (nonatomic, strong) ESGradientButton * enterSpace;
@end

@implementation ESDiskEmptyPage

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBackBt = NO;
    self.viewModel.delegate = self;

    ESCommListHeaderView *headerView = [[ESCommListHeaderView alloc] initWithFrame:CGRectMake(0, 0, 400, 198)];
    headerView.iconImageView.image = [UIImage imageNamed:@"cp"];
    headerView.titleLabel.text = NSLocalizedString(@"disk_initialization", @"磁盘初始化");
    headerView.detailLabel.text = NSLocalizedString(@"binding_recommendeddiskSettings",  @"以下是磁盘的推荐设置，你可以使用这些设置来进行\n磁盘初始化，也可以逐个自定义设置");
    self.listModule.listView.tableHeaderView = headerView;
    
    [self setupViews];
}

- (Class)listModuleClass {
    return [ESDiskEmptyPageModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(0, 26, 40 + kBottomHeight, 26);
}

- (void)setupViews {
    [self.view addSubview:self.enterSpace];
    [_enterSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(60 + kBottomHeight);
    }];
}

- (void)onShutdown {
    NSString * title = NSLocalizedString(@"binding_shutdownprompt", @"关机提示");
    NSString * msg = NSLocalizedString(@"binding_shutdown", @"是否确认关闭傲空间服务器，并返回登\n录页？");

    [self showAlert:title
            message:msg
            optName:NSLocalizedString(@"cancel", @"取消")
             handle:nil
           optName1:NSLocalizedString(@"Shutdown", @"关机")
            handle1:^{
        [self.viewModel sendSystemShutdown];
        [ESToast toastInfo:NSLocalizedString(@"Req Sent", @"已发送请求")];
    }];
}

- (void)showAlert:(NSString *)title
          message:(NSString *)message
          optName:(NSString *)optName
           handle:(void (^ __nullable)(void))handler
          optName1:(NSString *)optName1
           handle1:(void (^ __nullable)(void))handler1 {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if (optName.length > 0) {
        UIAlertAction * action = [UIAlertAction actionWithTitle:optName
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
            if (handler) {
                handler();
            }
        }];
        [alert addAction:action];
    }
    if (optName1.length > 0) {
        UIAlertAction * action = [UIAlertAction actionWithTitle:optName1
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
            if (handler1) {
                handler1();
            }
        }];
        [alert addAction:action];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewModelSystemShutdown:(ESBaseResp *)response {
    
}

- (ESGradientButton *)enterSpace {
    if (!_enterSpace) {
        _enterSpace = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_enterSpace setCornerRadius:10];
        [_enterSpace setTitle:NSLocalizedString(@"Shutdown", @"关机") forState:UIControlStateNormal];
        _enterSpace.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_enterSpace setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_enterSpace setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [_enterSpace addTarget:self action:@selector(onShutdown) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterSpace;
}

- (ESDiskImagesView *)diskImageView {
    if (!_diskImageView) {
        ESDiskImagesView * view = [[ESDiskImagesView alloc] init];
        _diskImageView = view;
    }
    return _diskImageView;
}

@end
