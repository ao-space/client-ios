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

#import "ESShareOperateItem.h"
#import "ESShareView.h"
#import "ESPicModel.h"
#import "ESFileInfoPub.h"
#import "ESFileDefine.h"
#import "ESFileLoadingViewController.h"
#import "ESFileInfoPub+ESTool.h"

@interface ESShareOperateItem () <ESShareViewDelegate>

@property (nonatomic, strong) ESShareView *shareView;
@property (nonatomic, strong) NSArray<NSString *> *selectUUIDSArray;

@end

@implementation ESShareOperateItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
    if (self = [super initWithParentMoreOperateVC:moreOperateVC]) {
        __weak typeof (self) weakSelf = self;
        self.actionBlock = ^() {
            __strong typeof(weakSelf) self = weakSelf;
            [self showSharePane];
        };
    }
    return self;
}

- (void)showSharePane {
////    if(!self.shareView){
//        self.shareView = [[ESShareView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//        self.shareView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
////    }
//    
//    self.shareView.delegate = self;
//    self.shareView.fileIds = [self.selectedModule validSelectedUUIDArray];
//    self.shareView.hidden = NO;
    
    ESPicModel *model = self.selectedModule.selectedInfoArray.firstObject;
    ESFileInfoPub *file = [ESFileInfoPub new];
    file.uuid = model.uuid;
    file.name = model.name;
    file.path = model.path;
    file.size = @(model.size);
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

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    [self.selectedModule updateSelectedList:selectedList];
}

- (NSString *)title {
    return NSLocalizedString(@"file_bottom_share", @"分享");
}

- (NSString *)iconName {
    return @"file_bottom_share";
}

#pragma mark - share

- (void)shareFile:(NSURL *)localPath {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[localPath] applicationActivities:nil];
    [self.parentVC presentViewController:vc animated:YES completion:nil];
}

- (void)shareLink:(NSString *)shareLinkStr {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[shareLinkStr] applicationActivities:nil];
    [self.parentVC presentViewController:vc animated:YES completion:nil];
    
}

- (void)shareView:(ESShareView *)shareView didClicCancelBtn:(UIButton *)button{
    [self.moreOperateVC showFrom:self.parentVC];
}

- (void)shareViewShareOther:(ESShareView *)shareView{
    ESPicModel *model = self.selectedModule.selectedInfoArray.firstObject;
    ESFileInfoPub *file = [ESFileInfoPub new];
    file.uuid = model.uuid;
    file.name = model.name;
    file.path = model.path;
    file.size = @(model.size);
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

- (void)otherShareLinkBtnTap:(NSString *)linkStr{
    [self shareLink:linkStr];
    if ([self.parentVC respondsToSelector:@selector(finishActionAndStaySelecteStyleWithCleanSelected)]) {
        [self.parentVC finishActionAndStaySelecteStyleWithCleanSelected];
    }
}


@end
