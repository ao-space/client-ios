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
//  ESCommentToolVC.m
//  EulixSpace
//
//  Created by qu on 2021/10/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCommentToolVC.h"
#import "ESBottomDetailView.h"
#import "ESBottomMoreView.h"
#import "ESFileDefine.h"
#import "ESFileDelectView.h"
#import "ESFileLoadingViewController.h"
#import "ESGlobalMacro.h"
#import "ESLocalPath.h"
#import "ESLocalizableDefine.h"
#import "ESToast.h"
#import "ESTransferManager.h"
#import "ESShareView.h"
#import "ESFileApi.h"
#import <Masonry/Masonry.h>
#import <YCEasyTool/NSArray+YCTools.h>
#import "ESAutoErrorView.h"
#import "ESCacheInfoDBManager.h"
#import "ESBoxManager.h"

#import "ESNetworkRequestManager.h"
#import "ESCommonProcessStatusVC.h"
#import "ESNetworkRequestManager.h"
#import "UIView+Status.h"


@interface ESCommentToolVC () <ESFileBottomViewDelegate, ESBottomMoreViewDelegate, ESBottomDetailViewDelegate, ESBottomDetailViewDelegate, UIDocumentPickerDelegate, ESFileDelectViewDelegate,ESShareViewDelegate>

@property (nonatomic, strong) ESBottomMoreView *moreView;
@property (nonatomic, strong) ESBottomDetailView *detailView;
@property (nonatomic, strong) ESFileDelectView *delectView;
@property (nonatomic, strong) NSMutableArray<NSString *> *selectedUUIDSArray;
@property (nonatomic, strong) NSMutableArray<ESFileInfoPub *> *selectedInfoSArray;
@property (nonatomic, strong) UIViewController *vc;
@property (nonatomic, copy) NSString *currentDirUUID;
@property (nonatomic, strong) ESShareView *shareView;
@end

FOUNDATION_EXPORT NSString *const ESComeFromSmartPhotoPageTag;

@implementation ESCommentToolVC

- (void)showSelectArray:(NSMutableArray<ESFileInfoPub *> *)selectedInfoSArray {
    self.bottomView.hidden = NO;

    self.selectedInfoSArray = selectedInfoSArray;
    self.selectedUUIDSArray = [NSMutableArray new];
    for (ESFileInfoPub *info in selectedInfoSArray) {
        [self.selectedUUIDSArray addObject:info.uuid];
    }
    if (self.selectedInfoSArray.count > 1) {
        self.bottomView.isMoreSelect = YES;
    } else {
        self.bottomView.isMoreSelect = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidEnterBackgroundNotification object:nil];
    self.bottomView.isSelectUUIDSArray = self.selectedUUIDSArray;
}

- (void)didBecomeActive{
    self.shareView.hidden = YES;
}

- (void)showSelectArray:(NSMutableArray<ESFileInfoPub *> *)selectedInfoSArray currentDirUUID:(NSString *)currentDirUUID {
    self.bottomView.hidden = NO;
    BOOL isHaveDir = NO;
    for (ESFileInfoPub *fileInfo in selectedInfoSArray) {
        if (fileInfo.isDir.boolValue) {
            isHaveDir = YES;
        }
    }
    self.selectedInfoSArray = selectedInfoSArray;
    self.selectedUUIDSArray = [NSMutableArray new];
    for (ESFileInfoPub *info in selectedInfoSArray) {
        [self.selectedUUIDSArray addObject:info.uuid];
    }
    if (self.selectedInfoSArray.count > 1) {
        self.bottomView.isMoreSelect = YES;
        self.bottomView.isHaveDir = isHaveDir;
    } else {
        self.bottomView.isMoreSelect = NO;
    }
    self.bottomView.isSelectUUIDSArray = self.selectedUUIDSArray;
    self.currentDirUUID = currentDirUUID;
}

- (ESBottomMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[ESBottomMoreView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _moreView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _moreView.delegate = self;
        [self.delegate.view.window addSubview:_moreView];
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
        [_moreView addGestureRecognizer:delectActionTapGesture];
    }
    return _moreView;
}

