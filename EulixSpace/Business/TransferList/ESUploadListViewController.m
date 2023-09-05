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
//  ESUploadListViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESUploadListViewController.h"
#import "ESAccountManager.h"
#import "ESTransferAlbumSyncCell.h"
#import "ESColor.h"
#import "ESEmptyView.h"
#import "ESFileDefine.h"
#import "ESFormItem.h"
#import "ESGlobalDefine.h"
#import "ESLocalizableDefine.h"
#import "ESThemeDefine.h"
#import "ESTransferCellItem.h"
#import "ESTransferUploadHeader.h"
#import "ESTransferManager.h"
#import "ESUploadMetadata.h"
#import "NSDate+Format.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>
#import <YCEasyTool/NSArray+YCTools.h>
#include <CommonCrypto/CommonDigest.h>
#import "ESMultipartApi.h"
#import "ESDeleteMultipartTaskReq.h"
#import "ESMultipartNetworking.h"
#import "ESBoxManager.h"
#import "ESTransferUploadCell.h"
#import "ESFilePreviewViewController.h"
#import "ESFileLoadingViewController.h"
#import "ESToast.h"
#import "ESTransferCompletedCell.h"


typedef NS_ENUM(NSUInteger, ESUploadListSection) {
    ESUploadListSectionSync,
    ESUploadListSectionOngoing,
    ESUploadListSectionComplete,
};

@interface ESUploadListViewController ()

@property (nonatomic, strong) NSDictionary<NSNumber *, ESFormItem *> *headerItemDict;

@property (nonatomic, strong) ESEmptyView *emptyView;

@property (nonatomic, strong) ESTransferCellItem *syncItem;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *processCache;
// 是否正在自动同步中
@property (nonatomic, assign) BOOL isAutoUploading;
@property (nonatomic, strong) ESTransferUploadHeader * uploadingHeaderView;
@end

@implementation ESUploadListViewController

/// 断点续传
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [ESColor systemBackgroundColor];
    [self.tableView registerClass:[ESTransferUploadHeader class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([ESTransferUploadHeader class])];
    self.cellClass = [ESTransferUploadCell class];
    self.cellClass = [ESTransferCompletedCell class];
    self.cellClass = [ESTransferAlbumSyncCell class];
    _headerItemDict = @{
        @(ESUploadListSectionSync): [ESFormItem new],
        @(ESUploadListSectionOngoing): [ESFormItem new],
        @(ESUploadListSectionComplete): [ESFormItem new],
    };
    _processCache = NSMutableDictionary.dictionary;
   
    [self.tableView reloadData];
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadData) name:kESGlobalUploadAutoUploadReady object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadData) name:kESGlobalUploadAutoUploadSuccess object:nil];
//    [[[UIApplication sharedApplication].keyWindow viewWithTag:100101] removeFromSuperview];
//    //[[[UIApplication sharedApplication].keyWindow viewWithTag:100102] removeFromSuperview];
//    [[[UIApplication sharedApplication].keyWindow viewWithTag:100103] removeFromSuperview];
//    [[[UIApplication sharedApplication].keyWindow viewWithTag:100104] removeFromSuperview];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (NSArray<ESTransferTask *> *)getUploadedTaskList {
    return ESTransferManager.manager.uploaded;
}

- (BOOL)isAutoUploading {
    return _isAutoUploading;
}

- (void)reloadProgress:(NSNotification *)sender {
    ESUploadMetadata *data = [sender object];
    self.processCache[data.assetLocalIdentifier] = @(data.progress);
    if ([data.assetLocalIdentifier isEqualToString:self.syncItem.metadata.assetLocalIdentifier]) {
        self.syncItem.metadata.progress = data.progress;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.syncItem.notifyListener) {
                self.syncItem.notifyListener();
            }
        });
    }
}

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadSyncData];
        if (self.tableView.numberOfSections && [self.tableView numberOfRowsInSection:0] > 0) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:(UITableViewRowAnimationNone)];
        }
    });
}

