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
//  ESQRCodeScanViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/7.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESQRCodeScanViewController.h"
#import "ESBoxManager.h"
#import "ESGlobalDefine.h"
#import "ESLoginAuthCodeForPlatformController.h"
#import "ESSetingViewController.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "NSString+ESTool.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import "NSString+ESTool.h"
#import "ESLoginAuthCodeForBoxController.h"
#import "ESPermissionController.h"
#import "UIImage+ESTool.h"

#define channelOnPeropheralView @"peripheralView"

@interface ESQRCodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView *scanLine;
@property (nonatomic, strong) UIImageView *scanRectView;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic, strong) UILabel *hint;

@property (nonatomic, strong) UIButton *noHaveBoxBtn;

@property (nonatomic, strong) UIButton *flashlightButton;

@property (nonatomic, strong) UIView *errorCover;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *errorHint;

@property (nonatomic, copy) NSString *serviceId;

@property (nonatomic, strong) NSNumber *affairId;

@property (nonatomic, copy) NSString *naviTitle;

@property (nonatomic, assign) BOOL withoutAlbum;

@property (nonatomic, assign) BOOL animated;

@property (nonatomic, strong) NSMutableArray *peripheralDataArray;

@property (nonatomic, strong) NSMutableArray *services;

@property (copy, nonatomic) NSString *qcCodeValue;

@property (copy, nonatomic) NSString *serviceUUID;

@property (nonatomic, assign) BOOL isToLogin;

@property (nonatomic, copy) UIButton *delectBtn;

@property (nonatomic, strong) UIImageView *hightlight;

@property (nonatomic, copy) UIButton *readAlbumPicBtn;

@end

@implementation ESQRCodeScanViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isToLogin = NO;
    [self startScan];
    self.services = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hideNavigationBar = YES;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [ESToast toastError:@"模拟器中无法打开照相机,请在真机中使用"];
        return;
    }
    
    if (self.action ==  ESQRCodeScanActionBoxUrl ) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
            [ESPermissionController showPermissionView:ESPermissionTypeCamera];
            self.hideNavigationBar = NO;
            return;
        }
    } else {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
            [ESPermissionController showPermissionView:ESPermissionTypeCamera];
            self.hideNavigationBar = NO;
            return;
        }
    }
   
    [self initCamera];
    self.killWhenPushed = YES;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinch];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
}

- (void)doubleTap:(UITapGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    if (state != UIGestureRecognizerStateEnded) {
        return;
    }
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        if (captureDevice.videoZoomFactor < captureDevice.activeFormat.videoMaxZoomFactor) {
            CGFloat current = MIN(captureDevice.videoZoomFactor * 2, captureDevice.activeFormat.videoMaxZoomFactor);
            //SIDLog(@"doubleTap :[%@] [%@]",@(state), @(current));
            [captureDevice rampToVideoZoomFactor:current withRate:10];
        } else {
            [captureDevice rampToVideoZoomFactor:1.0 withRate:10];
        }
    }];
}

- (void)pinch:(UIPinchGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    if (state != UIGestureRecognizerStateBegan && state != UIGestureRecognizerStateChanged) {
        return;
    }
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        if (sender.scale > 1) {
            CGFloat current = MIN(1.0 * sender.scale * 4, captureDevice.activeFormat.videoMaxZoomFactor);
            [captureDevice rampToVideoZoomFactor:current withRate:10];
        } else {
            CGFloat current = MAX(captureDevice.videoZoomFactor * sender.scale, 1.0);
            [captureDevice rampToVideoZoomFactor:current withRate:10];
        }
    }];
}

