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
//  ESAppUpdatingNotificationVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppUpdatingNotificationVC.h"

@interface ESAppUpdatingNotificationVC ()

@end

@implementation ESAppUpdatingNotificationVC

+ (void)showNotification {
    ESTopNotificationVC * vc = [ESTopNotificationVC notificationWithTitle:@"正在安装系统" message:@"系统安装期间，傲空间设备可能无法正常访问，升级完后将自动恢复使用。"];
    [vc setIconImageWithName:@"update_notitication_icon"];
    vc.tapBlock = ^() {
        
    };
    [vc show];
}

@end