- (void)reloadSyncData {
    ESAccount *account = ESAccountManager.manager.currentAccount;
    self.isAutoUploading = NO;
    if (account.canAutoUpload) {
        NSMutableArray *cellArray = NSMutableArray.array;
        NSArray<ESUploadMetadata *> *metadatas = [ESUploadMetadata autoUploadMetadata:nil limit:-1];
        ESTransferCellItem *item = [ESTransferCellItem new];
        self.syncItem = item;
        item.identifier = @"ESTransferAlbumSyncCell";
        [metadatas enumerateObjectsUsingBlock:^(ESUploadMetadata *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.status == ESUploadMetadataStatusUploading || obj.status == ESUploadMetadataStatusInUpload) {
                item.metadata = obj;
                *stop = YES;
            }
        }];
        
        if (item.metadata) {
            NSArray * taskArr = [[ESTransferManager manager] getAutoSyncUploadingTask];
            [taskArr enumerateObjectsUsingBlock:^(ESTransferTask * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.metadata.assetLocalIdentifier isEqual:item.metadata.assetLocalIdentifier]) {
                    item.data = obj;
                }
            }];
        }
        if (metadatas.count > 0) {
            self.isAutoUploading = YES;
            item.height = 96;
            NSString *count = [NSString stringWithFormat:@"%@", @(metadatas.count)];
            NSString *title = [NSString stringWithFormat:TEXT_TRANSFER_SYNC_TITLE, count];
            NSDictionary *attributes = @{
                NSFontAttributeName: [UIFont systemFontOfSize:16],
                NSForegroundColorAttributeName: ESColor.labelColor,
            };
            NSDictionary *highlightAttr = @{
                NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                NSForegroundColorAttributeName: ESColor.primaryColor,
            };
            item.attributedTitle = [title match:count highlightAttr:highlightAttr defaultAttr:attributes];
            item.content = FileSizeString(item.metadata.size, YES);
        } else {
            item.height = 84;
            item.icon = IMAGE_FILE_SYNC_DONE;
            NSString *count = [NSString stringWithFormat:@"%@", @(account.uploadCountOfToday)];
            NSString *title = [NSString stringWithFormat:TEXT_TRANSFER_SYNC_COMPLETE, count];
            NSDictionary *attributes = @{
                NSFontAttributeName: [UIFont systemFontOfSize:16],
                NSForegroundColorAttributeName: ESColor.labelColor,
            };
            NSDictionary *highlightAttr = @{
                NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                NSForegroundColorAttributeName: ESColor.primaryColor,
            };
            item.attributedTitle = [title match:count highlightAttr:highlightAttr defaultAttr:attributes];
            item.content = [NSString stringWithFormat:TEXT_TRANSFER_SYNC_LAST_TIME, account.lastSyncCompleteTimeString];
        }
        [cellArray addObject:item];
        self.dataSource[@(ESUploadListSectionSync)] = cellArray;
    }
}

