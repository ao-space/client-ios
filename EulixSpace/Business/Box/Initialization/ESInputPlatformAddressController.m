//
//  ESInputPlatformAddressController.m
//  EulixSpace
//
//  Created by dazhou on 2023/7/28.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESInputPlatformAddressController.h"
#import "UIButton+Extension.h"
#import "AAPLCustomPresentationController.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"

@interface ESInputPlatformAddressController ()
@property (nonatomic, weak) UIViewController * srcCtl;
@property (nonatomic, strong) NSString * urlString;
@property (nonatomic, strong) UIView * containView;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, copy) void (^onSureBlock)(NSString * urlString);
@end

@implementation ESInputPlatformAddressController

+ (BOOL)showView:(UIViewController *)srcCtl url:(NSString *)urlString block:(void(^)(NSString * urlString))sureBlock {
    ESInputPlatformAddressController * dstCtl = [[ESInputPlatformAddressController alloc] init];
    dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    dstCtl.srcCtl = srcCtl;
    dstCtl.urlString = urlString;
    dstCtl.onSureBlock = sureBlock;
    AAPLCustomPresentationController *presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:dstCtl presentingViewController:srcCtl];
    dstCtl.transitioningDelegate = presentationController;
    [srcCtl presentViewController:dstCtl animated:YES completion:nil];

    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor es_colorWithHexString:@"#00000050"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];

    [self setupViews];
    [self.textField becomeFirstResponder];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = keyboardFrame.origin.y - 216;
    self.containView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onCancelBtn {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSureBtn {
    if (self.onSureBlock) {
        NSString * text = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.onSureBlock(text);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupViews {
    UILabel * label = [UILabel createLabel:NSLocalizedString(@"es_address", @"地址") font:ESFontPingFangMedium(18) color:@"#333333"];
    [self.containView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containView).offset(20);
        make.centerX.mas_equalTo(self.containView);
    }];
    
    UIButton * cancelBtn = [UIButton es_create:NSLocalizedString(@"common_cancel", @"取消") font:ESFontPingFangRegular(18) txColor:@"#337AFF" bgColor:@"#FFFFFF" target:self selector:@selector(onCancelBtn)];
    [self.containView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containView).inset(20);
        make.centerY.mas_equalTo(label);
    }];
    
    UIButton * sureBtn = [UIButton es_create:NSLocalizedString(@"common_ok", @"确定") font:ESFontPingFangRegular(18) txColor:@"#337AFF" bgColor:@"#FFFFFF" target:self selector:@selector(onSureBtn)];
    [self.containView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.containView).inset(20);
        make.centerY.mas_equalTo(label);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView).inset(26);
        make.top.mas_equalTo(label.mas_bottom).offset(30);
    }];
    
    UIView * lineView = [[UIView alloc] init];
    [self.containView addSubview:lineView];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView).inset(26);
        make.top.mas_equalTo(self.textField.mas_bottom).offset(20);
        make.height.mas_equalTo(1);
    }];
    
    //说明：请填写您的空间平台地址，安装部署指南：https://ao.space/open/documentation/104002，如使用傲空间官方通道请输入：https://ao.space
    UILabel * label1 = [UILabel createLabel:NSLocalizedString(@"es_input_platform_address_detail", @"") font:ESFontPingFangRegular(12) color:@"#85899C"];
    [self.containView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView).inset(26);
        make.top.mas_equalTo(lineView.mas_bottom).offset(10);
    }];
}

- (UIView *)containView {
    if (!_containView) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        _containView = view;
        
        UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = view.bounds;
        maskLayer.path = maskPath.CGPath;
        view.layer.mask = maskLayer;
    }
    return _containView;
}


- (UITextField *)textField {
    if (!_textField) {
        UITextField * tf = [[UITextField alloc] init];
        tf.backgroundColor = [UIColor whiteColor];
        tf.placeholder = NSLocalizedString(@"es_input_platform_address", @"请输入空间平台地址");
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField = tf;
        tf.text = self.urlString;
        [self.containView addSubview:tf];
    }
    return _textField;
}

@end
