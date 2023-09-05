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
//  UIWindow.h
//  EulixSpace
//
//  Created by qu on 2021/9/1.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//
#import "UIWindow+topViewController.h"

@implementation UIWindow (topViewController)

- (UIViewController *)topViewController {
    UIViewController *topViewController = self.rootViewController;
    if ([topViewController isKindOfClass:[UITabBarController class]]) {
        if ([(UITabBarController *)topViewController selectedViewController]) {
            topViewController = [(UITabBarController *)topViewController selectedViewController];
        } else {
            if (topViewController.presentedViewController) {
                topViewController = topViewController.presentedViewController;
            }
        }
    }

    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        topViewController = [(UINavigationController *)topViewController visibleViewController];
    }
    while (topViewController.presentedViewController) { //若存在从tabbar直接present的控制器，此处需继续向上层递进查找
        topViewController = topViewController.presentedViewController;
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            topViewController = [(UINavigationController *)topViewController visibleViewController];
        }
    }
    if (topViewController.isBeingDismissed || topViewController.navigationController.isBeingDismissed) { //顶层控制器正在dimiss，获取下层控制器
        if (topViewController.navigationController.presentingViewController) {
            topViewController = topViewController.navigationController.presentingViewController;
        } else if (topViewController.presentingViewController) {
            topViewController = topViewController.presentingViewController;
        }

        //若下层控制器是tabbar，获取当前选中项的可见控制器
        if ([topViewController isKindOfClass:[UITabBarController class]]) {
            topViewController = [(UITabBarController *)topViewController selectedViewController];
        }
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            topViewController = [(UINavigationController *)topViewController visibleViewController];
        }
    }
    return topViewController;
}

@end
