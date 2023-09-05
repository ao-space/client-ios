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
//  ESTransferProgress.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/2.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESTransferProgress.h"
#import "ESFileDefine.h"

@interface ESTransferProgress ()

// 这次写入的数量
@property (nonatomic, assign) int64_t bytes;
// 已传输的数量
@property (nonatomic, assign) int64_t totalBytes;
// 文件的总大小
@property (nonatomic, assign) int64_t totalBytesExpected;
// 传输进度
@property (nonatomic, assign) CGFloat progress;
// 传输速度
@property (nonatomic, assign) CGFloat speed;

@property (nonatomic, assign) NSTimeInterval modifyTimestamp;

@property (nonatomic, assign) int64_t previoustotalBytes;

@property (nonatomic, strong) NSMutableArray * fragmentSpeedList;
@end



@implementation ESTransferProgress

- (instancetype)init {
    if (self = [super init]) {
        self.fragmentSpeedList = [NSMutableArray array];
    }
    return self;
}

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[
        @"fragmentSpeedList"
    ];
}

- (BOOL)onUpdateProgress:(int64_t)bytes
              totalBytes:(int64_t)totalBytes
      totalBytesExpected:(int64_t)totalBytesExpected {
    if (totalBytesExpected <= 0) {
        return NO;
    }
    self.bytes = bytes;
    self.totalBytes = totalBytes;
    self.totalBytesExpected = totalBytesExpected;
    self.progress = totalBytes * 1.0 / totalBytesExpected;
    NSTimeInterval current = NSDate.date.timeIntervalSinceReferenceDate;
    if (self.modifyTimestamp == 0) {
        self.modifyTimestamp = current;
        return YES;
    }
    NSTimeInterval interval = current - self.modifyTimestamp;
    if (totalBytes < self.previoustotalBytes) {
        self.previoustotalBytes = 0;
    }
    if (interval > 1 || totalBytes == totalBytesExpected) {
        self.speed = (self.totalBytes - self.previoustotalBytes) / interval;
        self.modifyTimestamp = current;
        self.previoustotalBytes = self.totalBytes;
        return YES;
    }
    return NO;
}

- (void)addFragmentSpeed:(float)speed {
    [self.fragmentSpeedList addObject:@(speed)];
}

- (NSString *)getTaskSpeed:(int)concurrent {
    CGFloat speed = self.speed;
    if (self.fragmentSpeedList.count > 0) {
        __block CGFloat totalSpeed = 0;
        __block int num = 0;
        [self.fragmentSpeedList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            totalSpeed += [obj floatValue];
            num ++;
            if (num >= concurrent) {
                *stop = YES;
            }
        }];
        
        speed = totalSpeed;
    }
    if (speed > 0) {
        return [NSString stringWithFormat:@"%@/s", FileSizeString(speed, YES)];
    }
    return @"";
}

@end
