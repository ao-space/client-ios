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
//  ESLoopOnline.m
//  EulixSpace
//
//  Created by qu on 2023/5/5.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESLoopOnline.h"
#import "ESBoxManager.h"
#import "ESCache.h"
#import "ESToast.h"

@implementation ESLoopOnline

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        [instance saveOffline];
    });
    return instance;
}

-(void)startOnlineLoop{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ESBoxManager checkBoxStateByDomain
         :^(BOOL offline) {
            NSString *cacheOfflineKey = [NSString stringWithFormat:@"%@offline",ESBoxManager.activeBox.boxUUID];
            NSNumber *offlinenNumber = [[ESCache defaultCache] objectForKey:cacheOfflineKey];
            if(!(offlinenNumber.boolValue == offline) && offline){
                [ESToast toastWarning: NSLocalizedString(@"onlineOff", @"设备离线，请检查设备或网络情况")];
                NSString *cacheOfflineKey = [NSString stringWithFormat:@"%@offline",ESBoxManager.activeBox.boxUUID];
                [[ESCache defaultCache] setObject:@(offline) forKey:cacheOfflineKey];
            }else if(!offline){
                NSString *cacheOfflineKey = [NSString stringWithFormat:@"%@offline",ESBoxManager.activeBox.boxUUID];
                [[ESCache defaultCache] setObject:@(offline) forKey:cacheOfflineKey];
            }
            [self startOnlineLoop];
        }];
    });
}

-(void)saveOffline{
    [ESBoxManager checkBoxStateByDomain:^(BOOL offline) {
        NSString *cacheOfflineKey = [NSString stringWithFormat:@"%@offline",ESBoxManager.activeBox.boxUUID];
        [[ESCache defaultCache] setObject:@(offline) forKey:cacheOfflineKey];
    }];

}
@end
