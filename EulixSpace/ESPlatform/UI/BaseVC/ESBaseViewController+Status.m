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
//  ESBaseViewController+Status.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseViewController+Status.h"
#import "ESToast.h"
#import "ESHomeCoordinator.h"

@implementation ESBaseViewController (Status)

- (void)showLoading:(BOOL)bShow
{
    if (bShow) {
        ESToast.showLoading(self.titleForLoading, self.view);
        return;
    }
    
    [ESToast dismiss];
}

- (void)showLoadingWithMask:(BOOL)bShow {
    if (bShow) {
        UIWindow *window = [ESHomeCoordinator sharedInstance].window;
        if (_maskView) {
            [_maskView removeFromSuperview];
        }
        _maskView = [[UIView alloc] initWithFrame:window.bounds];
        _maskView.backgroundColor = ESColor.systemBackgroundColor;
        _maskView.alpha = 0.06;
        if (window.subviews.count > 0) {
            [window insertSubview:_maskView atIndex:1];
        }
        ESToast.showLoading(self.titleForLoading, self.view);
        return;
    }
    
    if (_maskView.superview) {
        [_maskView removeFromSuperview];
    }
    [ESToast dismiss];
}

- (void)showEmptyLoading:(BOOL)show {
    if (show) {
        if(!_emptyLoadingView) {
            _emptyLoadingView = [[ESEmptyLoadingView alloc] initWithFrame:self.view.bounds];
        }
        _emptyLoadingView.messgaeLable.text = self.emptyLoadingMessage;
        [self.view addSubview:_emptyLoadingView];
        [_emptyLoadingView startAnimation];
        return;
    }
    [_emptyLoadingView stopAnimation];
    if (_emptyLoadingView.superview) {
        [_emptyLoadingView removeFromSuperview];
    }
}

- (NSString *)emptyLoadingMessage {
    return NSLocalizedString(@"waiting_operate", @"请稍后");
    
}

- (void)showEmpty:(BOOL)bShow
{
    [self showLoading:NO];

    if (bShow) {
        if (!_emptyView) {
            _emptyView = [[ESDefaultEmptyView alloc] initWithFrame:self.view.bounds];
        }
        _emptyView.backgroundImageView.image = self.backgroudImageForEmpty;
        _emptyView.iconImageView.image = self.imageForEmpty;
        _emptyView.titleLabel.text = self.titleForEmpty;
        _emptyView.detailLabel.text = self.subtitleForEmpty;
        _emptyView.userInteractionEnabled = NO;
        
        [_emptyView setTopOffset:[self emptyViewTopOffset]];
        [self.view addSubview:_emptyView];
    } else if (_emptyView.superview) {
        [_emptyView removeFromSuperview];
    }
}

- (void)showEmptyWithImage:(UIImage *)image
       withAttributedTitle:(NSAttributedString *)title
    withAttributedSubTitle:(NSAttributedString *)subTitle {
    [self showLoading:NO];

    if (!_emptyView) {
        _emptyView = [[ESDefaultEmptyView alloc] initWithFrame:self.view.bounds];
    }
    _emptyView.backgroundImageView.image = self.backgroudImageForEmpty;
    _emptyView.iconImageView.image = image;
    _emptyView.titleLabel.attributedText = title;
    _emptyView.detailLabel.attributedText = subTitle;
    [self.view addSubview:_emptyView];
}

- (NSString *)titleForLoading {
    return NSLocalizedString(@"wait", @"请稍后");
}

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"applet_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"applet_empty_icon"];
}

- (NSString *)titleForEmpty {
    return @"暂未安装应用";
}

- (NSString *)subtitleForEmpty {
    return @"";
}

- (CGFloat)emptyViewTopOffset {
    return self.view.bounds.size.height / 2.0 - 64;
}

@end
