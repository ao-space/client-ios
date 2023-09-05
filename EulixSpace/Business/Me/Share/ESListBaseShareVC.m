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
//  ESListBaseShareVC.m
//  EulixSpace
//
//  Created by qu on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESListBaseShareVC.h"
#import "ESRecyclePopUpView.h"
#import "ESRecycledApi.h"
#import "UIButton+Extension.h"
#import "ESFileInfoPub.h"
#import "ESShareApi.h"
#import "ESMyShareRsp.h"
#import "ESShareListVC.h"


@interface ESListBaseShareVC ()
@property (nonatomic, strong) ESShareListVC *listShareView;
@property (nonatomic, strong) ESEmptyView *shareBlankSpaceView;
@end

@implementation ESListBaseShareVC

- (void)loadView {
    [super loadView];
    self.category = @"shareVC";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.current = self.listShareView;
}

- (void)getFileRequestStart:(NSString *)fileUUID {
    ESShareApi *api = [ESShareApi new];
    [api spaceV1ApiShareHistoryGetWithPage:@(1) pageSize:@(200) completionHandler:^(ESRspMyShareListRsp *output, NSError *error) {
        if (!error) {
            self.children = [NSMutableArray new];
            NSMutableArray *shareListArray = [[NSMutableArray alloc] init];
            self.childrenShare = [[NSMutableArray alloc] init];
            shareListArray = output.results.shareList.mutableCopy;
            for (ESMyShareRsp *info in shareListArray) {
                [self.childrenShare addObject:info];
            }
            self.listShareView.childrenShare = self.childrenShare;
            if (self.childrenShare.count > 0) {
                self.shareBlankSpaceView.hidden = YES;
                [self.listShareView reloadData];
            }
            else {
                self.shareBlankSpaceView.hidden = NO;
            }
        }else{
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            self.shareBlankSpaceView.hidden = NO;
        }
    }];
}


- (ESShareListVC *)listShareView {
    if (!_listShareView) {
        _listShareView = [ESShareListVC new];
        [self.view addSubview:_listShareView.view];
        [self addChildViewController:_listShareView];
        __weak __typeof__(self) weak_self = self;
        _listShareView.selectedFolder = ^(ESFileInfoPub *folder) {
        };

        _listShareView.selectFile = ^(ESFileInfoPub *data) {
            __typeof__(self) self = weak_self;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:data forKey:@"fileInfo"];
            [dic setValue:@(self.listShareView.isCopyMove) forKey:@"isMoveCopy"];

            if ([data.isDir boolValue] && self.listShareView.isCopyMove) {
                if (self.enterFileUUIDArray.count > 0) {
                    ESFileInfoPub *repeatData = self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1];
                    if (![repeatData.uuid isEqual:data.uuid]) {
                        [self.enterFileUUIDArray addObject:data];
                        [self headerRefreshWithUUID:data.uuid];
                    }
                } else {
                    [self.enterFileUUIDArray addObject:data];
                    [self headerRefreshWithUUID:data.uuid];
                }
            }

            if (self.isSearch) {
                self.listShareView.category = @"Search";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didSecrchEnterFolderClick" object:dic];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didEnterFolderClick" object:dic];
            }
        };
    }
    return _listShareView;
}

- (void)selectAll:(BOOL)isAllSelect {
    [self.current selectedAll:isAllSelect];
}


- (ESEmptyView *)shareBlankSpaceView {
    if (!_shareBlankSpaceView) {
        _shareBlankSpaceView = [ESEmptyView new];
        ESEmptyItem *item = [ESEmptyItem new];
        item.icon = IMAGE_ME_SHARE_ICON;
        item.content = @"还没有任何分享哦";
        _shareBlankSpaceView.hidden = YES;
        [self.view addSubview:_shareBlankSpaceView];
        [_shareBlankSpaceView reloadWithData:item];
        [_shareBlankSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _shareBlankSpaceView;
}

@end
