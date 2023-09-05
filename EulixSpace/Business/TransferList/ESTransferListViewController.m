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
//  ESTransferListViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTransferListViewController.h"
#import "ESAccountManager.h"
#import "ESDownloadListViewController.h"
#import "ESFileDefine.h"
#import "ESFilePageContentView.h"
#import "ESFilePageTitleView.h"
#import "ESFormItem.h"
#import "ESGlobalMacro.h"
#import "ESGradientButton.h"
#import "ESLocalNetworking.h"
#import "ESLocalizableDefine.h"
#import "ESThemeDefine.h"
#import "ESTransferInfo.h"
#import "ESTransferManager.h"
#import "ESUploadListViewController.h"
#import "UIView+ESTool.h"
#import "ESCommonToolManager.h"
#import <Masonry/Masonry.h>
#import "ESCaChe.h"
#import "ESBoxManager.h"

#import "ESCommonToolManager.h"

#import "UIColor+ESHEXTransform.h"
#import "UILabel+ESTool.h"
#import "UIView+ESTool.h"

#define kPhoneInfoH (CGFloat)64
#define kTitleViewH (CGFloat)56
#define kSloganHeight (CGFloat)30

#define ESUploadHintKey [NSString stringWithFormat:@"ESUploadHintKey_%@", ESBoxManager.activeBox.uniqueKey]
#define ESAutoUploadHintKey [NSString stringWithFormat:@"ESAutoUploadHintKey_%@", ESBoxManager.activeBox.uniqueKey]
#define ESDownloadHintKey [NSString stringWithFormat:@"ESDownloadHintKey_%@", ESBoxManager.activeBox.uniqueKey]

@interface ESTransferManager ()

@property (nonatomic, copy) void (^notifyListener)(void);

@end

@interface ESTransferListViewController () <ESPageContentViewDelegate, ESPageTitleViewDelegate, ESLocalNetworkingStatusProtocol>

@property (nonatomic, strong) ESTransferInfo *storageInfo;

@property (nonatomic, strong) ESTransferInfo *networkingStatus;

// 标题栏
@property (nonatomic, strong) ESFilePageTitleView *pageTitleView;

@property (nonatomic, strong) ESFilePageContentView *pageContentView;

@property (nonatomic, strong) ESDownloadListViewController *downloadList;

@property (nonatomic, strong) ESUploadListViewController *uploadList;

@property (nonatomic, strong) UIColor *previousNaviColor;

@property (nonatomic, assign) BOOL inSelectionMode;

@property (nonatomic, weak) id<ESTransferListSelectionProtocol> current;

@property (nonatomic, strong) ESGradientButton *removeTask;

@property (nonatomic, strong) UIView * sloganView;

@end

@implementation ESTransferListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_TRANSFER_LIST;
    self.view.backgroundColor = [ESColor secondarySystemBackgroundColor];
    self.hideNavigationBar = NO;
    [self pageTitleView];
    [self setupUI];
    [self showPhoneInfo];
    weakfy(self);
    ESTransferManager.manager.notifyListener = ^{
        [weak_self reloadData];
    };
    [self reloadData];
    self.navigationBarBackgroundColor = self.view.backgroundColor;
    [ESLocalNetworking.shared addLocalNetworkStatusObserver:self];
}

- (void)reloadData {
    [self.downloadList loadData];
    [self checkDownloadCompletedTask];

    [self.uploadList loadData];
    [self checkUploadCompletedTask];
}

- (void)checkDownloadCompletedTask {
    NSArray<ESTransferTask *> * taskList = [self.downloadList getDownloadedTaskList];
    if (!taskList || taskList.count == 0) {
        [[ESCache defaultCache] setObject:nil forKey:ESDownloadHintKey];
        [self.pageTitleView showHintPoint:0 show:NO];
        return;
    }
    
    __block BOOL show = NO;
    NSArray<NSString *> * downloadList = [[ESCache defaultCache] objectForKey:ESDownloadHintKey];
    NSMutableArray * resultList = [NSMutableArray array];
    if (!downloadList || downloadList.count == 0) {
        show = YES;
    } else {
        resultList = [NSMutableArray arrayWithArray:downloadList];
    }
    
    [taskList enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * key = [NSString stringWithFormat:@"%@_%llu", obj.name, obj.timestamp];
        if (![resultList containsObject:key]) {
            show = YES;
            *stop = YES;
        }
    }];
    
    if (self.current == self.downloadList) {
        show = NO;
    }
    
    [self.pageTitleView showHintPoint:0 show:show];
    [self saveLatestRecords];
}

