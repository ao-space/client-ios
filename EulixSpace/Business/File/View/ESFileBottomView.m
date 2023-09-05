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
//  ESFileBottomView.m
//  EulixSpace
//
//  Created by qu on 2021/2/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileBottomView.h"
#import "ESColor.h"
#import "ESCommentCreateFolder.h"
#import "ESFileBottomBtnView.h"
#import "ESGlobalMacro.h"
#import "ESImageDefine.h"
#import "ESLocalizableDefine.h"
#import "ESCommonToolManager.h"
#import "ESToast.h"

@interface ESFileBottomView () <ESMoveCopyViewDelegate>

/// 下载
@property (nonatomic, strong) ESFileBottomBtnView *downBtn;
/// 分享
@property (nonatomic, strong) ESFileBottomBtnView *shareBtn;
/// 删除
@property (nonatomic, strong) ESFileBottomBtnView *delectBtn;
/// 详情
@property (nonatomic, strong) ESFileBottomBtnView *detailsBtn;
/// 查看更多
@property (nonatomic, strong) ESFileBottomBtnView *moreBtn;

/// 复制
@property (nonatomic, strong) ESFileBottomBtnView *copyBtn;
/// 移动
@property (nonatomic, strong) ESFileBottomBtnView *moveBtn;

/// 重命名
@property (nonatomic, strong) ESFileBottomBtnView *reNameBtn;

@end

@implementation ESFileBottomView

- (void)setIsMoreSelect:(BOOL)isMoreSelect {
    self.backgroundColor = ESColor.systemBackgroundColor;
    self.reNameBtn.hidden = YES;
    CGFloat middle;

    middle = (ScreenWidth - 26 * 2 - 40 * 5)/4 ;
 
    if (isMoreSelect) {
        self.shareBtn.hidden = YES;
        self.detailsBtn.hidden = YES;
        self.moreBtn.hidden = YES;
        self.copyBtn.hidden = NO;
        self.moveBtn.hidden = NO;
        if (self.isHaveDir) {
            self.downBtn.hidden = YES;
            self.delectBtn.frame = CGRectMake(26, 9, 40, 40);
            self.copyBtn.frame = CGRectMake(26 + 40 + middle, 9, 40, 40);
            self.moveBtn.frame = CGRectMake(26 + 40*2 + middle*2, 9, 40, 40);
            self.backgroundColor = [ESColor systemBackgroundColor];
        } else {
            self.downBtn.hidden = NO;
            self.moveBtn.hidden = NO;
            self.downBtn.frame = CGRectMake(26, 9, 40, 40);
            self.delectBtn.frame = CGRectMake(26 + 40 + middle, 9, 40, 40);
            self.copyBtn.frame = CGRectMake(26 + 40*2 + middle*2, 9, 40, 40);
            self.moveBtn.frame = CGRectMake(26 + 40*3 + middle*3, 9, 40, 40);
            self.backgroundColor = [ESColor systemBackgroundColor];
        }
    } else {
        if ([self.fileInfo.isDir boolValue]) {
            self.shareBtn.hidden = YES;
            self.downBtn.hidden = YES;
            self.detailsBtn.hidden = NO;
            self.reNameBtn.hidden = NO;
            self.copyBtn.hidden = NO;
            self.moveBtn.hidden = NO;
            self.moreBtn.hidden = YES;


            self.delectBtn.frame = CGRectMake(26, 9, 40, 40);
            self.detailsBtn.frame = CGRectMake(26 + 40 + middle, 9, 40, 40);
            self.reNameBtn.frame = CGRectMake(26 + 40*2 + middle*2, 9, 40, 40);
            self.copyBtn.frame =  self.moveBtn.frame = CGRectMake(26 + 40*3 + middle*3, 9, 40, 40);
            self.moveBtn.frame = CGRectMake(26 + 40*4 + middle*4, 9, 40, 40);

        } else {
            self.reNameBtn.hidden = YES;
            self.shareBtn.hidden = NO;
            self.detailsBtn.hidden = NO;
            self.downBtn.hidden = NO;
            self.copyBtn.hidden = YES;
            self.downBtn.hidden = NO;
            self.moveBtn.hidden = YES;
            self.moreBtn.hidden = NO;

            self.downBtn.frame = CGRectMake(26, 9, 40, 40);
            self.shareBtn.frame = CGRectMake(26 + 40 + middle, 9, 40, 40);
            self.delectBtn.frame = CGRectMake(26 + 40*2+ middle*2, 9, 40, 40);
            self.detailsBtn.frame = self.moveBtn.frame = CGRectMake(26 + 40*3+ middle*3, 9, 40, 40);
            self.moreBtn.frame = CGRectMake(26 + 40*4 + middle*4, 9, 40, 40);
  

        }
    }
    [self setNeedsUpdateConstraints];
}