- (void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange {
    AVCaptureDevice *captureDevice = self.device;
    if ([captureDevice lockForConfiguration:nil]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }
}

- (void)initCamera {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if (!self.input) {
        return;
    }
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:([UIScreen mainScreen].bounds.size.height < 500) ? AVCaptureSessionPreset640x480 : AVCaptureSessionPresetHigh];
    [self.session addInput:self.input];
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.output];
    [self.session addOutput:videoDataOutput];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];

    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGRect scanRect = [UIScreen mainScreen].bounds;
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.bounds;
    self.scanRectView.frame = scanRect;
    self.scanRectView.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.5];
    CGRect rectOfInterest = CGRectMake(scanRect.origin.y / windowSize.height,
                                       scanRect.origin.x / windowSize.width,
                                       scanRect.size.height / windowSize.height,
                                       scanRect.size.width / windowSize.width);
    self.output.rectOfInterest = rectOfInterest;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    self.hint.text = TEXT_BOX_SCAN_QRCODE;

    [self.noHaveBoxBtn setTitle:@"暂无盒子，点击试用" forState:UIControlStateNormal];
    [self setupCorner:scanRect];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 140, ScreenHeight - 28 - 155, 280, 28)];
    hint.font = [UIFont systemFontOfSize:20];
    hint.textAlignment = NSTextAlignmentCenter;
//    if(self.action == ESQRCodeScanActionBoxUrl || self.action == ESQRCodeScanActionTrailBoxUrl){
//        hint.text =  NSLocalizedString(@"box_scan_qrcode", @"扫描设备二维码");
//    } else {
//        hint.text =  NSLocalizedString(@"common_scan_qrcode", @"扫描二维码");
//    }
    
    hint.textColor = ESColor.lightTextColor;
    [self.view addSubview:hint];
    
    if(self.action == ESQRCodeScanActionBoxUrl){
        hint.font = ESFontPingFangRegular(14);
        hint.frame = CGRectMake(ScreenWidth / 2 - 140, ScreenHeight - 20 - 193, 280, 20);
        UIImageView *hintImageView = [[UIImageView alloc] init];
        hintImageView.image = [UIImage es_imageNamed:@"sacn_code_hint"];
        [self.view addSubview:hintImageView];
        [hintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(hint.mas_bottom).offset(20);
            make.height.mas_equalTo(100);
            make.width.mas_equalTo(190);
            make.centerX.mas_equalTo(self.view);
        }];
        
        UILabel *bootomHintLabel = [[UILabel alloc] init];
        bootomHintLabel.font = ESFontPingFangRegular(14);
        bootomHintLabel.textAlignment = NSTextAlignmentCenter;
        bootomHintLabel.textColor = ESColor.lightTextColor;
        bootomHintLabel.numberOfLines = 0;
        bootomHintLabel.text = NSLocalizedString(@"es_scan_qrcode_on_pc", @"请扫描电脑浏览器上显示的二维码");
        [self.view addSubview:bootomHintLabel];
        [bootomHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(hintImageView.mas_bottom).offset(20);
            make.centerX.mas_equalTo(self.view);
            make.left.right.mas_equalTo(self.view).offset(10);
            make.width.mas_equalTo(360);
        }];
    } else {
        [self.view addSubview:self.readAlbumPicBtn];
        [self.readAlbumPicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(hint.mas_bottom).offset(12);
            make.centerX.mas_equalTo(self.view);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(294);
        }];
    }
    
    UIButton *returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, 62, 48, 48)];
    [returnBtn addTarget:self action:@selector(didReturnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [returnBtn setImage:IMAGE_QRCODE_BACK forState:UIControlStateNormal];
    [self.view addSubview:returnBtn];
}

- (void)setupCorner:(CGRect)scanRect {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGRect rect = self.view.bounds;
    UIColor *fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(rect),
                                                                     CGRectGetMinY(scanRect))];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(0,
                                                                 CGRectGetMaxY(scanRect),
                                                                 CGRectGetWidth(rect),
                                                                 CGRectGetHeight(rect) - CGRectGetMaxY(scanRect))]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(0,
                                                                 CGRectGetMinY(scanRect),
                                                                 CGRectGetMinX(scanRect),
                                                                 CGRectGetHeight(scanRect))]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMaxX(scanRect),
                                                                 CGRectGetMinY(scanRect),
                                                                 CGRectGetWidth(rect) - CGRectGetMaxX(scanRect),
                                                                 CGRectGetHeight(scanRect))]];
    shapeLayer.frame = rect;
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = fillColor.CGColor;
    [self.view.layer addSublayer:shapeLayer];
}

