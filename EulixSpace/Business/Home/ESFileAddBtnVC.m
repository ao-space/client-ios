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
//  ESFileAddBtnVC.m
//  EulixSpace
//
//  Created by qu on 2021/9/1.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileAddBtnVC.h"
#import "ESColor.h"
#import "ESCommentCreateFolder.h"
#import "ESFileSelectPhotoListVC.h"
#import "ESFolderList.h"
#import "ESLocalPath.h"
#import "ESTransferManager.h"
#import "ESUploadMetadata.h"
#import "UIButton+Extension.h"
#import "ESCommonToolManager.h"
#import "ESFolderApi.h"
#import "ESPermissionController.h"
#import "ESLocalizableDefine.h"
#import "ESPermissionController.h"

#import "ESUploadMetadata.h"
#import "ESTransferManager.h"
#import "ESBoxManager.h"
#import "ESQRCodeScanViewController.h"

@import PhotosUI;

@interface ESFileAddBtnVC () <ESMoveCopyViewDelegate, UIDocumentPickerDelegate,PHPickerViewControllerDelegate>

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIButton *delectBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *titleLabel1;

@property (nonatomic, strong) UILabel *pointOutLabel;

@property (nonatomic, strong) UILabel *uploadPositionLabel;

@property (nonatomic, strong) UILabel *uploadPositionTextLabel;

@property (nonatomic, strong) UIButton * scanBtn;
/// 相册
@property (nonatomic, strong) UIButton *intoPhotoBtn;
/// 视频
@property (nonatomic, strong) UIButton *intoVideoBtn;
/// 文档
@property (nonatomic, strong) UIButton *intofileBtn;
/// 新建文件夹
@property (nonatomic, strong) UIButton *intonNewFolderBtn;

@property (nonatomic, strong) ESMoveCopyView *movecopyView;

@property (nonatomic, strong) NSString *pathUpLoadStr;

@property (nonatomic, strong) NSString *pathUpLoadUUID;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, copy) NSString *dir;

@property (nonatomic, copy) NSString *category;

@end


@implementation ESFileAddBtnVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];

    self.view.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFolderClick:) name:@"didEnterFolderClick" object:nil];
}

/// 取消
- (void)didClickDelectBtn:(UIButton *)delectBtn {
    if (self.actionBlock) {
        self.actionBlock(@"delect");
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 self.tabBarController.tabBar.hidden = NO;
                             }];
}

/// 上传相册
- (void)didClickUploadPhotoBtn:(UIButton *)delectBtn {
    self.category = @"photo";
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self toSelectPhotoListVCWithCategory:@"photo"];
            });
        } else if (status == PHAuthorizationStatusDenied) {
            [self noPhotoPermissionwithType];
        }
    }];

}

/// 上传视频
- (void)didClickUploadVideoBtn:(UIButton *)delectBtn {
    self.category = @"video";
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self toSelectPhotoListVCWithCategory:@"video"];
        } else if (status == PHAuthorizationStatusDenied) {
            [self noPhotoPermissionwithType];
        }
    }];
}


-(void)toSelectPhotoListVCWithCategory:(NSString *)category{
    dispatch_async(dispatch_get_main_queue(), ^{
        ESFileSelectPhotoListVC *vc = [[ESFileSelectPhotoListVC alloc] init];
        vc.category = category;
        vc.uploadDir = self.dir;
        self.navigationController.navigationBar.backgroundColor = ESColor.systemBackgroundColor;
        self.navigationController.view.backgroundColor = ESColor.systemBackgroundColor;
        self.navigationController.navigationBar.backgroundColor = ESColor.systemBackgroundColor;
        [self.navigationController pushViewController:vc animated:YES];
    });
}



-(void)noPhotoPermissionwithType{
    if (@available(iOS 14, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHPickerConfiguration *config = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
//                    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
            if([self.category isEqual:@"video"]){
                config.selectionLimit = 10;
                config.filter = [PHPickerFilter videosFilter];
            }else{
                config.selectionLimit = 100;
                config.filter = [PHPickerFilter imagesFilter];
            }

            PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
            pickerViewController.delegate = self;
            [self presentViewController:pickerViewController animated:YES completion:nil];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ESPermissionController showPermissionView:ESPermissionTypeAlbum];
        });
    }
}

