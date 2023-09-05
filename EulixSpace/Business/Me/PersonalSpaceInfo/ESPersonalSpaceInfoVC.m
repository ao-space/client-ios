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
//  ESPersonalSpaceInfoVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESPersonalSpaceInfoVC.h"
#import "ESPersonalSpaceInfoModule.h"
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
#import "ESNetworkRequestManager.h"
#import "UIView+Status.h"
#import "ESGatewayManager.h"
#import "ESAES.h"
#import <YYModel/YYModel.h>
#import "NSString+ESTool.h"

@implementation ESConnectedNetworkModel

@end

@implementation ESInternetServiceConfigModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"connectedNetwork" : [ESConnectedNetworkModel class] };
}

@end

@interface ESPersonalSpaceInfoVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) ESGradientButton *switchButton;

@end

@implementation ESPersonalSpaceInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    self.navigationItem.title = NSLocalizedString(@"binding_spatialinformation", @"空间信息");
//    [self.switchButton setTitle:TEXT_ME_PERSONAL_SWITCH_ACCOUNT forState:UIControlStateNormal];
    
    self.showBackBt = YES;
    [self.listModule reloadData:[(ESPersonalSpaceInfoModule *)self.listModule loadData]];
    
    [ESAccountManager.manager loadInfo:^(ESPersonalInfoResult *info) {
        [self.listModule reloadData:[(ESPersonalSpaceInfoModule *)self.listModule loadData]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.listModule reloadData:[(ESPersonalSpaceInfoModule *)self.listModule loadData]];
    [self loadeInternetAccessStatus];
}

- (void)loadeInternetAccessStatus {
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-agent-service"
                                                    apiName:@"internet_service_get_config"
                                                queryParams:@{@"clientUUID" : ESSafeString(ESBoxManager.clientUUID),
                                                              @"aoId" : ESSafeString(dic[@"aoId"])
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@"ESInternetServiceConfigModel"
                                               successBlock:^(NSInteger requestId, ESInternetServiceConfigModel *_Nullable response) {
        strongfy(self)
        ESBoxManager.activeBox.enableInternetAccess = response.enableInternetAccess;
        if (response.userDomain.length > 0 &&
            ![response.userDomain isEqualToString:ESSafeString(ESBoxManager.activeBox.info.userDomain)]) {
            ESBoxManager.activeBox.info.userDomain = response.userDomain;
        }
        [ESBoxManager.manager saveBox:ESBoxManager.activeBox];

        [self.listModule reloadData:[(ESPersonalSpaceInfoModule *)self.listModule loadData]];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
    }];
    

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
              [self.listModule reloadData:[(ESPersonalSpaceInfoModule *)self.listModule loadData]];
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
    // ESFamilyListVC *next = [ESFamilyListVC new];
    ESBoxListViewController *next = [ESBoxListViewController new];
    // next.category = @"设备列表";
    [self.navigationController pushViewController:next animated:YES];
}

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

- (Class)listModuleClass {
    return [ESPersonalSpaceInfoModule class];
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}


- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
