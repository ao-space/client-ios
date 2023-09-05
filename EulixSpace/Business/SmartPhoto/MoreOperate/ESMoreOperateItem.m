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
//  ESBottomToolVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//
#import "ESMoreOperateItem.h"
#import "ESPicBottomMoreView.h"
#import "ESBottomDetailView.h"
#import "ESFileApi.h"
#import "ESToast.h"

@interface ESMoreOperateItem () <ESPicBottomMoreViewDelegate, ESBottomDetailViewDelegate>

@property (nonatomic, strong) ESPicBottomMoreView *moreView;
@property (nonatomic, copy) NSArray<ESPicModel *> *selectedInfoArray;
@property (nonatomic, copy) NSArray *isSelectUUIDSArray;
@property (nonatomic, strong) ESBottomDetailView *detailView;

@end

@implementation ESMoreOperateItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
   if (self = [super initWithParentMoreOperateVC:moreOperateVC]) {
       __weak typeof (self) weakSelf = self;
       self.actionBlock = ^() {
           __strong typeof(weakSelf) self = weakSelf;
           [self showMoreMenu];
       };
   }
   return self;
}

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    _selectedInfoArray = selectedList;
    NSMutableArray *uuidList = [NSMutableArray array];
    [selectedList enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uuidList addObject:ESSafeString(obj.uuid)];
    }];
    _isSelectUUIDSArray = uuidList;
}

- (NSString *)title {
   return NSLocalizedString(@"common_more", @"更多");
}

- (NSString *)iconName {
   return @"file_bottom_more";
}

- (ESPicBottomMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[ESPicBottomMoreView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _moreView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _moreView.delegate = self;
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroudAction:)];
        [_moreView addGestureRecognizer:delectActionTapGesture];
    }
    return _moreView;
}

- (ESBottomDetailView *)detailView {
    if (!_detailView) {
        _detailView = [[ESBottomDetailView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _detailView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _detailView.delegate = self;
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroudAction:)];
        [_detailView addGestureRecognizer:delectActionTapGesture];
        _detailView.userInteractionEnabled = YES;
    }
    return _detailView;
}

- (void)showMoreMenu {
    if ([UIApplication sharedApplication].keyWindow) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.moreView];
    }
    self.moreView.reNameView.hidden = YES;
    if (self.selectedInfoArray.count > 0) {
        ESPicModel *pic = self.selectedInfoArray[0];
        ESFileInfoPub *fileInfo = [ESFileInfoPub new];
        fileInfo.uuid = pic.uuid;
        fileInfo.name = pic.name;
        fileInfo.size = [NSNumber numberWithLong:pic.size];
        self.moreView.fileInfo = fileInfo;
        
        NSMutableArray *uuidList = [NSMutableArray array];
        [self.selectedInfoArray enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [uuidList addObject:ESSafeString(obj.uuid)];
            
        }];
        self.moreView.isSelectUUIDSArray = uuidList;
    }

    [self.moreOperateVC hidden];
}

- (void)hidden {
    if (self.moreView.superview) {
        [self.moreView removeFromSuperview];
    }
    if ([self.parentVC respondsToSelector:@selector(finishActionAndStaySelecteStyle)]) {
        [self.parentVC finishActionAndStaySelecteStyle];
    } else {
        [self.moreOperateVC showFrom:self.parentVC];
    }
}

- (void)showDetailView {
    if (self.selectedInfoArray.count > 0) {
        ESPicModel *pic = self.selectedInfoArray[0];
        ESFileInfoPub *fileInfo = [ESFileInfoPub new];
        fileInfo.uuid = pic.uuid;
        fileInfo.name = pic.name;
        fileInfo.path = pic.path;
        fileInfo.operationAt = @(pic.shootAt);
        fileInfo.size = [NSNumber numberWithLong:pic.size];
        self.detailView.fileInfo = fileInfo;
    }
    self.detailView.hidden = NO;
    
    if ([UIApplication sharedApplication].keyWindow) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.detailView];
    }
}

- (void)hiddenDetailView {
    if (self.detailView.superview) {
        [self.detailView removeFromSuperview];
    }
}

