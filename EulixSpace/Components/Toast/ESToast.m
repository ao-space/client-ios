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
//  ESToast.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/6.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESToast.h"
#import "ESThemeDefine.h"
#import <Lottie/LOTAnimationView.h>
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>

static const CGFloat kESToastDefaultDismissDuration = 1;

static const CGFloat kESToastMinDismissDuration = 10;

typedef NS_ENUM(NSUInteger, ESToastType) {
    ESToastTypeNone,
    ESToastTypeInfo,
    ESToastTypeNetworkError,
    ESToastTypeWaiting,
};

@interface ESToast ()

@property (nonatomic, copy) NSString *pInfo;

@property (nonatomic, assign) ESToastType type;

@property (nonatomic, assign) BOOL appeared;

@property (nonatomic, assign) CGFloat pDelay;

@property (nonatomic, weak) UIView *holder;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) LOTAnimationView *animation;

@property (nonatomic, strong) UILabel *pPrompt;

@property (nonatomic, strong) UIView *messageContentView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation ESToast

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)toastInfo:(NSString *)info {
    if (ESToast.shared.appeared) {
        return;
    }
    ESToast.shared.appeared = YES;
    [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.5]];
    [SVProgressHUD dismiss];
    [SVProgressHUD showInfoWithStatus:info];
    [SVProgressHUD dismissWithDelay:kESToastDefaultDismissDuration
                         completion:^{
                             ESToast.shared.appeared = NO;
                             [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
                         }];
}

