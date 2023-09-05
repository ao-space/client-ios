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
//  ESCellModel.m
//  EulixSpace
//
//  Created by qu on 2023/1/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDeveloInfo.h"
#import "UIColor+ESHEXTransform.h"

@implementation ESDeveloInfo

- (instancetype)init {
    if (self = [super init]) {
        self.valueColor = [UIColor es_colorWithHexString:@"#85899C"];
        self.placeholderValueColor = [UIColor es_colorWithHexString:@"#DFE0E5"];

    }
    return self;
}

@end