/// 上传文件
- (void)didClickUploadFileBtn:(UIButton *)delectBtn {
    [self selectLocalFile];
}

- (void)selectLocalFile {
    NSArray *documentTypes = @[@"public.item"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:documentPicker animated:YES completion:nil];
}

- (void)cancelView {
    if (self.actionBlock) {
        self.actionBlock(@"delect");
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 self.tabBarController.tabBar.hidden = NO;
                             }];
}
/// 新加文件夹
- (void)didClickNewFolderBtn:(UIButton *)delectBtn {
    NSArray *array = [self.uploadPositionTextLabel.text componentsSeparatedByString:@"/"];
    if (array.count >= 20) {
        [ESToast toastError: NSLocalizedString(@"Too many folder layers, no more than 20 layers", @"文件夹层数过多，不得超过20层")];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"file_new_file", @"新建文件夹") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确认")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
                                                        ESCommentCreateFolder *checkTool = [ESCommentCreateFolder new];
                                                        NSString *checkStr = [checkTool checkCreateFolder:alert.textFields.lastObject.text];
                                                        if (checkStr.length > 0) {
                                                
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                [self presentViewController:alert animated:YES completion:nil];
                                                            });
                                                      
                                                            
                                                            [ESToast toastSuccess:checkStr];
                                                            return;
                                                        }
                                                        ESFolderApi *api = [ESFolderApi new];
                                                        ESCreateFolderReq *body = [ESCreateFolderReq new];
                                                        if (self.pathUpLoadUUID.length > 0) {
                                                            body.currentDirUuid = self.pathUpLoadUUID;
                                                        } else {
                                                            NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path_uuid"];
                                                            body.currentDirUuid = uuid;
                                                        }
                                                        body.folderName = alert.textFields.lastObject.text;

                                                        [api spaceV1ApiFolderCreatePostWithCreateFolderReq:body
                                                                                         completionHandler:^(ESRspFileInfo *output, NSError *error) {
                                                                                             if (!error) {
                                                                                                 if (output.code.intValue == 1015) {
                                                                                                     [ESToast toastError: NSLocalizedString(@"Too many folder layers, no more than 20 layers", @"文件夹层数过多，不得超过20层")];
                                                                                                 } else if (output.code.intValue == 1013) {
                                                                                                     [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
                                                                                                 } else {
                                                                                                     [ESToast toastSuccess:NSLocalizedString(@"New Folder Succeed", @"新建文件夹成功")];
                                                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"newCreateFolder" object:nil];
                                                                                                     [self cancelView];
                                                                                                 }
                                                                                             }else{
                                                                                                  [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                                                                             }
                                                                                         }];
                                                    }];
    //2.2 取消按钮
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Please enter a folder name", @"请输入文件夹名称");
    }];

    //3.将动作按钮 添加到控制器中
    [alert addAction:conform];
    [alert addAction:cancel];

    //4.显示弹框
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)viewDidLayoutSubviews {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 50);
    self.scanBtn.transform = transform;
    self.intoPhotoBtn.transform = transform;
    self.intoVideoBtn.transform = transform;
    self.intofileBtn.transform = transform;
    self.intonNewFolderBtn.transform = transform;
    
    weakfy(self);
  
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
        strongfy(self);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0);
        self.scanBtn.transform = transform;
        self.intoPhotoBtn.transform = transform;
        self.intoVideoBtn.transform = transform;
        self.intofileBtn.transform = transform;
        self.intonNewFolderBtn.transform = transform;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)initUI {
    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view).offset(0);
        make.height.mas_equalTo(660.0f);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    self.titleLabel.text = @"Hi~";
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.programView.mas_left).offset(29);
        make.top.mas_equalTo(self.programView.mas_top).offset(40);
        make.height.mas_equalTo(25.0f);
        make.width.mas_equalTo(28.0f);
    }];
    
    self.titleLabel1.text = TEXT_V2_POINTOUT;
    [self.titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.programView.mas_left).offset(29);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(22.0f);
        make.width.mas_equalTo(192.0f);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.programView.mas_right).offset(-25);
        make.top.mas_equalTo(self.programView.mas_top).offset(40);
        make.height.mas_equalTo(72.0f);
        make.width.mas_equalTo(90.0f);
    }];
    
    NSArray *buttons = @[self.intoPhotoBtn, self.intoVideoBtn, self.intofileBtn, self.intonNewFolderBtn];
    CGFloat btnSpacing = (ScreenWidth - 30 * 2 - 70 * 4) / 3 ;