+ (void)toastInDarkStyleInfo:(NSString *)info {
    if (ESToast.shared.appeared) {
        return;
    }
    ESToast.shared.appeared = YES;
    [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
    [SVProgressHUD dismiss];
    [SVProgressHUD showInfoWithStatus:info];
    [SVProgressHUD dismissWithDelay:kESToastDefaultDismissDuration
                         completion:^{
                             ESToast.shared.appeared = NO;
                             [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
                         }];
}

+ (void)toastSuccess:(NSString *)success {
    [self toastSuccess:success handle:nil];
}

+ (void)toastSuccess:(NSString *)success handle:(void (^ __nullable)(void))handler {
    if (ESToast.shared.appeared) {
        return;
    }
    ESToast.shared.appeared = YES;
    [SVProgressHUD dismiss];
    [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
    [SVProgressHUD showSuccessWithStatus:success];
    [SVProgressHUD dismissWithDelay:kESToastDefaultDismissDuration
                         completion:^{
        ESToast.shared.appeared = NO;
        [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
        if (handler) {
            handler();
        }
    }];
}

+ (void)toastError:(NSString *)error {
    if (ESToast.shared.appeared) {
        return;
    }
    ESToast.shared.appeared = YES;
    [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:error];
    [SVProgressHUD dismissWithDelay:kESToastDefaultDismissDuration
                         completion:^{
                             ESToast.shared.appeared = NO;
                             [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
                         }];
}

+ (void)toastWarning:(NSString *)warning {
    if (ESToast.shared.appeared) {
        return;
    }
    ESToast.shared.appeared = YES;
//    ESToast.shared.info
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"warning"]];
    [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
    [SVProgressHUD dismiss];
    
    [SVProgressHUD showInfoWithStatus:warning];
    [SVProgressHUD dismissWithDelay:kESToastDefaultDismissDuration
                         completion:^{
                             ESToast.shared.appeared = NO;
                             [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
                         }];
}

+ (void)dismiss {
    ESToast.shared.appeared = NO;
    [ESToast.shared reset];
    [SVProgressHUD dismiss];
}

+ (void)setDefaultTheme {
    [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
    UIImage *nullImage = nil;
    [SVProgressHUD setInfoImage:nullImage];
    [SVProgressHUD setSuccessImage:IMAGE_TOAST_SUCCESS];
    [SVProgressHUD setErrorImage:IMAGE_TOAST_ERROR];
    [SVProgressHUD setMinimumSize:CGSizeMake(130, 72)];
    [SVProgressHUD setMinimumDismissTimeInterval:kESToastMinDismissDuration];
    [SVProgressHUD setForegroundColor:ESColor.lightTextColor];
}

- (void)toast {
    if (ESToast.shared.appeared) {
        return;
    }
    ESToast.shared.appeared = YES;
    [SVProgressHUD dismiss];
    if (self.type == ESToastTypeNetworkError) {
        [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
        [SVProgressHUD setErrorImage:IMAGE_TOAST_ERROR_SAD_FACE];
        [SVProgressHUD showErrorWithStatus:self.pInfo];
    } else {
        [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.5]];
        [SVProgressHUD showInfoWithStatus:self.pInfo];
    }

    [SVProgressHUD dismissWithDelay:self.pDelay
                         completion:^{
                             ESToast.shared.appeared = NO;
                             [SVProgressHUD setBackgroundColor:[ESColor.darkTextColor colorWithAlphaComponent:0.8]];
                             [SVProgressHUD setErrorImage:IMAGE_TOAST_ERROR];
                         }];
}

+ (ESToast *)pure {
    ESToast *toast = [ESToast shared];
    return toast;
}

- (void)setAppeared:(BOOL)appeared {
    _appeared = appeared;
}

- (void)reset {
    if (ESToast.shared.appeared) {
        return;
    }
    self.type = ESToastTypeNone;
    self.pInfo = nil;
    self.holder = nil;
    self.pDelay = 0.0;
    [self removeFromSuperview];
    [_animation removeFromSuperview];
    _animation = nil;
    [_contentView removeFromSuperview];
    _contentView = nil;
    [_pPrompt removeFromSuperview];
    _pPrompt = nil;
}

+ (ESToast * (^)(NSString *))info {
    return ^(NSString *info) {
        ESToast *toast = [ESToast pure];
        toast.type = ESToastTypeInfo;
        toast.pInfo = info;
        toast.pDelay = kESToastDefaultDismissDuration;
        return toast;
    };
}

+ (ESToast * (^)(NSString *))networkError {
    return ^(NSString *error) {
        ESToast *toast = [ESToast pure];
        toast.type = ESToastTypeNetworkError;
        toast.pInfo = error;
        toast.pDelay = kESToastDefaultDismissDuration;
        return toast;
    };
}

+ (ESToast * (^)(NSString *))waiting {
    return ^(NSString *info) {
        ESToast *toast = [ESToast pure];
        toast.type = ESToastTypeWaiting;
        toast.pInfo = info;
        toast.pDelay = kESToastDefaultDismissDuration;
        return toast;
    };
}

- (ESToast * (^)(NSTimeInterval delay))delay {
    return ^(NSTimeInterval delay) {
        self.pDelay = delay;
        return self;
    };
}

- (ESToast * (^)(void))show {
    return ^(void) {
        [self toast];
        return self;
    };
}

- (ESToast * (^)(UIView *holder))showFrom {
    return ^(UIView *holder) {
        self.holder = holder;
        [self showWaiting];
        return self;
    };
}

+ (ESToast * (^)(NSString *info, UIView *formView))showLoading {
    return ^(NSString *info, UIView *formView) {
        if (ESToast.shared.appeared) {
            [self dismiss];
        }
        ESToast *toast = [ESToast pure];
        toast.type = ESToastTypeWaiting;
        toast.pInfo = info;
        toast.holder = formView;
        [self showLoadingHUD:toast];
        return self;
    };
}

+ (ESToast * (^)(NSString *info, UIView *formView))showInfo {
    return ^(NSString *info, UIView *formView) {
        if (ESToast.shared.appeared) {
            [self dismiss];
        }
        ESToast *toast = [ESToast pure];
        toast.type = ESToastTypeInfo;
        toast.pInfo = info;
        toast.holder = formView;
        [self showInfo:toast];
        return self;
    };
}

+ (void)showInfo:(ESToast *)toast {
    ESToast.shared.appeared = YES;
    toast.frame = toast.holder.bounds;
    [toast.holder addSubview:toast.messageContentView];
    toast.messageLabel.text = toast.pInfo;
    
    CGRect labelRect;
    CGFloat labelHeight = 0;
    CGFloat labelWidth = 0;
    if(toast.pInfo.length > 0) {
          CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
          labelRect = [toast.pInfo boundingRectWithSize:constraintSize
                                                          options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading |
                                                                                           NSStringDrawingTruncatesLastVisibleLine |
                                                                                           NSStringDrawingUsesLineFragmentOrigin)
                                                       attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]}
                                                          context:NULL];
          labelHeight = ceilf(CGRectGetHeight(labelRect));
          labelWidth = ceilf(CGRectGetWidth(labelRect));
      }
    
    [toast.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(labelHeight);
    }];
    
    toast.messageContentView.frame = CGRectMake(0, 0, labelWidth + 40 , labelHeight + 40);
    toast.messageContentView.center = toast.center;
}

+ (void)dismissInfo {
    ESToast.shared.appeared = NO;
    ESToast *toast = [ESToast pure];
    if (toast.messageLabel.superview) {
        [toast.messageLabel removeFromSuperview];
        toast.messageLabel = nil;
    }
    if (toast.messageContentView.superview) {
        [toast.messageContentView removeFromSuperview];
        toast.messageContentView = nil;
    }
    
    [self dismiss];
}

+ (void)showLoadingHUD:(ESToast *)toast {
    ESToast.shared.appeared = YES;
    toast.frame = toast.holder.bounds;
    [toast.holder addSubview:toast];
    toast.contentView.frame = CGRectMake(0, 0, 130, 104);
    toast.contentView.center = toast.center;
    toast.pPrompt.text = toast.pInfo;
    [toast.animation play];
}

- (void)showWaiting {
    if (ESToast.shared.appeared) {
        return;
    }
    ESToast.shared.appeared = YES;
    self.frame = self.holder.bounds;
    [self.holder addSubview:self];
    self.contentView.frame = CGRectMake(0, 0, 130, 124);
    self.contentView.center = self.center;
    self.pPrompt.text = self.pInfo;
    [self.animation play];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.pDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!ESToast.shared.appeared) {
            return;
        }
        ESToast.shared.appeared = NO;
        [self removeFromSuperview];
    });
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        [self addSubview:_contentView];
        _contentView.layer.cornerRadius = 6;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.8];
    }
    return _contentView;
}

