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
//  ESFormCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/14.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFormCell.h"
#import "ESGlobalMacro.h"
#import <Masonry/Masonry.h>

@interface ESFormCell ()

@property (nonatomic, strong) ESFormView *form;

@end

@implementation ESFormCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.form mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    [self.form reloadWithData:model];
}

#pragma mark - Lazy Load

- (ESFormView *)form {
    if (!_form) {
        _form = [[ESFormView alloc] init];
        [self.contentView addSubview:_form];
        weakfy(self);
        _form.actionBlock = ^(id action) {
            strongfy(self);
            if (self.actionBlock) {
                self.actionBlock(action);
            }
        };
    }
    return _form;
}

@end
