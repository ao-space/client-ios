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
//  ESMoveCopyView.m
//  EulixSpace
//
//  Created by qu on 2021/8/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESMoveCopyView.h"
#import "ESColor.h"
#import "ESCopyMoveFolderListVC.h"

@interface ESMoveCopyView ()

@property (nonatomic, strong) UIView *programView;
@property (nonatomic, strong) UIButton *returnBtn;
@property (nonatomic, strong) UIButton *delectBtn;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *selectNumLable;

@property (nonatomic, strong) UIButton *buildFolderBtn;
@property (nonatomic, strong) UIButton *completeBtn;

@property (nonatomic, strong) ESCopyMoveFolderListVC *folderList;

@property (nonatomic, strong) NSString *pathUpLoadStr;
@property (nonatomic, strong) NSString *pathUpLoadUUID;

@end

@implementation ESMoveCopyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
    }
    return self;
}

//- (void)setHidden:(BOOL)hidden {
//    [super setHidden:hidden];
//    self.programView.hidden = hidden;
//}

///  返回
- (void)returnBtnClick:(UIButton *)returnBtn {
    [self.folderList.enterFileUUIDArray removeLastObject];
    if (self.folderList.enterFileUUIDArray.count > 0) {
        ESFileInfoPub *info = self.folderList.enterFileUUIDArray[self.folderList.enterFileUUIDArray.count - 1];
        [self.folderList headerRefreshWithUUID:info.uuid];
        self.returnBtn.hidden = NO;
        self.titleLabel.text = info.name;
        
    } else {
        [self.folderList headerRefreshWithUUID:@""];
        self.returnBtn.hidden = YES;
        if ([self.category isEqual:@"move"]) {
            self.titleLabel.text = NSLocalizedString(@"Move to my space", @"移动到“我的空间”");
        }else if([self.category isEqual:@"copy"]){
            self.titleLabel.text = NSLocalizedString(@"Copy to my space", @"复制到“我的空间”");
        }else{
            self.titleLabel.text = NSLocalizedString(@"Upload to my space", @"上传到“我的空间”");
        }
    }

    if (self.folderList.enterFileUUIDArray.count > 18) {
        [self.buildFolderBtn setTitleColor:ESColor.grayColor forState:UIControlStateNormal];
        [self.buildFolderBtn setBackgroundColor:ESColor.grayBgColor];
        self.buildFolderBtn.layer.masksToBounds = NO;
        self.buildFolderBtn.userInteractionEnabled = NO;
        self.buildFolderBtn.layer.borderWidth = 0;
        self.buildFolderBtn.enabled = NO;
        
    } else {
        [self.buildFolderBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        self.buildFolderBtn.layer.borderColor = ESColor.primaryColor.CGColor;
        [self.buildFolderBtn setBackgroundColor:ESColor.systemBackgroundColor];
        self.buildFolderBtn.layer.borderWidth = 1;
        self.buildFolderBtn.layer.masksToBounds = YES;
        self.buildFolderBtn.userInteractionEnabled = YES;
        self.buildFolderBtn.enabled = YES;
    }
}

- (void)didClickCompleteBtn:(UIButton *)delectBtn {
    self.pathUpLoadStr = @"";
    self.hidden = YES;
    if (self.folderList.enterFileUUIDArray.count > 0) {
        ESFileInfoPub *info = self.folderList.enterFileUUIDArray[self.folderList.enterFileUUIDArray.count - 1];
        self.pathUpLoadUUID = info.uuid;
    }

    for (ESFileInfoPub *info in self.folderList.enterFileUUIDArray) {
        self.pathUpLoadStr = [NSString stringWithFormat:@"%@/%@", self.pathUpLoadStr, info.name];
    }

    self.pathUpLoadStr = [NSString stringWithFormat:@"%@/", self.pathUpLoadStr];
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileMoveCopyView:didClickCompleteBtnWithPath:selectUUID:category:)]) {
        if (self.pathUpLoadStr.length < 1) {
            self.pathUpLoadStr = @"/";
        }
        [self.delegate fileMoveCopyView:self didClickCompleteBtnWithPath:self.pathUpLoadStr selectUUID:self.pathUpLoadUUID category:self.category];
    }
}

///  取消
- (void)moveCopyCancelBtnClick:(UIButton *)delectBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileMoveCopyView:didClicCancelBtn:)]) {
        [self.delegate fileMoveCopyView:self didClicCancelBtn:delectBtn];
    }
}

/// 新建文件夹
- (void)buildFolderBtnClick:(UIButton *)buildFolderBtnClick {
    [self.folderList didClickCreateFolder];
}

