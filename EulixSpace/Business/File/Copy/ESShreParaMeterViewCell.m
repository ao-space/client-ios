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
//  ESShreParaMeterViewCell.m
//  EulixSpace
//
//  Created by qu on 2022/6/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShreParaMeterViewCell.h"
#import "UIButton+Extension.h"
#import "ESShareView.h"
#import "ESCommonToolManager.h"
#import "ESColor.h"
#import "ESCopyMoveFolderListVC.h"
#import "ESShreParaMeterViewCell.h"
#import "ESShareApi.h"

@implementation ESShreParaMeterViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.mas_left).offset(39.0f);
        make.right.equalTo(self.mas_right).offset(-70.0f);

    }];
    self.iconImageView.hidden = YES;

}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        //_titleLabel.text = @"移动到“最近项目…";
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = IMAGE_SHARE_SELECTED;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)pointOutImageView {
    if (!_pointOutImageView) {
        _pointOutImageView = [[UIImageView alloc] init];
        _pointOutImageView.image = IMAGE_SHARE_PEO_NUM;
        [self addSubview:_pointOutImageView];
    }
    return _pointOutImageView;
}

-(void)setIsPointOut:(BOOL)isPointOut{
    if(isPointOut){

        if ([ESCommonToolManager isEnglish]) {
//            [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.mas_top).offset(20);
//                make.right.equalTo(self.mas_right).offset(-29.0f);
//                make.width.equalTo(@(24));
//                make.height.equalTo(@(24));
//            }];
            
            [self.pointOutImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_top).offset(28);
                make.left.equalTo(self.mas_left).offset(23.0f);
                make.width.equalTo(@(12));
                make.height.equalTo(@(12));
            }];
        }else{
//            [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.mas_top).offset(20);
//                make.right.equalTo(self.mas_right).offset(-29.0f);
//                make.width.equalTo(@(24));
//                make.height.equalTo(@(24));
//            }];
    
            [self.pointOutImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_top).offset(22);
                make.left.equalTo(self.mas_left).offset(23.0f);
                make.width.equalTo(@(12));
                make.height.equalTo(@(12));
            }];
        }
    }
}

@end
