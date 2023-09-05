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
//  EnterFullScreenTransition.m
//  PlayerDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "EnterFullScreenTransition.h"
#import "Masonry.h"
@interface EnterFullScreenTransition ()
@property(nonatomic,strong)WMPlayer *wmplayer;


@end

@implementation EnterFullScreenTransition
- (instancetype)initWithPlayer:(WMPlayer *)wmplayer{
    self = [super init];
    if (self) {
        self.wmplayer = wmplayer;
    }
    return self;
}
#pragma mark - UIViewControllerTransitioningDelegate
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.30;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
        UIView *containerView = [transitionContext containerView];
        UIViewController  *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//        UIViewController  *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        toView.backgroundColor = [UIColor clearColor];

        CGPoint initialCenter = [containerView convertPoint:self.wmplayer.beforeCenter fromView:self.wmplayer];

        [containerView addSubview:toView];

        [toView addSubview:self.wmplayer];

        toView.bounds = self.wmplayer.beforeBounds;
        toView.center = initialCenter;

    
    
        if ([toViewController isKindOfClass:[NSClassFromString(@"LandscapeLeftViewController") class]]) {
           toView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }else{
            toView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }

   
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        toView.transform = CGAffineTransformIdentity;
        toView.bounds = containerView.bounds;
        toView.center = containerView.center;
    } completion:^(BOOL finished) {
          [transitionContext completeTransition:YES];
    }];
}

@end

