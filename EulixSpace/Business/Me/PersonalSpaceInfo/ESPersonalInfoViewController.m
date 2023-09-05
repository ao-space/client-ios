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
//  ESPersonalInfoViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/2.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPersonalInfoViewController.h"
#import "ESAccountManager.h"
#import "ESBoxListViewController.h"
#import "ESFormCell.h"
#import "ESGradientButton.h"
#import "ESInfoEditViewController.h"
#import "ESLocalPath.h"
#import "ESThemeDefine.h"
#import "ESBoxItem.h"
#import "ESCommentCachePlistData.h"
#import "ESBoxManager.h"
#import <Masonry/Masonry.h>
#import <YCEasyTool/NSArray+YCTools.h>
#import <YYModel/YYModel.h>
#import "ESAccountServiceApi.h"
#import <AVFoundation/AVFoundation.h>
#import "ESPermissionController.h"

#define TableData @[                          \
    @{                                        \
        @"title": TEXT_ME_PERSONAL_AVATAR,    \
    },                                        \
    @{                                        \
        @"title": NSLocalizedString(@"me_spaceidentification", @"空间标识"),  \
        @"content": @"傲空间JHSKJ",           \
    },                                        \
    @{                                        \
        @"title": TEXT_ME_PERSONAL_SIGN,      \
        @"content": TEXT_ME_PERSONAL_NO_SIGN, \
    },                                        \
    @{                                        \
        @"title": TEXT_ME_PERSONAL_DOMIN,      \
        @"content": TEXT_ME_DOMAIN_NAME, \
    },                                        \
]

typedef NS_ENUM(NSUInteger, ESPersonalInfoSection) {
    ESPersonalInfoSectionDefault,
};

typedef NS_ENUM(NSUInteger, ESPersonalInfoCell) {
    ESPersonalInfoCellAvatar,
    ESPersonalInfoCellNickname,
    ESPersonalInfoCellSign,
    ESPersonalInfoCellDomain
};

@interface ESPersonalInfoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) ESGradientButton *switchButton;

@end

@implementation ESPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"空间信息"; //TEXT_ME_PERSONAL_INFO;
    self.cellClass = [ESFormCell class];
    self.cellHeight = 60;
    [self.switchButton setTitle:TEXT_ME_PERSONAL_SWITCH_ACCOUNT forState:UIControlStateNormal];
    self.section = @[@(ESPersonalInfoSectionDefault)];
    [self loadData];
    self.hideNavigationBar = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.hideNavigationBar = NO;
    self.tabBarController.tabBar.hidden = YES;
    [ESAccountManager.manager loadInfo:^(ESPersonalInfoResult *info) {
        [self loadData];
    }];
}

