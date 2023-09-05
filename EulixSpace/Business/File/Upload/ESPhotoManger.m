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
//  ESPhotoManger.m
//  EulixSpace
//
//  Created by qu on 2021/9/5.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPhotoManger.h"

@implementation ESPhotoManger

+ (ESPhotoManger *)standardPhotoManger {
    static ESPhotoManger *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ESPhotoManger alloc] init];
    });

    return manager;
}

#pragma mark - Set方法
- (void)setMaxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
    self.photoModelList = [NSMutableArray array];
    self.choiceCount = 0;
}

- (void)setChoiceCount:(NSInteger)choiceCount {
    _choiceCount = choiceCount;
    if (self.choiceCountChange) {
        self.choiceCountChange(choiceCount);
    }
}

@end
