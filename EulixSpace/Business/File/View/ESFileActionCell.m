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
//  ESFileActionCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileActionCell.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESFileActionCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *title;

@end

@implementation ESFileActionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    //    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(self.contentView).inset(28);
    //        make.width.height.mas_equalTo(36);
    //        make.centerX.mas_equalTo(self.contentView);
    //    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).inset(0.5);
    }];
}

- (void)reloadWithData:(ESFormItem *)item {
    self.title.text = item.title;
    //    self.icon.image = [UIImage imageNamed:item.icon];
    //    if (item.type == ESFileViewSelectionModeIn) {
    //        self.contentView.backgroundColor = item.selected ? ESColor.linkColor : ESColor.systemBackgroundColor;
    //    } else {
    //        self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    //    }
}

#pragma mark - Lazy Load

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:14];
        _title.layer.borderColor = ESColor.secondaryLabelColor.CGColor;
        _title.layer.borderWidth = 1;
        _title.layer.masksToBounds = YES;
        _title.layer.cornerRadius = 3;

        [self.contentView addSubview:_title];
    }
    return _title;
}

@end
