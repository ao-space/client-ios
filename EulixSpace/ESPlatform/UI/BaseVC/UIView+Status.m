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
//  UIView+Status.m
//  EulixSpace
//
//  Created by KongBo on 2023/4/4.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "UIView+Status.h"
#import "ESToast.h"
#import "ESEmptyLoadingView.h"
#import <objc/runtime.h>

@interface UIView ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) ESEmptyLoadingView *emptyLoadingView;

@end

@implementation UIView (Status)

- (void)showLoading:(BOOL)bShow
{
    if (bShow) {
        ESToast.showLoading(self.titleForLoading, self);
        return;
    }
    
    [ESToast dismiss];
}

- (void)showLoading:(BOOL)bShow message:(NSString *)message
{
    if (bShow) {
        ESToast.showLoading(message, self);
        return;
    }
    
    [ESToast dismiss];
}

- (void)showLoadingWithMask:(BOOL)bShow {
    [self showLoadingWithMask:bShow message:self.titleForLoading];
}

- (void)showLoadingWithMask:(BOOL)bShow message:(NSString *)message {
    if (bShow) {
        if (self.maskView) {
            [self.maskView removeFromSuperview];
        }
        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        self.maskView.backgroundColor = ESColor.systemBackgroundColor;
        self.maskView.alpha = 0.06;
        [self addSubview:self.maskView];
        ESToast.showLoading(message, self);
        return;
    }
    
    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
    }
    [ESToast dismiss];
}

- (void)showEmptyLoading:(BOOL)show {
    if (show) {
        if(!self.emptyLoadingView) {
            self.emptyLoadingView = [[ESEmptyLoadingView alloc] initWithFrame:self.bounds];
        }
        self.emptyLoadingView.messgaeLable.text = self.emptyLoadingMessage;
        [self addSubview:self.emptyLoadingView];
        [self.emptyLoadingView startAnimation];
        return;
    }
    [self.emptyLoadingView stopAnimation];
    if (self.emptyLoadingView.superview) {
        [self.emptyLoadingView removeFromSuperview];
    }
}

- (NSString *)titleForLoading {
    return NSLocalizedString(@"wait", @"请稍后");
}

- (NSString *)emptyLoadingMessage {
    return NSLocalizedString(@"waiting_operate", @"请稍后");
}

- (void)setMaskView:(UIView *)maskView {
    objc_setAssociatedObject(self, @selector(maskView),
                             maskView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)maskView {
    return objc_getAssociatedObject(self, @selector(maskView));
}

- (ESEmptyLoadingView *)emptyLoadingView {
    return objc_getAssociatedObject(self, @selector(emptyLoadingView));
}

- (void)setEmptyLoadingView:(ESEmptyLoadingView *)emptyLoadingView {
    objc_setAssociatedObject(self, @selector(emptyLoadingView),
                             emptyLoadingView, OBJC_ASSOCIATION_ASSIGN);
}

@end