- (void)loadData {
    NSUInteger taskCount = 0;
    BOOL showSync = NO;
    ESAccount *account = ESAccountManager.manager.currentAccount;
    if (account.canAutoUpload) {
        [self reloadSyncData];
        showSync = YES;
        taskCount += 1;
    }

    {
        NSArray *sorted = [ESTransferManager.manager.uploading sortedArrayUsingComparator:^NSComparisonResult(ESTransferTask *obj1, ESTransferTask *obj2) {
            return [@(obj2.timestamp) compare:@(obj1.timestamp)];
        }];
        NSMutableArray *cellArray = [sorted yc_mapWithBlock:^id(NSUInteger idx, ESTransferTask *obj) {
            ESTransferCellItem *item = [ESTransferCellItem new];
            item.identifier = @"ESTransferUploadCell";
            item.title = obj.name;
            item.content = FileSizeString(obj.size, YES);
            item.height = 96;
            item.data = obj;
            if (obj.state == ESTransferStateFailed) {
                item.state = TEXT_TRANSFER_UPLOAD_FAILED;
            }
            return item;
        }];
        self.dataSource[@(ESUploadListSectionOngoing)] = cellArray;
        taskCount += cellArray.count;
    }
    {
        NSArray *sorted = [ESTransferManager.manager.uploaded sortedArrayUsingComparator:^NSComparisonResult(ESTransferTask *obj1, ESTransferTask *obj2) {
            return [@(obj2.timestamp) compare:@(obj1.timestamp)];
        }];
        NSMutableArray *cellArray = [sorted yc_mapWithBlock:^id(NSUInteger idx, ESTransferTask *obj) {
            ESTransferCellItem *item = [ESTransferCellItem new];
            item.identifier = @"ESTransferCompletedCell";
            item.title = obj.name;
            NSString *date = [[NSDate dateWithTimeIntervalSince1970:obj.timestamp] stringFromFormat:@"YYYY-MM-dd HH:mm:ss"];
            NSString *target = [NSString stringWithFormat:TEXT_TRANSFER_UPLOAD_TARGET, obj.targetDir ?: @"/"];
            target = [target substringToIndex:target.length - 1];
            item.content = [FileSizeString(obj.size, YES) stringByAppendingFormat:@" %@\n%@", date, target];
            item.height = 106;
            item.data = obj;
            return item;
        }];
        self.dataSource[@(ESUploadListSectionComplete)] = cellArray;
        taskCount += cellArray.count;
    }

    if (taskCount > 0) {
        _emptyView.hidden = YES;
        if (showSync) {
            self.section = @[
                @(ESUploadListSectionSync),
                @(ESUploadListSectionOngoing),
                @(ESUploadListSectionComplete),
            ];
        } else {
            self.section = @[
                @(ESUploadListSectionOngoing),
                @(ESUploadListSectionComplete),
            ];
        }

    } else {
        self.section = nil;
        [self showEmpty];
    }

    [self.tableView reloadData];
}

- (void)showEmpty {
    self.emptyView.hidden = NO;
    ESEmptyItem *item = [ESEmptyItem new];
    item.icon = IMAGE_EMPTY_NO_TRANSFER;
    item.content = TEXT_TRANSFER_NO_TASK;
    [self.emptyView reloadWithData:item];
    [self.view bringSubviewToFront:self.emptyView];
}

- (void)removeTaskAction {
    NSArray<ESTransferCellItem *> *cellArray = self.dataSource[@(ESUploadListSectionComplete)];
    NSArray<ESTransferTask *> *selectedArray = [cellArray yc_mapWithBlock:^id(NSUInteger idx, ESTransferCellItem *obj) {
        if (obj.data.selectForDelectRecord) {
            return obj.data;
        }
        return nil;
    }];
    ESTransferDeleteHistoryAlert(self, TEXT_TRANSFER_UPLOAD_CLEAR_CONFIRM_MESSAGE, ^(UIAlertAction *action) {
        [ESTransferManager.manager clearUploadTask:selectedArray];
        [self.parent reloadSelectionState:ESTransferSelectionStateSelectedNone num:0];
    });
}

- (void)showAllSelectOrNot {
    __block NSUInteger count = 0;
    __block NSUInteger selected = 0;
    NSArray<ESTransferCellItem *> *cellArray = self.dataSource[@(ESUploadListSectionComplete)];
    count += cellArray.count;
    [cellArray yc_each:^(ESTransferCellItem *item) {
        if (item.data.selectForDelectRecord) {
            selected++;
        }
    }];
    ESTransferSelectionState state = ESTransferSelectionStateSelectedNone;
    if (selected > 0) {
        state = selected == count ? ESTransferSelectionStateSelectedAll : ESTransferSelectionStateSelectedPart;
    }
    [self.parent reloadSelectionState:state num:selected];
}

- (void)previewFile:(ESTransferCellItem *)item {
    ESFileInfoPub * file = item.data.uploadFile;
    if (!file) {
        return;
    }
    
    if (IsVideoForFile(file)) {
        ESFileShowLoading(self, file, NO, ^(void) {
            ESFilePreviewWithTag(self, file, nil);
        });
    } else {
        ESFilePreview(self, file);
    }
}