//    [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:btnSpacing leadSpacing:30 tailSpacing:30];
//
//    [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.programView.mas_top).offset(151.0f);
//        make.height.mas_equalTo(90.0f);
//    }];
//

    [self.intoPhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(151.0f);
        make.left.mas_equalTo(self.view).offset(30.0f);
        make.height.mas_equalTo(90.0f);
        make.width.mas_equalTo(70.0f);
    }];

    [self.scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.intoPhotoBtn.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(30.0f);
        make.height.mas_equalTo(90.0f);
        make.width.mas_equalTo(60.0f);
    }];
    
    [self.intoVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.intoPhotoBtn);
        make.left.mas_equalTo(self.intoPhotoBtn.mas_right).offset(btnSpacing);
        make.height.mas_equalTo(90);
        make.width.mas_equalTo(70.0f);
    }];

    [self.intofileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.intoVideoBtn);
        make.left.mas_equalTo(self.intoVideoBtn.mas_right).offset(btnSpacing);
        make.height.mas_equalTo(90);
        make.width.mas_equalTo(70.0f);
    }];

    [self.intonNewFolderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.intofileBtn);
        make.left.mas_equalTo(self.intofileBtn.mas_right).offset(btnSpacing);
        make.height.mas_equalTo(90);
        make.width.mas_equalTo(70.0f);
    }];

    
    UIFont *fnt = [UIFont fontWithName:@"PingFangSC-Medium" size:14];

       // 根据字体得到NSString的尺寸
    CGSize size = [self.uploadPositionLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName,nil]];

    [self.uploadPositionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom).offset(119.0f);
        make.left.mas_equalTo(self.programView.mas_left).offset(31);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(size.width+5);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-25.0);
        make.left.mas_equalTo(self.view.mas_left).offset(25);
        make.height.mas_equalTo(1.0f);
        make.top.mas_equalTo(self.scanBtn.mas_bottom).offset(30);
    }];
    
    [self.pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view).inset(28);
        make.top.mas_equalTo(self.line.mas_bottom).offset(29);
    }];

    
    [self.uploadPositionTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom).offset(119.0f);
        make.left.mas_equalTo(self.uploadPositionLabel.mas_right).offset(5);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.arrowImageView.mas_right).offset(-11);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.uploadPositionTextLabel.mas_centerY);
        make.height.width.mas_equalTo(16);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
    }];
    
    [self.delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.programView.mas_bottom).offset(-54);;
        make.centerX.mas_equalTo(self.programView.mas_centerX);
        make.height.mas_equalTo(52.0f);
        make.width.mas_equalTo(52.0f);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHiddeSelf:) name:@"didHiddenSelfNSNotification" object:nil];
}

#pragma mark - Lazy Load

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 660, ScreenWidth, 660)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_programView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _programView.bounds;
        maskLayer.path = maskPath.CGPath;
        _programView.layer.mask = maskLayer;
        [self.view addSubview:_programView];
    }
    return _programView;
}

- (void)onScanBtn {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
     if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
         [ESPermissionController showPermissionView:ESPermissionTypeCamera];
     }else{
         ESQRCodeScanViewController *qcCode = [ESQRCodeScanViewController new];
         qcCode.action = ESQRCodeScanActionLogin;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.navigationController.navigationBar.backgroundColor = ESColor.systemBackgroundColor;
             self.navigationController.view.backgroundColor = ESColor.systemBackgroundColor;
             [self.navigationController pushViewController:qcCode animated:YES];
         });
     }
}

