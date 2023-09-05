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
//  ESListModel.h
//  EulixSpace
//
//  Created by qu on 2022/11/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+YYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESListModel : NSObject

@property (nonatomic, strong) NSNumber *opType;
@property (nonatomic, copy) NSNumber *currentTime;
@property (nonatomic, copy) NSString *recordCount;
@property (nonatomic, copy) NSString *recordId;
@property (nonatomic, copy) NSString *terminalType;
@property (nonatomic, copy) NSNumber *recordTime;
@property (nonatomic, strong) NSMutableArray *recordList;

@property (nonatomic, copy) NSString *fileType;

@end

NS_ASSUME_NONNULL_END
