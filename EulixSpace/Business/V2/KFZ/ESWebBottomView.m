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
//  ESWebBottomView.m
//  EulixSpace
//
//  Created by qu on 2022/2/10.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESWebBottomView.h"

#import "ESColor.h"
#import "ESFileDefine.h"
#import "ESGlobalMacro.h"
#import "ESImageDefine.h"
#import "ESWebBottomBtnView.h"

#import "NSDate+Format.h"
#import "ESBoxManager.h"

#import <Masonry/Masonry.h>

@interface ESWebBottomView ()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView *line1;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *titleName;

@property (nonatomic, strong) UILabel *cancel;

@property (nonatomic, strong) ESWebBottomBtnView *backBtn;

@property (nonatomic, strong) ESWebBottomBtnView *delectBtn;

@property (nonatomic, strong) ESWebBottomBtnView *settingBtn;


@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation ESWebBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
    }
    return self;
}



- (void)updateConstraints {
    [super updateConstraints];

    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(0);
        make.left.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(269.0f);
        make.width.mas_equalTo(ScreenWidth);
    }];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(15);
        make.left.mas_equalTo(self.mas_left).offset(15);
        make.height.mas_equalTo(30.0f);
        make.width.mas_equalTo(30.0f);
    }];
    
    [self.titleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
        make.left.mas_equalTo(self.mas_left).offset(58);
        make.right.mas_equalTo(self.mas_right).offset(-58);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(54);
        make.left.mas_equalTo(self.mas_left).offset(0);
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.height.mas_equalTo(1.0f);
    }];
    
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(175);
        make.left.mas_equalTo(self.mas_left).offset(0);
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.height.mas_equalTo(6.0f);
    }];

    if(ESBoxManager.activeBox.boxType == ESBoxTypeMember ){
        [self boxTypeMember];
    }else if(ESBoxManager.activeBox.boxType == ESBoxTypeAuth && ![ESBoxManager.activeBox.aoid  isEqual:@"aoid-1"]){
        [self boxTypeMember];
    }else{
        
        [self.delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line.mas_bottom).offset(19);
            make.left.mas_equalTo(self.mas_left).offset(15);
            make.height.mas_equalTo(80.0f);
            make.width.mas_equalTo(50.0f);
        }];
        
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line.mas_bottom).offset(19);
            make.left.mas_equalTo(self.delectBtn.mas_right).offset(50);
            make.height.mas_equalTo(80.0f);
            make.width.mas_equalTo(50.0f);
        }];

        [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line.mas_bottom).offset(19);
            make.left.mas_equalTo(self.backBtn.mas_right).offset(50);
            make.height.mas_equalTo(80.0f);
            make.width.mas_equalTo(50.0f);
        }];
    }
 


    [self.cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line1.mas_bottom).offset(0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-kBottomHeight);
    }];
    

}

-(void)boxTypeMember{
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(self.line.mas_bottom).offset(19);
          make.left.mas_equalTo(self.mas_left).offset(15);
          make.height.mas_equalTo(80.0f);
          make.width.mas_equalTo(50.0f);
         
      }];

      [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(self.line.mas_bottom).offset(19);
          make.left.mas_equalTo(self.backBtn.mas_right).offset(50);
          make.height.mas_equalTo(80.0f);
          make.width.mas_equalTo(50.0f);
      }];
}
/// 取消
- (void)didClickDetailDelectBtn:(UIButton *)detailDelectBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomDetailView:didClickDelectBtn:)]) {
        [self.delegate fileBottomDetailView:self didClickDelectBtn:detailDelectBtn];
    }
}

#pragma mark - Lazy Load

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 350, ScreenWidth, 350)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_programView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _programView.bounds;
        maskLayer.path = maskPath.CGPath;
        _programView.layer.mask = maskLayer;
        [self addSubview:_programView];
    }
    return _programView;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.programView addSubview:_title];
    }
    return _title;
}

