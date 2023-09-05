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
//  ESFunctionView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFunctionView.h"
#import "ESFormItem.h"
#import "ESAppStoreModel.h"
#import "ESThemeDefine.h"
#import "ESCommonToolManager.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface ESFunctionView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UIImageView *loading;

@property (nonatomic, strong) UILabel *badge;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) ESFormItem *model;

@end

@implementation ESFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    if ([ESCommonToolManager isEnglish]) {
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(40);
        }];
    }else{
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
    }
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.mas_equalTo(self.contentView);
        make.height.width.mas_equalTo(40);
    }];
    
    [self.badge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.avatar.mas_right);
        make.centerY.mas_equalTo(self.avatar.mas_top);
        make.height.width.mas_equalTo(16);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.model = model;
    self.title.text = model.title;
    
    if(model.icon){
        self.avatar.image = model.icon;
    }else if (model.iconURL){
        [self.avatar es_setImageWithURL:model.iconURL placeholderImageName:@"V2_app_list_def"];
    } else{
        if([model.deployMode isEqual:@"service"]){
            [self.avatar es_setImageWithURL:model.iconUrl placeholderImageName:@"app_docker"];
        }else{
            [self.avatar es_setImageWithURL:model.iconUrl placeholderImageName:@"V2_app_list_def"];
        }
    }
    self.badge.hidden = model.badge == 0;
    self.badge.text = [NSString stringWithFormat:@"%zd", model.badge];
    
    if([self.classType isEqual:@"app"]){
        self.avatar.backgroundColor = ESColor.iconBg;
        self.avatar.layer.cornerRadius = 6;
        self.avatar.layer.masksToBounds = YES;
        
        if(model.state == ESINSTALLING){
            [self.avatar addSubview:self.maskView];
            [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.top.mas_equalTo(self.contentView);
                make.height.width.mas_equalTo(40);
            }];
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
            rotationAnimation.duration = 1.0;
            rotationAnimation.repeatCount = HUGE_VALF;
            // 执行动画
            
            CALayer *layer = self.loading.layer;
            [layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        }else if(model.state == ESINSTALLFAIL){
            self.loading.image = [UIImage imageNamed:@"V2_app_list_shibai"];
            CALayer *layer = self.loading.layer;
            [layer removeAnimationForKey:@"rotationAnimation"];
            self.title.textColor = ESColor.disableTextColor;
            [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.top.mas_equalTo(self.contentView);
                make.height.width.mas_equalTo(40);
            }];
            [self.loading mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.avatar);
                make.centerY.mas_equalTo(self.avatar);
                make.height.width.mas_equalTo(14);
            }];
        }else{
            self.title.textColor = ESColor.labelColor;
            [self.maskView removeFromSuperview];
            self.maskView = nil;
        }
    }
}

- (void)setBadgeNum:(int)num {
    self.badge.hidden = (num == 0);
    self.badge.text = [NSString stringWithFormat:@"%d", num];
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    return self;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.numberOfLines = 0;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_title];
    }
    return _title;
}


- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)badge {
    if (!_badge) {
        _badge = [[UILabel alloc] init];
        _badge.layer.cornerRadius = 8;
        _badge.layer.masksToBounds = YES;
        _badge.backgroundColor = ESColor.redColor;
        _badge.textColor = ESColor.lightTextColor;
        _badge.textAlignment = NSTextAlignmentCenter;
        _badge.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_badge];
    }
    return _badge;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.3];
        UIImageView *loading = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
        _maskView.frame = self.bounds;
        
        [self.avatar addSubview:_maskView];
        [self.avatar bringSubviewToFront:_maskView];
        [_maskView addSubview:loading];

        if(self.model.state == ESINSTALLFAIL){
            loading.image = [UIImage imageNamed:@"V2_app_list_shibai"];
            [loading mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.avatar);
                make.centerY.mas_equalTo(self.avatar);
                make.height.width.mas_equalTo(14);
            }];
        }else{
    
            loading.image = [UIImage imageNamed:@"V2_app_list_loading"];
            [loading mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.avatar);
                make.centerY.mas_equalTo(self.avatar);
                make.height.width.mas_equalTo(24);
            }];
        }
        self.loading = loading;
     
    }
    return _maskView;
}


@end
