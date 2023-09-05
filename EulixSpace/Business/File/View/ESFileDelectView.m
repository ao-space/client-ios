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
//  ESFileDelectView.m
//  EulixSpace
//
//  Created by qu on 2021/9/6.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileDelectView.h"
#import "ESColor.h"
#import "ESGlobalMacro.h"
#import <Masonry/Masonry.h>

@interface ESFileDelectView ()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIButton *delectCancelBtn;

@end
@implementation ESFileDelectView

#pragma mark - Lazy Load

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-110);
        make.left.mas_equalTo(self.mas_left).offset(10.0f);
        make.right.mas_equalTo(self.mas_right).offset(-10.0f);
        make.height.mas_equalTo(130.0f);
    }];

    [self.pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(10);
        make.left.mas_equalTo(self.mas_left).offset(26.0f);
        make.right.mas_equalTo(self.mas_right).offset(-26.0f);
        make.height.mas_equalTo(42.0f);
    }];

    [self.delectCompleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(65.0f);
        make.left.mas_equalTo(self.mas_left).offset(10.0f);
        make.right.mas_equalTo(self.mas_right).offset(-10.0f);
        make.height.mas_equalTo(65.0f);
    }];

    [self.delectCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-36.0f);
        make.left.mas_equalTo(self.mas_left).offset(10.0f);
        make.right.mas_equalTo(self.mas_right).offset(-10.0f);
        make.height.mas_equalTo(64.0f);
    }];
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 110 - 130, ScreenWidth - 20, 130)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        _programView.layer.masksToBounds = YES;
        _programView.layer.cornerRadius = 10;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, ScreenWidth - 20, 1)];
        lineView.backgroundColor = ESColor.separatorColor;
        [_programView addSubview:lineView];
        [self addSubview:_programView];

    }
    return _programView;
}


- (UIButton *)delectCompleteBtn {
    if (!_delectCompleteBtn) {
        _delectCompleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectCompleteBtn addTarget:self action:@selector(didClickDelectCompleteBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.programView addSubview:_delectCompleteBtn];
        [_delectCompleteBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_delectCompleteBtn setTitle:NSLocalizedString(@"Confirm", @"确认") forState:UIControlStateNormal];
        [_delectCompleteBtn setTitleColor:ESColor.redColor forState:UIControlStateNormal];
    }
    return _delectCompleteBtn;
}

- (UIButton *)delectCancelBtn {
    if (!_delectCancelBtn) {
        _delectCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectCancelBtn setBackgroundColor:ESColor.systemBackgroundColor];
        [_delectCancelBtn addTarget:self action:@selector(didClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [_delectCancelBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
        [_delectCancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_delectCancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [_delectCancelBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [self addSubview:_delectCancelBtn];
    }
    return _delectCancelBtn;
}

- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [[UILabel alloc] init];
        _pointOutLabel.textColor = [ESColor secondaryLabelColor];
        _pointOutLabel.numberOfLines = 0;
        _pointOutLabel.textAlignment = NSTextAlignmentCenter;
        _pointOutLabel.text = NSLocalizedString(@"file_delete_prompt", @"已删除的文件会放入回收站中，如有需要您可以从回收站中恢复");
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        [self addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}

- (void)didClickCancelBtn {
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomDelectView:didClickCancelBtn:)]) {
        [self.delegate fileBottomDelectView:self didClickCancelBtn:nil];
    }
}

- (void)didClickDelectCompleteBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomDelectView:didClickCompleteBtn:)]) {
        [self.delegate fileBottomDelectView:self didClickCompleteBtn:nil];
    }
}

- (void)setPointOutStr:(NSString *)pointOutStr {
    self.pointOutLabel.text = pointOutStr;
}


-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if(hidden){
        [self removeFromSuperview];
    }else{
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
    }
}

@end
