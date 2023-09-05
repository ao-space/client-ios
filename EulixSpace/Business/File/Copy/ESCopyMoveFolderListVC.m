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
//  ESCopyMoveFolderListVC.m
//  EulixSpace
//
//  Created by qu on 2021/8/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCopyMoveFolderListVC.h"
#import "ESCommentCreateFolder.h"
#import "ESFolderApi.h"
@interface ESCopyMoveFolderListVC ()

@end

@implementation ESCopyMoveFolderListVC

- (void)loadView {
    [super loadView];
    self.category = @"move";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.listView.isCopyMove = YES;
}

- (void)getFileRequestStart:(NSString *)fileUUID {
    self.fileUUID = fileUUID;
    [[ESFileApi new] spaceV1ApiFileListGetWithUuid:fileUUID
                                             isDir:@(YES)
                                              page:@(self.pageInt)
                                          pageSize:nil
                                           orderBy:nil
                                          category:nil
                                 completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                                     if (output) {
                                         self.children = [NSMutableArray new];
                                         if (output.results.pageInfo.page.intValue == output.results.pageInfo.total.intValue) {
                                             [self.listView.tableView.mj_footer endRefreshingWithNoMoreData];
                                         }
                                         NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
                                         fileListArray = output.results.fileList.mutableCopy;
                                         if (fileListArray.count > 0) {
                                             self.blankSpaceView.hidden = YES;
                                             for (ESFileInfoPub *info in fileListArray) {
                                                 if (info.isDir.boolValue) {
                                                     [self.children addObject:info];
                                                 }
                                             }
                                             ESPageInfoExt *pageInfo = output.results.pageInfo;
                                             self.totalInt = pageInfo.total.intValue;
                                             self.current.children = self.children;
                                             [self.current reloadData];
                                         } else {
                                             self.blankSpaceView.hidden = NO;
                                         }
                                     }else{
                                          [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                     }
                                 }];
}

- (void)didClickCreateFolder {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"file_new_file", @"新建文件夹") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    //2.1 确认按钮
    ESFileInfoPub *info;
    if (self.enterFileUUIDArray.count > 0) {
        info = self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1];
    }

    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确认")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
                                                        ESCommentCreateFolder *check = [ESCommentCreateFolder new];
                                                        NSString *checkStr = [check checkCreateFolder:alert.textFields.lastObject.text];
                                                        if (checkStr.length > 0) {
                                                            
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                           
                                                                [self presentViewController:alert animated:YES completion:nil];
                                                            });
                                                                  
                                                            [ESToast toastSuccess:checkStr];
                                                   
                                                            return;
                                                        }
                                                        ESFolderApi *api = [ESFolderApi new];
                                                        ESCreateFolderReq *body = [ESCreateFolderReq new];

                                                        if (info.uuid.length > 0) {
                                                            body.currentDirUuid = info.uuid;
                                                        } else {
                                                            body.currentDirUuid = self.fileUUID;
                                                        }
                                                        body.folderName = alert.textFields.lastObject.text;
                                                        [api spaceV1ApiFolderCreatePostWithCreateFolderReq:body
                                                                                         completionHandler:^(ESRspFileInfo *output, NSError *error) {
                                                                                             if (!error) {
                                                                                                 if (output.code.intValue == 1015) {
                                                                                                     [ESToast toastError:NSLocalizedString(@"Too many folder layers, no more than 20 layers", @"文件夹层数过多，不得超过20层")];
                                                                                                 } else if (output.code.intValue == 1013) {
//                                                                                                     [ESToast toastError:@"当前目录已存在同名称文件夹在"];
                                                                                                     [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
                                                                                                 } else {
                                                                                                     [ESToast toastSuccess:NSLocalizedString(@"New Folder Succeed", @"新建文件夹成功")];
                                                                                                     [self headerRefreshWithUUID:info.uuid];
                                                                                                     self.blankSpaceView.hidden = YES;
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

@end
