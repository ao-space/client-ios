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
//  ESFeedbackViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFeedbackViewController.h"
#import "ESBoxManager.h"
#import "ESFeedbackDefine.h"
#import "ESFeedbackDescCell.h"
#import "ESFeedbackFormCell.h"
#import "ESFeedbackImagItem.h"
#import "ESFeedbackImageCell.h"
#import "ESFeedbackResultView.h"
#import "ESFormItem.h"
#import "ESGradientButton.h"
#import "ESLocalPath.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "UIImage+ESTool.h"
#import "ESPlatformProposalManagementServiceApi.h"
#import <Masonry/Masonry.h>
#import <YCEasyTool/NSArray+YCTools.h>

@interface ESFeedbackImagItem ()

@property (nonatomic, copy) NSString *url;

@end

@interface ESFeedbackViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) ESFormItem *descItem;

@property (nonatomic, strong) ESFormItem *imageItem;

@property (nonatomic, strong) ESFormItem *emailItem;

@property (nonatomic, strong) ESFormItem *phoneItem;

@property (nonatomic, strong) ESGradientButton *submitButton;

@property (nonatomic, strong) ESFeedbackResultView *resultView;

@end

@implementation ESFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_FEEDBACK;
    ESDLog(@"当前平台地址%@", ESPlatformClient.platformClient.baseURL);
    self.cellClassArray = @[
        [ESFeedbackDescCell class],
        [ESFeedbackFormCell class],
        [ESFeedbackImageCell class],
    ];
    self.section = @[@(0)];
    [self initForm];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight + 44);
    }];
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    if (self.snapshootImage) {
        NSParameterAssert([NSFileManager.defaultManager fileExistsAtPath:self.snapshootImage.localPath]);
        NSParameterAssert(self.snapshootImage.image);
    }
    
    //重新设置下级子页面导航栏返回按钮文字
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;


}

/// 初始化页面布局
- (void)initForm {
    NSMutableArray *cellArray = NSMutableArray.array;
    {
        ESFormItem *item = [ESFormItem new];
        item.height = 26 + 22 + 12 + 170;
        item.identifier = @"ESFeedbackDescCell";
        item.title = TEXT_FEEDBACK_DESC;
        item.placeholder = TEXT_FEEDBACK_DESC_PLADEHOLDER;
        self.descItem = item;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        // 左右边距 26 * 2
        // 图片间距 6 * 3
        CGFloat width = (ScreenWidth - kESViewDefaultMargin * 2 - 6 * 3) / 4;
        width = floor(width);
        item.width = width;
        ///对着设计稿
        ///
        item.height = 20 + 22 + 10 + width + 10 + 14;
        item.identifier = @"ESFeedbackImageCell";
        item.title = TEXT_FEEDBACK_UPLOAD_IMAGE_FORMAT;
        item.content = TEXT_FEEDBACK_UPLOAD_IMAGE_PROMPT;
        NSMutableArray *data = NSMutableArray.array;
        item.data = data;
        if (self.snapshootImage) {
            [data addObject:self.snapshootImage];
        }
        self.imageItem = item;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        item.height = 92;
        item.identifier = @"ESFeedbackFormCell";
        item.title = TEXT_FEEDBACK_EMAIL;
        item.placeholder = TEXT_FEEDBACK_EMAIL_PLADEHOLDER;
        self.emailItem = item;
        [cellArray addObject:item];
    }

    {
        ESFormItem *item = [ESFormItem new];
        item.height = 92;
        item.identifier = @"ESFeedbackFormCell";
        item.title = TEXT_FEEDBACK_PHONE_NUMBER;
        item.placeholder = TEXT_FEEDBACK_PHONE_NUMBER_PLADEHOLDER;
        self.phoneItem = item;
        [cellArray addObject:item];
    }
    self.dataSource[@(0)] = cellArray;
}

