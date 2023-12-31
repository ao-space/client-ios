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
//  ExitFullScreenTransition.m
//  PlayerDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "ExitFullScreenTransition.h"
#import "Masonry.h"

@interface ExitFullScreenTransition ()
@property(nonatomic,strong)WMPlayer *player;
@end


@implementation ExitFullScreenTransition
- (instancetype)initWithPlayer:(WMPlayer *)wmplayer{
    self = [super init];
    if (self) {
        self.player = wmplayer;
    }
    return self;
}
#pragma mark - UIViewControllerTransitioningDelegate
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.30;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //转场过渡的容器view
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = ESColor.darkTextColor;
    //ToVC
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    fromView.backgroundColor = [UIColor clearColor];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    CGPoint initialCenter = [containerView convertPoint:self.player.beforeCenter fromView:nil];

    [containerView insertSubview:toView belowSubview:fromView];
   
    if ([self.player.parentView isKindOfClass:[UIImageView class]]) {
        self.player.frame = CGRectMake(self.player.oldFrameToWindow.origin.x, self.player.oldFrameToWindow.origin.y, self.player.frame.size.width, self.player.frame.size.height);
        [[UIApplication sharedApplication].keyWindow addSubview:self.player];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = initialCenter;
            fromView.bounds = self.player.beforeBounds;
        } completion:^(BOOL finished) {
            [self.player removeFromSuperview];
            self.player.frame = self.player.parentView.bounds;
            [self.player.parentView addSubview:self.player];
            [fromView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }else{
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = initialCenter;
            fromView.bounds = self.player.beforeBounds;
        } completion:^(BOOL finished) {
            [self.player.parentView addSubview:self.player];
            [fromView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

@end


