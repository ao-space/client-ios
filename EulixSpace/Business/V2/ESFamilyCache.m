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
//  ESFamilyCache.m
//  EulixSpace
//
//  Created by danjiang on 2023/4/24.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESFamilyCache.h"
#import "ESCache.h"
#import "ESAccountServiceApi.h"
#import "ESSpaceAccountAdminInviteServiceApi.h"
#import "ESCommonToolManager.h"
#import "ESLocalPath.h"
#import "ESBoxManager.h"


#import "ESAccountManager.h"

@interface ESFamilyCache()

@end


@implementation ESFamilyCache
static ESFamilyCache *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void)getFamilyListFirstCache {
    ESAccountServiceApi *api = [[ESAccountServiceApi alloc] init];
    [api spaceV1ApiMemberListGetWithCompletionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
        if (!error) {
            ESResponseBaseArrayListAccountInfoResult *data = output;
            NSArray<ESAccountInfoResult> *results = data.results;
           // self.dataSource = results;
   
            NSMutableArray *arrayNew = [NSMutableArray new];
            NSArray *array = [NSArray new];
            array = results;
            // 1.创建一个串行队列，保证for循环依次执行
            dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

            // 2.异步执行任务
            dispatch_async(serialQueue, ^{
                // 3.创建一个数目为1的信号量，用于“卡”for循环，等上次循环结束在执行下一次的for循环
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);

                for (int i = 0; i < array.count; i++) {
                    // 开始执行for循环，让信号量-1，这样下次操作须等信号量>=0才会继续,否则下次操作将永久停止
                    ESAccountInfoResult *info = array[i];
                    [[ESAccountManager manager] loadAvatar:info.aoId
                                                    completion:^(NSString *path) {
                                                        info.headImagePath = path.shareCacheFullPath;
                                                        [arrayNew addObject:info];
                                                        dispatch_semaphore_signal(sema);
                             
                    }];
                    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                }
   
                if(arrayNew.count == array.count){
                    NSArray<ESAccountInfoResult> *arrayResult = [NSArray arrayWithArray:arrayNew];
                    ESBoxManager.activeBox.results = arrayResult;
                }
            });
        }
    }];
}


- (void)getFamilyListFirstCache:(void (^)(void))completion {
    ESAccountServiceApi *api = [[ESAccountServiceApi alloc] init];
    [api spaceV1ApiMemberListGetWithCompletionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
        if (!error) {
            ESResponseBaseArrayListAccountInfoResult *data = output;
            NSArray<ESAccountInfoResult> *results = data.results;
           // self.dataSource = results;
   
            NSMutableArray *arrayNew = [NSMutableArray new];
            NSArray *array = [NSArray new];
            array = results;
            // 1.创建一个串行队列，保证for循环依次执行
            dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

            // 2.异步执行任务
            dispatch_async(serialQueue, ^{
                // 3.创建一个数目为1的信号量，用于“卡”for循环，等上次循环结束在执行下一次的for循环
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);

                for (int i = 0; i < array.count; i++) {
                    // 开始执行for循环，让信号量-1，这样下次操作须等信号量>=0才会继续,否则下次操作将永久停止
                    ESAccountInfoResult *info = array[i];
                    [[ESAccountManager manager] loadAvatar:info.aoId
                                                    completion:^(NSString *path) {
                                                        info.headImagePath = path.shareCacheFullPath;
                                                        [arrayNew addObject:info];
                                                        dispatch_semaphore_signal(sema);
                             
                    }];
                    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                }
   
                if(arrayNew.count == array.count){
                    NSArray<ESAccountInfoResult> *arrayResult = [NSArray arrayWithArray:arrayNew];
                    if (completion && arrayResult.count > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion();
                        });
                    }
                    ESBoxManager.activeBox.results = arrayResult;
                }
            });
        }
    }];
}


-(void)saveFamilyList:(NSArray<ESAccountInfoResult> *)results{
    ESBoxManager.activeBox.results = results;
}

@end
