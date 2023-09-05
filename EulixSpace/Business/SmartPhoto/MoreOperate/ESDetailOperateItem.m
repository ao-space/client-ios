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
//  ESDetailOperateItem.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDetailOperateItem.h"
#import "ESPicModel.h"
#import "ESBottomDetailView.h"

@interface ESDetailOperateItem () <ESBottomDetailViewDelegate>

@property (nonatomic, strong) ESBottomDetailView *detailView;

@end

@implementation ESDetailOperateItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
   if (self = [super initWithParentMoreOperateVC:moreOperateVC]) {
       __weak typeof (self) weakSelf = self;
       self.actionBlock = ^() {
           __strong typeof(weakSelf) self = weakSelf;
           [self showDetailView];
       };
   }
   return self;
}

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    [self.selectedModule updateSelectedList:selectedList];
}

- (void)showDetailView {
    if (self.selectedModule.selectedInfoArray.count > 0) {
        ESPicModel *pic = self.selectedModule.selectedInfoArray[0];
        ESFileInfoPub *fileInfo = [ESFileInfoPub new];
        fileInfo.uuid = pic.uuid;
        fileInfo.name = pic.name;
        fileInfo.path = pic.path;
        fileInfo.operationAt =  @(pic.shootAt);
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

- (NSString *)title {
    return NSLocalizedString(@"Details", @"详情");
}

- (NSString *)iconName {
   return @"file_bottom_details";
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

- (void)fileBottomDetailView:(ESBottomDetailView *_Nullable)fileBottomDetailView didClickDelectBtn:(UIButton *_Nullable)button {
    [self hiddenDetailView];
}

- (void)tapBackgroudAction:(UITapGestureRecognizer *)tapGes {
    [self hiddenDetailView];
}

@end