- (UIButton *)scanBtn {
    if (nil == _scanBtn) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onScanBtn) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:NSLocalizedString(@"es_scan", @"扫一扫") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [btn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 60, 90);
        [btn sc_setLayout:SCEImageTopTitleBootomStyle spacing:10];
        [self.programView addSubview:btn];
        _scanBtn = btn;
    }
    return _scanBtn;
}

- (UIButton *)intoPhotoBtn {
    if (nil == _intoPhotoBtn) {
        _intoPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_intoPhotoBtn setImage:IMAGE_FILE_UPLOAD_IMAGE forState:UIControlStateNormal];
        [_intoPhotoBtn addTarget:self action:@selector(didClickUploadPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_intoPhotoBtn setTitle:TEXT_FILE_UPLOAD_PHOTO forState:UIControlStateNormal];
        _intoPhotoBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [_intoPhotoBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        _intoPhotoBtn.frame = CGRectMake(0, 0, 70, 90);
        [_intoPhotoBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:10];
        [self.programView addSubview:_intoPhotoBtn];
    }
    return _intoPhotoBtn;
}

- (UIButton *)intoVideoBtn {
    if (nil == _intoVideoBtn) {
        _intoVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_intoVideoBtn setTitle:TEXT_FILE_UPLOAD_VIDEO forState:UIControlStateNormal];
        [_intoVideoBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_intoVideoBtn addTarget:self action:@selector(didClickUploadVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_intoVideoBtn setImage:IMAGE_FILE_UPLOAD_VIDEO forState:UIControlStateNormal];
        _intoVideoBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        _intoVideoBtn.frame = CGRectMake(0, 0, 70, 90);
        [_intoVideoBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:10];
        [self.programView addSubview:_intoVideoBtn];
    }
    return _intoVideoBtn;
}

- (UIButton *)intofileBtn {
    if (nil == _intofileBtn) {
        _intofileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _intofileBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [_intofileBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_intofileBtn addTarget:self action:@selector(didClickUploadFileBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_intofileBtn setImage:IMAGE_FILE_UPLOAD_DOCUMENT forState:UIControlStateNormal];
        [_intofileBtn setTitle:TEXT_FILE_UPLOAD_DOCUMENT forState:UIControlStateNormal];
        _intofileBtn.frame = CGRectMake(0, 0, 70, 90);
        [_intofileBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:10];
//        _intofileBtn.imageEdgeInsets = UIEdgeInsetsMake(-25 ,10 , 0, 0);
        [self.programView addSubview:_intofileBtn];
    }
    return _intofileBtn;
}
- (UIButton *)intonNewFolderBtn {
    if (nil == _intonNewFolderBtn) {
        _intonNewFolderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _intonNewFolderBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [_intonNewFolderBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_intonNewFolderBtn addTarget:self action:@selector(didClickNewFolderBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_intonNewFolderBtn setImage:IMAGE_FILE_NEWFOLDER forState:UIControlStateNormal];
        //关键语句
        [_intonNewFolderBtn setTitle:NSLocalizedString(@"Folder_Add", @"新建文件夹") forState:UIControlStateNormal];
        _intonNewFolderBtn.frame = CGRectMake(0, 0, 70, 90);
        [_intonNewFolderBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:10];
        [self.programView addSubview:_intonNewFolderBtn];
    }
    return _intonNewFolderBtn;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(didClickDelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:[UIImage imageNamed:@"shangchuan"] forState:UIControlStateNormal];
        [self.programView addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.text = TEXT_FILE_UPLOAD_OR_NEW;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)titleLabel1 {
    if (!_titleLabel1) {
        _titleLabel1 = [[UILabel alloc] init];
        _titleLabel1.textColor = ESColor.grayLabelColor;
        _titleLabel1.text = TEXT_FILE_UPLOAD_OR_NEW;
        _titleLabel1.textAlignment = NSTextAlignmentCenter;
        _titleLabel1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.programView addSubview:_titleLabel1];
    }
    return _titleLabel1;
}
- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [[UILabel alloc] init];
        _pointOutLabel.textColor = ESColor.secondaryLabelColor;
        _pointOutLabel.numberOfLines = 0;
        _pointOutLabel.text = TEXT_ADD_POINTOUT;
        _pointOutLabel.textAlignment = NSTextAlignmentLeft;
        _pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.programView addSubview:_pointOutLabel];
    }
    return _pointOutLabel;
}