- (void)checkUploadCompletedTask {
    NSArray<ESTransferTask *> * taskList = [self.uploadList getUploadedTaskList];
    if (!taskList || taskList.count == 0) {
        [[ESCache defaultCache] setObject:nil forKey:ESUploadHintKey];
        [self.pageTitleView showHintPoint:1 show:NO];
        return;
    }
    
    __block BOOL show = NO;
    ESAccount *account = ESAccountManager.manager.currentAccount;
    NSInteger num = account.uploadCountOfToday;
    if (account.autoUpload && num > 0 && ![self.uploadList isAutoUploading]) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMdd";
        NSString * today = [formatter stringFromDate:[NSDate date]];

        NSString * autoRecord = [[ESCache defaultCache] objectForKey:ESAutoUploadHintKey];
        if (autoRecord == nil || autoRecord.length == 0) {
            show = YES;
        } else {
            NSArray * arr = [autoRecord componentsSeparatedByString:@"_"];
            NSString * recordDate = [arr firstObject];
            NSInteger lastNum = [[arr lastObject] longLongValue];

            if (![recordDate isEqualToString:today] || num > lastNum) {
                show = YES;
            }
        }
        
        NSString * str = [NSString stringWithFormat:@"%@_%ld", today, num];
        [[ESCache defaultCache] setObject:str forKey:ESAutoUploadHintKey];
    }
    
    NSArray<NSString *> * uploadList = [[ESCache defaultCache] objectForKey:ESUploadHintKey];
    NSMutableArray * resultList = [NSMutableArray array];
    if (!uploadList || uploadList.count == 0) {
        show = YES;
    } else {
        resultList = [NSMutableArray arrayWithArray:uploadList];
    }
    
    [taskList enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * key = [NSString stringWithFormat:@"%@_%llu", obj.name, obj.timestamp];
        if (![resultList containsObject:key]) {
            show = YES;
            *stop = YES;
        }
    }];
    
    if (self.current == self.uploadList) {
        show = NO;
    }
    [self.pageTitleView showHintPoint:1 show:show];
    [self saveLatestRecords];
}

- (void)saveLatestRecords {
    NSString * key;
    NSArray<ESTransferTask *> * taskList;
 
    if (self.current == self.downloadList) {
        key = ESDownloadHintKey;
        taskList = [self.downloadList getDownloadedTaskList];
    } else {
        key = ESUploadHintKey;
        taskList = [self.uploadList getUploadedTaskList];
    }
    
    NSArray<NSString *> * list = [[ESCache defaultCache] objectForKey:key];
    NSMutableArray * resultList = [NSMutableArray array];
    if (list && list.count > 0) {
        resultList = [NSMutableArray arrayWithArray:list];
    }
    
    [taskList enumerateObjectsUsingBlock:^(ESTransferTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * key = [NSString stringWithFormat:@"%@_%llu", obj.name, obj.timestamp];
        if (![resultList containsObject:key]) {
            [resultList addObject:key];
        }
    }];
    [[ESCache defaultCache] setObject:resultList forKey:key];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)loadData {
    [self showNetworkingStatus];
}

- (void)localNetworkReachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    weakfy(self);
    ESPerformBlockOnMainThread(^{
        strongfy(self)
        [self showNetworkingStatus];
    });
}

- (void)localNetworkUnreachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    weakfy(self);
    ESPerformBlockOnMainThread(^{
        strongfy(self)
        [self showNetworkingStatus];
    });
}