/// 下载
- (void)didClickDownBtn:(UIButton *)downBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomToolView:didClickDownBtn:)]) {
        [self.delegate fileBottomToolView:self didClickDownBtn:downBtn];
    }
}

/// 分享
- (void)didClickShareBtn:(UIButton *)shareBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomToolView:didClickShareBtn:)]) {
        [self.delegate fileBottomToolView:self didClickShareBtn:shareBtn];
    }
}

/// 删除
- (void)didClickDelectBtn:(UIButton *)detailsBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomToolView:didClickDelectBtn:)]) {
        [self.delegate fileBottomToolView:self didClickDelectBtn:detailsBtn];
    }
}

///详情
- (void)didClickDetailsBtn:(UIButton *)detailsBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomToolView:didClickDetailsBtn:)]) {
        [self.delegate fileBottomToolView:self didClickDetailsBtn:detailsBtn];
    }
}

/// 更多
- (void)didClickMoreBtn:(UIButton *)moreBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomToolView:didClickMoreBtn:)]) {
        [self.delegate fileBottomToolView:self didClickMoreBtn:moreBtn];
    }
}

- (ESFileBottomBtnView *)downBtn {
    if (nil == _downBtn) {
        _downBtn = [[ESFileBottomBtnView alloc] init];
        _downBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_DOWN;
        _downBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_DOWN;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickDownBtn:)];
        [_downBtn addGestureRecognizer:tapGesture];
        [self addSubview:_downBtn];
    }
    return _downBtn;
}

- (ESFileBottomBtnView *)shareBtn {
    if (nil == _shareBtn) {
        _shareBtn = [[ESFileBottomBtnView alloc] init];
        _shareBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_SHARE;
        _shareBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_SHARE;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickShareBtn:)];
        [_shareBtn addGestureRecognizer:tapGesture];
        [self addSubview:_shareBtn];
    }
    return _shareBtn;
}

- (ESFileBottomBtnView *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [[ESFileBottomBtnView alloc] init];
        _delectBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_DELECT;
        _delectBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_DEL;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickDelectBtn:)];
        [_delectBtn addGestureRecognizer:tapGesture];
        [self addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (ESFileBottomBtnView *)detailsBtn {
    if (nil == _detailsBtn) {
        _detailsBtn = [[ESFileBottomBtnView alloc] init];
        _detailsBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_DETAILS;
        _detailsBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_DETAILS;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickDetailsBtn:)];
        [_detailsBtn addGestureRecognizer:tapGesture];
        [self addSubview:_detailsBtn];
    }
    return _detailsBtn;
}

- (ESFileBottomBtnView *)moreBtn {
    if (nil == _moreBtn) {
        _moreBtn = [[ESFileBottomBtnView alloc] init];
        _moreBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_MORE;
        _moreBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_MORE;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickMoreBtn:)];
        [_moreBtn addGestureRecognizer:tapGesture];
        [self addSubview:_moreBtn];
    }
    return _moreBtn;
}

- (ESFileBottomBtnView *)copyBtn {
    if (nil == _copyBtn) {
        _copyBtn = [[ESFileBottomBtnView alloc] init];
        _copyBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_COPY;
        _copyBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_COPY;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickCopyBtn:)];
        [_copyBtn addGestureRecognizer:tapGesture];
        [self addSubview:_copyBtn];
    }
    return _copyBtn;
}

