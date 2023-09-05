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
//  ESSpaceInitialzationProcessVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceInitialzationProcessVC.h"
#import "ESBoxBindViewModel.h"
#import "ESSpaceInitialZationProcessModule.h"
#import <Lottie/LOTAnimationView.h>
#import "ESPicModel.h"
#import "ESCommonToolManager.h"
#import "ESADBannerView.h"
#import "UIButton+ESTouchArea.h"
#import "ESSpaceInfoEditeVC.h"
#import "ESSpaceInitializationFailView.h"
#import "ESBoxListViewController.h"
#import "ESToast.h"

@interface ESSpaceInitialzationProcessVC () <ESBoxBindViewModelDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *loadingRotateImage;
@property (nonatomic, strong) ESADBannerView *adView;
@property (nonatomic, strong) UIButton *closeAdBt;
@property (nonatomic, strong) ESSpaceInitializationFailView *failView;

@end

@implementation ESSpaceInitialzationProcessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    
    self.viewModel.delegate = self;
    self.showBackBt = NO;
    [self setupViews];
  
    [(ESSpaceInitialZationProcessModule *)self.listModule processedIndex:ESSpaceInitialZationProcess_unStart];
    
    [self sendSpaceStartReq];

    [self.closeAdBt setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self addBackgroudProcessBt];
}

- (void)sendSpaceStartReq {
    [self.viewModel sendSpaceStartInitialize];
}

- (void)setupViews {
    self.listModule.listView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    self.listModule.listView.layer.cornerRadius = 10.0f;
    self.listModule.listView.clipsToBounds = YES;
    self.listModule.listView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    [self.listModule.listView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kTopHeight + 100);
        make.left.mas_equalTo(self.view.mas_left).inset(25);
        make.right.mas_equalTo(self.view.mas_right).inset(25);
        make.height.mas_equalTo(270);
    }];
   
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kTopHeight + 29);
        make.left.mas_equalTo(self.view.mas_left).inset(25);
        make.right.mas_equalTo(self.view.mas_right).inset(140);
        make.height.mas_equalTo(25);
    }];
    
    [self.view addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(self.view.mas_left).inset(25);
        make.right.mas_equalTo(self.view.mas_right).inset(25);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.loadingRotateImage];
    [_loadingRotateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).inset(26);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.view addSubview:self.adView];
    [self.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view).inset(10);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(kBottomHeight + 40);
        make.height.mas_equalTo(70);
    }];
    
    [self.adView addSubview:self.closeAdBt];
    [self.closeAdBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.adView).inset(6);
        make.width.height.mas_equalTo(16);
    }];
}

- (void)addBackgroudProcessBt {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"box_background", @"后台执行")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(processBackgroud:)];
  
    [rightBarItem setTintColor:ESColor.primaryColor];
    rightBarItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)showFailView:(BOOL)show {
    if (show) {
        [self.view addSubview:self.failView];
        [self.failView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.mas_equalTo(self.view);
            make.height.mas_equalTo(600);
        }];
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    if (self.failView.superview) {
        [self.failView removeFromSuperview];
    }
    [self addBackgroudProcessBt];
    
}
- (void)processBackgroud:(id)sender {
    [self goback2BoxlistVC];
    ESPerformBlockOnMainThreadAfterDelay(1, ^{
        [ESToast toastInfo: NSLocalizedString(@"binding_systemerror", @"在登录页点击【绑定设\n备】，根据引导操作即可\n恢复此进度")];
    });
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.font = ESFontPingFangMedium(18);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = NSLocalizedString(@"binding_initializingspace1", @"正在初始化您的傲空间");
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.textColor = ESColor.grayLabelColor;
        _detailLabel.font = ESFontPingFangRegular(14);
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.text = NSLocalizedString(@"binding_initializingtip",@"请勿关机或切断电源");
    }
    return _detailLabel;
}

- (UIImageView *)loadingRotateImage {
    if (!_loadingRotateImage) {
        _loadingRotateImage = [UIImageView new];
        _loadingRotateImage.animationDuration = 1;
        _loadingRotateImage.image = [UIImage imageNamed:@"process_loading"];
    }
    return _loadingRotateImage;
}

- (ESADBannerView *)adView {
    if (!_adView) {
        _adView = [[ESADBannerView alloc] initWithFrame:CGRectZero];
        _adView.layer.cornerRadius = 8.0f;
        _adView.clipsToBounds = YES;
        [_adView bindData:[self addList]];
    }
    return _adView;
}

- (NSArray<NSString *> *)addList {
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        NSString *picName =  [NSString stringWithFormat:@"ad_%d%@", i, [ESCommonToolManager isEnglish] ? @"_en" : @""] ;
        [list addObject:picName];
    }
    return list;
}

