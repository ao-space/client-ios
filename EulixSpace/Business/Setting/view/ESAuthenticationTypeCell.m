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
//  ESAuthenticationTypeCell.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/14.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthenticationTypeCell.h"

@interface ESAuthenticationTypeCell()
@property (nonatomic, strong) UILabel * mTitleLabel;
@property (nonatomic, strong) UILabel * mContentLabel;
@property (nonatomic, strong) UIImageView * hintIv;
@end

@implementation ESAuthenticationTypeCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setModel:(ESAuthenticationTypeModel *)model {
    _model = model;
    self.mTitleLabel.text = model.title;
    self.mContentLabel.text = model.content;
    self.hintIv.image = [UIImage imageNamed:model.imageName];
}

- (void)initViews {
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor es_colorWithHexString:@"#EDF3FF"];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 10;
    [self.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).mas_offset(UIEdgeInsetsMake(10, 10, 0, 10));
    }];
    
    UIImageView * iv = [[UIImageView alloc] init];
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.left.mas_equalTo(view).offset(40);
        make.top.mas_equalTo(view).mas_offset(@(35));
        make.bottom.mas_equalTo(view).mas_offset(@(-35));
    }];
    self.hintIv = iv;
    
    UILabel * typeLabel = [[UILabel alloc] init];
    typeLabel.textColor = [UIColor es_colorWithHexString:@"#85899C"];
    typeLabel.font = ESFontPingFangMedium(14);
    [view addSubview:typeLabel];
    self.mTitleLabel = typeLabel;
    
    [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iv.mas_right).offset(30);
        make.top.mas_equalTo(iv);
    }];
    
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor es_colorWithHexString:@"#333333"];
    titleLabel.font = ESFontPingFangMedium(18);
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [view addSubview:titleLabel];
    self.mContentLabel = titleLabel;
    
    UIImageView * arrowiv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_arrow"]];
    [view addSubview:arrowiv];
    [arrowiv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16);
        make.right.mas_equalTo(view).offset(-20);
        make.centerY.mas_equalTo(view);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iv.mas_right).offset(30);
        make.right.mas_equalTo(arrowiv.mas_left).offset(-10);
        make.bottom.mas_equalTo(iv);
    }];
}



@end
