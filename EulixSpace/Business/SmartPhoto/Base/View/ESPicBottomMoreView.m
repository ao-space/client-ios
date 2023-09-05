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
//  ESPicBottomMoreView.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPicBottomMoreView.h"
#import "ESColor.h"
#import "ESCommentCreateFolder.h"
#import "ESFileDefine.h"
#import "ESFileTotalVC.h"
#import "ESMoveCopyView.h"

@interface ESPicBottomMoreView ()<ESMoveCopyViewDelegate>

@property (nonatomic, strong) UIView *programView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIButton *delectBtn;
@property (nonatomic, strong) UIView *detailCellView;

@property (nonatomic, strong) UILabel *reNameLabele;
@property (nonatomic, strong) UITextField *reNameTextField;
@property (nonatomic, strong) UIButton *reNameCompleteBtn;
@property (nonatomic, strong) UIButton *reNameViewCancelBtn;
@property (nonatomic, strong) ESMoveCopyView *movecopyView;

@end

@implementation ESPicBottomMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
        self.programView.hidden = NO;
        self.isSelectUUIDSArray = [[NSMutableArray alloc] init];
    }
    self.reNameView.hidden = YES;
    return self;
}

- (void)handlereNameTap:(UITapGestureRecognizer *)sender {
    NSString *fileName = [self.fileInfo.name stringByDeletingPathExtension];
    self.reNameTextField.text = fileName;
    self.reNameView.hidden = NO;
    self.programView.hidden = YES;
}


- (void)reNameCompleteBtn:(UIButton *)completeBtn {
    [self.reNameTextField resignFirstResponder];
    ESCommentCreateFolder *check = [ESCommentCreateFolder new];
    NSString *checkStr = [check checkReNameFolder:self.reNameTextField.text];
    if (checkStr.length > 0) {
        [ESToast toastSuccess:checkStr];
        self.reNameView.hidden = NO;
        return;
    }

    if ([self.delegate respondsToSelector:@selector(bottomMoreView:reNameFileInfo:fileName:)]) {
        [self.delegate bottomMoreView:self reNameFileInfo:self.fileInfo fileName:self.reNameTextField.text];
    }
}

- (void)handlereDetailViewTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(bottomMoreViewShowDetail:)]) {
        [self.delegate bottomMoreViewShowDetail:self];
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.programView.hidden = hidden;
}

- (void)reNameViewCancelClick {
    self.reNameView.hidden = YES;
    self.programView.hidden = NO;
    [self endEditing:YES];
}

- (void)updateConstraints {
    [super updateConstraints];

    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(0);
        make.left.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(300.0f);
        make.width.mas_equalTo(ScreenWidth);
    }];

    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(20.0f);
        make.left.mas_equalTo(self.mas_left).offset(24.0f);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(20.0f);
    }];

    [self.delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.programView.mas_right);
        make.top.mas_equalTo(self.programView.mas_top);
        make.height.mas_equalTo(18 + 40);
        make.width.mas_equalTo(18 + 40);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(10.0f);
        make.right.mas_equalTo(self.delectBtn.mas_right).offset(-20.0);
        make.top.mas_equalTo(self.programView.mas_top).offset(20);
        make.height.mas_equalTo(18);
    }];
    
    [self.reNameCellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.programView.mas_left).offset(0.0);
        make.top.mas_equalTo(self.programView.mas_top).offset(61.0);
        make.height.mas_equalTo(62.0);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    [self.mCopyCellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.programView.mas_left).offset(0.0);
        make.top.mas_equalTo(self.reNameCellView.mas_bottom).offset(0);
        make.height.mas_equalTo(62.0);
        make.width.mas_equalTo(ScreenWidth);
    }];

    [self.moveCellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.programView.mas_left).offset(0.0);
        make.top.mas_equalTo(self.mCopyCellView.mas_bottom).offset(0);
        make.height.mas_equalTo(62.0);
        make.width.mas_equalTo(ScreenWidth);
    }];

    [self.reNameView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(200.0f);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@(270.0f));
        make.height.equalTo(@(140.0f));
    }];

    [self.reNameLabele mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.reNameView.mas_top).offset(14.0f);
        make.centerX.equalTo(self.mas_centerX);
        make.height.equalTo(@(25.0f));
    }];

    [self.reNameTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.reNameView.mas_top).offset(49.0f);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@(230.0f));
        make.height.equalTo(@(34.0f));
    }];

    [self.reNameCompleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.reNameView.mas_bottom).offset(0.0f);
        make.right.equalTo(self.reNameView.mas_right);
        make.width.equalTo(@(135.0f));
        make.height.equalTo(@(45.0f));
    }];


    [self.reNameViewCancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.reNameView.mas_bottom).offset(0.0f);
        make.left.equalTo(self.reNameView.mas_left);
        make.width.equalTo(@(135.0f));
        make.height.equalTo(@(45.0f));
    }];

    self.reNameView.hidden = YES;
}