- (void)submit {
    
    if (self.descItem.content.length < 1) {
        [ESToast toastError:NSLocalizedString(@"feedback_check_no_desc", @"详细描述不能为空，请描述您的问题")];
        return;
    }
    
    if(self.emailItem.content.length < 1 && self.phoneItem.content.length  < 1){
        [ESToast toastError:NSLocalizedString(@"feedback_check_no_email_and_phone_number", @"电话和联系邮箱请至少填写一个")];
        return;
    }
    
    
    if(self.emailItem.content.length > 0){
        if(![self checkEmail:self.emailItem.content]){
            [ESToast toastError:NSLocalizedString(@"feedback_email_error", @"请输入正确的联系邮箱")];
            return;
        }
    }
    
    if(self.phoneItem.content.length > 0){
        if(![self checkPhoneNumber:self.phoneItem.content]){
            [ESToast toastError:NSLocalizedString(@"feedback_phone_error", @"请输入正确的联系方式")];
            return;
        }
    }
    

    ESProposalReq *req = [ESProposalReq new];
    req.content = self.descItem.content;
    req.email = self.emailItem.content;
    if (req.email.length == 0) {
        req.email = nil;
    }
    req.phoneNumber = self.phoneItem.content;
    if (req.phoneNumber.length == 0) {
        req.phoneNumber = nil;
    }
    //
    
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *userId = dic[@"aoId"];
    if(userId.length >0){
        req.userId = userId;
    }else{
        req.userId = ESBoxManager.activeBox.aoid;
    }
    
    req.boxUUID = ESBoxManager.activeBox.boxUUID;
    
    //提交意见反馈    mine.click.feedback
    NSMutableArray<ESFeedbackImagItem *> *imageArray = self.imageItem.data;

    [self.submitButton startLoading:TEXT_FEEDBACK_SUBMIT];
    self.view.userInteractionEnabled = NO;
    dispatch_group_t group = dispatch_group_create();
    [imageArray enumerateObjectsUsingBlock:^(ESFeedbackImagItem *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        dispatch_group_enter(group);
        [self uploadImage:obj
               completion:^(BOOL success) {
                   dispatch_group_leave(group);
               }];
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        req.imageUrls = [imageArray yc_mapWithBlock:^id(NSUInteger idx, ESFeedbackImagItem *obj) {
            return obj.url;
        }];
        if (req.imageUrls.count != imageArray.count) {
            [self.submitButton stopLoading:TEXT_FEEDBACK_SUBMIT];
            self.view.userInteractionEnabled = YES;
            [ESToast toastError:TEXT_FEEDBACK_CHECK_FAILED_TO_UPLOAD_IMAGE];
            return;
        }
        NSURL *requesetUrl = [NSURL URLWithString:ESPlatformClient.platformClient.platformUrl];
        ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
        ESPlatformProposalManagementServiceApi *api = [[ESPlatformProposalManagementServiceApi alloc] initWithApiClient:client];
        [api proposalSaveWithBody:req
                completionHandler:^(ESProposalRes *output, NSError *error) {
                    [self.submitButton stopLoading:TEXT_FEEDBACK_SUBMIT];
                    self.view.userInteractionEnabled = YES;
                    if (!error) {
                        self.resultView.hidden = NO;
                        return;
                    }

                    NSDictionary *dict = [[[NSString alloc] initWithData:error.userInfo[@"ESResponseObject"] encoding:NSUTF8StringEncoding] toJson];
                    ESDLog(@"[FeedBack] error : %@", dict);
                    NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];

                    if (response.statusCode == 400 && [dict isKindOfClass:[NSDictionary class]]) {
                        NSString *errorDesc = dict[@"error"];
                        if ([errorDesc isKindOfClass:[NSString class]]) {
                            if ([errorDesc containsString:@"proposalSave.proposalReq.email"]) {
                                [ESToast toastError:TEXT_FEEDBACK_CHECK_EMAIL_FORMAT_ERROR];
                                return;
                            }
                            if ([errorDesc containsString:@"proposalSave.proposalReq.phoneNumber"]) {
                                [ESToast toastError:TEXT_FEEDBACK_CHECK_PHONE_NUMBER_FORMAT_ERROR];
                                return;
                            }
                        }
                    }
                     [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                }];
    });
}