- (UILabel *)uploadPositionLabel {
    if (!_uploadPositionLabel) {
        _uploadPositionLabel = [[UILabel alloc] init];
        _uploadPositionLabel.textColor = ESColor.labelColor;
        _uploadPositionLabel.text = TEXT_FILE_UPLOAD_PLACE;
        _uploadPositionLabel.textAlignment = NSTextAlignmentCenter;
        _uploadPositionLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.programView addSubview:_uploadPositionLabel];
        
    }
    return _uploadPositionLabel;
}

- (UILabel *)uploadPositionTextLabel {
    if (!_uploadPositionTextLabel) {
        _uploadPositionTextLabel = [[UILabel alloc] init];
        _uploadPositionTextLabel.textColor = ESColor.primaryColor;
        NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path"];

        NSString *myStr = NSLocalizedString(@"me_space", @"我的空间");
        if (path.length > 0) {
            _uploadPositionTextLabel.text = [NSString stringWithFormat:@"%@%@",myStr,path];
        } else {
            _uploadPositionTextLabel.text =  NSLocalizedString(@"me_space", @"我的空间");
        }
        _uploadPositionTextLabel.textAlignment = NSTextAlignmentLeft;
        _uploadPositionTextLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.programView addSubview:_uploadPositionTextLabel];
        UITapGestureRecognizer *tapRecognizerWeibo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPathClick:)];
        _uploadPositionTextLabel.userInteractionEnabled = YES;
        [_uploadPositionTextLabel addGestureRecognizer:tapRecognizerWeibo];
    }
    return _uploadPositionTextLabel;
}

- (void)selectPathClick:(UITapGestureRecognizer *)tag {
    self.movecopyView.hidden = NO;

    self.movecopyView.uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path_uuid"];
    self.movecopyView.selectNum = self.selectNum;
    //self.movecopyView.name = self.uploadPositionTextLabel.text;
    NSArray *array = [self.uploadPositionTextLabel.text componentsSeparatedByString:@"/"];
    if (array.count > 0) {
        NSString *str = array[array.count - 1];
        if (str.length < 1) {
            self.movecopyView.name = array[array.count - 2];
        } else {
            self.movecopyView.name = array[array.count - 1];
        }
    }
}

- (ESMoveCopyView *)movecopyView {
    if (!_movecopyView) {
        _movecopyView = [[ESMoveCopyView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _movecopyView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _movecopyView.delegate = self;
        [self.view addSubview:_movecopyView];
    }
    return _movecopyView;
}

- (void)fileMoveCopyView:(ESMoveCopyView *_Nullable)fileBottomToolView didClicCancelBtn:(UIButton *_Nonnull)button {
    self.movecopyView.hidden = YES;
}

- (void)fileMoveCopyView:(ESMoveCopyView *_Nullable)fileBottomToolView didClickCompleteBtnWithPath:(NSString *_Nullable)pathName selectUUID:(NSString *_Nullable)uuid category:(NSString *)category {
    self.pathUpLoadUUID = uuid;
    self.dir = pathName;
    NSString *str = NSLocalizedString(@"me_space", @"我的空间");
    self.uploadPositionTextLabel.text = [NSString stringWithFormat:@"%@%@",str,pathName];
    [[NSUserDefaults standardUserDefaults] setObject: pathName forKey:@"select_up_path"];

    self.movecopyView.hidden = YES;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self.view addSubview:_line];
    }
    return _line;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [UIImageView new];
        _arrowImageView.image = IMAGE_FILE_COPYBACK;
        [self.view addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
        _icon.image = [UIImage imageNamed:@"shape"];
        [self.view addSubview:_icon];
    }
    return _icon;
}


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:url
                                            options:NSFileCoordinatorReadingWithoutChanges
                                              error:&error
                                         byAccessor:^(NSURL *cloudFileURL) {
                                             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//                                             [ESToast toastSuccess:TEXT_ADDED_TO_TRANSFER_LIST];
                                             [self didClickDelectBtn:nil];
                                             @autoreleasepool {
                                                 NSError *blockError = nil;
                                                 NSString *name = cloudFileURL.lastPathComponent;
                                                 NSString *shortPath = [NSString randomCacheLocationWithName:name];
                                                 NSString *local = shortPath.fullCachePath;
                                                 [[NSFileManager defaultManager] copyItemAtURL:cloudFileURL toURL:[NSURL fileURLWithPath:local] error:&blockError];
                        
                                                 ESUploadMetadata *metadata = [ESUploadMetadata fromFile:local];
                        
                                                 NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path"];
                                           
                                                 if(path.length < 1){
                                                     path = @"/";
                                                 }else{
                                                     if (![path hasSuffix:@"/"]) {
                                                         path = [NSString stringWithFormat:@"%@/", path];
                                                     }
                                                 }
                                                 metadata.folderPath = path;
                                                 metadata.category = @"file";
                                                 [ESTransferManager.manager upload:metadata
                                                                          callback:nil];
                                             }
                                         }];
        [url stopAccessingSecurityScopedResource];
    }
}
#pragma GCC diagnostic pop

