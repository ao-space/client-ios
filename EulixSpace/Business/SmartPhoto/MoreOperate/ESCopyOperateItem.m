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
//  ESCopyOperateItem.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCopyOperateItem.h"
#import "ESPicModel.h"
#import "ESMoveCopyView.h"
#import "ESPicModel.h"
#import "ESToast.h"
#import "ESFileApi.h"

@interface ESCopyOperateItem () <ESMoveCopyViewDelegate>

@property (nonatomic, strong) ESMoveCopyView *moveCopyView;

@end

@implementation ESCopyOperateItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
   if (self = [super initWithParentMoreOperateVC:moreOperateVC]) {
       __weak typeof (self) weakSelf = self;
       self.actionBlock = ^() {
           __strong typeof(weakSelf) self = weakSelf;
           [self showMoveCopyView];
       };
   }
   return self;
}

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    [self.selectedModule updateSelectedList:selectedList];
}

- (ESMoveCopyView *)moveCopyView {
    if (!_moveCopyView) {
        _moveCopyView = [[ESMoveCopyView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _moveCopyView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _moveCopyView.delegate = self;
    }
    return _moveCopyView;
}


- (void)showMoveCopyView {
    self.moveCopyView.category = @"copy";
    self.moveCopyView.isSelectUUIDSArray = [self.selectedModule.validSelectedUUIDArray mutableCopy];
    self.moveCopyView.selectNum = self.selectedModule.validSelectedUUIDArray.count;
    //self.movecopyView.name = self.fileInfo.path;
    //  if([self.fileInfo.path isEqual:@"/"]){
    self.moveCopyView.name = NSLocalizedString(@"me_space", @"我的空间");
    self.moveCopyView.uuid = @"";
    //  }
    self.moveCopyView.hidden = NO;

    if ([UIApplication sharedApplication].keyWindow) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.moveCopyView];
    }

    [self.moreOperateVC hidden];
}

- (void)hidden {
    if (self.moveCopyView.superview) {
        [self.moveCopyView removeFromSuperview];
    }
}

- (void)fileMoveCopyView:(ESMoveCopyView *)fileBottomToolView didClicCancelBtn:(UIButton *)button {
    [self hidden];
    if ([self.parentVC respondsToSelector:@selector(finishActionShowNormalStyleWithCleanSelected)]) {
        [self.parentVC finishActionShowNormalStyleWithCleanSelected];
    }
}

- (void)fileMoveCopyView:(ESMoveCopyView *)fileBottomToolView didClickCompleteBtnWithPath:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category {
    ESFileApi *api = [[ESFileApi alloc] init];

        if ([self.selectedModule.validSelectedUUIDArray containsObject:uuid]) {
            [ESToast toastError:NSLocalizedString(@"Copy Fail", @"复制失败")]; 
            return;
        }
   
        ESCopyFileReq *req = [[ESCopyFileReq alloc] init];
        req.dstPath = uuid;
        req.uuids = self.selectedModule.validSelectedUUIDArray;

        [api spaceV1ApiFileCopyPostWithVarCopyFilesReq:req
                                     completionHandler:^(ESRspCopyRsp *output, NSError *error) {
                                         if (!error) {
                                             if (output.code.intValue == 1022) {
                                                [ESToast toastError:NSLocalizedString(@"Copy Fail", @"复制失败")]; 
                                                 return;
                                             }
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                              [ESToast toastSuccess:NSLocalizedString(@"Copy Success", @"复制成功")];
                                             });
                                           
                                             [self hidden];
                                             if ([self.parentVC respondsToSelector:@selector(finishActionShowNormalStyleWithCleanSelected)]) {
                                                 [self.parentVC finishActionShowNormalStyleWithCleanSelected];
                                             }
                                             if ([self.parentVC respondsToSelector:@selector(tryAsyncData)]) {
                                                 [self.parentVC tryAsyncData];
                                             }
                                         } else {
                                              [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                         }
                                     }];
}

- (NSString *)title {
   return NSLocalizedString(@"file_bottom_copy", @"复制");
}

- (NSString *)iconName {
   return @"file_bottom_copy";
}

@end