- (void)tapBackgroudAction:(UITapGestureRecognizer *)tapGes {
    if (self.detailView.superview) {
        [self  hiddenDetailView];
        return;
    }
    
    [self hidden];
}

- (void)bottomMoreViewShowDetail:(ESPicBottomMoreView *)bottomMoreView {
    [self showDetailView];
}

- (void)bottomMoreViewDidClickCancel:(ESPicBottomMoreView *)bottomMoreView {
    [self hidden];
    [self.moreOperateVC showFrom:self.parentVC];
}

- (void)bottomMoreView:(ESPicBottomMoreView *)bottomMoreView reNameFileInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName {
    [self reNameInfo:info fileName:fileName];
}

- (void)fileBottomToolMoreView:(ESPicBottomMoreView *)fileBottomToolMoreView didClickDelectBtn:(UIButton *)button {
    [self hidden];
    [self.moreOperateVC showFrom:self.parentVC];
}

- (void)reNameInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName {
    if ([info.name isEqual:fileName]) {
       [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
        [self.moreOperateVC showFrom:self.parentVC];
        return;
    }

    NSArray *array = [info.name componentsSeparatedByString:@"."];
    if (array.count > 1) {
        fileName = [NSString stringWithFormat:@"%@.%@", fileName, array[1]];
    }

    ESFileApi *api = [[ESFileApi alloc] init];
    [self.moreOperateVC hidden];
    self.moreView.hidden = YES;
    if (info.uuid.length > 0 && fileName.length > 0) {
        ESModifyFileReq *req = [ESModifyFileReq new];
        req.fileName = fileName;
        req.uuid = info.uuid;
        [api spaceV1ApiFileRenamePostWithModifyFileReq:req
                                     completionHandler:^(ESRspDbAffect *output, NSError *error) {
                                         if (!error) {
                                             if (output.code.intValue == 1013) {
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                     [ESToast toastSuccess:@"当前目录已存在同名称文件"];
                                                 });
                                                 if ([self.parentVC respondsToSelector:@selector(finishActionAndStaySelecteStyle)]) {
                                                     [self.parentVC finishActionAndStaySelecteStyle];
                                                 } else {
                                                     [self.moreOperateVC showFrom:self.parentVC];
                                                 }
                                                 return;
                                             }
                                             
                                             if (output.code.intValue == 200) {
                                                 if ([self.parentVC respondsToSelector:@selector(finishActionShowNormalStyleWithCleanSelected)]) {
                                                     [self.parentVC finishActionShowNormalStyleWithCleanSelected];
                                                 } else {
                                                     [self.moreOperateVC showFrom:self.parentVC];
                                                 }
                                                 if ([self.parentVC respondsToSelector:@selector(tryAsyncDataWithRename:uuid:)]) {
                                                     [self.parentVC tryAsyncDataWithRename:fileName uuid:info.uuid];
                                                 }
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                     [ESToast toastSuccess:NSLocalizedString(@"Modified successfully", @"修改成功")];
                                                 });
                                                 
                                                 return;
                                             }
                                             //失败
                                             if ([self.parentVC respondsToSelector:@selector(finishActionAndStaySelecteStyleWithCleanSelected)]) {
                                                 [self.parentVC finishActionAndStaySelecteStyleWithCleanSelected];
                                             } else {
                                                 [self.moreOperateVC showFrom:self.parentVC];
                                             }
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                                 [ESToast toastSuccess:@"修改失败"];
                                                 [ESToast toastSuccess:NSLocalizedString(@"Modify Fail", @"修改失败")];
                                             });
                                             return;
                                         } else {
                                             if ([self.parentVC respondsToSelector:@selector(finishActionAndStaySelecteStyleWithCleanSelected)]) {
                                                 [self.parentVC finishActionAndStaySelecteStyleWithCleanSelected];
                                             } else {
                                                 [self.moreOperateVC showFrom:self.parentVC];
                                             }
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                  [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                             });
                                         }
                                     }];
    }
}

/// 点击取消底部view
- (void)fileBottomDetailView:(ESBottomDetailView *_Nullable)fileBottomDetailView didClickDelectBtn:(UIButton *)button {
    [self hiddenDetailView];
}

@end
