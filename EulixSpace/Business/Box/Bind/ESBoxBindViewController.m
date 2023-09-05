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
//  ESBoxBindViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/13.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxBindViewController.h"
#import "ESBoxBindBlePromptView.h"
#import "ESBoxBindInfoCell.h"
#import "ESBoxBindModeSelectView.h"
#import "ESBoxBindViewModel.h"
#import "ESBoxBindWiredConnectionPromptView.h"
#import "ESBoxManager.h"
#import "ESCarouselFlowLayout.h"
#import "ESGradientButton.h"
#import "ESQRCodeScanViewController.h"
#import "ESSecurityPasswordInputViewController.h"
#import "ESThemeDefine.h"
#import "ESBoxBindViewModel.h"
#import "ESToast.h"
#import <Masonry/Masonry.h>
#import "UIViewController+ESTool.h"
#import "ESPermissionController.h"
#import <AVFoundation/AVFoundation.h>
#import "ESBoxSearchingPromptView.h"
#import "ESBoxSearchingNotFoundView.h"
#import "ESSpaceInitializationCountryAndLanguageVC.h"
#import "ESSpaceInitialzationProcessVC.h"
#import "ESSpaceInfoEditeVC.h"
#import "ESDeviceStartupDiskEncryptionController.h"
#import "ESDiskInitStartPage.h"
#import "ESDiskEmptyPage.h"
#import "ESDiskInitSuccessPage.h"
#import "ESDiskInitProgressPage.h"
#import "UIView+Status.h"
#import "ESBindNotMatchHintView.h"

@interface ESBoxBindViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESBoxSearchingPromptView *searchingPrompt;
@property (nonatomic, strong) ESBoxSearchingNotFoundView *searchingNotFoundPrompt;

@property (nonatomic, strong) ESBoxBindViewModel *viewModel;

@property (nonatomic, strong) UICollectionView *carousel;
@property (nonatomic, strong) UIView *holder;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, copy) NSString *serviceUUID;

@property (nonatomic, strong) ESBoxBindModeSelectView *modeSelectView;
@property (nonatomic, assign) BOOL bleClosed;
@property (nonatomic, strong) ESBindNotMatchHintView * notMatchView;
@end

@implementation ESBoxBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = TEXT_BOX_BIND;
    if (!self.viewModel) {
        self.viewModel = [ESBoxBindViewModel viewModelWithDelegate:self];
        self.viewModel.mode = ESBoxBindModeBluetoothAndWiredConnection;
    }
    
    if (self.netServiceItem) {
        self.viewModel.mode = ESBoxBindModeWiredConnectionWithIp;
        self.viewModel.scanNetServiceInfo = self.netServiceItem;
    }
    [self initLayout];
    [self startBoxSearch];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.delegate = self;
}

- (void)startBoxSearch {
    [self.viewModel searchWithUniqueId:self.btid];
    [self reloadWithState:ESBoxBindStateScaning];
}


- (void)reloadWithState:(ESBoxBindState)state {
    if (state == ESBoxBindStateScaning) {
        self.searchingNotFoundPrompt.hidden = YES;
        self.searchingPrompt.hidden = NO;
        [self.searchingPrompt reloadWithState:ESBoxSearchingStateScaning];
    } else  {
        [self.searchingPrompt reloadWithState:ESBoxSearchingStateStop];
    }
    
    if (state == ESBoxBindStateNotFound) {
        self.searchingNotFoundPrompt.hidden = NO;
        self.searchingPrompt.hidden = YES;
    }
}

- (void)tryPairWithNetServiceInfo:(ESNetServiceItem *)serviceInfo {
    ESBoxBindViewController *next = [ESBoxBindViewController new];
    next.btid = self.btid;
    next.viewModel = [ESBoxBindViewModel viewModelWithDelegate:next];
    next.viewModel.mode = ESBoxBindModeWiredConnectionWithIp;
    next.viewModel.scanNetServiceInfo = serviceInfo;
    ESPerformBlockOnMainThreadAfterDelay(0.5, ^{
        [self.navigationController pushViewController:next animated:YES];
    });
}

- (void)hideBoxList {
    //self.dismissButton.hidden = YES;
    self.holder.hidden = YES;
}

#pragma mark - ESBoxBindViewModelDelegate

- (void)viewModelOnClose:(NSError *)error {
    if (!self.view.window) {
        self.bleClosed = YES;
        return;
    }
}

- (void)viewModelLocalNetServiceNotReachable:(NSError *)error {
    [self reloadWithState:ESBoxBindStateNotFound];
}