- (UIView *)cellViewWithTitleStr:(NSString *)titleStr cellImage:(UIImage *)cellImage {
    UIView *cellView = [[UIView alloc] init];

    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 19, 24, 24)];
    headImageView.image = cellImage;
    [cellView addSubview:headImageView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(58, 20, 200, 22)];
    title.text = titleStr;
    [cellView addSubview:title];
    title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];

    return cellView;
}

#pragma mark - Lazy Load

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 300, ScreenWidth, 300)];
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

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(didClickMoreDelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];
        [self.programView addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        [self.programView addSubview:_headImageView];
    }
    return _headImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIView *)reNameCellView {
    if (!_reNameCellView) {
        _reNameCellView = [self cellViewWithTitleStr:TEXT_FILE_BOTTOM_RENAME cellImage:IMAGE_FILE_RENAME];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlereNameTap:)];
        [_reNameCellView addGestureRecognizer:singleTap];
        [self.programView addSubview:_reNameCellView];
    }
    return _reNameCellView;
}

- (UIView *)detailCellView {
    if (!_detailCellView) {
        _detailCellView = [self cellViewWithTitleStr:TEXT_FILE_BOTTOM_DETAILS cellImage:IMAGE_FILE_BOTTOM_DETAILS];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlereDetailViewTap:)];
        [_detailCellView addGestureRecognizer:singleTap];
        [self.programView addSubview:_detailCellView];
    }
    return _detailCellView;
}

- (UIView *)mCopyCellView {
    if (!_mCopyCellView) {
        _mCopyCellView = [self cellViewWithTitleStr:TEXT_FILE_BOTTOM_COPY cellImage:IMAGE_FILE_BOTTOM_COPY];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCopyTap:)];
        [_mCopyCellView addGestureRecognizer:singleTap];
        [self.programView addSubview:_mCopyCellView];
    }
    return _mCopyCellView;
}

- (UIView *)moveCellView {
    if (!_moveCellView) {
        _moveCellView = [self cellViewWithTitleStr:TEXT_FILE_BOTTOM_MOVE cellImage:IMAGE_FILE_BOTTOM_MOVE];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlereMoveTap:)];
        [_moveCellView addGestureRecognizer:singleTap];
        [self.programView addSubview:_moveCellView];
    }
    return _moveCellView;
}

