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
//  ESShareBtnView.m
//  EulixSpace
//
//  Created by qu on 2022/6/14.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShareBtnView.h"

@implementation ESShareBtnView

- (void)initUI {
  
    [self.btnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(60.0f);
        make.width.mas_equalTo(60.0f);
    }];

    [self.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.btnImageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(20.0f);
    }];
    
}
@end
