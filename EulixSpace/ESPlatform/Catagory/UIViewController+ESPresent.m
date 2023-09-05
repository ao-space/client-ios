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
//  UIViewController+ESPresent.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UIViewController+ESPresent.h"
#import "NSObject+ESAOP.h"
#import <objc/runtime.h>
#import "ESColor.h"

@implementation UIViewController (ESPresent)

- (void)es_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion {
    if (!self.es_presentBackgroudMaskView) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        maskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.0];
        [self.view addSubview:maskView];
        [viewControllerToPresent setEs_presentBackgroudMaskView:maskView];
        
        [UIView animateWithDuration:0.5 animations:^{
            maskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.5];
        }];
    }
    
    [self presentViewController:viewControllerToPresent animated:flag completion:^{
        UIView *tapMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
        tapMaskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.06];
        [viewControllerToPresent.view insertSubview:tapMaskView atIndex:0];
        [viewControllerToPresent setEs_presentBackgroudTapMaskView:tapMaskView];

        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:viewControllerToPresent action:@selector(cancel:)];
        [tapMaskView addGestureRecognizer:tapGes];
        if(completion) {
            completion();
        }
    }];
}

- (void)es_dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion {
    if (self.es_presentBackgroudMaskView) {
        __weak typeof(self) weakSelf  = self;
        [UIView animateWithDuration:0.5 animations:^{
            __strong typeof(weakSelf) self = weakSelf;
            self.es_presentBackgroudMaskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.0];
            [self.es_presentBackgroudMaskView removeFromSuperview];
            self.es_presentBackgroudMaskView = nil;
        }];
    }
    if (self.es_presentBackgroudTapMaskView) {
        self.es_presentBackgroudTapMaskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.0];
    }

    [self dismissViewControllerAnimated:flag completion:completion];
}

- (UIView *)es_presentBackgroudMaskView {
    return objc_getAssociatedObject(self, @selector(es_presentBackgroudMaskView));
}

- (void)setEs_presentBackgroudMaskView:(UIView *)maskView {
    objc_setAssociatedObject(self, @selector(es_presentBackgroudMaskView),
                             maskView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)es_presentBackgroudTapMaskView {
    return objc_getAssociatedObject(self, @selector(es_presentBackgroudTapMaskView));
}

- (void)setEs_presentBackgroudTapMaskView:(UIView *)tapMaskView {
    objc_setAssociatedObject(self, @selector(es_presentBackgroudTapMaskView),
                             tapMaskView, OBJC_ASSOCIATION_ASSIGN);
}

- (void)cancel:(UITapGestureRecognizer *)tapGes {
    self.es_presentBackgroudTapMaskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.0];
    [self es_dismissViewControllerAnimated:YES completion:nil];
}

@end