- (ESBottomDetailView *)detailView {
    if (!_detailView) {
        _detailView = [[ESBottomDetailView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _detailView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _detailView.delegate = self;
        [self.delegate.view.window addSubview:_detailView];
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
        [_detailView addGestureRecognizer:delectActionTapGesture];
        _detailView.userInteractionEnabled = YES;
    }
    return _detailView;
}

- (ESFileDelectView *)delectView {
    if (!_delectView) {
        _delectView = [[ESFileDelectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _delectView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _delectView.delegate = self;
        [self.delegate.view.window addSubview:_delectView];
          UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
          [_delectView addGestureRecognizer:delectActionTapGesture];
        _delectView.userInteractionEnabled = YES;
    }
    return _delectView;
}

// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)delectTapGestureAction:(UITapGestureRecognizer *)tap {
    self.delectView.hidden = YES;
    self.detailView.hidden = YES;
    self.moreView.hidden = YES;
}

- (ESFileBottomView *)bottomView {
    if (nil == _bottomView) {
        CGFloat height = 50 + kBottomHeight;
        UIView *superView = self.specificView ?: self.delegate.view;
        CGRect frame = superView.bounds;
        frame.origin.y = CGRectGetHeight(frame) - height;
        frame.size.height = height;
        _bottomView.isSelectUUIDSArray = self.selectedUUIDSArray;
        _bottomView = [[ESFileBottomView alloc] initWithFrame:frame];
        if (self.specificView) {
            [superView addSubview:_bottomView];
            if(superView){
                [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.left.right.mas_equalTo(superView);
                    make.height.mas_equalTo(height);
                }];
            }
        
        } else {
            _bottomView.tag = 990001;
            [self.currentWindow addSubview:_bottomView];
            if(self.currentWindow){
                [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.left.right.mas_equalTo(self.currentWindow);
                    make.height.mas_equalTo(height);
                }];
            }
        }
        _bottomView.hidden = NO;
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDownBtn:(UIButton *)button {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject error:&error];
    if (dictionary) {
        NSNumber *free = dictionary[NSFileSystemFreeSize];
        long long int size = 0;
        for(int i = 0; i < self.selectedInfoSArray.count; i++){
            ESFileInfoPub *info =  [ESFileInfoPub new];
            size = size + info.size.unsignedLongLongValue;
        }
        if(free.unsignedLongLongValue < size/2){
            [ESToast toastError:@"手机空间不足"];
            return;
        }
    }
    [self.selectedInfoSArray enumerateObjectsUsingBlock:^(ESFileInfoPub *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.isDir.boolValue) {
            return;
        }
        [ESToast toastSuccess:TEXT_ADDED_TO_TRANSFER_LIST];
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                        apiName:@"history_record_add"                                  queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                         header:@{}
                                                           body:@{@"phoneType" : @"ios",
                                                                  @"uuid" : obj.uuid,
                                                                  @"fileName" : obj.name,
                                                                  @"category" :obj.category,
                                                                  @"opType" : @(1),
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
              NSLog(@"%@",response);
          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
         }];
        
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                        apiName:@"ESNetworkRequestManager"                                                queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                         header:@{}
                                                           body:@{@"phoneType" : @"ios",
                                                                  @"uuid" : obj.uuid,
                                                                  @"fileName" : obj.name,
                                                                  @"category" :obj.category,
                                                                  @"opType" : @(1),
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
  
          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
         }];
        
        [ESTransferManager.manager download:obj
                                   callback:^(NSURL *output, NSError *error) {
                                       if (!error) {
                                        
                                           [self completeLoadData];
                                           ESCacheInfoItem *item = [ESCacheInfoItem new];
                                           item.name = obj.name;
                                           item.size = [obj.size integerValue];
                                           item.uuid = obj.uuid;
                                           if ([output isKindOfClass:[NSURL class]]) {
                                               NSRange range = [output.absoluteString rangeOfString:@"Library/Caches/"];
                                               if (range.location != NSNotFound) {
                                                   item.path = [output.absoluteString substringFromIndex:(range.location + range.length)];
                                               }
                                           }
                                           
                                           item.cacheType = [self.comeFromTag isEqualToString:ESComeFromSmartPhotoPageTag] ?
                                                            ESBusinessCacheInfoTypePhoto : ESBusinessCacheInfoTypeFile;
                                           [[ESCacheInfoDBManager shared] insertOrUpdatCacheInfoToDB:@[item]];
                                       }
                                   }];
    }];
}