- (ESMoveCopyView *)movecopyView {
    if (!_movecopyView) {
        _movecopyView = [[ESMoveCopyView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _movecopyView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        UIWindow *windowView = self.window;
        _movecopyView.delegate = self;
        [windowView addSubview:_movecopyView];
    }
    return _movecopyView;
}

- (void)fileMoveCopyView:(ESMoveCopyView *_Nullable)fileBottomToolView didClicCancelBtn:(UIButton *_Nonnull)button {
    [self didClickMoreDelectBtn:nil];
    self.movecopyView.hidden = YES;
}

- (void)fileMoveCopyView:(ESMoveCopyView *_Nullable)fileBottomToolView didClickCompleteBtnWithPath:(NSString *_Nullable)pathName selectUUID:(NSString *_Nullable)uuid category:(NSString *)category {
    [self didClickMoreDelectBtn:nil];
    self.movecopyView.hidden = YES;
    
    
    ESFileApi *api = [[ESFileApi alloc] init];
    
    if ([category isEqual:@"copy"]) {
        if ([pathName isEqual:@"/"] && ([uuid isEqual:@"/"] || [uuid isEqual:@""] || uuid.length < 1)) {
            [ESToast toastError:NSLocalizedString(@"Move Fail", @"移动失败")];
        }
        ESCopyFileReq *req = [[ESCopyFileReq alloc] init];
        req.dstPath = uuid;
        req.uuids = self.isSelectUUIDSArray;
        
        [api spaceV1ApiFileCopyPostWithVarCopyFilesReq:req
                                     completionHandler:^(ESRspCopyRsp *output, NSError *error) {
            if (!error) {
                if (output.code.intValue == 1022) {
                    [ESToast toastError:NSLocalizedString(@"Copy Fail", @"复制失败")];
                }
                [ESToast toastSuccess:NSLocalizedString(@"Copy Success", @"复制成功")];
            } else {
                [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
            
        }];
    }
    if ([category isEqual:@"move"]) {
        if ([pathName isEqual:@"/"] && ([uuid isEqual:@"/"] || [uuid isEqual:@""] || uuid.length < 1)) {
            [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
        ESMoveFileReq *req = [[ESMoveFileReq alloc] init];
        if (uuid.length > 0) {
            req.destPath = uuid;
        } else {
            req.destPath = @"";
        }
        req.uuids = self.isSelectUUIDSArray;
        [api spaceV1ApiFileMovePostWithMoveFilesReq:req
                                  completionHandler:^(ESRspDbAffect *output, NSError *error) {
            if (!error) {
                if (output.code.intValue == 1022) {
                    [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                }
                [ESToast toastSuccess:NSLocalizedString(@"Move Successful", @"移动成功")];
            } else {
                [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }
}

- (void)handleCopyTap:(UITapGestureRecognizer *)sender {
    self.movecopyView.category = @"copy";
    self.movecopyView.isSelectUUIDSArray = self.isSelectUUIDSArray;
    self.movecopyView.selectNum = self.isSelectUUIDSArray.count;
    //self.movecopyView.name = self.fileInfo.path;
    //  if([self.fileInfo.path isEqual:@"/"]){
    self.movecopyView.name = NSLocalizedString(@"me_space", @"我的空间");
    self.movecopyView.uuid = @"";
    //  }
    self.movecopyView.hidden = NO;
    self.programView.hidden = YES;
    self.hidden = YES;
}

- (void)handlereMoveTap:(UITapGestureRecognizer *)sender {
    self.movecopyView.category = @"move";
    self.movecopyView.isSelectUUIDSArray = self.isSelectUUIDSArray;
    self.movecopyView.selectNum = self.isSelectUUIDSArray.count;
    self.movecopyView.name = self.fileInfo.path;
    self.movecopyView.name = NSLocalizedString(@"me_space", @"我的空间");
    self.movecopyView.uuid = @"";
    self.movecopyView.hidden = NO;
    self.programView.hidden = YES;
    self.hidden = YES;
}

/// 取消
- (void)didClickMoreDelectBtn:(UIButton *)moreDelectBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomMoreViewDidClickCancel:)]) {
        [self.delegate bottomMoreViewDidClickCancel:self];
    }
}

- (UIButton *)reNameViewCancelBtn {
    if (nil == _reNameViewCancelBtn) {
        _reNameViewCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reNameViewCancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:18]];
        [_reNameViewCancelBtn addTarget:self action:@selector(reNameViewCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [_reNameViewCancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [_reNameViewCancelBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_reNameViewCancelBtn.layer setCornerRadius:3.0]; //设置矩圆角半径
        [self addSubview:_reNameViewCancelBtn];
    }
    return _reNameViewCancelBtn;
}

- (UIView *)reNameView {
    if (!_reNameView) {
        _reNameView = [UIView new];
        _reNameView.layer.masksToBounds = YES;
        _reNameView.layer.cornerRadius = 10;
        _reNameView.backgroundColor = ESColor.systemBackgroundColor;
        [_reNameView addSubview:self.reNameLabele];
        [_reNameView addSubview:self.reNameTextField];
        [_reNameView addSubview:self.reNameCompleteBtn];
        [_reNameView addSubview:self.reNameViewCancelBtn];
        UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 95, 270, 1)];
        verticalLineView.backgroundColor = ESColor.separatorColor;
        [_reNameView addSubview:verticalLineView];
        UIView *horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(134, 95, 1, 46)];
        horizontalLineView.backgroundColor = ESColor.separatorColor;
        [_reNameView addSubview:horizontalLineView];
        [self addSubview:_reNameView];
    }
    return _reNameView;
}

- (UILabel *)reNameLabele {
    if (!_reNameLabele) {
        _reNameLabele = [[UILabel alloc] init];
        _reNameLabele.textColor = ESColor.labelColor;
        _reNameLabele.text = TEXT_FILE_BOTTOM_RENAME;
        _reNameLabele.textAlignment = NSTextAlignmentCenter;
        _reNameLabele.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    }
    return _reNameLabele;
}

- (UIButton *)reNameCompleteBtn {
    if (nil == _reNameCompleteBtn) {
        _reNameCompleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reNameCompleteBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
        [_reNameCompleteBtn addTarget:self action:@selector(reNameCompleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_reNameCompleteBtn setTitle:NSLocalizedString(@"Confirm", @"确认") forState:UIControlStateNormal];
        [_reNameCompleteBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
    }
    return _reNameCompleteBtn;
}

- (UITextField *)reNameTextField {
    if (nil == _reNameTextField) {
        _reNameTextField = [UITextField new];
        _reNameTextField.borderStyle = UITextBorderStyleNone;
        _reNameTextField.clipsToBounds = YES;
        _reNameTextField.layer.cornerRadius = 6.0f;
        _reNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _reNameTextField.backgroundColor = ESColor.secondarySystemBackgroundColor;
        _reNameTextField.placeholder = NSLocalizedString(@"Please enter a new file name", @"请输入新的文件名") ; 
        [self addSubview:_reNameTextField];
    }
    return _reNameTextField;
}

- (void)setFileInfo:(ESFileInfoPub *)fileInfo {
    _fileInfo = fileInfo;

    self.reNameCellView.hidden = NO;
    self.headImageView.image = IconForFile(fileInfo);

    [self.programView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(0);
        make.left.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(300.0f);
        make.width.mas_equalTo(ScreenWidth);
    }];
    self.titleLabel.text = fileInfo.name;

}

@end