- (void)showNetworkingStatus {
    ESFormItem *item = [ESFormItem new];
    item.icon = IMAGE_NETWORKING_STATUS;
    item.title = TEXT_CURRENT_NETWORKING;
//    item.content = ESLocalNetworking.shared.reachableBox ? TEXT_CURRENT_NETWORKING_LOCAL : TEXT_CURRENT_NETWORKING_INTERNET;
    item.content = [ESLocalNetworking getConnectedDescribe];
    [self.networkingStatus reloadWithData:item];
}

- (void)showPhoneInfo {
    NSError *error = nil;
    NSString *content;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject error:&error];
    if (dictionary) {
        NSNumber *free = dictionary[NSFileSystemFreeSize];
        NSNumber *total = dictionary[NSFileSystemSize];
        UInt64 useSpace = [total unsignedLongLongValue] - [free unsignedLongLongValue];
        content = [NSString stringWithFormat:TEXT_PHONE_STORAGE_INFO, FileSizeString(useSpace, YES), FileSizeString([total unsignedLongLongValue], YES)];
    } else {
        content = [NSString stringWithFormat:TEXT_PHONE_STORAGE_INFO, @"--", @"--"];
    }

    ESFormItem *item = [ESFormItem new];
    item.icon = IMAGE_STORAGE_INFO;
    item.title = TEXT_PHONE_STORAGE_INFO_TITLE;
    item.content = content;
    [self.storageInfo reloadWithData:item];
}

- (void)loadDeviceInfo {
    [self showBoxInfo:ESAccountManager.manager.deviceInfo];
    [ESAccountManager.manager loadDeviceStorage:^(ESDeviceInfoResult *deviceInfo) {
        [self showBoxInfo:ESAccountManager.manager.deviceInfo];
    }];
}

- (void)showBoxInfo:(ESDeviceInfoResult *)deviceInfo {
    UInt64 spaceSizeUsed = deviceInfo.spaceSizeUsed.longLongValue;
    UInt64 spaceSizeTotal = deviceInfo.spaceSizeTotal.longLongValue;
    ESFormItem *item = [ESFormItem new];
    item.icon = IMAGE_STORAGE_INFO;
    item.title = TEXT_BOX_STORAGE_INFO_TITLE;
    item.content = [NSString stringWithFormat:@"%@ / %@", FileSizeString(spaceSizeUsed, YES), FileSizeString(spaceSizeTotal, YES)];
    [self.storageInfo reloadWithData:item];
}

- (void)setupUI {
    [self.storageInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(kPhoneInfoH);
    }];
    [self.storageInfo es_addline:10 offset:0 vertical:YES];
    [self.networkingStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(kPhoneInfoH);
    }];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#DFE0E5"];
    [self.storageInfo addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(37);
        make.centerY.mas_equalTo(self.storageInfo);
        make.right.mas_equalTo(self.storageInfo);
    }];
    
    [self.view addSubview:self.pageContentView];
    self.pageContentView.backgroundColor = [UIColor purpleColor];
    
    [self.sloganView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.storageInfo.mas_bottom);
    }];
    [self.view bringSubviewToFront:self.pageTitleView];
}

- (void)dealloc {
    [[ESTransferManager manager] clearAllSelectRecordState];
}
#pragma mark - SelectionMode

