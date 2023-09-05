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
//  ESDownloadListViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESDownloadListViewController.h"
#import "ESColor.h"
#import "ESEmptyView.h"
#import "ESFileDefine.h"
#import "ESFilePreviewViewController.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESTransferCellItem.h"
#import "ESTransferDownloadHeader.h"
#import "ESTransferManager.h"
#import "NSDate+Format.h"
#import <Masonry/Masonry.h>
#import <YCEasyTool/NSArray+YCTools.h>
#import "ESCommentCachePlistData.h"
#import "ESTransferDownloadCell.h"
#import "ESToast.h"
#import "ESTransferCompletedCell.h"

@interface ESTransferManager ()

@property (nonatomic, readonly) NSArray<ESTransferTask *> *downloading;

@property (nonatomic, readonly) NSArray<ESTransferTask *> *downloaded;

- (void)clearDownloaded:(NSArray<ESTransferTask *> *)itemArray;

@end

typedef NS_ENUM(NSUInteger, ESDownloadListSection) {
    ESDownloadListSectionOngoing,
    ESDownloadListSectionComplete,
};

@interface ESDownloadListViewController ()

@property (nonatomic, strong) NSArray<ESFormItem *> *headerItemArray;

@property (nonatomic, strong) ESEmptyView *emptyView;
@property (nonatomic, strong) ESTransferDownloadHeader * downloadingHeaderView;
@end