- (void)updateConstraints {
    self.programView.hidden = NO;
    [super updateConstraints];
    self.pathUpLoadStr = @"";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFolderClick:) name:@"didEnterFolderClick" object:nil];

    self.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];

    if (self.folderList.enterFileUUIDArray.count > 0) {
        self.returnBtn.hidden = NO;
    } else {
        self.returnBtn.hidden = YES;
    }
    [self.programView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(44.0f);
        make.left.equalTo(self.mas_left).offset(0.0f);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@(ScreenHeight - 44));
    }];

    [self.returnBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.programView.mas_left).offset(kESViewDefaultMargin);
        make.top.equalTo(self.programView.mas_top).offset(20.0f);
        make.width.equalTo(@(18.0f));
        make.height.equalTo(@(18.0f));
    }];

    [self.delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.programView.mas_right).offset(-20.0f);
        make.top.equalTo(self.programView.mas_top).offset(20.0f);
        make.width.equalTo(@(18.0f));
        make.height.equalTo(@(18.0f));
    }];

    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.programView.mas_centerX);
        make.top.equalTo(self.programView.mas_top).offset(20.0f);
        make.right.equalTo(self.delectBtn.mas_left).offset(-10.0f);
        make.height.equalTo(@(25.0f));
    }];

    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.programView.mas_left).offset(kESViewDefaultMargin);
        make.top.equalTo(self.programView.mas_top).offset(68.0f);
        make.width.equalTo(@(16.0f));
        make.height.equalTo(@(16.0f));
    }];

    [self.selectNumLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10.0f);
        make.centerY.equalTo(self.iconImageView.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-20.0f);
        make.height.equalTo(@(22.0f));
    }];

    CGFloat moddle = (ScreenWidth - 20 - 2*150)/2;
    [self.buildFolderBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.programView.mas_left).offset(moddle);
        make.bottom.equalTo(self.programView.mas_bottom).offset(-33.0f);
        make.width.equalTo(@(150.0f));
        make.height.equalTo(@(44.0f));
    }];

    [self.completeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.buildFolderBtn.mas_right).offset(20.0f);
        make.bottom.equalTo(self.programView.mas_bottom).offset(-33.0f);
        make.width.equalTo(@(150.0f));
        make.height.equalTo(@(44.0f));
    }];


    [self.folderList.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.programView.mas_top).offset(106.0f);
        make.left.equalTo(self.mas_left).offset(0);
        make.bottom.equalTo(self.programView.mas_bottom).offset(-93);
        make.width.equalTo(@(ScreenWidth));
    }];
    
    [self.buildFolderBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    [self.buildFolderBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
    self.buildFolderBtn.layer.borderColor = ESColor.primaryColor.CGColor;
    self.buildFolderBtn.layer.borderWidth = 1;
    self.buildFolderBtn.layer.masksToBounds = YES;
    self.buildFolderBtn.enabled = YES;
    [self.buildFolderBtn setBackgroundColor:ESColor.clearColor];
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, ScreenWidth, ScreenHeight - 44)];
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

- (void)didEnterFolderClick:(NSNotification *)notifi {
    NSDictionary *dic = notifi.object;
    ESFileInfoPub *data = dic[@"fileInfo"];
    BOOL isMoveCopy = [dic[@"isMoveCopy"] boolValue];
    if (isMoveCopy) {
        if (self.folderList.enterFileUUIDArray.count > 0) {
            if (self.folderList.enterFileUUIDArray.count > 18) {
                [self.buildFolderBtn setTitleColor:ESColor.grayColor forState:UIControlStateNormal];
                [self.buildFolderBtn setBackgroundColor:ESColor.grayBgColor];
                self.buildFolderBtn.layer.masksToBounds = NO;
                self.buildFolderBtn.layer.borderWidth = 0;
                self.buildFolderBtn.enabled = NO;
            } else {
                [self.buildFolderBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
                [self.buildFolderBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
                self.buildFolderBtn.layer.borderColor = ESColor.primaryColor.CGColor;
                self.buildFolderBtn.layer.borderWidth = 1;
                [self.buildFolderBtn setBackgroundColor:ESColor.clearColor];
                self.buildFolderBtn.layer.masksToBounds = YES;
                self.buildFolderBtn.enabled = YES;
            }
            self.returnBtn.hidden = NO;
        } else {
            self.returnBtn.hidden = YES;
        }

        if ([self.category isEqual:@"move"]) {
            if (self.name.length > 0) {
                self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Move to %@", @"移动到“%@”"), data.name];
            } else {
                self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Move to %@", @"移动到“%@”"), data.name];
            }
        } else if ([self.category isEqual:@"copy"]) {
            if (self.name.length > 0) {
                self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"copy_to", @"复制到“%@”"), data.name];
            } else {
                self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"copy_to", @"复制到“%@”"), data.name];
            }
        } else {
            if (self.name.length > 0) {
                self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Upload to %@", @"上传到“%@”"), data.name];
            } else {
                self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Upload to %@", @"上传到“%@”"), data.name];
            }
        }
    }
}
- (ESCopyMoveFolderListVC *)folderList {
    if (!_folderList) {
        _folderList = [[ESCopyMoveFolderListVC alloc] init];
        [self.programView addSubview:_folderList.view];
    }
    return _folderList;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = IMAGE_FILE_SELECTED_ICON;
        [self.programView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        //_titleLabel.text = @"移动到“最近项目…";
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)selectNumLable {
    if (!_selectNumLable) {
        _selectNumLable = [[UILabel alloc] init];
        _selectNumLable.textColor = ESColor.secondaryLabelColor;
        _selectNumLable.textAlignment = NSTextAlignmentLeft;
        _selectNumLable.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.programView addSubview:_selectNumLable];
    }
    return _selectNumLable;
}

