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

#import "ESDeleteOperateItem.h"
#import "ESFileApi.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import "ESToast.h"
#import "ESFileDelectView.h"
#import "ESPicModel.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountInfoStorage.h"
#import "ESAlertViewController.h"
#import "ESCommonProcessStatusVC.h"

@interface ESDeleteOperateItem () <ESFileDelectViewDelegate>

@property (nonatomic, strong) ESFileDelectView *delectView;

@end

@implementation ESDeleteOperateItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
   if (self = [super initWithParentMoreOperateVC:moreOperateVC]) {
       __weak typeof (self) weakSelf = self;
       self.actionBlock = ^() {
           __strong typeof(weakSelf) self = weakSelf;
           [self showDeleteDialog];
       };
   }
   return self;
}

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    [self.selectedModule updateSelectedList:selectedList];
}

- (NSString *)title {
   return NSLocalizedString(@"delete", @"删除");
}

- (NSString *)iconName {
   return @"delete_item";
}

- (ESFileDelectView *)delectView {
    if (!_delectView) {
        _delectView = [[ESFileDelectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _delectView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _delectView.delegate = self;
          UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroudAction:)];
          [_delectView addGestureRecognizer:delectActionTapGesture];
        _delectView.userInteractionEnabled = YES;
    }
    return _delectView;
}

- (void)showDeleteDialog {
    if ([UIApplication sharedApplication].keyWindow) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.delectView];
    }
}


- (void)hidden {
    if (self.delectView.superview) {
        [self.delectView removeFromSuperview];
    }
}

- (void)deleteItems {
    if (self.selectedModule.isSelectUUIDSArray.count <= 0) {
        return;
    }

    
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"delete_file"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{@"uuids" : self.selectedModule.isSelectUUIDSArray ?: @""}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
            strongfy(self)
            [self deleteSuccess];
            [self hidden];
            return;
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        strongfy(self)
        [self hidden];

        //show 异步删除进度条
        if ([error.userInfo[@"code"] intValue] == 201) {
            NSDictionary *results = error.userInfo[ESNetworkErrorUserInfoResposeResultKey];
            if ([results[@"results"] isKindOfClass:[NSDictionary class]] && results[@"results"][@"taskId"] != nil) {
                NSString *taskId = results[@"results"][@"taskId"];
                ESCommonProcessStatusVC *processVC = [[ESCommonProcessStatusVC alloc] init];
                processVC.customProcessTitle = NSLocalizedString(@"delete_loading_message", @"正在删除");
                processVC.taskId = taskId;
                
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
                [processVC showFrom:self];
            }
            return;
        }
        [self deleteFail];
    }];
}

- (void)deleteSuccess {
    if ([self.parentVC respondsToSelector:@selector(finishActionShowNormalStyleWithCleanSelected)] ) {
        [self.parentVC finishActionShowNormalStyleWithCleanSelected];
    }
    //处理预览模式照片删除
    if (self.selectedModule.validSelectedInfoArray.count == 1 &&
        [self.parentVC respondsToSelector:@selector(deletePicItem:index:)] ) {
        [self.parentVC deletePicItem:self.selectedModule.validSelectedInfoArray[0]
                               index:NSNotFound];
    }
    if ([self.parentVC respondsToSelector:@selector(tryAsyncData)] ) {
        [self.parentVC tryAsyncData];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
    });
}

- (void)deleteFail {
    [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
}

- (void)tapBackgroudAction:(UITapGestureRecognizer *)tapGes {
    [self hidden];
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCancelBtn:(UIButton *_Nullable)button {
    [self hidden];
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button {
    [self deleteItems];
}

@end