- (void)setInSelectionMode:(BOOL)inSelectionMode {
    _inSelectionMode = inSelectionMode;
    self.navigationItem.leftBarButtonItems = nil;
    if (_inSelectionMode) {
        self.removeTask.hidden = NO;
        [self.view bringSubviewToFront:self.removeTask];
        self.pageTitleView.userInteractionEnabled = NO;
        self.navigationItem.leftBarButtonItem = [self barItemWithTitle:TEXT_CANCEL selector:@selector(leaveSelectionMode)];
        self.navigationItem.leftBarButtonItem.tintColor = ESColor.primaryColor;
        self.navigationItem.rightBarButtonItem = [self barItemWithTitle:TEXT_SELECT_ALL selector:@selector(selectAll)];
        self.navigationItem.rightBarButtonItem.tintColor = ESColor.primaryColor;
    } else {
        self.navigationItem.title = TEXT_TRANSFER_LIST;
        self.removeTask.hidden = YES;
        [self.view sendSubviewToBack:self.removeTask];
        self.pageTitleView.userInteractionEnabled = YES;
        UIImage *backArrow = [IMAGE_IC_BACK_CHEVRON imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
        self.navigationItem.leftBarButtonItem = [self barItemWithImage:backArrow selector:@selector(goBack)];
        
        self.navigationItem.rightBarButtonItem = nil;
        [[ESTransferManager manager] clearAllSelectRecordState];
    }
    self.pageContentView.collectionView.scrollEnabled = !inSelectionMode;
    self.current.inSelectionMode = inSelectionMode;
}

- (void)leaveSelectionMode {
    self.inSelectionMode = NO;
}

- (void)selectAll {
    [self.current selectAllItem:YES];
}

- (void)unselectAll {
    [self.current selectAllItem:NO];
}

- (void)removeTaskAction {
    [self.current removeTaskAction];
}

- (void)reloadSelectionState:(ESTransferSelectionState)state num:(NSUInteger)num {
    if (state == ESTransferSelectionStateSelectedNone) {
        [self leaveSelectionMode];
        return;
    }
    if (state == ESTransferSelectionStateSelectedAll) {
        self.navigationItem.rightBarButtonItem = [self barItemWithTitle:TEXT_UNSELECT_ALL selector:@selector(unselectAll)];
    } else {
        self.navigationItem.rightBarButtonItem = [self barItemWithTitle:TEXT_SELECT_ALL selector:@selector(selectAll)];
    }
    self.navigationItem.rightBarButtonItem.tintColor = ESColor.primaryColor;
    self.navigationItem.title = [[NSString alloc] initWithFormat:NSLocalizedString(@"file_select", @"已选择 %lu 个文件"), num];
}

- (void)setCurrent:(id<ESTransferListSelectionProtocol>)current {
    _current = current;
    if (current == self.uploadList) {
        [self.pageTitleView showHintPoint:1 show:NO];
    } else {
        [self.pageTitleView showHintPoint:0 show:NO];
    }
    [self saveLatestRecords];
}

#pragma mark -title view's delegate method

- (void)pageTitletView:(id)contentView selectedIndex:(NSInteger)targetIndex {
    if (targetIndex == 0) {
        self.current = self.downloadList;
        [self showPhoneInfo];
    } else {
        self.current = self.uploadList;
        [self loadDeviceInfo];
    }
    [self.pageContentView setCurrentIndex:targetIndex];
}

#pragma mark -content view's delegate

- (void)pageContentView:(id)contentView progress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    if (targetIndex == 0) {
        self.current = self.downloadList;
    } else {
        self.current = self.uploadList;
    }
    [self.pageTitleView setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
}

#pragma mark - Lazy Load

- (ESFilePageTitleView *)pageTitleView {
    CGRect frame = CGRectMake(0, kPhoneInfoH + kSloganHeight, ScreenWidth, kTitleViewH - 1);
    NSArray *titles = @[TEXT_TRANSFER_DOWNLOAD_LIST, TEXT_TRANSFER_UPLOAD_LIST];
    if (!_pageTitleView) {
        __weak typeof(self) weakSelf = self;
//        CGFloat space = (ScreenWidth - 80 * 2) / 3;
        if([ESCommonToolManager isEnglish]){
            CGFloat space = (ScreenWidth - 120 * 2) / 3;
            _pageTitleView = [ESFilePageTitleView initWithFrame:frame titles:titles titleW:120 titleH:20 leftDistance:space titleSpacing:space fontOfSize:14];
        }else{
            CGFloat space = (ScreenWidth - 80 * 2) / 3;
            _pageTitleView = [ESFilePageTitleView initWithFrame:frame titles:titles titleW:80 titleH:20 leftDistance:space titleSpacing:space fontOfSize:14];
        }
     
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kPhoneInfoH + kSloganHeight + 10, ScreenWidth, kTitleViewH - 10)];
        bgView.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:bgView];
        UIView *line = [UIView new];
        line.backgroundColor = ESColor.separatorColor;
        [bgView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(bgView);
            make.bottom.mas_equalTo(bgView);
            make.height.mas_equalTo(1);
        }];
        
        _pageTitleView.delegate = weakSelf;
        _pageTitleView.backgroundColor = ESColor.systemBackgroundColor;
        _pageTitleView.layer.cornerRadius = 10;
        _pageTitleView.layer.masksToBounds = YES;
        
        [self.view addSubview:_pageTitleView];
    }
    return _pageTitleView;
}