- (UIButton *)returnBtn {
    if (nil == _returnBtn) {
        _returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnBtn addTarget:self action:@selector(returnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_returnBtn setImage:IMAGE_IC_BACK_CHEVRON forState:UIControlStateNormal];
        [_returnBtn.layer setCornerRadius:3.0]; //设置矩圆角半径
        [self addSubview:_returnBtn];
    }
    return _returnBtn;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_delectBtn addTarget:self action:@selector(moveCopyCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];

        [self addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (UIButton *)buildFolderBtn {
    if (nil == _buildFolderBtn) {
        _buildFolderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buildFolderBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_buildFolderBtn addTarget:self action:@selector(buildFolderBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_buildFolderBtn setTitle:NSLocalizedString(@"file_new_file", @"新建文件夹") forState:UIControlStateNormal];
        [_buildFolderBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_buildFolderBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
        _buildFolderBtn.layer.masksToBounds = YES;
        _buildFolderBtn.layer.borderColor = ESColor.primaryColor.CGColor;
        _buildFolderBtn.layer.borderWidth = 1;
  
        [self.programView addSubview:_buildFolderBtn];
    }
    return _buildFolderBtn;
}

- (UIButton *)completeBtn {
    if (nil == _completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_completeBtn addTarget:self action:@selector(didClickCompleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_completeBtn setTitle:NSLocalizedString(@"Confirm", @"确认") forState:UIControlStateNormal];
        [_completeBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_completeBtn setBackgroundImage:IMAGE_COMMON_GRADUAL_BTNBG forState:UIControlStateNormal];
        [_completeBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
        _completeBtn.layer.masksToBounds = YES;
        [self.programView addSubview:_completeBtn];
    }
    return _completeBtn;
}

- (void)setSelectNum:(NSUInteger)selectNum {
    _selectNum = selectNum;
    self.selectNumLable.text = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), (unsigned long)selectNum];
}

- (void)setName:(NSString *)name {
    _name = name;
    _name = NSLocalizedString(@"me_space", @"我的空间");
    // self.titleLabel.text = [NSString stringWithFormat:@"上传到“%@”", self.name];
    //ESFileInfoPub *fileInfo = dic[@"fileInfo"];
    if ([self.category isEqual:@"move"]) {
        if (self.name.length > 0) {
            self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Move to %@", @"移动到“%@”"), _name];
        } else {
            self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Move to %@", @"移动到“%@”"), _name];
        }
    } else if ([self.category isEqual:@"copy"]) {
        if (self.name.length > 0) {
            self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"copy_to", @"复制到“%@”"), _name];
        } else {
            self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"copy_to", @"复制到“%@”"), _name];
        }
    } else {
        if (self.name.length > 0) {
            self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Upload to %@", @"上传到“%@”"), _name];
        } else {
            self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Upload to %@", @"上传到“%@”"), _name];
        }
    }
}

- (void)setUuid:(NSString *)uuid {
    if (self.folderList.enterFileUUIDArray.count > 0) {
        self.returnBtn.hidden = NO;
    } else {
        self.returnBtn.hidden = YES;
    }
    self.folderList.enterFileUUIDArray = [NSMutableArray new];
    [self.folderList headerRefreshWithUUID:@""];
}


-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    self.programView.hidden = hidden;
    if(hidden){
        [self removeFromSuperview];
    }else{
        [self setNeedsUpdateConstraints];
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            self.programView.hidden = NO;
        }
    }
}
@end
