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
//  ESDiskMainStorageCell.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDiskMainStorageCell.h"
#import "UIButton+ESTouchArea.h"

@implementation ESDiskMainStorageModel

- (instancetype)init {
    if (self = [super init]) {
        self.diskInfoList = [NSMutableArray array];
    }
    return self;
}

@end


@interface ESDiskMainStorageCell()
@property (nonatomic, strong) UILabel * mTitleLabel;
@property (nonatomic, strong) UIView * lineView;
@property (nonatomic, weak) UIButton * selectBtn;
@property (nonatomic, weak) UIImageView * recommendIv;

@end
@implementation ESDiskMainStorageCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setModel:(ESDiskMainStorageModel *)model {
    _model = model;
    self.mTitleLabel.text = model.title;
    self.lineView.hidden = model.lastCell;
    self.recommendIv.hidden = !model.isRecommend;
    NSString * imName = model.isSelected ? @"select" : @"unSelect";
    [self.selectBtn setImage:[UIImage imageNamed:imName] forState:UIControlStateNormal];
}

- (void)setTitleColor:(UIColor *)color {
    self.mTitleLabel.textColor = color;
}

- (void)initViews {
    UILabel * label = [[UILabel alloc] init];
    label.font = ESFontPingFangRegular(16);
    label.textColor = [UIColor es_colorWithHexString:@"#333333"];
    [self.contentView addSubview:label];
    self.mTitleLabel = label;
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [self.contentView addSubview:lineView];
    self.lineView = lineView;
    
    [self.mTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(26);
        make.top.mas_equalTo(self.contentView).offset(19);
        make.bottom.mas_equalTo(self.contentView).offset(-19);
    }];
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommend"]];
    [self.contentView addSubview:iv];
    self.recommendIv = iv;
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mTitleLabel.mas_trailing).offset(10);
        make.centerY.mas_equalTo(self.mTitleLabel);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(26);
        make.trailing.mas_equalTo(self.contentView).offset(-26);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView).offset(-26);
        make.top.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(30);
    }];
    [self.selectBtn setEnlargeEdge:UIEdgeInsetsMake(10, 10, 10, 10)];
}


- (void)onSelectBtn {
    if (self.model.onClick) {
        self.model.onClick();
    }
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn addTarget:self action:@selector(onSelectBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _selectBtn = btn;
    }
    return _selectBtn;
}

@end
