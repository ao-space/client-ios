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
//  ESAppMiniStopServiceCell.m
//  EulixSpace
//
//  Created by qu on 2023/8/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESAppMiniStopServiceCell.h"
#import "ESFormItem.h"
#import "ESLongTextInputView.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "UIColor+ESHEXTransform.h"
#import "ESCommonToolManager.h"
#import <Masonry/Masonry.h>
#import "UILabel+ESTool.h"
@interface ESAppMiniStopServiceCell()

@property (nonatomic, strong) UILabel *exitleLabel;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UIView *bgView;
@end


@implementation ESAppMiniStopServiceCell

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

    self.bgView = [[UIView alloc] init];
    [self.contentView addSubview:self.bgView];
    
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bgView.bounds
//                                                   cornerRadius:10.0];
//
//    // 创建一个形状图层
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.path = maskPath.CGPath;
//
//    // 设置视图的遮罩图层
//    self.bgView.layer.mask = maskLayer;
    
//
    self.bgView.backgroundColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
    
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.masksToBounds = YES;
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(0.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20.0f);;
        make.left.mas_equalTo(self.contentView.mas_left).offset(20.0f);
        make.height.mas_equalTo(120);
    }];
    
    
    [self.bgView addSubview:self.iconImageView];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(20);
        make.centerX.mas_equalTo(self.bgView.mas_centerX);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(50);
    }];
    
    self.exitleLabel = [[UILabel alloc] init];
    self.exitleLabel.font = [UIFont systemFontOfSize:14.0];
    self.exitleLabel.textColor = [UIColor grayColor];
    self.exitleLabel.textAlignment = NSTextAlignmentRight;
    self.exitleLabel.text = NSLocalizedString(@"application_view",@"若要查看统计数据，请先启动服务");
    [self.bgView addSubview:self.exitleLabel];
    
    [self.exitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.bgView.mas_centerX);
    }];

}


- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"no_data"];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

@end