@implementation ESDownloadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [ESColor systemBackgroundColor];
    [self.tableView registerClass:[ESTransferDownloadHeader class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([ESTransferDownloadHeader class])];
    self.cellClass = [ESTransferDownloadCell class];
    self.cellClass = [ESTransferCompletedCell class];
    _headerItemArray = @[
        [ESFormItem new],
        [ESFormItem new],
    ];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

- (NSArray<ESTransferTask *> *)getDownloadedTaskList {
    return ESTransferManager.manager.downloaded;
}

- (void)loadData {
    NSUInteger taskCount = 0;
    {
        NSArray *sorted = [ESTransferManager.manager.downloading sortedArrayUsingComparator:^NSComparisonResult(ESTransferTask *obj1, ESTransferTask *obj2) {
            return [@(obj2.timestamp) compare:@(obj1.timestamp)];
        }];
        NSMutableArray *cellArray = [sorted yc_mapWithBlock:^id(NSUInteger idx, ESTransferTask *obj) {
            ESTransferCellItem *item = [ESTransferCellItem new];
            item.identifier = @"ESTransferDownloadCell";
            item.title = obj.name;
            item.content = FileSizeString(obj.size, YES);
            item.height = 96;
            item.data = obj;
            return item;
        }];
        self.dataSource[@(ESDownloadListSectionOngoing)] = cellArray;
        taskCount += cellArray.count;
    }
    
    {
        NSArray *sorted = [ESTransferManager.manager.downloaded sortedArrayUsingComparator:^NSComparisonResult(ESTransferTask *obj1, ESTransferTask *obj2) {
            return [@(obj2.timestamp) compare:@(obj1.timestamp)];
        }];
        NSMutableArray *cellArray = [sorted yc_mapWithBlock:^id(NSUInteger idx, ESTransferTask *obj) {
            ESTransferCellItem *item = [ESTransferCellItem new];
            item.title = obj.name;
            item.identifier = @"ESTransferCompletedCell";
            NSString *date = [[NSDate dateWithTimeIntervalSince1970:obj.timestamp] stringFromFormat:kESDateFomatYMDHHMMSS];
            item.content = [NSString stringWithFormat:@"%@ %@", FileSizeString(obj.size, YES), date];
            item.height = 84;
            item.data = obj;
            return item;
        }];
        NSArray *originalArr = cellArray;
        NSMutableArray *resultArrM = [NSMutableArray array];
        
        for (ESTransferCellItem *item in originalArr) {
            BOOL isHave = NO;
            for(ESTransferCellItem *itemNew in resultArrM){
                if (itemNew.title == item.title) {
                    isHave = YES;
                }
            }
            if (!isHave) {
                [resultArrM addObject:item];
            }
        }
        self.dataSource[@(ESDownloadListSectionComplete)] = resultArrM;
        taskCount += resultArrM.count;
    }
    if (taskCount > 0) {
        _emptyView.hidden = YES;
        self.section = @[
            @(ESDownloadListSectionOngoing),
            @(ESDownloadListSectionComplete),
        ];
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
    NSArray<ESTransferCellItem *> *cellArray = self.dataSource[@(ESDownloadListSectionComplete)];
    [cellArray yc_each:^(ESTransferCellItem *item) {
        [item.data updateSelectForRecord:flag];
    }];
    NSUInteger num = flag ? cellArray.count : 0;
    [self.parent reloadSelectionState:flag ? ESTransferSelectionStateSelectedAll : ESTransferSelectionStateSelectedPart num:num];
    [self.tableView reloadData];
}

- (void)removeTaskAction {
    NSArray<ESTransferCellItem *> *cellArray = self.dataSource[@(ESDownloadListSectionComplete)];
    NSArray<ESTransferTask *> *selectedArray = [cellArray yc_mapWithBlock:^id(NSUInteger idx, ESTransferCellItem *obj) {
        if (obj.data.selectForDelectRecord) {
            return obj.data;
        }
        return nil;
    }];
    
    ESTransferDeleteHistoryAlert(self, TEXT_TRANSFER_DOWNLOAD_CLEAR_CONFIRM_MESSAGE, ^(UIAlertAction *action) {
        [ESTransferManager.manager clearDownloaded:selectedArray];
        [self.parent reloadSelectionState:ESTransferSelectionStateSelectedNone num:0];
    });
}

#pragma mark - Action

- (void)shareFile:(ESTransferTask *)task {
    NSString * path = [task getDownloadFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [ESToast toastError:NSLocalizedString(@"File cache has been lost", @"文件缓存已丢失")];
        return;
    }
    NSString * filePath = [[NSString alloc] initWithFormat:@"file://%@", path];
    NSURL *shareURL = [NSURL URLWithString:filePath];
    NSArray *activityItems = [[NSArray alloc] initWithObjects:shareURL, nil];
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    };
    
    vc.completionWithItemsHandler = myBlock;
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)previewFile:(ESTransferCellItem *)item {
    if (!item.data.localPath) {
        return;
    }
    if (UnsupportFileForPreview(item.data.file)) {
        [self shareFile:item.data];
        return;
    }
    
    ESFilePreview(self, item.data.file);
}

- (void)showAllSelectOrNot {
    __block NSUInteger count = 0;
    __block NSUInteger selected = 0;
    NSArray<ESTransferCellItem *> *cellArray = self.dataSource[@(ESDownloadListSectionComplete)];
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

/// 断点续传
- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESTransferCellItem *item = [self objectAtIndexPath:indexPath];
    if (!action) {
        if (indexPath.section == ESDownloadListSectionComplete) {
            [self previewFile:item];
        }
        return;
    }
    ESTransferCellAction type = [action integerValue];
    switch (type) {
        case ESTransferCellActionPause: {
            [ESTransferManager.manager suspendedDownloadTask:item.data];
            [self refreshHeaderView];
            return;
        } break;
        case ESTransferCellActionResume: {
            [ESTransferManager.manager resumeDownloadTask:item.data];
            [self refreshHeaderView];
            return;
        } break;
        case ESTransferCellActionSelect: {
            if (!self.inSelectionMode) {
                self.parent.inSelectionMode = YES;
            }
            [self showAllSelectOrNot];
        } break;
        case ESTransferCellActionLongPress: {
            ESTransferDeleteHistoryAlert(self, TEXT_TRANSFER_DOWNLOAD_CLEAR_CONFIRM_MESSAGE, ^(UIAlertAction *action) {
                [ESTransferManager.manager clearDownloaded:@[item.data]];
            });
        } break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.headerItemArray[section].selected) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

#pragma mark - Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESTransferDownloadHeader *header = (ESTransferDownloadHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([ESTransferDownloadHeader class])];
    ESFormItem *item = self.headerItemArray[section];
    if (section == ESDownloadListSectionOngoing) {
        self.downloadingHeaderView = header;
        item.title = [NSString stringWithFormat:TEXT_TRANSFER_DOWNLOAD_ONGOING, @([super tableView:tableView numberOfRowsInSection:section])];
        if (ESTransferManager.manager.downloading.count > 0){
            header.allDownButtonPaues.hidden = NO;
            BOOL hasRun = NO;
            for (ESTransferTask * task in ESTransferManager.manager.downloading) {
                if (task.state == ESTransferStateRunning || task.state == ESTransferStateReady) {
                    hasRun = YES;
                    break;
                }
            }
            
            [header setButtonAction:(hasRun ? ESTransferHeaderActionResume : ESTransferHeaderActionPause)];
        } else {
            header.allDownButtonPaues.hidden = YES;
        }
    } else {
        header.allDownButtonPaues.hidden = YES;
        item.title = [NSString stringWithFormat:TEXT_TRANSFER_DOWNLOAD_COMPLETE, @([super tableView:tableView numberOfRowsInSection:section])];
        item.content = TEXT_TRANSFER_CLEAR_HISTORY;
        item.type = ESTransferHeaderActionClear;
    }
    weakfy(self);
    item.icon = IMAGE_FILE_HEADER_EXPAND;
    header.actionBlock = ^(id action) {
        [weak_self headerAction:[action integerValue] item:item];
    };
    [header reloadWithData:item];
    return header;
}

- (void)refreshHeaderView {
    if (ESTransferManager.manager.downloading.count > 0){
        self.downloadingHeaderView.allDownButtonPaues.hidden = NO;
        BOOL hasRun = NO;
        for (ESTransferTask * task in ESTransferManager.manager.downloading) {
            if (task.state == ESTransferStateRunning || task.state == ESTransferStateReady) {
                hasRun = YES;
                break;
            }
        }
        
        [self.downloadingHeaderView setButtonAction:(hasRun ? ESTransferHeaderActionResume : ESTransferHeaderActionPause)];
    } else {
        self.downloadingHeaderView.allDownButtonPaues.hidden = YES;
    }
}

- (void)headerAction:(ESTransferHeaderAction)action item:(ESFormItem *)item {
    if (action == ESTransferHeaderActionClear) {
        ESTransferDeleteHistoryAlert(self, TEXT_TRANSFER_DOWNLOAD_CLEAR_CONFIRM_MESSAGE, ^(UIAlertAction *action) {
            [ESTransferManager.manager clearDownloaded:nil];
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
