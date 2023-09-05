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
//  ESBetagCalculator.h
//  EulixSpace
//
//  Created by dazhou on 2023/3/1.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTransferTask.h"
#import "ESFileStreamOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESBetagCalculatorResult) {
    ESBetagCalculatorSuccess, // 计算完成
    ESBetagCalculatorFileNotExist, // 文件已丢失
};

@interface ESBetagCalculator : NSObject

// Asynchronous calculating betag
- (void)asyncCalBetag:(ESTransferTask *)task completed:(void(^)(ESBetagCalculatorResult result))block;

@end

NS_ASSUME_NONNULL_END
