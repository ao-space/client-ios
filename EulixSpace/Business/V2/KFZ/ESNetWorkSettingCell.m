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
//  ESNetWorkSettingCell.m
//  EulixSpace
//
//  Created by qu on 2023/2/6.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESNetWorkSettingCell.h"

@interface ESNetWorkSettingCell()

@property (nonatomic, strong) UILabel *title1;

@property (nonatomic, strong) UILabel *title2;



@end


@implementation ESNetWorkSettingCell

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

    [self.title1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26);
        make.height.mas_equalTo(22);
       
    }];
    
    [self.title2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.height.mas_equalTo(22);
    }];
}

- (UILabel *)title1 {
    if (!_title1) {
        _title1 = [[UILabel alloc] init];
        _title1.text = NSLocalizedString(@"box_network_setup", @"网络设置");
        _title1.textColor = ESColor.labelColor;
        _title1.textAlignment = NSTextAlignmentLeft;
        _title1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.contentView addSubview:_title1];
    }
    return _title1;
}

- (UILabel *)title2 {
    if (!_title2) {
        _title2 = [[UILabel alloc] init];
        _title2.textColor = ESColor.labelColor;
        _title2.text = @"bridge";
        _title2.textAlignment = NSTextAlignmentLeft;
        _title2.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_title2];
    }
    return _title2;
}

@end