- (ESFileBottomBtnView *)moveBtn {
    if (nil == _moveBtn) {
        _moveBtn = [[ESFileBottomBtnView alloc] init];
        _moveBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_MOVE;
        _moveBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_MOVE;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickMoveBtn:)];
        [_moveBtn addGestureRecognizer:tapGesture];
        [self addSubview:_moveBtn];
    }
    return _moveBtn;
}

- (ESFileBottomBtnView *)reNameBtn {
    if (nil == _reNameBtn) {
        _reNameBtn = [[ESFileBottomBtnView alloc] init];
        _reNameBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_RENAME;
        _reNameBtn.fileBottomBtnImageView.image = IMAGE_FILE_RENAME;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickReNameBtn:)];
        [_reNameBtn addGestureRecognizer:tapGesture];
        [self addSubview:_reNameBtn];
    }
    return _reNameBtn;
}

/// 复制
- (void)didClickCopyBtn:(UIButton *)moreBtn {
    self.movecopyView.category = @"copy";
    self.movecopyView.isSelectUUIDSArray = self.isSelectUUIDSArray;
    self.movecopyView.selectNum = self.isSelectUUIDSArray.count;
    self.movecopyView.name = self.fileInfo.name;
    self.movecopyView.uuid = @"";
    self.movecopyView.hidden = NO;
}

/// 移动
- (void)didClickMoveBtn:(UIButton *)moreBtn {
    self.movecopyView.category = @"move";
    self.movecopyView.selectNum = self.isSelectUUIDSArray.count;
    self.movecopyView.name = self.fileInfo.name;
    self.movecopyView.isSelectUUIDSArray = self.isSelectUUIDSArray;
    self.movecopyView.uuid = @"";
    self.movecopyView.hidden = NO;
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

- (void)fileMoveCopyView:(ESMoveCopyView *)fileBottomToolView didClickCompleteBtnWithPath:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomToolView:didClickCopyCompleteWithPathName:selectUUID:category:)]) {
        [self.delegate fileBottomToolView:self didClickCopyCompleteWithPathName:pathName selectUUID:uuid category:category];
    }
}

- (void)fileMoveCopyView:(ESMoveCopyView *)fileBottomToolView didClicCancelBtn:(UIButton *)button {
    self.movecopyView.hidden = YES;
}

- (void)didClickReNameBtn:(UITapGestureRecognizer *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TEXT_FILE_BOTTOM_RENAME message:@"" preferredStyle:UIAlertControllerStyleAlert];
    NSString *fileName = [self.fileInfo.name stringByDeletingPathExtension];
    alert.textFields.firstObject.text = fileName;
    alert.textFields.firstObject.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确认")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
                                                        ESCommentCreateFolder *check = [ESCommentCreateFolder new];
                                                        NSString *checkStr = [check checkReNameFolder:alert.textFields.lastObject.text];
                                                        if (checkStr.length > 0) {
                                                            [ESToast toastSuccess:checkStr];
                                                            return;
                                                        }
                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(fileBottomToolView:didClickReNameCompleteInfo:fileName:category:)]) {
                                                            [self.delegate fileBottomToolView:self didClickReNameCompleteInfo:self.fileInfo fileName:alert.textFields.lastObject.text category:@"ReName"];
                                                        }
                                                    }];
    //2.2 取消按钮
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Please enter a folder name", @"请输入文件夹名称");
        textField.text = fileName;
    }];

    //3.将动作按钮 添加到控制器中
    [alert addAction:conform];
    [alert addAction:cancel];

    //4.显示弹框
    [[self theTopviewControler] presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)theTopviewControler {
    UIViewController *resultVC;
    resultVC = [self topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if(hidden){
        [self removeFromSuperview];
    }else{
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            
            CGFloat height = 50 + kBottomHeight + 5;
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.mas_equalTo([UIApplication sharedApplication].keyWindow);
                    make.height.mas_equalTo(height);
                    make.bottom.mas_equalTo([UIApplication sharedApplication].keyWindow.mas_bottom).offset(-5);
            }];
        }
    }
}

@end