/// 断点续传
- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESTransferCellItem *item = [self objectAtIndexPath:indexPath];
    if (!action) {
        [self previewFile:item];
        return;
    }
    ESTransferCellAction type = [action integerValue];
    switch (type) {
        case ESTransferCellActionPause: {
            [ESTransferManager.manager suspendedUploadTask:item.data];
            [self refreshHeaderView];
        } break;
        case ESTransferCellActionResume: {
            ///重新开始
            if (item.data.taskErrorState == ESTransferErrorStateUploadFailedMissing) {
                [ESToast toastInfo:NSLocalizedString(@"Upload File Missing Hint", nil)];
                return;
            }
            [ESTransferManager.manager resumeUploadTask:item.data];
            [self silentReloadIndexPath:indexPath];
            [self refreshHeaderView];
        } break;
        case ESTransferCellActionSelect: {
            if (!self.inSelectionMode) {
                self.parent.inSelectionMode = YES;
            }
            [self showAllSelectOrNot];
        } break;
        case ESTransferCellActionLongPress: {
            if(item.data.state == ESTransferStateReady || item.data.state == ESTransferStateRunning){
                NSString * text = NSLocalizedString(@"Delete Uploading task Hint", @"是否确定删除正在上传的任务？");
                ESTransferDeleteHistoryAlert(self, text, ^(UIAlertAction *action) {
                    [ESTransferManager.manager clearUploadTask:@[item.data]];
                    [self deleteBoxTask:item.data];
                    [self deleteUploadingArray:item.data.metadata.photoID];
                });
            }else if(item.data.state == ESTransferStateCompleted){
                NSString * text = NSLocalizedString(@"Delete Upload Records Hint", @"只删除上传记录，已上传的文件不受影响");
                ESTransferDeleteHistoryAlert(self, text, ^(UIAlertAction *action) {
                    [ESTransferManager.manager clearUploadTask:@[item.data]];
                });
            }
            else if(item.data.state == ESTransferStateFailed) {
                NSString * text = NSLocalizedString(@"Delete Uploading task Hint", @"是否确定删除正在上传的任务？");
                ESTransferDeleteHistoryAlert(self, text, ^(UIAlertAction *action) {
                    [ESTransferManager.manager clearUploadTask:@[item.data]];
                    [self deleteBoxTask:item.data];
                    [self deleteUploadingArray:item.data.metadata.photoID];
                });
            }else{
                ESTransferDeleteHistoryAlert(self, TEXT_TRANSFER_UPLOAD_CLEAR_CONFIRM_MESSAGE, ^(UIAlertAction *action) {
                    [self deleteBoxTask:item.data];
                    [ESTransferManager.manager clearUploadTask:@[item.data]];
                });
                [self deleteUploadingArray:item.data.metadata.photoID];
            }
        } break;
        default:
            break;
    }
}


-(void)deleteUploadingArray:(NSString *)str{
    NSArray *uploadingArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadUploadingArray"];
    if(uploadingArray.count > 0){
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:uploadingArray];
        [mutableArray removeObject:str];
        NSArray *array = mutableArray;
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"uploadUploadingArray"];
    }
}

-(void)deleteBoxTask:(ESTransferTask *)data{
    if ([[ESTransferManager manager] hasSameBetagTaskInUploadingQueue:data]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ESMultipartApi *api = [ESMultipartApi new];
        ESDeleteMultipartTaskReq *rep = [ESDeleteMultipartTaskReq new];
      
        if (data.metadata.uploadId.length > 0) {
            rep.uploadId = data.metadata.uploadId;
            [api spaceV1ApiMultipartDeletePostWithRequestId:NSUUID.UUID.UUIDString.lowercaseString object:rep completionHandler:^(ESRsp *output, NSError *error) {
                
            }];
        }
    });
}

#pragma mark - SelectionMode

- (void)setInSelectionMode:(BOOL)inSelectionMode {
    _inSelectionMode = inSelectionMode;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        float bottom = inSelectionMode ? (44 + kBottomHeight) : 0;
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, bottom, 0));
    }];
    [self.tableView reloadData];
}

- (void)selectAllItem:(BOOL)flag {
    NSArray<ESTransferCellItem *> *cellArray = self.dataSource[@(ESUploadListSectionComplete)];
    [cellArray yc_each:^(ESTransferCellItem *item) {
        [item.data updateSelectForRecord:flag];
    }];
    [self.tableView reloadData];
    NSUInteger num = flag ? cellArray.count : 0;
    [self.parent reloadSelectionState:flag ? ESTransferSelectionStateSelectedAll : ESTransferSelectionStateSelectedPart num:num];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.headerItemDict[self.section[section]].selected) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