- (void)viewModelOnInit:(ESBoxStatusItem *)boxStatus {
    if ([ESBoxManager boxExist:self.viewModel.boxStatus.infoResult.boxUuid]) {
        [self.navigationController popViewControllerAnimated:YES];
        ESPerformBlockOnMainThreadAfterDelay(0.5, ^{
            [ESToast toastError:NSLocalizedString(@"binding_checkBluetooth", @"您已绑定此傲空间设备，\n请勿重复绑定")];
        });
        return;
    }
    if (self.viewModel.boxStatus.infoResult) {
        [self reloadWithState:ESBoxBindStateFound];
        [self showBoxList];
        return;
    }
    [self reloadWithState:ESBoxBindStateNotFound];
}

- (void)nextStep {
    ESDLog(@"[Bind] setup network");
    
    // 已绑定未换手机端
    //使用原手机端
    //设备已经初始化完成 ESPairStatusUnpaired || self.paired == ESPairStatusPairedWithoutAdmin
    if (self.viewModel.boxStatus.infoResult.oldBox) {
        if (!self.viewModel.boxStatus.infoResult.deviceAbility.innerDiskSupport) {
            [self hideBoxList];
            ESDLog(@"[ESBoxBindViewController] [nextStep] oldBox:%d innerDiskSupport:%d", self.viewModel.boxStatus.infoResult.oldBox, self.viewModel.boxStatus.infoResult.deviceAbility.innerDiskSupport);

            ESSecurityPasswordInputViewController *next = [ESSecurityPasswordInputViewController new];
            next.viewModel = self.viewModel;
            next.type = ESSecurityPasswordTypeUnbind;
            next.authType = ESAuthenticationTypeNewDeviceResetPassword;
            
            NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
            [vcs removeLastObject];
            [vcs addObject:next];
            [self.navigationController setViewControllers:vcs animated:YES];
            return;
        }
        
        [self.view showLoading:YES];
        [self.viewModel sendSpaceReadyCheck];
        return;
    }
    
    //查询初始化进度
    [self.view showLoading:YES];
    [self.viewModel sendBindComProgress];
}

- (void)onBindCommand:(ESBCCommandType)command resp:(NSDictionary *)response {
    if (command == ESBCCommandTypeBindComProgressReq) {
        [self.view showLoading:NO];
        if (![response.allKeys containsObject:@"results"] ||
            ![response[@"results"] isKindOfClass:[NSDictionary class]]) {
            return;
        }
        [self hideBoxList];

        NSInteger progress = [response[@"results"][@"progress"] intValue];
        if ( progress <= 0) {
            ESSpaceInitializationCountryAndLanguageVC *next = [ESSpaceInitializationCountryAndLanguageVC new];
            next.viewModel = self.viewModel;
            [self.navigationController pushViewController:next animated:YES];
            return;
        }
        
        if (progress < 100) {
            //有网络 继续流程
            ESSpaceInitialzationProcessVC *next = [ESSpaceInitialzationProcessVC new];
            next.viewModel = self.viewModel;
            [self.navigationController pushViewController:next animated:YES];
            return;
        }
        
        // >= 100
        ESSpaceInfoEditeVC *next = [ESSpaceInfoEditeVC new];
        next.viewModel = self.viewModel;
        [self.navigationController pushViewController:next animated:YES];
        return;
    }
}

- (void)viewModelOnSpaceCheckReady:(ESSpaceReadyCheckResp *)response {
    ESDLog(@"[ESBoxBindViewController] [viewModelOnSpaceCheckReady] response %@", [response yy_modelToJSONString]);

    if ([response isOK]) {
        ESSpaceReadyCheckResultModel * model = response.results;
        self.viewModel.diskInited = model.diskInitialCode == ESDiskInitStatusNormal;
        self.viewModel.diskInitialCode = model.diskInitialCode;
    } else {
        self.viewModel.diskInited = NO;
        self.viewModel.diskInitialCode = ESDiskInitStatusError;
    }
    //盒子已绑定， 新手机
    BOOL pairdNotCachedBox = ![ESBoxManager.manager pairingBoxCachedWithUUID:self.viewModel.boxStatus.infoResult.boxUuid];
    if (self.viewModel.diskInited || pairdNotCachedBox) {
        //已经初始化完成, 走安全密码验证 + 重绑定
        [self hideBoxList];
        [self.view showLoading:NO];

        ESSecurityPasswordInputViewController *next = [ESSecurityPasswordInputViewController new];
        next.viewModel = self.viewModel;
        next.type = ESSecurityPasswordTypeUnbind;
        next.authType = ESAuthenticationTypeNewDeviceResetPassword;
        
        NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
        [vcs removeLastObject];
        [vcs addObject:next];
        [self.navigationController setViewControllers:vcs animated:YES];
        return;
    }
    
    [self.viewModel sendDiskRecognition];
}

- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response {
    ESDLog(@"[ESBoxBindViewController] [viewModelDiskRecognition] response %@", [response yy_modelToJSONString]);

    [self.view showLoading:NO];
    if (![response isOK]) {
        NSString * text = NSLocalizedString(@"enter disk init failed", @"进入磁盘初始化流程失败");
        [ESToast toastError:text];
    }
        [self hideBoxList];
        
    if (self.viewModel.diskInitialCode == ESDiskInitStatusNormal) {
        //已经初始化完成, 走安全密码验证 + 重绑定
        ESSecurityPasswordInputViewController *next = [ESSecurityPasswordInputViewController new];
        next.viewModel = self.viewModel;
        next.type = ESSecurityPasswordTypeUnbind;
        next.authType = ESAuthenticationTypeNewDeviceResetPassword;
        NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
        [vcs removeLastObject];
        [vcs addObject:next];
        [self.navigationController setViewControllers:vcs animated:YES];
    } else if (self.viewModel.diskInitialCode == ESDiskInitStatusFormatting
               || self.viewModel.diskInitialCode == ESDiskInitStatusSynchronizingData) {
        ESDiskInitProgressPage * ctl = [[ESDiskInitProgressPage alloc] init];
        ctl.status = ESDeviceStartupStatusDiskIniting;
        ctl.viewModel = self.viewModel;
        ctl.diskListModel = response.results;
        [self.navigationController pushViewController:ctl animated:NO];
    } else {
        ESDiskListModel *diskModel = response.results;
        // 空磁盘
        if ([diskModel hasDisk:ESDiskStorage_Disk1] == NO &&
            [diskModel hasDisk:ESDiskStorage_Disk2] == NO &&
            [diskModel hasDisk:ESDiskStorage_SSD] == NO) {
            ESDiskEmptyPage * ctl = [[ESDiskEmptyPage alloc] init];
            ctl.viewModel = self.viewModel;
            ctl.diskListModel = response.results;
            [self.navigationController pushViewController:ctl animated:NO];
            return;
        }
        
        ESDiskInitStartPage * ctl = [[ESDiskInitStartPage alloc] init];
        ctl.viewModel = self.viewModel;
        ctl.diskListModel = response.results;
        [self.navigationController pushViewController:ctl animated:NO];
    }
}

#pragma mark - UI

- (void)initLayout {
    [self.searchingPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight);
    }];
    
    [self.searchingNotFoundPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight);
    }];
    
    self.searchingNotFoundPrompt.hidden = YES;
}

- (void)showBoxList {
    if (!self.viewModel.boxStatus.infoResult) {
        [self hideBoxList];
        return;
    }
    
    if (self.holder.superview) {
        return;
    }
    
    float height = 314;
    if (self.viewModel.boxStatus.infoResult.deviceAbility.openSource && !self.viewModel.boxStatus.infoResult.unpaired) {
        height = 364;
    }
    ESCarouselFlowLayout *layout = [[ESCarouselFlowLayout alloc] initWithType:(ESCarouselLayoutTypeCarousel)];
//    layout.itemSize = CGSizeMake(ScreenWidth - 25 * 2, self.viewModel.boxStatus.infoResult.unpaired ? 314 : 364);
    layout.itemSize = CGSizeMake(ScreenWidth - 25 * 2, height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.carousel.collectionViewLayout = layout;
    [_carousel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(self.viewModel.boxStatus.infoResult.unpaired ? 314 : 364);
        make.height.mas_equalTo(height);
    }];
    
    [self.carousel reloadData];
    self.holder.hidden = NO;
    self.backButton.hidden = NO;
    self.titleLabel.hidden = NO;
    self.holder.frame = self.view.window.bounds;
    [self.view.window addSubview:self.holder];
    [self.view.window bringSubviewToFront:self.holder];
    
    if (!self.viewModel.boxStatus.infoResult.deviceAbility.openSource) {
        [self.holder addSubview:self.notMatchView];
        [self.notMatchView setContent:NSLocalizedString(@"es_app_download_address_1", @"")];
        [self.notMatchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.holder).inset(20);
            make.top.mas_equalTo(self.carousel.mas_bottom).offset(20);
        }];
    }
}

- (void)dismiss {
    [self.holder removeFromSuperview];
    [self goBack];
}