- (void)startScan {
    if (!self.session) {
        return;
    }
    self.hightlight.hidden = YES;
    [self stopScan];
    if (!self.session.running) {
        ESPerformBlockAsyn(^{
            [self.session startRunning];
        });
    }
    self.animated = YES;
    [self startAnimation];
}

- (void)startAnimation {
    [UIView animateWithDuration:2
        delay:0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
            self.scanLine.frame = CGRectMake(kESViewDefaultMargin, ScreenHeight - 230 - kBottomHeight, ScreenWidth - kESViewDefaultMargin * 2, 75);
        }
        completion:^(BOOL finished) {
            self.scanLine.frame = CGRectMake(kESViewDefaultMargin, 100, ScreenWidth - kESViewDefaultMargin * 2, 75);
            if (self.animated) {
                [self startAnimation];
            }
        }];
}

- (void)stopAnimation {
    self.animated = NO;
    [self.scanLine.layer removeAllAnimations];
    self.scanLine.frame = CGRectMake(26, 100, ScreenWidth - 52, 75);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self stopScan];
}

- (void)stopScan {
    if (!self.session) {
        return;
    }
    if (self.session.running) {
        [self.session stopRunning];
    }
    [self stopAnimation];
}

- (void)continueScan {
    self.errorCover.hidden = YES;
    [self startScan];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)analysis:(NSString *)code {
    [self stopScan];
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
    [self.view bringSubviewToFront:self.indicatorView];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ((metadataObjects.count == 0)) {
        return;
    }

    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    AVMetadataObject *dataObject = [self.preview transformedMetadataObjectForMetadataObject:metadataObject];
    self.hightlight.hidden = NO;
    self.hightlight.center = CGPointMake(CGRectGetMidX(dataObject.bounds), CGRectGetMidY(dataObject.bounds));
    [self processQRMessage:metadataObject.stringValue];
}

- (void)processQRMessage:(NSString *)message {
    if (self.action == ESQRCodeScanActionDefault) {
        NSString *value = message;
        if (self.regExpStr.length > 0) {
            //匹配正则
            if (![value ifMatchRegex:self.regExpStr]) {
                [self stopScan];
                [ESToast toastWarning:TEXT_BOX_SCAN_NO_BOX];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self startScan];
                });
                return;
            }
        }
        
        [self stopScan];
        if (self.callback) {
            self.callback(value);
        }
        [self goBack];
        return;
    }
    
    if (self.action == ESQRCodeScanActionLogin) {
        [self processAuthLogin:message];
        return;
    }
    if (self.action == ESQRCodeScanActionBoxUrl || self.action == ESQRCodeScanActionResetNetwork) {
        __block NSString *value = message;
        if ( (![value ifMatchRegex:kESBoxUrlRegex] &&
              ![value ifMatchRegex:kESBoxUrlRegexLocalNew] &&
              ![value ifMatchRegex:kESBoxUrlRegexLocalNewSN]) &&
            ![value ifMatchRegex:kESBoxUrlRegex1]) {
            [self stopScan];
            [ESToast toastWarning:TEXT_BOX_SCAN_NO_BOX];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startScan];
            });
        } else {
            if ([value ifMatchRegex:kESBoxUrlRegex1] || [value ifMatchRegex:kESBoxUrlRegexLocalNewSN]) {
                NSURLComponents *components = [NSURLComponents componentsWithString:value.stringByRemovingPercentEncoding];
                [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj,
                                                                    NSUInteger idx,
                                                                    BOOL *_Nonnull stop) {
                    if ([obj.name isEqualToString:@"sn"]) {
                        NSString * snValue = obj.value;
                        NSString * snSha256Value = [snValue.SHA256 substringToIndex:16];
//                        value = [value stringByReplacingOccurrencesOfString:snValue withString:snSha256Value];
                        value = [value stringByAppendingFormat:@"&realSn=%@",snSha256Value];
                        *stop = YES;
                    }
                }];
            }
            
            [self stopScan];
            if (self.action == ESQRCodeScanActionBoxUrl) {
                if (self.callback) {
                    self.callback(value);
                }
                [self goBack];
                return;
            }
            if (self.action == ESQRCodeScanActionResetNetwork) {
             
            }
        }
        return;
    }
}