/// 分享
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickShareBtn:(UIButton *)button {
//    NSMutableArray *isSelectUUIDSArray = [NSMutableArray new];
//    for (int i =0; i < self.selectedInfoSArray.count; i++) {
//        ESFileInfoPub *info = self.selectedInfoSArray[i];
//        if (info.uuid) {
//         [isSelectUUIDSArray addObject:info.uuid];
//      }
//   }
    
//    if(!self.shareView){
//        self.shareView = [[ESShareView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//        self.shareView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
//        self.shareView.delegate =self;
//        self.shareView.fileIds = isSelectUUIDSArray;
//        [self.delegate.view.window addSubview:self.shareView];
    
    ESFileInfoPub *file = self.selectedInfoSArray.firstObject;
    NSString *path =[file getOriginalFileSavePath];
    if (!file) {
        return;
    }
    if (LocalFileExist(file)) {
        [self shareFile:[NSURL fileURLWithPath:path]];
        return;
    }
    ESFileShowLoading(self.parentVC, file, NO, ^{
        [file getOriginalFileSavePath];
        [self shareFile:[NSURL fileURLWithPath:path]];
    });
}



- (void)shareViewShareOther:(ESShareView *)shareView{
    ESFileInfoPub *file = self.selectedInfoSArray.firstObject;
    if (!file) {
        return;
    }
    NSString *path =[file getOriginalFileSavePath];
    if (LocalFileExist(file)) {
        [self shareFile:[NSURL fileURLWithPath:path]];
        return;
    }
    ESFileShowLoading(self.delegate, file, NO, ^{
        [file getOriginalFileSavePath];
        [self shareFile:[NSURL fileURLWithPath:path]];
    });
}

- (void)otherShareLinkBtnTap:(NSString *)strLink{
    [self shareFileLink:strLink];
}

- (void)shareFile:(NSURL *)localPath {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[localPath] applicationActivities:nil];
    [self.delegate presentViewController:vc animated:YES completion:nil];
}

- (void)shareFileLink:(NSString *)linkSrr {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[linkSrr] applicationActivities:nil];
    [self.delegate presentViewController:vc animated:YES completion:nil];
}

/// 删除
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDelectBtn:(UIButton *)button {
    self.delectView.hidden = NO;
    self.bottomView.hidden = YES;
}

/// 更多
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickMoreBtn:(UIButton *)button {
    self.moreView.hidden = NO;
    self.moreView.reNameView.hidden = YES;

    if (self.selectedUUIDSArray.count > 0) {
        self.moreView.fileInfo = self.selectedInfoSArray[0];
    }

    if (self.selectedInfoSArray.count > 0) {
        self.moreView.isSelectUUIDSArray = self.selectedInfoSArray;
    }

    self.bottomView.hidden = YES;


   // [self completeLoadData];
}

/// 详情
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDetailsBtn:(UIButton *)button {
    if (self.selectedUUIDSArray.count > 0) {
        self.detailView.fileInfo = self.selectedInfoSArray[0];
    }
    self.detailView.hidden = NO;
    self.bottomView.hidden = YES;

}