- (LOTAnimationView *)animation {
    if (!_animation) {
        _animation = [LOTAnimationView animationNamed:@"wait_a_minute"];
        _animation.loopAnimation = YES;
        [self addSubview:_animation];
        [_animation mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).inset(20);
            make.height.width.mas_equalTo(35);
            make.centerX.mas_equalTo(self.contentView);
        }];
    }
    return _animation;
}

- (UILabel *)pPrompt {
    if (!_pPrompt) {
        _pPrompt = [[UILabel alloc] init];
        _pPrompt.textColor = ESColor.lightTextColor;
        _pPrompt.textAlignment = NSTextAlignmentCenter;
        _pPrompt.font = [UIFont systemFontOfSize:10];
        _pPrompt.numberOfLines = 0;
        [self.contentView addSubview:_pPrompt];
        [_pPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.animation.mas_bottom).offset(10);
            make.left.right.mas_equalTo(self.contentView).inset(10);
        }];
    }
    return _pPrompt;
}


- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [UIView new];
        [self addSubview:_messageContentView];
        _messageContentView.layer.cornerRadius = 14;
        _messageContentView.layer.masksToBounds = YES;
        _messageContentView.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.8];
    }
    return _messageContentView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = ESColor.lightTextColor;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        [self.messageContentView addSubview:_messageLabel];
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.messageContentView.mas_top).inset(20);
            make.height.mas_equalTo(14);
            make.left.right.mas_equalTo(self.messageContentView).inset(20);
        }];
    }
    return _messageLabel;
}

+ (void)toastServiceError {
    [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
}

+ (void)toastWaitView:(UIView *)fromView {
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), fromView);
}
@end