- (void)loadData {
    self.dataSource[@(ESPersonalInfoSectionDefault)] = [TableData yc_mapWithBlock:^id(NSUInteger idx, id obj) {
        ESFormItem *item = [ESFormItem yy_modelWithJSON:obj];
        switch (idx) {
            case ESPersonalInfoCellAvatar: {
                if (ESAccountManager.manager.avatarPath) {
                    item.avatarImage = [UIImage imageWithContentsOfFile:ESAccountManager.manager.avatarPath];
                } else {
                    item.avatarImage = IMAGE_ME_AVATAR_DEFAULT;
                }
            } break;
            case ESPersonalInfoCellNickname: {
                item.content = ESAccountManager.manager.userInfo.personalName;
            } break;
            case ESPersonalInfoCellSign: {
                item.content = ESAccountManager.manager.userInfo.personalSign;
            } break;
            case ESPersonalInfoCellDomain: {
                item.hideLine = YES;
                item.isHiddenArrowBtn = YES;
                ESBoxItem *box = ESBoxManager.activeBox;
                NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
                item.content = dic[@"userDomain"];            
            } break;
            default:
                break;
        }
        return item;
    }];
    [self.tableView reloadData];
}

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESFormItem *item = [self objectAtIndexPath:indexPath];
    switch (indexPath.row) {
        case ESPersonalInfoCellAvatar: {
            //修改头像    mine.click.switchHead
            [self changeAvatar];
        } break;
        case ESPersonalInfoCellNickname: {
            //修改昵称    mine.click.changeName
            ESInfoEditViewController *next = [ESInfoEditViewController new];
            next.type = ESInfoEditTypeName;
            next.value = item.content;
            ESBoxItem *box = ESBoxManager.activeBox;
            NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
            next.aoid = dic[@"aoId"];
            next.updateName = ^(NSString *name) {
                        ESAccountManager.manager.userInfo.personalName = name;
                        box.spaceName = name;
                        box.bindUserName = name;
                      };
            [self.navigationController pushViewController:next animated:YES];
        } break;
        case ESPersonalInfoCellSign: {
            //修改个性签名    mine.click.changeSignature
            ESInfoEditViewController *next = [ESInfoEditViewController new];
            next.type = ESInfoEditTypeSign;
            next.value = item.content;
            ESBoxItem *box = ESBoxManager.activeBox;
            NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
            next.aoid = dic[@"aoId"];
            [self.navigationController pushViewController:next animated:YES];
        } break;
        case ESPersonalInfoCellDomain: {
            return;
            
        } break;
      
        default:
            break;
    }
}

//更换头像
- (void)changeAvatar {
    
    //底部弹出来个actionSheet来选择拍照或者相册选择
    UIAlertController *alet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //系统相机拍照
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:TEXT_ME_CAMERA
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                                 imagePicker.delegate = self;
                                                                 imagePicker.allowsEditing = YES;
                                                                 imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                 
                                                                 
                                                                 AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                                                  if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
                                                                      [ESPermissionController showPermissionView:ESPermissionTypeCamera];
                                                                  }else{
                                                                      [self presentViewController:imagePicker animated:YES completion:nil];
                                                                  }
                                                             }
                                                         }];
    //相册选择
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:TEXT_ME_ALBUM
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *_Nonnull action) {
                                                            //这里加一个判断，是否是来自图片库
                                                            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                                                                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                                imagePicker.delegate = self; //协议
                                                                imagePicker.allowsEditing = YES;
                                                                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                [self presentViewController:imagePicker animated:YES completion:nil];
                                                            }
                                                        }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TEXT_CANCEL style:UIAlertActionStyleCancel handler:nil];
    [alet addAction:albumAction];
    [alet addAction:cameraAction];
    [alet addAction:cancelAction];
    [self presentViewController:alet animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self uploadImage:[info objectForKey:UIImagePickerControllerEditedImage]];
                             }];
}

- (void)extracted:(NSString *)localPath {
    [ESAccountManager.manager updateAvatar:localPath.fullCachePath
                                completion:^() {
                                    [self loadData];
    }];
}

- (void)uploadImage:(UIImage *)image {
    NSString *fileName = @"personal.png";
    NSString *localPath = [NSString randomCacheLocationWithName:fileName];
    [UIImagePNGRepresentation(image) writeToFile:localPath.fullCachePath atomically:YES];
    [self extracted:localPath];
}

- (void)switchAccount {
    //切换账号    basic.click.switchAccount
    ESBoxListViewController *next = [ESBoxListViewController new];
    // next.category = @"设备列表";
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Lazy Load

- (ESGradientButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_switchButton setCornerRadius:10];
        [_switchButton setTitle:TEXT_ME_PERSONAL_SWITCH_ACCOUNT forState:UIControlStateNormal];
        _switchButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_switchButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_switchButton setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [self.view addSubview:_switchButton];
        [_switchButton addTarget:self action:@selector(switchAccount) forControlEvents:UIControlEventTouchUpInside];
        [_switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).inset(kBottomHeight + 68);
        }];
    }
    return _switchButton;
}

@end
