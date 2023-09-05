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
//  ESAlbumInfoEditeVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAlbumInfoEditeVC.h"
#import "ESAlbumModifyModule.h"
#import "ESThemeDefine.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESToast.h"
#import "ESAlbumPageVC.h"

@interface ESInfoEditViewController ()

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end

@interface ESInfoEditViewController ()

@property (nonatomic, strong) UITextField *input;
@property (nonatomic, assign) UILabel *prompt;
@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, copy) NSString *naviTitle;

- (void)submit;

@end

@interface ESAlbumInfoEditeVC ()

@property (nonatomic, assign) BOOL createSuccess;

@end

@implementation ESAlbumInfoEditeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [self barItemWithTitle:TEXT_OK selector:@selector(submit)];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    if (self.editeType == ESAlbumInfoEditeTypeName ||
        self.editeType == ESAlbumInfoEditeTypeAddAlbum ||
        self.editeType == ESAlbumInfoEditeTypeAddAlbumFromActionSheet) {
        self.prompt.text = NSLocalizedString(@"album_support", @"支持中文、英文、数字、下划线，最长10个字");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]||[obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            obj.backgroundColor = ESColor.systemBackgroundColor;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]||[obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
        obj.backgroundColor = nil;
        }
    }];
    if (!self.createSuccess) {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }
}

- (void)setEditeType:(ESAlbumInfoEditeType)editeType {
    _editeType = editeType;
    if (editeType == ESAlbumInfoEditeTypeName) {
        self.limit = 10;
        self.naviTitle = NSLocalizedString(@"album_name", @"相簿名称");
    } else if (editeType == ESAlbumInfoEditeTypeAddAlbum || editeType == ESAlbumInfoEditeTypeAddAlbumFromActionSheet) {
        self.limit = 10;
        self.naviTitle = NSLocalizedString(@"New Album", @"新建相簿");
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.limit > 0 && result.length > self.limit) {
        return NO;
    }
    if (![self validateTextInput:result]) {
        [ESToast toastError:NSLocalizedString(@"album_specification", @"名称输入不符合规范")];
        return NO;
    }
    return [super textField:textField shouldChangeCharactersInRange:range replacementString:string];;
}

- (void)submit {
    if (self.input.text.length <= 0) {
        [ESToast toastError:NSLocalizedString(@"album_specification", @"名称输入不符合规范")];
        return;
    }
    if (self.editeType == ESAlbumInfoEditeTypeName) {
        [ESAlbumModifyModule modifyAlbumName:self.input.text
                                      albumId:[self.albumModel.albumId integerValue]
                                  completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
            if (error != nil) {
                [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                return;
            }
            if (success) {
                ESAlbumModel *albumModel = [ESSmartPhotoDataBaseManager.shared getAlbumByid:self.albumModel.albumId];
                albumModel.albumName = self.input.text;
                [ESSmartPhotoDataBaseManager.shared insertOrUpdateAlbumsToDB:@[albumModel]];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        return;
    }
    
    if (self.editeType == ESAlbumInfoEditeTypeAddAlbum) {
        [ESAlbumModifyModule createAlbumName:self.input.text
                                  completion:^(ESAlbumModifyType modifyType, ESCreateAlbumResponseModel * _Nullable albumInfo, NSError * _Nullable error) {
            if (error != nil) {
                if ([error.userInfo[@"code"] isEqual:@(1057)]) {
//                    [ESToast toastError:[NSString stringWithFormat:@"相簿“%@”命名重复", self.input.text]];
                    [ESToast toastError:NSLocalizedString(@"Duplicatewithanotheralbumname", @"与其他相簿名称重复")];
                    return;

                }
                [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                return;
            }
            if (albumInfo != nil) {
                ESAlbumModel *album = [ESAlbumModel new];
                album.albumId = [NSString stringWithFormat:@"%ld", (long)albumInfo.albumId];
                album.albumName = albumInfo.albumName;
                album.createdAt = albumInfo.createdAt;
                album.modifyAt = albumInfo.modifyAt;
                album.type = @(albumInfo.type);
                
                [ESSmartPhotoDataBaseManager.shared insertOrUpdateAlbumsToDB:@[album]];
                self.createSuccess = YES;
                ESAlbumPageVC *albumPageVc = [[ESAlbumPageVC alloc] init];
                albumPageVc.albumModel = album;
                NSMutableArray *subVC = [self.navigationController.viewControllers mutableCopy];
                [subVC removeLastObject];
                [subVC addObject:albumPageVc];
                [self.navigationController setViewControllers:subVC];
            }
            
            [ESToast toastSuccess:[NSString stringWithFormat:NSLocalizedString(@"album_successed_%@", @"%@创建成功"), self.input.text]];
           
        }];
        return;
    }
    
    if (self.editeType == ESAlbumInfoEditeTypeAddAlbumFromActionSheet) {
        [ESAlbumModifyModule createAlbumName:self.input.text
                                  completion:^(ESAlbumModifyType modifyType, ESCreateAlbumResponseModel * _Nullable albumInfo, NSError * _Nullable error) {
            if (error != nil) {
                if ([error.userInfo[@"code"] isEqual:@(1057)]) {
//                    [ESToast toastError:[NSString stringWithFormat:@"相簿“%@”命名重复", self.input.text]];
                    [ESToast toastError:NSLocalizedString(@"Duplicatewithanotheralbumname", @"与其他相簿名称重复")];
                    if (self.albumModelCreatedBlock) {
                        self.albumModelCreatedBlock(NO, nil);
                    }
                    return;

                }
                [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
//                [ESToast toastError:[NSString stringWithFormat:NSLocalizedString(@"album_fail_%@", @"%@创建失败"), self.input.text]];
                return;
            }
            if (albumInfo != nil) {
                ESAlbumModel *album = [ESAlbumModel new];
                album.albumId = [NSString stringWithFormat:@"%ld", (long)albumInfo.albumId];
                album.albumName = albumInfo.albumName;
                album.createdAt = albumInfo.createdAt;
                album.modifyAt = albumInfo.modifyAt;
                album.type = @(albumInfo.type);
                
                [ESSmartPhotoDataBaseManager.shared insertOrUpdateAlbumsToDB:@[album]];
                if (self.albumModelCreatedBlock) {
                    self.albumModelCreatedBlock(YES, album);
                }
                self.createSuccess = YES;
                NSMutableArray *subVC = [self.navigationController.viewControllers mutableCopy];
                [subVC removeLastObject];
                [self.navigationController setViewControllers:subVC];
            }
            
            [ESToast toastSuccess:[NSString stringWithFormat:NSLocalizedString(@"album_successed_%@", @"%@创建成功"), self.input.text]];
           
        }];
        return;
    }
}

- (BOOL)validateTextInput:(NSString *)textString {
    NSString *other = @"➋➌➍➎➏➐➑➒";
    NSString *number=@"^(?!\\s)[0-9a-zA-Z_\u4e00-\u9fa5\\s]*$";
    if(textString.length > 0 &&
       [other rangeOfString:[textString substringFromIndex:(textString.length - 1)]].location != NSNotFound) {
        return  YES;
    }
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
 }

@end
