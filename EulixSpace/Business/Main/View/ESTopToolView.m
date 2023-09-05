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
//  ESTopToolView.m
//  EulixSpace
//
//  Created by qu on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTopToolView.h"
#import "ESColor.h"
#import "ESImageDefine.h"
#import "ESSearchListVC.h"

#import "ESSearchBarView.h"
#import "ESLocalNetworking.h"
#import <SDCycleScrollView/SDCycleScrollView.h>

@interface ESTopToolView () <SDCycleScrollViewDelegate, ESLocalNetworkingStatusProtocol> {
    NSArray *kvDataArray;
}

/// 扫描二维码
@property (nonatomic, strong) UIButton *scanQRCodeBtn;
/// 传输列表
@property (nonatomic, strong) UIButton *transferListBtn;
///// 搜索框
//@property (nonatomic, strong) ESTopBar *searchBar;

@property (nonatomic, strong) ESSearchBarView *searchBar;

//@property (nonatomic, strong) UIImageView *newHandImageView;

@property (nonatomic, strong) UIButton *delectBtn;

@property (nonatomic, strong) UILabel *numLable;

@property (nonatomic, strong) UIView *transferListNumView;



@end

@implementation ESTopToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
        [ESLocalNetworking.shared addLocalNetworkStatusObserver:self];
    }
    return self;
}

- (void)localNetworkReachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    ESPerformBlockOnMainThread(^{
        NSString * name = [ESLocalNetworking getConnectionImageName];
        [self.transferListBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    });
}

- (void)localNetworkUnreachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    ESPerformBlockOnMainThread(^{
        NSString * name = [ESLocalNetworking getConnectionImageName];
        [self.transferListBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    });
}

-(void) reloadWithData {
    NSString * name = [ESLocalNetworking getConnectionImageName];
    [self.transferListBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    
    if(ESLocalNetworking.shared.reachableBox){
//        [self.transferListBtn setBackgroundImage:IMAGE_MAIN_TRANSFER_LAN forState:UIControlStateNormal];
        [self.transferRotateImage setImage:IMAGE_MAIN_ROTATE_LAN];
    }else{
//        [self.transferListBtn setBackgroundImage:IMAGE_MAIN_TRANSFER_INTERNET forState:UIControlStateNormal];
      //  [self.transferRotateImage setImage:IMAGE_MAIN_ROTATER_INTERNET];
    }
}

- (void)setNum:(NSInteger)num {
    self.transferListNumView.hidden = (num <= 0);
    NSString * text;
    if (num <= 0) {
        [self.transferRotateImage.layer removeAllAnimations];
        self.transferRotateImage.hidden = YES;
        return;
    }
    
    if (num > 99) {
        text = @"99+";
    } else {
        text = [NSString stringWithFormat:@"%ld", (long)num];
    }
    self.numLable.text = text;
    [self startAnimation];
    self.transferRotateImage.hidden = NO;
}


- (void)updateConstraints {
    [super updateConstraints];
//    self.backgroundColor = [ESColor secondarySystemBackgroundColor];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(22.0f);
        make.right.mas_equalTo(self.mas_right).offset(-127.0f);
        make.top.mas_equalTo(self.mas_top);
        make.height.mas_equalTo(46.0f);
    }];
    
    [self.transferRotateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.right.mas_equalTo(self.mas_right).offset(-14.0f);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];
    
    [self.transferListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-14.0f);
        make.centerY.mas_equalTo(self.searchBar.mas_centerY);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];
    
    [self.transferListNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferListBtn.mas_top).offset(8.0f);
        make.left.mas_equalTo(self.transferListBtn.mas_right).offset(-16.0f);
        make.height.mas_equalTo(13.0f);
        make.width.mas_greaterThanOrEqualTo(13.0f);
    }];
    
    [self bringSubviewToFront:self.transferListNumView];
    [self.scanQRCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchBar.mas_right).offset(15.0f);
        make.centerY.mas_equalTo(self.searchBar.mas_centerY);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];

//    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self).offset(0.0f);
//        make.left.mas_equalTo(self).offset(22.0f);
//        make.right.mas_equalTo(self.scanQRCodeBtn.mas_left).offset(-20.0f);
//        make.height.mas_equalTo(46.0f);
//    }];


}

#pragma mark - Lazy Load

//- (UIImageView *)newHandImageView {
//    if (!_newHandImageView) {
//        _newHandImageView = [UIImageView new];
//        _newHandImageView.image = IMAGE_MAIN_NEWHAND;
//        [self addSubview:_newHandImageView];
//        [_newHandImageView setUserInteractionEnabled:YES];
//        _newHandImageView.userInteractionEnabled = YES;
//
//        //给图片添加点击手势（也可以添加其他手势）
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectnewHandImageView)];
//        [_newHandImageView addGestureRecognizer:tap];
//    }
//    return _newHandImageView;
//}

//点击事件
- (void)selectnewHandImageView {
}

