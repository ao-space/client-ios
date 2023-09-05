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
//  ESBaseCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseCell.h"

@interface ESBaseCell ()

@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation ESBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupBaseViews];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupBaseViews];
    }
    return self;
}

- (void)setupBaseViews {
    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).inset(1);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).inset(26.0f);
        make.leading.mas_equalTo(self.contentView.mas_leading).inset(26.0f);
        make.height.mas_equalTo(1);
    }];
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = [self separatorLineColor];
    }
    return _bottomLine;
}

- (UIColor *)separatorLineColor {
    return ESColor.separatorColor;
}

- (void)hiddenSeparatorStyleSingleLine:(BOOL)hidden {
    self.bottomLine.hidden = hidden;
}

- (void)bindData:(id)data {
    
}

@end