//- (void)modeSelectViewAction:(ESBoxBindModeSelectType)type {
//    self.modeSelectView.hidden = YES;
//    [self.modeSelectView removeFromSuperview];
//    if (type == ESBoxBindModeSelectTypeRetryBle) {
//        [self startBluetoothSearch];
//        return;
//    }
//    if (type == ESBoxBindModeSelectTypeWiredConnection) {
//        ESBoxBindViewController *next = [ESBoxBindViewController new];
//        next.btid = self.btid;
//        next.viewModel = [ESBoxBindViewModel viewModelWithDelegate:self];
//        next.viewModel.mode = ESBoxBindModeWiredConnection;
//        [self.navigationController pushViewController:next animated:YES];
//        return;
//    }
//}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.viewModel.boxStatus.infoResult) {
        return 1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESBoxBindInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ESBoxBindInfoCell" forIndexPath:indexPath];
    weakfy(self);
    [cell reloadWithData:self.viewModel.boxStatus.infoResult];
    [cell reloadSN:self.sn];
    if (!self.viewModel.boxStatus.infoResult.deviceAbility.openSource) {
        [cell setCannotBind];
    }
    cell.actionBlock = ^(NSNumber *action) {
        strongfy(self);
        if (action.integerValue == ESBoxBindActionDismiss) {
            [self hideBoxList];
            return;
        }
        [self nextStep];
    };
    return cell;
}

#pragma mark - Lazy Load

- (ESBoxSearchingPromptView *)searchingPrompt {
    if (!_searchingPrompt) {
        _searchingPrompt = [ESBoxSearchingPromptView new];
        [self.view addSubview:_searchingPrompt];
    }
    return _searchingPrompt;
}

- (ESBoxSearchingNotFoundView *)searchingNotFoundPrompt {
    if (!_searchingNotFoundPrompt) {
        _searchingNotFoundPrompt = [ESBoxSearchingNotFoundView new];
        [self.view addSubview:_searchingNotFoundPrompt];
        weakfy(self)
        _searchingNotFoundPrompt.searchAginBlock = ^() {
            strongfy(self)
            self.searchingNotFoundPrompt.hidden = YES;
            [self startBoxSearch];
        };
    }
    return _searchingNotFoundPrompt;
}

- (UICollectionView *)carousel {
    if (!_carousel) {
        ESCarouselFlowLayout *layout = [[ESCarouselFlowLayout alloc] initWithType:(ESCarouselLayoutTypeCarousel)];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _carousel = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _carousel.showsHorizontalScrollIndicator = NO;
        _carousel.backgroundColor = ESColor.clearColor;
        _carousel.showsVerticalScrollIndicator = NO;
        _carousel.delegate = self;
        _carousel.dataSource = self;
        _carousel.scrollEnabled = NO;
        [_carousel registerClass:[ESBoxBindInfoCell class]
            forCellWithReuseIdentifier:@"ESBoxBindInfoCell"];
        [self.holder addSubview:_carousel];
        [_carousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.holder);
            make.top.mas_equalTo(self.holder).offset(110 + kStatusBarHeight);
            make.height.mas_equalTo(350);
        }];
    }
    
    return _carousel;
}

- (UIView *)holder {
    if (!_holder) {
        _holder = [[UIView alloc] initWithFrame:self.view.window.bounds];
        _holder.backgroundColor = [ESColor.systemBackgroundColor colorWithAlphaComponent:0.0];
        // blur
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualView.frame = self.view.window.bounds;
        [_holder addSubview:visualView];
//        [self.view.window addSubview:_holder];
    }
    return _holder;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [self.holder addSubview:_titleLabel];
        _titleLabel.text = NSLocalizedString(@"binding_selectdevice", @"请选择要绑定的设备：");

        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(200);
            make.left.mas_equalTo(self.holder).offset(26);
            make.bottom.mas_equalTo(self.carousel.mas_top).inset(20);
        }];
    }
    return _titleLabel;
    
}
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.holder addSubview:_backButton];
        [_backButton setImage:[UIImage imageNamed:@"back_1"] forState:UIControlStateNormal];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(18);
            make.left.mas_equalTo(self.holder).offset(26);
            make.bottom.mas_equalTo(self.carousel.mas_top).inset(74);
        }];
        [_backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)dealloc {
    [_holder removeFromSuperview];
    [_modeSelectView removeFromSuperview];
}

- (ESBindNotMatchHintView *)notMatchView {
    if (!_notMatchView) {
        ESBindNotMatchHintView * view = [[ESBindNotMatchHintView alloc] init];
        _notMatchView = view;
    }
    return _notMatchView;
}

@end
