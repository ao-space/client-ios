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
//  ESBottomDetailView.m
//  EulixSpace
//
//  Created by qu on 2021/8/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBottomDetailView.h"
#import "ESCommonToolManager.h"
#import "ESColor.h"
#import "ESFileDefine.h"
#import "ESGlobalMacro.h"
#import "ESImageDefine.h"
#import "NSDate+Format.h"
#import <Masonry/Masonry.h>

@interface ESBottomDetailView ()

@property (nonatomic, strong) UIView *programView;
@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *titleName;

@property (nonatomic, strong) UILabel *fileNameLabel;

@property (nonatomic, strong) UILabel *updateTimeLabel;
@property (nonatomic, strong) UILabel *updateTimeTextLabel;

@property (nonatomic, strong) UILabel *fileSizeLabel;
@property (nonatomic, strong) UILabel *fileSizeTextLabel;

@property (nonatomic, strong) UILabel *filePathlabel;
@property (nonatomic, strong) UILabel *filePathTextlabel;

@property (nonatomic, strong) UIButton *delectBtn;

@end

@implementation ESBottomDetailView

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
        make.height.mas_equalTo(350.0f);
        make.width.mas_equalTo(ScreenWidth);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(20);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(30.0f);
    }];
    
    if ([ESCommonToolManager isEnglish]) {
        [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.programView.mas_top).offset(86);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(94);
        }];
    }else{
        [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.programView.mas_top).offset(86);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(64);
        }];
    }
  
    [self.titleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.fileNameLabel.mas_right).offset(20.0);
        make.top.mas_equalTo(self.programView.mas_top).offset(86);
        make.right.mas_equalTo(self.mas_right).offset(-20);
    }];

    if ([ESCommonToolManager isEnglish]) {
        [self.updateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.titleName.mas_bottom).offset(20.0);
            make.height.mas_equalTo(22.0);
            make.width.mas_equalTo(94);
        }];
    }else{
        [self.updateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.titleName.mas_bottom).offset(20.0);
            make.height.mas_equalTo(22.0);
            make.width.mas_equalTo(64);
        }];
    }


    [self.updateTimeTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.updateTimeLabel.mas_right).offset(20.0);
        make.top.mas_equalTo(self.titleName.mas_bottom).offset(20.0);
        make.height.mas_equalTo(22.0);
        make.right.mas_equalTo(self.mas_right).offset(-20);
    }];

    
    if ([ESCommonToolManager isEnglish]) {
        [self.fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.updateTimeLabel.mas_bottom).offset(20.0);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(94);
        }];
    }else{
        [self.fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.updateTimeLabel.mas_bottom).offset(20.0);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(64);
        }];
    }
//
//    [self.fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
//        make.top.mas_equalTo(self.updateTimeLabel.mas_bottom).offset(20.0);
//        make.height.mas_equalTo(22);
//        make.width.mas_equalTo(64);
//    }];

    [self.fileSizeTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.fileSizeLabel.mas_right).offset(20.0);
        make.top.mas_equalTo(self.updateTimeLabel.mas_bottom).offset(20.0);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self.mas_right).offset(-20);
    }];

//    [self.filePathlabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
//        make.top.mas_equalTo(self.fileSizeLabel.mas_bottom).offset(20.0);
//        make.height.mas_equalTo(22.0f);
//        make.width.mas_equalTo(64.0f);
//    }];

    
    if ([ESCommonToolManager isEnglish]) {
        [self.filePathlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.fileSizeLabel.mas_bottom).offset(20.0);
            make.width.mas_equalTo(94.0f);
        }];
    }else{
        [self.filePathlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.programView.mas_left).offset(24.0);
            make.top.mas_equalTo(self.fileSizeLabel.mas_bottom).offset(20.0);
            make.width.mas_equalTo(64.0f);
        }];
    }
    
  
    [self.filePathTextlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.filePathlabel.mas_right).offset(20.0);
        make.top.mas_equalTo(self.fileSizeLabel.mas_bottom).offset(20.0);
        make.right.mas_equalTo(self.mas_right).offset(-20);
    }];

    [self.delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.programView.mas_right);
        make.top.mas_equalTo(self.programView.mas_top);
        make.height.mas_equalTo(18 + 40);
        make.width.mas_equalTo(18 + 40);
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
        _title.text = NSLocalizedString(@"Details", @"详情");
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self addSubview:_title];
    }
    return _title;
}

