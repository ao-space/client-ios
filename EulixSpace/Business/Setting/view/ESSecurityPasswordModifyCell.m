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
//  ESSecurityPasswordModifyCell.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityPasswordModifyCell.h"

@interface ESSecurityPasswordModifyCell()

@end

@implementation ESSecurityPasswordModifyCell

- (void)setModel:(ESCellModel *)model {
    [super setModel:model];
    self.mTextField.text = model.inputValue;
    self.mTextField.placeholder = model.placeholderValue;
}

- (void)initViews {
    [super initViews];
    
    self.mTextField.enabled = YES;
    
    [self.mTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-26);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(150);
    }];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 0 && textField.text.length >= 6) {
        return NO;
    }
    
    return YES;
}

@end
