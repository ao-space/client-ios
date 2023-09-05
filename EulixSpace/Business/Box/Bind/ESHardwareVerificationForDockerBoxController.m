//
//  ESHardwareVerificationForDockerBoxController.m
//  EulixSpace
//
//  Created by dazhou on 2023/7/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESHardwareVerificationForDockerBoxController.h"
#import "ESBoxSearchForDockerPromptView.h"
#import "ESBoxManager.h"
#import "ESGradientButton.h"
#import "ESQRCodeScanViewController.h"
#import "ESThemeDefine.h"
#import "ESBoxBindViewModel.h"
#import "ESToast.h"
#import <Masonry/Masonry.h>
#import "UIViewController+ESTool.h"
#import "ESNetServiceBrowser.h"
#import "ESPermissionController.h"
#import <AVFoundation/AVFoundation.h>

@interface ESHardwareVerificationForDockerBoxController ()<ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESBoxSearchForDockerPromptView *wcPrompt;

@property (nonatomic, strong) ESGradientButton *searchButton;

@property (nonatomic, strong) ESBoxBindViewModel *viewModel;

@property (nonatomic, copy) NSString *btid;
@property (nonatomic, copy) NSString *sn;

@end

@implementation ESHardwareVerificationForDockerBoxController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.title = NSLocalizedString(@"Hardware device verification", @"硬件设备验证");;
    if (!self.viewModel) {
        self.viewModel = [ESBoxBindViewModel viewModelWithDelegate:self];
    }
    [self initLayout];
    if (self.viewModel.mode == ESBoxBindModeWiredConnectionWithIp) {
        [self startMdnsSearch];
        self.searchButton.hidden = YES;
        [self.searchButton stopLoading:TEXT_BOX_SCAN_AGAIN];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.delegate = self;
}

- (void)startMdnsSearch {
    self.searchButton.enabled = NO;
    [self.prompt reloadWithState:ESBoxBindStateScaning];
    [self.viewModel searchWithUniqueId:self.btid];
}

- (void)startQrCodeScan {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
     if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
         [ESPermissionController showPermissionView:ESPermissionTypeCamera];
     } else {
         ESQRCodeScanViewController *next = [ESQRCodeScanViewController new];
         next.action = ESQRCodeScanActionBoxUrl;
         next.callback = ^(NSString *value) {
             NSString * urlStr = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
             urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
             urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
             NSURLComponents *components = [NSURLComponents componentsWithString:urlStr.stringByRemovingPercentEncoding];
             __block NSString *btid;
             __block NSString *ipaddr;
             __block NSString *port;
             __block NSString *sn;
             __block NSString *realSn;
             [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj,
                                                                 NSUInteger idx,
                                                                 BOOL *_Nonnull stop) {
                 if ([obj.name isEqualToString:@"sn"]) {
                     sn = obj.value;
                 }else if ([obj.name isEqualToString:@"realSn"]) {
                     realSn = obj.value;
                 }else if ([obj.name isEqualToString:@"btid"]) {
                     btid = obj.value;
                 } else if ([obj.name isEqualToString:@"ipaddr"]) {
                     ipaddr = obj.value;
                 } else if ([obj.name isEqualToString:@"port"]) {
                     port = obj.value;
                 }
                 
             }];
             ESDLog(@"[Bind] start with uuid : {%@:%@ - %@ -%@}", ipaddr, port, btid, sn);
             //内部不区分btid， sn、  用于展示逻辑
             if (btid.length > 0) {
                 self.btid = btid;
             }
             
             if (sn.length > 0) {
                 self.btid = realSn;
                 self.sn = sn;
             }
             
             if (ipaddr.length > 0 && port.length > 0) {
                 //走有线模拟器mode
                 ESDLog(@"[Bind] start with uuid : {%@:%@ - %@}", ipaddr, port, self.btid);
                 ESNetServiceItem *item = [[ESNetServiceItem alloc] initWithName:@"" ipv4:ipaddr port:[port intValue]];
                 [self tryPairWithNetServiceInfo:item];
             } else {
                 [ESToast toastWarning:TEXT_BOX_SCAN_NO_BOX];
             }
         };
         [self.navigationController pushViewController:next animated:YES];
     }
}

- (void)tryPairWithNetServiceInfo:(ESNetServiceItem *)serviceInfo {
    ESHardwareVerificationForDockerBoxController *next = [ESHardwareVerificationForDockerBoxController new];
    next.searchedBlock = self.searchedBlock;
    next.authType = self.authType;
    next.applyRsp = self.applyRsp;
    next.btid = self.btid;
    next.viewModel = [ESBoxBindViewModel viewModelWithDelegate:next];
    next.viewModel.mode = ESBoxBindModeWiredConnectionWithIp;
    next.viewModel.scanNetServiceInfo = serviceInfo;
    ESPerformBlockOnMainThreadAfterDelay(0.5, ^{
        [self.navigationController pushViewController:next animated:YES];
    });
}

#pragma mark - ESBoxBindViewModelDelegate
- (void)viewModelOnClose:(NSError *)error {
    if (!self.view.window) {
        return;
    }
    self.searchButton.enabled = YES;
    [self.searchButton stopLoading:TEXT_BOX_SCAN_AGAIN];
    [self.prompt reloadWithState:ESBoxBindStateFound];
}

- (void)viewModelLocalNetServiceNotReachable:(NSError *)error {
    [self.prompt reloadWithState:ESBoxBindStateNotFound];
  
    self.searchButton.hidden = NO;
    self.searchButton.enabled = YES;
    [self.searchButton stopLoading:TEXT_BOX_SCAN_AGAIN];
}

- (void)viewModelOnInit:(ESBoxStatusItem *)boxStatus {
    if (!boxStatus.infoResult) {
        self.searchButton.hidden = NO;
        self.searchButton.enabled = YES;
        [self.prompt reloadWithState:ESBoxBindStateNotFound];
        [self.searchButton stopLoading:TEXT_BOX_SCAN_AGAIN];
        return;
    }
    if (self.searchedBlock) {
        [self.prompt reloadWithState:ESBoxBindStateFound];
        self.searchedBlock(self.authType, self.viewModel, self.applyRsp);
    }
}

#pragma mark - UI

- (void)initLayout {
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight + 68);
    }];
    [self.prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.searchButton.mas_top).inset(20);
    }];
}

- (void)dismiss {
    [self goBack];
}

- (UIView<ESBoxBindPromptProtocol> *)prompt {
    return self.wcPrompt;
}

- (ESBoxSearchForDockerPromptView *)wcPrompt {
    if (!_wcPrompt) {
        _wcPrompt = [ESBoxSearchForDockerPromptView new];
        [self.view addSubview:_wcPrompt];
    }
    return _wcPrompt;
}

- (ESGradientButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_searchButton setCornerRadius:10];
        [_searchButton setTitle:NSLocalizedString(@"es_scan", @"扫一扫") forState:UIControlStateNormal];
        _searchButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_searchButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_searchButton];
        [_searchButton addTarget:self action:@selector(startQrCodeScan) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

@end
