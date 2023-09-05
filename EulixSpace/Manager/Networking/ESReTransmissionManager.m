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
//  ESReTransmissionManager.m
//  EulixSpace
//
//  Created by dazhou on 2022/6/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESReTransmissionManager.h"

@interface ESTransModel : NSObject
// 上传次数
@property (nonatomic, assign) int transNum;

@property (nonatomic, assign) int failedNums;
@property (nonatomic, assign) NSTimeInterval failedTime;
@end

@implementation ESTransModel
- (instancetype)init {
    if (self = [super init]) {
        _transNum = 0;
    }
    return self;
}
@end

@interface ESReTransmissionManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, ESTransModel *> * eventDict;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation ESReTransmissionManager

+ (instancetype)Instance {
    static dispatch_once_t once = 0;
    static id instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _eventDict = [NSMutableDictionary dictionary];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addTransmission:(NSString *)key {
    if (!key || key.length == 0) {
        return;
    }
    
    ESTransModel * model = [self getTransModel:key];
    model.transNum ++;
}

- (BOOL)canTrans:(NSString *)key max:(int)maxNum increment:(BOOL)increment {
    if (!key || key.length == 0) {
        return NO;
    }
    
    ESTransModel * model = [self getTransModel:key];
    
    if (model.transNum >= maxNum) {
        return NO;
    }
    if (increment) {
        model.transNum ++;
    }
    return YES;
}

- (void)removeTransission:(NSString *)key {
    if (!key || key.length == 0) {
        return;
    }
    [self.eventDict removeObjectForKey:key];
}

- (ESTransModel *)getTransModel:(NSString *)key {
    if (key == nil) {
        return nil;
    }
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    ESTransModel * model = self.eventDict[key];
    if (!model) {
        model = [[ESTransModel alloc] init];
        self.eventDict[key] = model;
    }
    dispatch_semaphore_signal(self.semaphore);
    return model;
}

- (int)addFailedEvent:(NSString *)key distance:(int)distance max:(int)max {
    ESTransModel * model = [self getTransModel:key];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - model.failedTime >= distance) {
        model.failedNums = 1;
        model.failedTime = now;
    } else {
        model.failedNums ++;
    }
    
    if (model.failedNums >= max) {
        return 0;
    }
    
    return max - model.failedNums;
}

- (BOOL)failedEventIsResume:(NSString *)key distance:(int)distance {
    return [self failedEventIsResume:key distance:distance max:3];
}

- (BOOL)failedEventIsResume:(NSString *)key distance:(int)distance max:(int)max {
    ESTransModel * model = [self getTransModel:key];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - model.failedTime > distance || model.failedNums < max) {
        return YES;
    }
    return NO;
}

@end
