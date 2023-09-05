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
//  ESToast.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/6.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESToast : UIView

+ (void)toastInfo:(NSString *)info;
+ (void)toastInDarkStyleInfo:(NSString *)info;

+ (void)toastSuccess:(NSString *)success;
+ (void)toastSuccess:(NSString *)success handle:(void (^)(void))handler;

+ (void)toastError:(NSString *)error;

+ (void)toastWarning:(NSString *)warning;

+ (void)dismiss;

+ (void)setDefaultTheme;

@property (class, nonatomic, readonly) ESToast * (^info)(NSString *info);

@property (class, nonatomic, readonly) ESToast * (^networkError)(NSString *error);

@property (nonatomic, readonly) ESToast * (^delay)(NSTimeInterval delay);

@property (nonatomic, readonly) ESToast * (^show)(void);

@property (class, nonatomic, readonly) ESToast * (^waiting)(NSString *info);

@property (nonatomic, readonly) ESToast * (^showFrom)(UIView *holder);

@property (nonatomic, class, readonly) ESToast * (^showLoading)(NSString *info, UIView *formView);

@property (nonatomic, class, readonly) ESToast * (^showInfo)(NSString *info, UIView *formView);

+ (void)dismissInfo;

+ (void)toastServiceError;
+ (void)toastWaitView:(UIView *)fromView;
@end