/// 进入文件夹
- (void)didEnterFolderClick:(NSNotification *)notifi {
    NSDictionary *dic = notifi.object;
    ESFileInfoPub *fileInfo = dic[@"fileInfo"];
    BOOL isMoveCopy = [dic[@"isMoveCopy"] boolValue];

    if ([fileInfo.isDir boolValue] && !isMoveCopy) {
    }
}

- (void)didHiddeSelf:(NSNotification *)notifi {
    [self didClickDelectBtn:nil];
}


- (NSString *)saveImageToSandbox:(UIImage *)image name:(NSString *)name{
    // Get the path to the app's Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];

    // Create a unique filename for the image
    NSString *filename = name;
    
    NSString *pathImage = [NSString stringWithFormat:@"%@/%@", ESBoxManager.activeBox.uniqueKey, filename];
 
    // Construct the full path to the image file
    NSString *directoryAtPath = [documentsDirectory stringByAppendingPathComponent:ESBoxManager.activeBox.uniqueKey];

    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:pathImage];
    // Save the image to the file path
    NSData *imageData = UIImagePNGRepresentation(image);
 
     NSFileManager *fileManager = [NSFileManager defaultManager];
     if (![fileManager fileExistsAtPath:directoryAtPath]) {
         [fileManager createDirectoryAtPath:directoryAtPath withIntermediateDirectories:YES attributes:nil error:nil];
     }
     
    [imageData writeToFile:imagePath atomically:YES];

    return imagePath;
}



-(void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)){

    [picker dismissViewControllerAnimated:YES completion:nil];
        
    if([self.category isEqual:@"video"]){
        if (@available(iOS 14, *)) {
            for (PHPickerResult *result in results) {
                {
                    if([result.itemProvider hasItemConformingToTypeIdentifier:@"public.movie"]) {
                        [result.itemProvider loadFileRepresentationForTypeIdentifier:@"public.movie"
                                                                   completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                            if(!error){
                                [self uploadAction:url];
                            }
                      
                        }];
                    }
                }
                self.actionBlock(@"1");
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }
        }
    }else{
        if (@available(iOS 14, *)) {
            for (PHPickerResult *result in results) {
                {
                    if([result.itemProvider hasItemConformingToTypeIdentifier:@"public.image"]) {
                        [result.itemProvider loadFileRepresentationForTypeIdentifier:@"public.image"
                                                                   completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                            if(!error){
                                [self uploadAction:url];
                            }
                        }];
                    }
                }
            }
            self.actionBlock(@"1");
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }
}