- (void)uploadImage:(ESFeedbackImagItem *)imageItem completion:(void (^)(BOOL success))completion {
    //避免重复上传
    if (imageItem.url.length > 0) {
        if (completion) {
            completion(YES);
        }
        return;
    }
  
    ESPlatformProposalManagementServiceApi *api = [[ESPlatformProposalManagementServiceApi alloc] initWithApiClient:ESPlatformClient.platformClient];
    [api uploadWithFileName:imageItem.name isPublish:@(NO) file:(id)[NSURL fileURLWithPath:imageItem.localPath] completionHandler:^(ESUploadFileRes *output, NSError *error) {
        imageItem.url = output.fileUrl;
        ESDLog(@"意见反馈图片上传%@ error：%@", output,error);
        if (completion) {
            completion(imageItem.url.length > 0);
        }
    }];
}

#pragma mark - Cell Action

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    if (!action) {
        return;
    }
    ESFeedbackAction type = [action integerValue];
    if (type == ESFeedbackActionAddImage) {
        [self selectImage];
    }
}

- (void)selectImage {
    //底部弹出来个actionSheet来选择拍照或者相册选择
    UIAlertController *alet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //系统相机拍照
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:TEXT_ME_CAMERA
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                                 imagePicker.delegate = self;
                                                                 imagePicker.allowsEditing = NO;
                                                                 imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                 [self presentViewController:imagePicker animated:YES completion:nil];
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
                                                                imagePicker.allowsEditing = NO;
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
                                 [self addImageToTable:[info objectForKey:UIImagePickerControllerOriginalImage]];
                             }];
}


- (void)addImageToTable:(UIImage *)image {
    NSString *fileName = [NSString stringWithFormat:@"feed_back_%zd.png", (NSInteger)NSDate.date.timeIntervalSince1970 * 1000];
    NSString *localPath = [NSString randomCacheLocationWithName:fileName];
    if (image.size.width > 1080) {
        CGSize size = CGSizeMake(1080, image.size.height / image.size.width * 1080);
        image = [image imageConvertToSize:size];
    }
    [UIImageJPEGRepresentation(image, 0.45) writeToFile:localPath.fullCachePath atomically:YES];
    NSMutableArray *imageArray = self.imageItem.data;
    ///ESFeedbackImagItem
    ESFeedbackImagItem *imageItem = [ESFeedbackImagItem new];
    imageItem.image = image;
    imageItem.name = fileName;
    imageItem.localPath = localPath.fullCachePath;

    [imageArray addObject:imageItem];
    [self.tableView reloadData];
}

#pragma mark - Lazy Load

- (ESGradientButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_submitButton setCornerRadius:10];
        [_submitButton setTitle:TEXT_FEEDBACK_SUBMIT forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_submitButton setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_submitButton];
        [_submitButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (ESFeedbackResultView *)resultView {
    if (!_resultView) {
        _resultView = [[ESFeedbackResultView alloc] initWithFrame:self.view.window.bounds];
        [self.view.window addSubview:_resultView];
        weakfy(self);
        _resultView.actionBlock = ^(id action) {
            [weak_self goBack];
        };
    }
    return _resultView;
}

- (BOOL)checkPhoneNumber : (NSString *) phoneNumber
{
    NSString *mobileRegex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",mobileRegex];
    BOOL isMatch = [pre evaluateWithObject:phoneNumber];
    return isMatch;
}

- (BOOL)checkEmail : (NSString *) checkEmail
{
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    BOOL isMatch = [pre evaluateWithObject:checkEmail];

    return isMatch;
}


@end