- (UILabel *)titleName {
    if (!_titleName) {
        _titleName = [[UILabel alloc] init];
        _titleName.textColor = ESColor.labelColor;
        _titleName.textAlignment = NSTextAlignmentLeft;
        _titleName.numberOfLines = 0;
        _titleName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self addSubview:_titleName];
    }
    return _titleName;
}
- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.textColor = ESColor.secondaryLabelColor;
        _fileNameLabel.text = NSLocalizedString(@"File Name", @"文件名称");
        _fileNameLabel.textAlignment = NSTextAlignmentLeft;
        _fileNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self addSubview:_fileNameLabel];
    }
    return _fileNameLabel;
}

- (UILabel *)updateTimeLabel {
    if (!_updateTimeLabel) {
        _updateTimeLabel = [[UILabel alloc] init];
        _updateTimeLabel.textColor = ESColor.secondaryLabelColor;
        _updateTimeLabel.text = NSLocalizedString(@"Modify Time", @"修改时间");
        _updateTimeLabel.textAlignment = NSTextAlignmentLeft;
        _updateTimeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.programView addSubview:_updateTimeLabel];
    }
    return _updateTimeLabel;
}

- (UILabel *)updateTimeTextLabel {
    if (!_updateTimeTextLabel) {
        _updateTimeTextLabel = [[UILabel alloc] init];
        _updateTimeTextLabel.textColor = ESColor.labelColor;
        _updateTimeTextLabel.textAlignment = NSTextAlignmentLeft;
        _updateTimeTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.programView addSubview:_updateTimeTextLabel];
    }
    return _updateTimeTextLabel;
}

- (UILabel *)fileSizeLabel {
    if (!_fileSizeLabel) {
        _fileSizeLabel = [[UILabel alloc] init];
        _fileSizeLabel.textColor = ESColor.secondaryLabelColor;
        _fileSizeLabel.text = NSLocalizedString(@"File Size", @"文件大小");
        _fileSizeLabel.textAlignment = NSTextAlignmentLeft;
        _fileSizeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.programView addSubview:_fileSizeLabel];
    }
    return _fileSizeLabel;
}

- (UILabel *)fileSizeTextLabel {
    if (!_fileSizeTextLabel) {
        _fileSizeTextLabel = [[UILabel alloc] init];
        _fileSizeTextLabel.textColor = ESColor.labelColor;
        _fileSizeTextLabel.textAlignment = NSTextAlignmentLeft;
        _fileSizeTextLabel.font = [UIFont systemFontOfSize:16];
        _fileSizeTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        [self.programView addSubview:_fileSizeTextLabel];
    }
    return _fileSizeTextLabel;
}

- (UILabel *)filePathlabel {
    if (!_filePathlabel) {
        _filePathlabel = [[UILabel alloc] init];
        _filePathlabel.textColor = ESColor.secondaryLabelColor;
        _filePathlabel.text =   NSLocalizedString(@"File Path", @"文件路径"); 
        _filePathlabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _filePathlabel.textAlignment = NSTextAlignmentLeft;
   
        [self.programView addSubview:_filePathlabel];
    }
    return _filePathlabel;
}

- (UILabel *)filePathTextlabel {
    if (!_filePathTextlabel) {
        _filePathTextlabel = [[UILabel alloc] init];
        _filePathTextlabel.textColor = ESColor.labelColor;
        _filePathTextlabel.textAlignment = NSTextAlignmentLeft;
        _filePathTextlabel.font = [UIFont systemFontOfSize:16];
        _filePathTextlabel.numberOfLines = 3;
        [self.programView addSubview:_filePathTextlabel];
    }
    return _filePathTextlabel;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(didClickDetailDelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];
        [self.programView addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (void)setFileInfo:(ESFileInfoPub *)fileInfo {
    _fileInfo = fileInfo;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:fileInfo.operationAt.integerValue / 1000];
    NSString *time = [date stringFromFormat:@"YYYY-MM-dd HH:mm:ss"];
    self.updateTimeTextLabel.text = time;
    self.fileSizeTextLabel.text = FileSizeString(fileInfo.size.integerValue, YES);
    self.filePathTextlabel.text = [NSString stringWithFormat:NSLocalizedString(@"me_space%@", @"我的空间%@"), fileInfo.path];
    self.titleName.text = fileInfo.name;
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
