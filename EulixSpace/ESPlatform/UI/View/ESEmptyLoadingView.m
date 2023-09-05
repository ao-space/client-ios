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
//  ESEmptyLoadingView.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/18.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESEmptyLoadingView.h"

@interface ESEmptyLoadingView ()

@property (nonatomic, strong) UIImageView *loadingRotateImage;
@property (nonatomic, strong) UILabel *messgaeLable;

@end

@implementation ESEmptyLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self startAnimation];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.loadingRotateImage];
    [self.loadingRotateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(180.0f);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self addSubview:self.messgaeLable];
    [self.messgaeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loadingRotateImage.mas_bottom).offset(20.0f);
        make.left.mas_equalTo(self.mas_left).offset(26.0f);
        make.right.mas_equalTo(self.mas_right).offset(-26.0f);
        make.height.mas_equalTo(20.0f);
    }];
}

- (UIImageView *)loadingRotateImage {
    if (!_loadingRotateImage) {
        _loadingRotateImage = [UIImageView new];
        _loadingRotateImage.animationDuration = 1;
        _loadingRotateImage.image = [UIImage imageNamed:@"es_empty_loading"];
    }
    return _loadingRotateImage;
}

- (UILabel *)messgaeLable {
    if (!_messgaeLable) {
        _messgaeLable = [[UILabel alloc] init];
        _messgaeLable.textColor = ESColor.secondaryLabelColor;
        _messgaeLable.textAlignment = NSTextAlignmentCenter;
        _messgaeLable.font = ESFontPingFangRegular(12);
    }
    return _messgaeLable;
}

- (void)startAnimation  {
   CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 1;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [self.loadingRotateImage.layer addAnimation:animation forKey:nil];
}

- (void)stopAnimation {
    [self.loadingRotateImage.layer removeAllAnimations];
}
@end