#pragma mark - Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    ESTransferUploadHeader *header = (ESTransferUploadHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([ESTransferUploadHeader class])];
    ESTransferUploadHeader *header = [ESTransferUploadHeader new];
    ESFormItem *item = self.headerItemDict[self.section[section]];
    ESUploadListSection sectionValue = [self.section[section] integerValue];
    if (sectionValue == ESUploadListSectionSync) {
        item.title = TEXT_TRANSFER_SYNC;
        //item.content = TEXT_TRANSFER_PAUSE_ALL;
        item.type = ESTransferHeaderActionPause;
        header.allButtonPaues.hidden = YES;
    } else if (sectionValue == ESUploadListSectionOngoing) {
        self.uploadingHeaderView = header;
        item.title = [NSString stringWithFormat:TEXT_TRANSFER_UPLOAD_ONGOING, @([super tableView:tableView numberOfRowsInSection:section])];
        NSNumber *sectionNum = @([super tableView:tableView numberOfRowsInSection:section]);
        
        if([sectionNum intValue] == 0){
            header.allButtonPaues.hidden = YES;
        }else{
            header.allButtonPaues.hidden = NO;
            if (ESTransferManager.manager.uploading.count > 0){
                header.allButtonPaues.hidden = NO;
                BOOL hasRun = NO;
                for (ESTransferTask * task in ESTransferManager.manager.uploading) {
                    if (task.state == ESTransferStateRunning || task.state == ESTransferStateReady) {
                        hasRun = YES;
                        break;
                    }
                }
                
                [header setButtonAction:(hasRun ? ESTransferHeaderActionResume : ESTransferHeaderActionPause)];
            } else {
                header.allButtonPaues.hidden = YES;
            }
        }
 
        //item.content = TEXT_TRANSFER_PAUSE_ALL;
        item.type = ESTransferHeaderActionPause;

    }
    else {
        header.allButtonPaues.hidden = YES;
        item.title = [NSString stringWithFormat:TEXT_TRANSFER_UPLOAD_COMPLETE, @([super tableView:tableView numberOfRowsInSection:section])];
        item.content = TEXT_TRANSFER_CLEAR_HISTORY;
        item.type = ESTransferHeaderActionClear;
    }
    item.icon = IMAGE_FILE_HEADER_EXPAND;
    [header reloadWithData:item];
    weakfy(self);
    header.actionBlock = ^(id action) {
        [weak_self headerAction:[action integerValue] item:item];
    };
    return header;
}

- (void)refreshHeaderView {
    if (ESTransferManager.manager.uploading.count > 0){
        self.uploadingHeaderView.allButtonPaues.hidden = NO;
        BOOL hasRun = NO;
        for (ESTransferTask * task in ESTransferManager.manager.uploading) {
            if (task.state == ESTransferStateRunning || task.state == ESTransferStateReady) {
                hasRun = YES;
                break;
            }
        }
        
        [self.uploadingHeaderView setButtonAction:(hasRun ? ESTransferHeaderActionResume : ESTransferHeaderActionPause)];
    } else {
        self.uploadingHeaderView.allButtonPaues.hidden = YES;
    }
}

- (void)headerAction:(ESTransferHeaderAction)action item:(ESFormItem *)item {
    if (action == ESTransferHeaderActionClear) {
        ESTransferDeleteHistoryAlert(self, TEXT_TRANSFER_UPLOAD_CLEAR_CONFIRM_MESSAGE, ^(UIAlertAction *action) {
            [ESTransferManager.manager clearUploadTask:nil];
            if (self.inSelectionMode) {
                self.inSelectionMode = NO;
                self.parent.inSelectionMode = NO;
            }
        });
    } else if (action == ESTransferHeaderActionShrink || action == ESTransferHeaderActionExpand) {
        item.selected = !item.selected;
        [self.tableView reloadData];
    }
}

#pragma mark - Lazy Load

- (ESEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[ESEmptyView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _emptyView;
}

@end