/// 复制
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickCopyCompleteWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category {
    [self copyMoveApiWithPathName:pathName selectUUID:uuid category:category];
    [self completeLoadData];
    self.bottomView.hidden = YES;
}

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickReNameCompleteInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName category:(NSString *)category {
    self.bottomView.hidden = NO;
    NSArray *array = [info.name componentsSeparatedByString:@"."];
    if (array.count > 1) {
        fileName = [NSString stringWithFormat:@"%@.%@", fileName, array[1]];
    }
    if ([fileName isEqual:info.name]) {
        [ESToast toastError:@"重命名重复"];
        self.bottomView.hidden = NO;
        self.moreView.hidden = YES;
        return;
    }

    ESFileApi *api = [[ESFileApi alloc] init];
    self.bottomView.hidden = YES;
    self.moreView.hidden = YES;
    if (info.uuid.length > 0 && fileName.length > 0) {
        ESModifyFileReq *req = [ESModifyFileReq new];
        req.fileName = fileName;
        req.uuid = info.uuid;

        [api spaceV1ApiFileRenamePostWithModifyFileReq:req
                                     completionHandler:^(ESRspDbAffect *output, NSError *error) {
                                         if (!error) {
                                             [self completeLoadData];
                                             if (output.code.intValue == 1013) {
                                                [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
                                                 self.bottomView.hidden = NO;
                                                 self.moreView.hidden = YES;
                                                 return;
                                             }
                                             info.name = fileName;
                                             [ESToast toastSuccess:NSLocalizedString(@"Modified successfully", @"修改成功")];
                                             return;
                                         } else {
                                             self.bottomView.hidden = NO;
                                              [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                             return;
                                         }
                                     }];
    }
}

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickCopyCompleteWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category {
    self.moreView.hidden = YES;
    [self copyMoveApiWithPathName:pathName selectUUID:uuid category:category];
    [self completeLoadData];
}

- (void)copyMoveApiWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category {
    self.moreView.hidden = YES;
    self.moreView.movecopyView.hidden = YES;
    self.bottomView.movecopyView.hidden = YES;
    ESFileApi *api = [[ESFileApi alloc] init];

    if ([category isEqual:@"copy"]) {
        if ([self.currentDirUUID isEqual:uuid]) {
            [ESToast toastError:NSLocalizedString(@"Copy Fail", @"复制失败")]; 
        }
        ESCopyFileReq *req = [[ESCopyFileReq alloc] init];
        req.dstPath = uuid;
        req.uuids = self.selectedUUIDSArray;

        [api spaceV1ApiFileCopyPostWithVarCopyFilesReq:req
                                     completionHandler:^(ESRspCopyRsp *output, NSError *error) {
                                         if (!error) {
                                             if (output.code.intValue == 1022) {
                                                 [ESToast toastError:NSLocalizedString(@"Copy Fail", @"复制失败")]; 
                                             }
                                            // [ESToast toastSuccess:@"复制成功"];
                                             [ESToast toastSuccess:NSLocalizedString(@"Copy Success", @"复制成功")];
                                         } else {
                                             [ESToast toastError:NSLocalizedString(@"Copy Fail", @"复制失败")]; 
                                         }
                                     }];
    }
    if ([category isEqual:@"move"]) {
        if ([self.currentDirUUID isEqual:uuid]) {
           [ESToast toastError:NSLocalizedString(@"Move Fail", @"移动失败")];
        }
        ESMoveFileReq *req = [[ESMoveFileReq alloc] init];
        if (uuid.length > 0) {
            req.destPath = uuid;
        } else {
            req.destPath = @"";
        }
        req.uuids = self.selectedUUIDSArray;
        [api spaceV1ApiFileMovePostWithMoveFilesReq:req
                                  completionHandler:^(ESRspDbAffect *output, NSError *error) {
                                      if (!error) {
                                          if (output.code.intValue == 1022) {
                                              [ESToast toastError:NSLocalizedString(@"Move Fail", @"移动失败")]; 
                                          }
                                          [ESToast toastSuccess:NSLocalizedString(@"Move Successful", @"移动成功")];
                                          return;
                                      } else {
                                           [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                      }
                                      [self completeLoadData];
                                  }];
    }
}

- (void)fileBottomToolMoreView:(ESBottomMoreView *_Nullable)fileBottomToolMoreView didClickCompleteBtn:(UIButton *_Nullable)button {
    self.delectView.hidden = YES;
    [self completeLoadData];
}

/// 点击取消底部view
- (void)fileBottomDetailView:(ESBottomDetailView *_Nullable)fileBottomDetailView didClickDelectBtn:(UIButton *)button {
    self.detailView.hidden = YES;
    self.bottomView.hidden = NO;
}


- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button {
    NSArray *uuids = [self.selectedUUIDSArray yc_mapWithBlock:^id(NSUInteger idx, NSString *uuid) {
        return uuid;
    }];
    [self.delegate.view showLoading:YES message:NSLocalizedString(@"delete_loading_message", @"正在删除")];
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"delete_file"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{@"uuids" : uuids ?: @""}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self.delegate.view showLoading:NO];
        [self deleteSuccess];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        strongfy(self)
        [self.delegate.view showLoading:NO];
        //show 异步删除进度条
        if (error) {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }

        if ([error.userInfo[@"code"] intValue] == 201) {
            NSDictionary *results = error.userInfo[ESNetworkErrorUserInfoResposeResultKey];
            if ([results[@"results"] isKindOfClass:[NSDictionary class]] && results[@"results"][@"taskId"] != nil) {
                NSString *taskId = results[@"results"][@"taskId"];
                ESCommonProcessStatusVC *processVC = [[ESCommonProcessStatusVC alloc] init];
                processVC.taskId = taskId;
                processVC.customProcessTitle = NSLocalizedString(@"delete_loading_message", @"正在删除");

                weakfy(processVC)
                processVC.processUpdateBlock = ^(BOOL success, BOOL isFinished, CGFloat process) {
                    strongfy(processVC)
                    if (isFinished) {
                        [processVC hidden:YES];
                        if (success) {
                            [self deleteSuccess];
                        } else {
                            [self deleteFail];
                        }
                    }
                };
                [processVC showFrom:self.delegate];
            }
            return;
        }
        [self deleteFail];
    }];
    
    self.delectView.hidden = YES;
}