- (UIButton *)closeAdBt {
    if (!_closeAdBt) {
        _closeAdBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeAdBt setImage:[UIImage imageNamed:@"async_hint_close"] forState:UIControlStateNormal];
        [_closeAdBt addTarget:self action:@selector(didClickAdCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeAdBt;
}

- (void)didClickAdCloseBtn:(id)sender {
    [self.adView removeFromSuperview];
    [self.closeAdBt removeFromSuperview];
}

- (void)startAnimation  {
   CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 1;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [self.loadingRotateImage.layer addAnimation:animation forKey:nil];
}

- (ESSpaceInitializationFailView *)failView {
    if (!_failView) {
        _failView = [[ESSpaceInitializationFailView alloc] initWithFrame:CGRectZero];
        weakfy(self)
        _failView.retryBlock = ^() {
            strongfy(self)
            [self showFailView:NO];
            [self sendSpaceStartReq];
        };
        _failView.gobackBlock = ^() {
            strongfy(self)
            [self goback2BoxlistVC];
        };
    }
    return _failView;
}

- (void)goback2BoxlistVC {
    __block UIViewController *vc;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ESBoxListViewController class]]) {
            vc = obj;
            *stop = YES;
        }
    }];
    if (vc != nil) {
        [self.navigationController popToViewController:vc animated:YES];
    }
}

- (void)stopAnimation {
    [self.loadingRotateImage.layer removeAllAnimations];
}

- (Class)listModuleClass {
    return [ESSpaceInitialZationProcessModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

//code=AG-200 成功; code=AG-460 已经绑定; code=AG-470 容器启动中; code=AG-471 容器已经启动;
- (void)onBindCommand:(ESBCCommandType)command resp:(id)response {
    if (command == ESBCCommandTypeBindComStartReq) {
        [self onSpaceStartInitialize:response];
        return;
    }
    
    if (command == ESBCCommandTypeBindComProgressReq) {
        [self onBindComProgress:response];
        return;
    }
}

//code=AG-200 成功; code=AG-460 已经绑定; code=AG-470 容器启动中; code=AG-471 容器已经启动;
- (void)onSpaceStartInitialize:(ESBaseResp *)response {
    if ([response.code isEqualToString:@"AG-200"]) {
        weakfy(self)
        ESPerformBlockOnMainThreadAfterDelay(3.5, ^{
            strongfy(self)
            [self.viewModel sendBindComProgress];
        });

        [self startAnimation];
        return;
    }
    
    if ([response.code isEqualToString:@"AG-460"]) {
       //失败
        [self showFailView:YES];
        return;
    }
    
    if ([response.code isEqualToString:@"AG-470"]) {
        [self.viewModel sendBindComProgress];
        [self startAnimation];
        return;
    }
    
    if ([response.code isEqualToString:@"AG-471"]) {
        ESSpaceInfoEditeVC *vc = [[ESSpaceInfoEditeVC alloc] init];
        vc.viewModel = self.viewModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [self showFailView:YES];
    
}

- (void)onBindComProgress:(NSDictionary *)response {
    if (![response.allKeys containsObject:@"results"] ||
        ![response[@"results"] isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSInteger progress = [response[@"results"][@"progress"] intValue];
    NSInteger comStatus = [response[@"results"][@"comStatus"] intValue];

//    ContainersUnStarted = -1
//    ContainersWaitOSReady = -2
//    ContainersStarting = 0
//    ContainersStarted = 1
//    ContainersStartedFail = 2
//    ContainersDownloading = 3
//    ContainersDownloaded = 4
//    ContainersDownloadedFail = 5
    
    if (comStatus == 2 || comStatus == 5) {
        [self showFailView:YES];
        return;
    }
    
    if ( progress >= 100) {
        ESSpaceInfoEditeVC *vc = [[ESSpaceInfoEditeVC alloc] init];
        vc.viewModel = self.viewModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    
    if ( progress < 100) {
        ESPerformBlockOnMainThreadAfterDelay(2, ^{
            [self.viewModel sendBindComProgress];
        });
    }
    weakfy(self)
    ESPerformBlockOnMainThread(^{
        strongfy(self)
        [(ESSpaceInitialZationProcessModule *)self.listModule processedIndex:[self progressMap:progress]];
    });
}

- (ESSpaceInitialZationProcess)progressMap:(NSInteger)progress {
    if (progress < 0) {
        return ESSpaceInitialZationProcess_unStart;
    }
    if (progress <= 25) {
        return ESSpaceInitialZationProcess_1;
    }
    
    if ( progress <= 50) {
        return ESSpaceInitialZationProcess_2;
    }
    
    if ( progress <= 75) {
        return ESSpaceInitialZationProcess_3;
    }
    
    if ( progress <= 100) {
        return ESSpaceInitialZationProcess_4;
    }
    
    return ESSpaceInitialZationProcess_unStart;
}
  
@end
