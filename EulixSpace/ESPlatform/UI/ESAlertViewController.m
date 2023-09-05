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
//  ESAlertViewController.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlertViewController.h"
#import "UIWindow+ESVisibleVC.h"
#import <objc/runtime.h>

@interface UIApplication (TVSAlertController)

@property (nonatomic, strong) UIWindow *previousKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;

@end

@implementation UIApplication (TVSAlertController)

static void *gTVSPreviousKeyWindowContext = &gTVSPreviousKeyWindowContext;

- (UIWindow *)previousKeyWindow {
    return (UIWindow *)objc_getAssociatedObject(self, gTVSPreviousKeyWindowContext);
}

- (void)setPreviousKeyWindow:(UIWindow *)TVSPreviousKeyWindow {
    objc_setAssociatedObject(self, gTVSPreviousKeyWindowContext, TVSPreviousKeyWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void *gESAlertWindowContext = &gESAlertWindowContext;

- (UIWindow *)alertWindow {
    return (UIWindow *)objc_getAssociatedObject(self, gESAlertWindowContext);
}

- (void)setAlertWindow:(UIWindow *)TVSAlertWindow {
    objc_setAssociatedObject(self, gESAlertWindowContext, TVSAlertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface ESAlertAction ()

@property (nullable, nonatomic, copy) void (^handler)(ESAlertAction *action);
@property (nonatomic, copy, readwrite) NSString *title;
@property (nullable, nonatomic, copy) void (^didClickAction)(ESAlertAction *action);

- (void)clickAction:(id)sender;

@end

@implementation ESAlertAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^ __nullable)(ESAlertAction *action))handler {
    ESAlertAction *action = [[ESAlertAction alloc] init];
    action.handler = handler;
    action.title = title;
    return action;
}

- (void)clickAction:(id)sender {
    if (self.didClickAction) {
        self.didClickAction(self);
    }
    if (self.handler) {
        self.handler(self);
    }
}

@end

static NSInteger const gMessageMaxLine = 5;
static CGFloat const gMessageFontSize = 14.0;
static CGFloat const gActionHeight = 44.0;


@interface ESAlertViewController ()

@property (nonatomic, strong) NSMutableArray<ESAlertAction *> *actions;

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *actionView;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *message;

@end
 
@implementation ESAlertViewController
 
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    ESAlertViewController *instance = [[self alloc] init];
    instance.alertTitle = title;
    instance.message = message;
    return instance;
}

- (void)addAction:(ESAlertAction *)action {
    __weak typeof(self) weakSelf = self;
    action.didClickAction = ^(ESAlertAction *action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf closeAction:action];
    };
    [self.actions addObject:action];
}

- (instancetype)init {
    self = [super init];
    if (self)
    {
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        _actions = [[NSMutableArray alloc] init];
        _actionOrientationStyle = ESAlertActionOrientationStyleHorizontal;
    }
    return self;
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.alertView];
    _alertView.layer.cornerRadius = 12.0;
    _alertView.clipsToBounds = YES;
    _alertView.backgroundColor = ESColor.systemBackgroundColor;
    
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
        make.width.mas_offset(270.0f);
        make.height.mas_offset([self alertViewHeight]);
    }];
    
    [self preAddAction];
    
    [self setupHeaderView];
    [self setupContentView];
    [self setupActionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[ESColor colorWithHex:0x000000 alpha:0.5]];

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [_alertView.layer addAnimation:animation forKey:@"animationAlertKey"];
}
 

- (void)setupHeaderView {
    if (!self.headerView) {
        return;
    }
    [self.alertView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self headerViewHeight]);
        make.top.left.right.equalTo(self.alertView);
    }];
}

- (void)setupContentView {
    if (![self customContentView]) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.alertView addSubview:_contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([self contentViewHeight]);
            make.left.right.equalTo(self.alertView);
            make.top.equalTo(self.headerView ? self.headerView.mas_bottom : self.alertView.mas_top);
        }];
        
        [self addTitleLabel];
        [self addMessageLabel];
        return;
    }
    
    [self.alertView addSubview:self.customContentView];
    [self.customContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self contentViewHeight]);
        make.left.right.equalTo(self.alertView);
        make.top.equalTo(self.headerView ? self.headerView.mas_bottom : self.alertView.mas_top);
    }];
    _contentView = self.customContentView;
}

- (void)setupActionView {
    _actionView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.alertView addSubview:_actionView];
    if (_contentView) {
        [_actionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo([self actionViewHeight]);
                    make.left.right.equalTo(self.alertView);
                    make.top.equalTo(self.contentView.mas_bottom);
                }];
    }
    [self addActions];
}


- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _alertView;
}

- (CGFloat)alertViewHeight {
    return [self contentViewHeight] + [self headerViewHeight] + [self actionViewHeight];
}

#pragma mark -protocol
- (UIView * _Nullable)headerView {
    return nil;
}

- (CGFloat)headerViewHeight {
    return 0;
}

- (UIView * _Nullable)customContentView {
    return nil;
}

- (CGFloat)contentViewWidth {
    return 270.0f;
}

- (CGFloat)contentViewHeight {
    CGSize size = [self sizeOfMessage:self.message];
    return self.contentViewContentInsets.top  + self.contentViewContentInsets.bottom
           + 25 + 16 + size.height;
}

- (UIEdgeInsets)contentViewContentInsets {
    return UIEdgeInsetsMake(6, self.headerView != nil ? 12 : 35, 0, self.headerView != nil ? 12 : 35);
}

- (CGFloat)actionViewHeight {
    if (self.actionOrientationStyle == UILayoutConstraintAxisHorizontal) {
        return 43;
    }
    
    if (self.actions.count <= 0) {
        return 43;
    }
    
    NSInteger count = self.actions.count;
    return count * 44 + 10 * (count - 1) + self.actionViewContentInsets.top + self.actionViewContentInsets.bottom;
}