- (void)deleteSuccess {
   [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
   [self completeLoadData];
   if (self.delegate && [self.delegate respondsToSelector:@selector(onFileDelete:)]) {
       [self.delegate onFileDelete:self.selectedInfoSArray];
   }
}

- (void)deleteFail {
    [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
}

- (void)noSelected {
    self.bottomView.hidden = YES && !self.alwaysShow;
}

- (void)completeLoadData {
    if (self.delegate && [self.delegate respondsToSelector:@selector(completeLoadData)]) {
        [self.delegate completeLoadData];
    }
    self.bottomView.hidden = YES && !self.alwaysShow;
}



- (void)hidden {
    self.bottomView.hidden = YES;
}

- (UIWindow *)lastWindow {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickReNameCompleteInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName category:(NSString *)category {
    [self reNameInfo:info fileName:fileName];
}

- (void)reNameInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName {
    if ([info.name isEqual:fileName]) {
       [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
        self.bottomView.hidden = NO;
        return;
    }

    NSArray *array = [info.name componentsSeparatedByString:@"."];
    if (array.count > 1) {
        fileName = [NSString stringWithFormat:@"%@.%@", fileName, array[1]];
    }

    ESFileApi *api = [[ESFileApi alloc] init];
    self.bottomView.hidden = YES;
    self.moreView.hidden = YES;
    if (info.uuid.length > 0 && fileName.length > 0) {
        ESModifyFileReq *req = [ESModifyFileReq new];
        req.fileName = fileName;
        req.uuid = info.uuid;
        [api spaceV1ApiFileRenamePostWithModifyFileReq:req
                                     completionHandler:^(ESRspDbAffect *output, NSError *error) {
                                         if (!error) {
                                             if (output.code.intValue == 1013) {
                                                 [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
                                                 [self noSelected];
                                                 self.bottomView.hidden = NO;
                                                 return;
                                             }

                                             [self completeLoadData];
                                             [ESToast toastSuccess:NSLocalizedString(@"Modified successfully", @"修改成功")];
                                             return;
                                         } else {
                                             self.bottomView.hidden = NO;
                                              [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                         }
                                     }];
    }
}

+ (UIViewController *)topViewController{
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] || [vc isKindOfClass:[UITabBarController class]] ) {
        if ( [vc isKindOfClass:[UINavigationController class]] ) vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] ) vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController ) vc = vc.presentedViewController;
    }
    return vc;
}

- (void)fileMoveCopyView:(ESMoveCopyView *)fileBottomToolView didClicCancelBtn:(UIButton *)button{
    self.bottomView.hidden = NO;
}
    
- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCancelBtn:(UIButton *_Nullable)button{
    self.bottomView.hidden = NO;
}

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickDelectBtn:(UIButton *)button{
    self.moreView.hidden = YES;
    self.bottomView.hidden = NO;
}



@end