- (UILabel *)cancel {
    if (!_cancel) {
        _cancel = [[UILabel alloc] init];
        _cancel.textColor = ESColor.labelColor;
        _cancel.textAlignment = NSTextAlignmentLeft;
        _cancel.text = NSLocalizedString(@"cancel", @"取消");
        _cancel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self addSubview:_cancel];
    }
    return _cancel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"app_docker"];
        _iconImageView.layer.cornerRadius = 4.0;
        _iconImageView.layer.masksToBounds = YES;
        [self.programView addSubview:_iconImageView];
    }
    return _iconImageView;
}


- (UILabel *)titleName {
    if (!_titleName) {
        _titleName = [[UILabel alloc] init];
        _titleName.textColor = ESColor.labelColor;
        _titleName.textAlignment = NSTextAlignmentLeft;
        _titleName.numberOfLines = 0;
        _titleName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.programView addSubview:_titleName];
    }
    return _titleName;
}


- (void)setFileInfo:(ESAppletInfoModel *)fileInfo {
    _fileInfo = fileInfo;
    self.titleName.text = fileInfo.name;
    NSURL *imageurl = [NSURL URLWithString:fileInfo.iconUrl];
    NSData *imagedata = [NSData dataWithContentsOfURL:imageurl];
    UIImage *image = [UIImage imageWithData:imagedata];
    if(image){
        self.iconImageView.image = image;
    }else{
        self.iconImageView.image = [UIImage imageNamed:@"app_docker"];
    }
 
}


- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self addSubview:_line];
    }
    return _line;
}

- (UIView *)line1 {
    if (!_line1) {
        _line1 = [UIView new];
        _line1.backgroundColor = ESColor.separatorColor;
        [self addSubview:_line1];
    }
    return _line1;
}



- (ESWebBottomBtnView *)backBtn {
    if (nil == _backBtn) {
        _backBtn = [ESWebBottomBtnView new];
        _backBtn.btnLabel.text = NSLocalizedString(@"close_applet", @"退出") ;
        _backBtn.btnImageView.image = [UIImage imageNamed:@"applet_close"];
        [self addSubview:_backBtn];
        UITapGestureRecognizer *linkCopyBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickIntoBackBtn)];
        [_backBtn addGestureRecognizer:linkCopyBtnTap];
    }
    return _backBtn;
}

- (ESWebBottomBtnView *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [ESWebBottomBtnView new];
        _delectBtn.btnLabel.text = NSLocalizedString(@"uninstall_applet", @"卸载") ;
        _delectBtn.btnImageView.image = [UIImage imageNamed:@"xiezai"];
        [self addSubview:_delectBtn];
        UITapGestureRecognizer *linkCopyBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickIntoDelectBtn)];
        [_delectBtn addGestureRecognizer:linkCopyBtnTap];
    }
    return _delectBtn;
}

- (ESWebBottomBtnView *)settingBtn {
    if (nil == _settingBtn) {
        _settingBtn = [ESWebBottomBtnView new];
        _settingBtn.btnLabel.text = NSLocalizedString(@"set_applet", @"设置") ;
        _settingBtn.btnImageView.image = [UIImage imageNamed:@"apple_setting"];
        [self addSubview:_settingBtn];
        UITapGestureRecognizer *linkCopyBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickIntoSettingBtn)];
        [_settingBtn addGestureRecognizer:linkCopyBtnTap];
    }
    return _settingBtn;
}



-(void)didClickIntoBackBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomDetailView:didClickBackBtn:)]) {
        [self.delegate fileBottomDetailView:self didClickBackBtn:nil];
    }
}

-(void)didClickIntoSettingBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomDetailView:didClickSettingBtn:)]) {
        [self.delegate fileBottomDetailView:self didClickSettingBtn:nil];
    }
}

-(void)didClickIntoDelectBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomDetailView:didClickDelectBtn:)]) {
        [self.delegate fileBottomDetailView:self didClickDelectBtn:nil];
    }
}


-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    self.programView.hidden = hidden;
    if(hidden){
        [self removeFromSuperview];
    }else{
        [self updateConstraints];
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
    }
}

@end