- (void)processAuthLogin:(NSString *)string {
    ESDLog(@"[扫码] qrcode value:%@", string);

    if (ESBoxManager.activeBox.boxType == ESBoxTypeAuth) {
        [ESToast toastError:@"请在绑定设备上操作"];
        return;
    }
    if (self.isToLogin) {
        return;
    }
    self.isToLogin = YES;
    
    // 老版本的平台侧的二维码，返回的只有 pkey 的值
    NSArray * list = [string componentsSeparatedByString:@"&"];
    if (list.count == 1) {
        NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:list.firstObject];
        if (uuid == nil) {
            [self stopScan];
            [ESToast toastWarning:TEXT_BOX_SCAN_NO_BOX];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isToLogin = NO;
                [self startScan];
            });
            return;
        }
        ESLoginAuthCodeForPlatformController *vc = [[ESLoginAuthCodeForPlatformController alloc] init];
        vc.v = list.firstObject;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    NSURL * url = [NSURL URLWithString:string];
    if (url && url.query) {
        list = [url.query componentsSeparatedByString:@"&"];
    }
    __block NSString * p, *bt, *v, *isApp, *isOpensource;
    [list enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"p="]) {
            p = [obj componentsSeparatedByString:@"="].lastObject;
        } else if ([obj hasPrefix:@"bt="]) {
            bt = [obj componentsSeparatedByString:@"="].lastObject;
        } else if ([obj hasPrefix:@"v="]) {
            v = [obj componentsSeparatedByString:@"="].lastObject;
        } else if ([obj hasPrefix:@"isApp="]) {
            isApp = [obj componentsSeparatedByString:@"="].lastObject;
        } else if ([obj hasPrefix:@"isOpensource="]) {
            isOpensource = [obj componentsSeparatedByString:@"="].lastObject;
        }
    }];
    
    if (![p isEqualToString:@"aospace"]) {
        [self stopScan];
        [ESToast toastWarning:TEXT_BOX_SCAN_NO_BOX];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isToLogin = NO;
            [self startScan];
        });
        return;
    }
    if ([isApp isEqualToString:@"1"] && ![isOpensource isEqualToString:@"1"]) {
        [self stopScan];
        [ESToast toastWarning:NSLocalizedString(@"es_version_not_match", @"版本不匹配，客户端和服务端版本需相同")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isToLogin = NO;
            [self startScan];
        });
        return;
    }
    
    
    ESLoginAuthCodeForPlatformController *vc;
    if ([ESLoginAuthCodeForPlatformController isLoginFromBox:bt]) {
        vc = [[ESLoginAuthCodeForBoxController alloc] init];
    } else {
        vc = [[ESLoginAuthCodeForPlatformController alloc] init];
    }
    vc.p = p;
    vc.bt = bt;
    vc.v = v;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReturnBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Lazy Load

- (UIImageView *)scanRectView {
    if (!_scanRectView) {
        _scanRectView = [UIImageView new];
        [self.view addSubview:_scanRectView];
        //_scanRectView.image = IMAGE_IC_SCAN_RECT;
        _scanRectView.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
    }
    return _scanRectView;
}

- (UIImageView *)scanLine {
    if (!_scanLine) {
        _scanLine = [UIImageView new];
        [self.scanRectView addSubview:_scanLine];
        _scanLine.image = IMAGE_IC_SCAN_LINE;
    }
    return _scanLine;
}