- (UIButton *)scanQRCodeBtn {
    if (nil == _scanQRCodeBtn) {
        _scanQRCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanQRCodeBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_scanQRCodeBtn addTarget:self action:@selector(didClickScanQRCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_scanQRCodeBtn setImage:IMAGE_MAIN_QRCODE forState:UIControlStateNormal];
        _scanQRCodeBtn.backgroundColor = [ESColor secondarySystemBackgroundColor];
        [self addSubview:_scanQRCodeBtn];
    }
    return _scanQRCodeBtn;
}

- (UIButton *)transferListBtn {
    if (nil == _transferListBtn) {
        _transferListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transferListBtn setBackgroundImage:[UIImage imageNamed:@"main_transfer_Internet"] forState:UIControlStateNormal];
        [_transferListBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_transferListBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_transferListBtn addTarget:self action:@selector(didClickTransferListBtn:) forControlEvents:UIControlEventTouchUpInside];
        //关键语句
        //_transferListBtn.backgroundColor = [ESColor secondarySystemBackgroundColor];
        [self addSubview:_transferListBtn];
    }
    return _transferListBtn;
}

- (UIImageView *)transferRotateImage {
    if (nil == _transferRotateImage) {
        _transferRotateImage = [UIImageView new];
        _transferRotateImage.hidden = YES;
        _transferRotateImage.animationDuration=1;
        [self addSubview:_transferRotateImage];
    }
    return _transferRotateImage;
}
    
    //旋转动画
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

- (void)didClickIntofileBtn:(UIButton *)transferListBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didIntoFileBtnClickButton:)]) {
        [self.delegate topToolView:self didIntoFileBtnClickButton:transferListBtn];
    }
}

- (void)didClicIntoPhotoBtn:(UIButton *)transferListBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didIntoPhotoBtnClickButton:)]) {
        [self.delegate topToolView:self didIntoPhotoBtnClickButton:transferListBtn];
    }
}

- (void)didClickintoOtherBtn:(UIButton *)transferListBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didIntoOtherBtnClickButton:)]) {
        [self.delegate topToolView:self didIntoOtherBtnClickButton:transferListBtn];
    }
}

- (void)didClickIntoVideoBtn:(UIButton *)transferListBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didIntoVideoBtnClickButton:)]) {
        [self.delegate topToolView:self didIntoVideoBtnClickButton:transferListBtn];
    }
}

- (ESSearchBarView *)searchBar {
    if (!_searchBar) {
//        _searchBar = [[ESSearchBarView alloc] init];
        _searchBar = [[ESSearchBarView alloc] initWithSearchDelegate:self];
        _searchBar.searchInput.userInteractionEnabled = NO;
        
//        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTapAction:)];
//        [_searchBar addGestureRecognizer:tapGes];
        
        [self addSubview:_searchBar];
        [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(22.0f);
            make.right.mas_equalTo(self.mas_right).offset(-127.0f);
            make.top.mas_equalTo(self.mas_top);
            make.height.mas_equalTo(46.0f);
        }];
        
        _searchBar.layer.masksToBounds = YES;
        _searchBar.placeholderName = TEXT_FILE_SEARCH_ALL;

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarTap:)];
        [_searchBar addGestureRecognizer:tapGesture];
//
//        [self addSubview:self.searchBar];
        self.searchBar = _searchBar;
    }
    return _searchBar;
}

- (UIView *)transferListNumView {
    if (!_transferListNumView) {
        _transferListNumView = [[UIView alloc] init];
        _transferListNumView.backgroundColor = ESColor.redColor;
        _transferListNumView.layer.masksToBounds = YES;
        _transferListNumView.layer.cornerRadius = 6.5;
        _transferListNumView.hidden = YES;
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.textColor = ESColor.lightTextColor;
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLable = numLabel;
        [_transferListNumView addSubview:numLabel];
        
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_transferListNumView);
            make.height.mas_equalTo(13);
            make.width.mas_equalTo(_transferListNumView);
        }];
        [self addSubview:_transferListNumView];
    }
    return _transferListNumView;
}

#pragma mark - *** 按钮点击事件 ***

- (void)didClickBoxTitleSelectBtn:(UIButton *)boxTitleSelectBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didScanboxTitleSelectClickButton:)]) {
        [self.delegate topToolView:self didScanboxTitleSelectClickButton:boxTitleSelectBtn];
    }
}

- (void)didClickScanQRCodeBtn:(UIButton *)scanQRCodeBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didscanQRCodeClickButton:)]) {
        [self.delegate topToolView:self didscanQRCodeClickButton:scanQRCodeBtn];
    }
}

- (void)didClickTransferListBtn:(UIButton *)transferListBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didTransferListClickButton:)]) {
        [self.delegate topToolView:self didTransferListClickButton:transferListBtn];
    }
}
//
//- (void)didClickDelectBtn:(UIButton *)delectBtn {
// //   self.newHandImageView.hidden = YES;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didClickDelectBtn:)]) {
//        [self.delegate topToolView:self didClickDelectBtn:delectBtn];
//    }
//}

- (void)searchBarTap:(UITapGestureRecognizer *)tag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolView:didClickSearchBar:)]) {
        [self.delegate topToolView:self didClickSearchBar:nil];
    }
}

@end