- (ESFilePageContentView *)pageContentView {
    if (!_pageContentView) {
        NSMutableArray *childVcs = [NSMutableArray array];
        CGFloat contentH = ScreenHeight - kTopHeight - kTitleViewH - kPhoneInfoH - kSloganHeight;
        CGRect contentFrame = CGRectMake(0, kTitleViewH + kPhoneInfoH + kSloganHeight, ScreenWidth, contentH);

        self.downloadList = [[ESDownloadListViewController alloc] init];
        self.downloadList.parent = (id)self;
        self.uploadList = [[ESUploadListViewController alloc] init];
        self.uploadList.parent = (id)self;
        [childVcs addObject:self.downloadList];
        [childVcs addObject:self.uploadList];
        self.current = self.downloadList;

        __weak typeof(self) weakSelf = self;
        _pageContentView = [ESFilePageContentView initWithFrame:contentFrame ChildViewControllers:childVcs parentViewController:self];
        _pageContentView.delegate = weakSelf;
    }
    return _pageContentView;
}

- (ESTransferInfo *)storageInfo {
    if (!_storageInfo) {
        _storageInfo = [[ESTransferInfo alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kPhoneInfoH)];
        [self.view addSubview:_storageInfo];
    }
    return _storageInfo;
}

- (ESTransferInfo *)networkingStatus {
    if (!_networkingStatus) {
        _networkingStatus = [[ESTransferInfo alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kPhoneInfoH)];
        [self.view addSubview:_networkingStatus];
    }
    return _networkingStatus;
}

- (ESGradientButton *)removeTask {
    if (!_removeTask) {
        _removeTask = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_removeTask setCornerRadius:10];
        [_removeTask setTitle:TEXT_DELETE forState:UIControlStateNormal];
        _removeTask.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_removeTask setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_removeTask];
        [_removeTask addTarget:self action:@selector(removeTaskAction) forControlEvents:UIControlEventTouchUpInside];
        [_removeTask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.mas_bottom).inset(34);
            make.centerX.mas_equalTo(self.view);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(200);
        }];
    }
    return _removeTask;
}

- (UIView *)sloganView {
    if (!_sloganView) {
        UIView * conView = [[UIView alloc] init];
        conView.backgroundColor = [UIColor es_colorWithHexString:@"#EEEFF5"];
        conView.layer.masksToBounds = YES;
        conView.layer.cornerRadius = 10;
        [self.view addSubview:conView];

        
        UIView * view = [UIView es_sloganView:NSLocalizedString(@"common_encrypted", @"加密传输，畅享极速")];
        [conView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_greaterThanOrEqualTo(conView).inset(20);
            make.trailing.mas_lessThanOrEqualTo(conView).inset(-20);
            make.top.mas_equalTo(conView);
            make.bottom.mas_equalTo(conView).offset(-10);
            make.centerX.mas_equalTo(conView);
        }];
        
        _sloganView = conView;
    }
    return _sloganView;
}

@end

extern void ESTransferDeleteHistoryAlert(UIViewController *from, NSString *message, void (^handler)(UIAlertAction *action)) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:TEXT_TRANSFER_CLEAR_CONFIRM_TITLE
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
                                                if (handler) {
                                                    handler(action);
                                                }
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:TEXT_CANCEL
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    //加上下面的判断
    if (alert.popoverPresentationController) {
        [alert.popoverPresentationController setPermittedArrowDirections:0]; //去掉arrow箭头
        alert.popoverPresentationController.sourceView = from.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(0, CGRectGetHeight(from.view.frame), CGRectGetWidth(from.view.frame), CGRectGetHeight(from.view.frame));
    }
    [from presentViewController:alert animated:YES completion:nil];
}
