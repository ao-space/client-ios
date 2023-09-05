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
//  ESTrailOnLineManager.m
//  EulixSpace
//
//  Created by KongBo on 2023/4/24.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESTrailOnLineManager.h"
#import "ESBoxListViewController.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESBoxManager.h"
#import "ESCache.h"

FOUNDATION_EXTERN NSNotificationName const ESUserInvaliedNotification;

@interface ESTrailOnLineManager ()

@property (nonatomic, assign) BOOL userInvaliedCheckOn;
@property (nonatomic, assign) BOOL noShowDialog;
@property (nonatomic, assign) BOOL tryShowDialog;

@end

static NSString * const ESTrailInvailedDomainList = @"ESTrailInvailedDomainList";

@implementation ESTrailOnLineManager

+ (instancetype)shareInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startService {
    ESDLog(@"[ESTrailOnLineManager] startService");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usereInvalied:) name:ESUserInvaliedNotification object:nil];
    self.tryShowDialog = YES;
}

- (void)usereInvalied:(NSNotification *)notification {
    ESDLog(@"[ESTrailOnLineManager] usereInvalied notification  isOnlineTrialBox:%d  tryShowDialog:%d", [ESBoxManager.activeBox.deviceAbilityModel isOnlineTrialBox], self.tryShowDialog);
    weakfy(self)
    if ([ESBoxManager.activeBox.deviceAbilityModel isOnlineTrialBox] && self.tryShowDialog) {
        [self cacheInvaliedUserDomain];
        ESPerformBlockAsynOnMainThread(^{
            strongfy(self)
            if ([self noShowDialog]) {
                self.tryShowDialog = NO;
                [self trailInvailed];
                ESDLog(@"[ESTrailOnLineManager] trailInvailed");
                ESPerformBlockAfterDelay(5, ^{
                    self.tryShowDialog = YES;
                });
            }
        });
    }
}

- (NSArray<NSString *> * _Nullable)cacheInvaliedUserDomainList {
    NSArray *list = [[ESCache defaultCache] objectForKey:ESTrailInvailedDomainList];
    return list;
}

- (void)cacheInvaliedUserDomain {
    NSArray *list = [[ESCache defaultCache] objectForKey:ESTrailInvailedDomainList];
    NSMutableArray *mulList = [NSMutableArray array];
    if (list.count > 0) {
        mulList = [list mutableCopy];
    }
    if (![mulList containsObject:ESSafeString(ESBoxManager.activeBox.uniqueKey)]) {
        [mulList addObject:ESSafeString(ESBoxManager.activeBox.uniqueKey)];
        [[ESCache defaultCache] setObject:mulList forKey:ESTrailInvailedDomainList];
    }
    ESDLog(@"[ESTrailOnLineManager] cacheInvaliedUserDomain %@", mulList);
}

- (BOOL)noShowDialog {
    UIViewController *currentVC = [UIWindow getCurrentVC];
    ESDLog(@"[ESTrailOnLineManager] check noShowDialog  currentVC： %@", currentVC);

    if([currentVC isKindOfClass:[ESBoxListViewController class]]){
        if ([(ESBoxListViewController *)currentVC showTrailUnvalied]) {
            ESDLog(@"[ESTrailOnLineManager] showTrailUnvalied");
            return NO;
        }
    }
    return YES;
}

- (void)trailInvailed {
    ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
//    boxVC.sourceVC = @"delectMember";
    boxVC.showTrailUnvalied = YES;
    UIViewController *currentVC = [UIWindow getCurrentVC];
    if([currentVC isKindOfClass:[ESBoxListViewController class]]){
        NSMutableArray *vcList = [currentVC.navigationController.viewControllers mutableCopy];
        [vcList removeLastObject];
        [vcList addObject:boxVC];
        [currentVC.navigationController setViewControllers:[vcList copy] animated:NO];
    }
    ESPerformBlockOnMainThread(^{
        [currentVC.navigationController pushViewController:boxVC animated:YES];
    });
    return;
}

@end
