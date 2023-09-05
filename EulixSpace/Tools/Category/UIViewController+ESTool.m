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
//  UIViewController+ESTool.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UIViewController+ESTool.h"

@implementation UIViewController (ESTool)


- (void)showAlert:(NSString *)message {
    [self showAlert:message handle:nil];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    [self showAlert:title message:message handle:nil];
}

- (void)showAlert:(NSString *)message handle:(void (^ __nullable)(void))handler {
    [self showAlert:NSLocalizedString(@"Tips", @"提示") message:message handle:handler];
}

- (void)showAlert:(NSString *)title message:(NSString *)message handle:(void (^ __nullable)(void))handler {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
//                                                                   message:message
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction * sure = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"确定")
//                                                    style:UIAlertActionStyleDefault
//                                                  handler:^(UIAlertAction * _Nonnull action) {
//        if (handler) {
//            handler();
//        }
//    }];
//    [alert addAction:sure];
//    [self presentViewController:alert animated:YES completion:nil];
    
    [self showAlert:title message:message optName:NSLocalizedString(@"ok", @"确定") handle:handler optName1:@"" handle1:nil];
}

- (void)showAlert:(NSString *)title
          message:(NSString *)message
          optName:(NSString *)optName
           handle:(void (^ __nullable)(void))handler
          optName1:(NSString *)optName1
           handle1:(void (^ __nullable)(void))handler1 {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if (optName.length > 0) {
        UIAlertAction * action = [UIAlertAction actionWithTitle:optName
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
            if (handler) {
                handler();
            }
        }];
        [alert addAction:action];
    }
    if (optName1.length > 0) {
        UIAlertAction * action = [UIAlertAction actionWithTitle:optName1
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
            if (handler1) {
                handler1();
            }
        }];
        [alert addAction:action];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}


+ (UIViewController *)es_getTopViewControler {
    //获取根控制器
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    UIViewController *parent = rootVC;
    //遍历 如果是presentViewController
    while ((parent = rootVC.presentedViewController) != nil ) {
        rootVC = parent;
    }
   
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    return rootVC;
}

@end