- (UIEdgeInsets)actionViewContentInsets {
    return UIEdgeInsetsMake(40, 35, 18, 35);
}

- (void)preAddAction {
    
}

- (void)addTitleLabel {
    if (self.alertTitle.length == 0) {
        return;
    }
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = ESFontPingFangMedium(18);
    _titleLabel.textColor = ESColor.labelColor ;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = [self alertTitle];
    _titleLabel.numberOfLines = 0;
    [_contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(25);
        make.top.equalTo(_contentView.mas_top).offset(self.headerView != nil ? 6.0f : 20.0f);
        make.left.equalTo(_contentView.mas_left).offset(12);
        make.right.equalTo(_contentView.mas_right).offset(-12);
    }];
}

- (void)addMessageLabel {
    if (self.message.length == 0) {
        return;
    }
    
    CGSize size = [self sizeOfMessage:self.message];
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.numberOfLines = gMessageMaxLine;
    _messageLabel.font = ESFontPingFangRegular(gMessageFontSize);
    _messageLabel.textColor = ESColor.labelColor;
    _messageLabel.text = self.message;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_messageLabel];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.centerX.equalTo(_contentView);
        if (_titleLabel) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(self.headerView != nil ? 16.0f : 20.0f);
        } else {
            make.top.equalTo(_contentView.mas_top).offset(self.headerView != nil ? 16.0f : 20.0f);
        }
    }];
}

- (void)addActions {
    NSArray<ESAlertAction *> *actions = self.actions;
    NSAssert(actions.count != 0, @"Cannot create a %@ with no action", NSStringFromClass(self.class));
    if (actions.count == 0) {
        return;
    }
    if (self.actionOrientationStyle == ESAlertActionOrientationStyleHorizontal) {
       //只能展示一、二个action
        [self  addActionButtonsWithHorizontalStyle];
        return;
    }
    
    if (self.actionOrientationStyle == ESAlertActionOrientationStyleVertical) {
        [self addActionButtonsWithVerticalStyle];
        return;
    }
}

- (void)addActionButtonsWithHorizontalStyle {
    NSInteger count = self.actions.count;
    CGFloat actionButtonWidth = count > 0 ? [self contentViewWidth] / count : 0 ;
    [self.actions enumerateObjectsUsingBlock:^(ESAlertAction * _Nonnull action, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= 3) {
            *stop = YES;
            return;
        }
        UIButton *button = [self buttonOfAction:action];
        button.layer.borderColor = ESColor.separatorColor.CGColor;
        button.layer.borderWidth = 1.0f;
        [_actionView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.width.mas_equalTo(actionButtonWidth);
                 make.height.mas_equalTo(gActionHeight);
                 make.left.mas_equalTo(_actionView).offset(idx * actionButtonWidth);
                 make.bottom.equalTo(_actionView.mas_bottom);
             }];
       }];
}

- (void)addActionButtonsWithVerticalStyle {
    UIEdgeInsets contentInsets = [self actionViewContentInsets];
    [self.actions enumerateObjectsUsingBlock:^(ESAlertAction * _Nonnull action, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= 3) {
            *stop = YES;
            return;
        }
        UIButton *button = [self buttonOfAction:action];
        if (action.backgroudImage) {
            [button setBackgroundImage:action.backgroudImage forState:UIControlStateNormal];
            [button setBackgroundImage:action.backgroudImage forState:UIControlStateDisabled];
        }
        
        if (action.backgroudColor) {
            button.backgroundColor = action.backgroudColor;
        } else {
            button.backgroundColor = [UIColor clearColor];
        }
        button.layer.cornerRadius = 10.0f;
        button.clipsToBounds = YES;
        [_actionView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.height.mas_equalTo(gActionHeight);
                 make.left.mas_equalTo(_actionView.mas_left).offset(contentInsets.left);
                 make.right.mas_equalTo(_actionView.mas_right).offset(- contentInsets.right);
                 make.top.mas_equalTo(_actionView.mas_top).offset(contentInsets.top +  idx * (gActionHeight + 10) );
             }];
       }];
}


- (UIButton *)buttonOfAction:(ESAlertAction *)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.titleLabel setFont:(action.font ? : ESFontPingFangRegular(16))];
    [button setTitleColor:(action.textColor ? : ESColor.labelColor)
                 forState:UIControlStateNormal];
    [button setTitle:action.title forState:UIControlStateNormal];
    [button addTarget:action action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)closeAction:(id)sender {
    [[UIApplication sharedApplication].alertWindow resignKeyWindow];
    [UIApplication sharedApplication].alertWindow  = nil;

    [[UIApplication sharedApplication].previousKeyWindow makeKeyWindow];
    [UIApplication sharedApplication].previousKeyWindow = nil;
}
 
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)show {
    [UIApplication sharedApplication].previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect frame = [UIApplication sharedApplication].previousKeyWindow.frame;
    UIWindow *window = [[UIWindow alloc] initWithFrame:frame];
    [UIApplication sharedApplication].alertWindow = window;
    window.rootViewController = self;
    [window makeKeyAndVisible];
}

- (CGSize)sizeOfMessage:(NSString *)subtitle {
    if (subtitle.length == 0) {
        return CGSizeMake(0, 0);
    }
    
    CGFloat width = [self contentViewWidth] - self.contentViewContentInsets.left - self.contentViewContentInsets.right;
    
    CGSize size = [subtitle boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : ESFontPingFangRegular(gMessageFontSize)}
                                         context:nil].size;
    
    size.height = ceil(size.height);
    size.width = ceil(width);
    return size;
}

@end

