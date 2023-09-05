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
//  ESTransferListBtn.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTransferListBtn.h"
#import "ESTransferListViewController.h"
#import "ESTransferManager.h"
#import "Reachability.h"
#import "ESLocalNetworking.h"
#import "ESBoxManager.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESImageDefine.h"

@interface ESTransferListBtn ()<ESLocalNetworkingStatusProtocol>

@property (nonatomic, strong) UIImageView *transferRotateImage;
@property (nonatomic, strong) UILabel *numLable;
@property (nonatomic, strong) UIView *transferListNumView;

@end

@implementation ESTransferListBtn

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(didClickTransferListBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self setupViews];
        [[ESLocalNetworking shared] addLocalNetworkStatusObserver:self];
    }
    return self;
}
- (void)setupViews {
    [self addSubview:self.transferRotateImage];
    [self.transferRotateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(self);
    }];

    self.transferListNumView.hidden = YES;
    [self.transferListNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(8.0f);
        make.left.mas_equalTo(self.mas_right).offset(-16.0f);
        make.height.mas_equalTo(13.0f);
        make.width.mas_greaterThanOrEqualTo(13.0f);
    }];
}

/// 传输列表
- (void)didClickTransferListBtn:(UIButton *)transferListBtn {
    ESTransferListViewController *next = [ESTransferListViewController new];
    [UIWindow.visibleViewController.navigationController pushViewController:next animated:YES];
}

- (UIImageView *)transferRotateImage {
    if (!_transferRotateImage) {
        _transferRotateImage = [UIImageView new];
        _transferRotateImage.hidden = YES;
        _transferRotateImage.animationDuration = 1;
    }
    return _transferRotateImage;
}

- (UIView *)transferListNumView {
    if (!_transferListNumView) {
        _transferListNumView = [[UIView alloc] init];
        _transferListNumView.backgroundColor = ESColor.redColor;
        _transferListNumView.layer.masksToBounds = YES;
        _transferListNumView.layer.cornerRadius = 6.5;
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.textColor = ESColor.lightTextColor;
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLable = numLabel;
        [_transferListNumView addSubview:numLabel];
        [self addSubview:_transferListNumView];
        
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_transferListNumView);
            make.height.mas_equalTo(13);
            make.width.mas_equalTo(_transferListNumView);
        }];
    }
    return _transferListNumView;
}

- (void)localNetworkReachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    ESPerformBlockOnMainThread(^{
        NSString * name = [ESLocalNetworking getConnectionImageName];
        [self setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    });
}

- (void)localNetworkUnreachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    ESPerformBlockOnMainThread(^{
        NSString * name = [ESLocalNetworking getConnectionImageName];
        [self setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    });
}


- (void)refreshStatus {
    NSString * name = [ESLocalNetworking getConnectionImageName];
    [self setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    if (ESLocalNetworking.shared.reachableBox) {
//        [self setBackgroundImage:IMAGE_MAIN_TRANSFER_LAN forState:UIControlStateNormal];
        [self.transferRotateImage setImage:IMAGE_MAIN_ROTATE_LAN];
    } else {
//        [self setBackgroundImage:IMAGE_MAIN_TRANSFER_INTERNET forState:UIControlStateNormal];
       //[self.transferRotateImage setImage:IMAGE_MAIN_ROTATER_INTERNET];
    }
    weakfy(self);
    [ESTransferManager manager].taskCountBlock = ^(NSInteger count) {
        strongfy(self);
        if (count > 0) {
            self.transferListNumView.hidden = NO;
            self.transferRotateImage.hidden = NO;
            [self startAnimation];
            if (count > 99) {
                self.numLable.text = [NSString stringWithFormat:@"99+"];
            } else {
                self.numLable.text = [NSString stringWithFormat:@"%ld", (long)count];
            }
        } else {
            self.transferListNumView.hidden = YES;
            [self.transferRotateImage.layer removeAllAnimations];
            self.transferRotateImage.hidden = YES;
        }
    };

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
    [self.transferRotateImage.layer addAnimation:animation forKey:nil];
}

@end
