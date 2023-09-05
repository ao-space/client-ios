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
// Created by Ye Tao on 2021/9/29.
// Copyright (c) 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

@interface ESAskAuthorization : NSObject

+ (instancetype)shared;

- (void)askAuthorizationPhotoLibrary:(UIViewController *)viewController completion:(void (^)(BOOL hasPermission))completion;

- (void)askAuthorizationLocationManager:(void (^)(BOOL hasFullPermissions))completion;

@end