-(void)uploadAction:(NSURL * _Nullable ) url{

            NSString *localPath;
            NSString *thumbnail;
            if (url) {
                     // Convert file URL to local path
                     localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[url lastPathComponent]];
                     // Copy file to local path
                     NSError *copyError;
                     if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL fileURLWithPath:localPath] error:&copyError]) {
                     } else {
                         // Load image from local path
                         UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                         if (image) {
                             CGFloat compressionQuality = 0.1; // 设置压缩质量为50%
                             NSData *compressedImageData = UIImageJPEGRepresentation(image, compressionQuality);
                             UIImage *compressedImage = [UIImage imageWithData:compressedImageData];
                             thumbnail = [self saveImageToSandbox:compressedImage name:[url lastPathComponent]];
                         } else {
                             AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                             AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                             imageGenerator.appliesPreferredTrackTransform = YES;
                             CMTime time = CMTimeMake(1, 1); //生成缩略图的时间点
                             CGImageRef thumbnailImageRef = NULL;
                             NSError *thumbnailImageGenerationError = nil;

                             thumbnailImageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&thumbnailImageGenerationError];

                             if (!thumbnailImageRef) {
                                 ESDLog(@"生成视频缩略图失败：%@", thumbnailImageGenerationError);
                             }

                             UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef];
                             CGImageRelease(thumbnailImageRef);
                             NSString *imageName = [url lastPathComponent];

                             NSString *fileNameWithoutExtension = [imageName stringByDeletingPathExtension]; // 获取没有扩展名的文件名
                             NSString *newFileName = [fileNameWithoutExtension stringByAppendingPathExtension:@"png"]; // 使用新扩展名创建新文件名

                             thumbnail = [self saveImageToSandbox:thumbnailImage name:newFileName];

                         }

                         // Delete file from temporary directory
                         NSError *deleteError;
                         if (![[NSFileManager defaultManager] removeItemAtURL:url error:&deleteError]) {
                             ESDLog(@"Error deleting file: %@", [deleteError localizedDescription]);
                         } else {
                             ESDLog(@"File deleted from temporary directory");
                         }
                     }
                 }

            dispatch_async(dispatch_get_main_queue(), ^{
                CGImageSourceRef imgSrc = CGImageSourceCreateWithData((__bridge CFDataRef)[NSData dataWithContentsOfURL:url], NULL);
                CFDictionaryRef metadataDictionaryRef = CGImageSourceCopyPropertiesAtIndex(imgSrc, 0, NULL);
                NSDictionary *exifDictionary = (__bridge_transfer NSDictionary *)metadataDictionaryRef;
                NSDictionary *dic = exifDictionary[@"{Exif}"];
                NSString *dateTimeOriginal = dic[@"DateTimeOriginal"];

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                NSDate *dateTime = [dateFormatter dateFromString:dateTimeOriginal];
                NSTimeInterval timestamp = [dateTime timeIntervalSince1970];

                NSString *imageName = [url lastPathComponent];
                ESUploadMetadata *metadata = [ESUploadMetadata new];
                NSData *imageData = [NSData dataWithContentsOfURL:url];

                metadata.url = localPath;

                 NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path"];

                 if(path.length < 1){
                     path = @"/";
                 }else{
                     if (![path hasSuffix:@"/"]) {
                         path = [NSString stringWithFormat:@"%@/", path];
                     }
                 }

                metadata.folderPath = path;
                metadata.multipart = YES;
                metadata.category = self.category;
                metadata.source = @"video";
                metadata.photoNum = @(0);
                metadata.noPermissionthumbnailPath = thumbnail;
                NSUInteger timestampInt = (NSUInteger)timestamp;

                metadata.creationDate = timestampInt;
                metadata.modificationDate = timestampInt;
                metadata.fileName = imageName;
                metadata.originalFilename = imageName;
                metadata.localDataFile = localPath;

                NSError *error;
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:metadata.url error:&error];
                long long fileSize;
                {
                    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
                    fileSize = [fileSizeNumber longLongValue];
                }
            
                metadata.size = fileSize;
                metadata.permission = @"NO";

                [ESTransferManager.manager upload:metadata
                                              callback:^(ESRspUploadRspBody *result, NSError *error) {
                    
                }];
       
                [self.view setNeedsLayout];
            });
}

@end