- (UIImageView *)hightlight {
    if (!_hightlight) {
        _hightlight = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.view addSubview:_hightlight];
        _hightlight.image = IMAGE_QRCODE_HIGHTLIGHT;
        _hightlight.hidden = YES;
    }
    return _hightlight;
}

- (UILabel *)errorHint {
    if (!_errorHint) {
        _errorHint = [UILabel new];
        _errorHint.numberOfLines = 2;
        _errorHint.textColor = [ESColor colorWithHex:0xcccccc];
        [self.errorCover addSubview:_errorHint];
        [_errorHint mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(self.scanRectView);
            make.size.mas_equalTo(CGSizeMake(200, 60));
        }];
        _errorHint.font = [UIFont systemFontOfSize:10];
        _errorHint.textAlignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"未发现二维码\n轻触屏幕继续扫描"];
        [attributedString addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:16],
            NSForegroundColorAttributeName: [ESColor systemBackgroundColor],
        }
                                  range:NSMakeRange(0, 6)];
        _errorHint.attributedText = attributedString;
    }
    return _errorHint;
}

- (UIButton *)noHaveBoxBtn {
    if (nil == _noHaveBoxBtn) {
        _noHaveBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_noHaveBoxBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
        [_noHaveBoxBtn addTarget:self action:@selector(readAlbumPicAction:) forControlEvents:UIControlEventTouchUpInside];
        [_noHaveBoxBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        //设置边框颜色
        _noHaveBoxBtn.layer.borderColor = [UIColor grayColor].CGColor;
        //设置边框宽度
        _noHaveBoxBtn.layer.borderWidth = 1.0f;
        //关键语句
        [_noHaveBoxBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
        _noHaveBoxBtn.hidden = YES;
        [self.view addSubview:_noHaveBoxBtn];

        [_noHaveBoxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
            make.centerX.mas_equalTo(self.view);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(294);
        }];
    }
    return _noHaveBoxBtn;
}

- (UIButton *)readAlbumPicBtn {
    if (nil == _readAlbumPicBtn) {
        _readAlbumPicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_readAlbumPicBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_readAlbumPicBtn addTarget:self action:@selector(readAlbumPicAction:) forControlEvents:UIControlEventTouchUpInside];
        [_readAlbumPicBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_readAlbumPicBtn setTitle:NSLocalizedString(@"trial_album", @"本地相册")  forState:UIControlStateNormal];
    }
    return _readAlbumPicBtn;
}

- (void)readAlbumPicAction:(id)sender {
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CIImage *ciimage = [[CIImage alloc] initWithImage:image];
    NSDictionary *options = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:options];
    NSArray * features = [detector featuresInImage:ciimage];
    __block NSString *message = nil;
    [features enumerateObjectsUsingBlock:^(CIFeature  *_Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item isKindOfClass:[CIQRCodeFeature class]]) {
            message = [(CIQRCodeFeature *)item messageString];
            *stop = YES;
        }
    }];
    [self processQRMessage:message];
}

- (UIView *)errorCover {
    if (!_errorCover) {
        _errorCover = [UIView new];
        [self.view addSubview:_errorCover];
        [_errorCover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        _errorCover.backgroundColor = [ESColor colorWithHex:0xffffff alpha:0.5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueScan)];
        [_errorCover addGestureRecognizer:tap];
    }
    return _errorCover;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        if (@available(iOS 13.0, *)) {
            _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
        }
        _indicatorView.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.5];
        _indicatorView.color = ESColor.systemBackgroundColor;
        [self.view addSubview:_indicatorView];
        _indicatorView.hidden = YES;
    }
    return _indicatorView;
}

- (void)noHaveBoxBtnAction {
    ESSetingViewController *settingVC = [[ESSetingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)dealloc {
    ESDLog(@"[扫码] dealloc");
}

@end
