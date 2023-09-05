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
//  ESFileListBaseVC.m
//  EulixSpace
//
//  Created by qu on 2021/8/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileListBaseVC.h"
#import "Reachability.h"
#import "ESApiClient.h"
#import "ESFileCacheManager.h"

#import "ESBoxManager.h"
#import "ESGatewayClient.h"
#import "ESMJHeader.h"

#import "UIViewController+ESTool.h"
#import "UIView+ESTool.h"


@interface ESFileListBaseVC ()
@property (nonatomic, strong) NSString *uuid;

@property (nonatomic, strong) NSNumber *isNotWorking;


@end

@implementation ESFileListBaseVC

- (void)loadView {
    [super loadView];
    self.category = @"Total";
    self.isSearch = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isSearch && ![self.category isEqual:@"move"] && self.category.length >0) {
        if (self.isNotWorking.intValue < 1) {
            if (self.enterFileUUIDArray.count > 0) {
                ESFileInfoPub *info = self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1];
                [self headerRefreshWithUUID:info.uuid];
            } else {
                [self headerRefreshWithUUID:@""];
               
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.hidesBottomBarWhenPushed = NO;
    self.reloadWhenAppear = NO;
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.listView.children = [[ESFileCacheManager manager] getFileListDataCategory:self.category];
    [self.listView reloadData];
    self.enterFileUUIDArray = [[NSMutableArray alloc] init];
    self.listView.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.listView.category = self.category;
    self.current = self.listView;
    self.listView.isCopyMove = NO;
    self.blankSpaceView.hidden = YES;
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 10;
    self.listView.tableView.estimatedRowHeight = 0;
    self.listView.tableView.estimatedSectionHeaderHeight = 0;
    self.listView.tableView.estimatedSectionFooterHeight = 0;
    if(![self.category isEqual:@"search"]){
        [self addRefresh];
    }
  
    if (!self.isSearch && ![self.category isEqual:@"move"] && ![self.category isEqual:@"Folder"]) {
        if (self.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1];
            [self headerRefreshWithUUID:info.uuid];
        } else {
            if(![self.category isEqual:@"v2FileListVC"]){
                [self headerRefreshWithUUID:@""];
            }
           
        }
    }
    self.sloganView.frame = CGRectMake(0, 0, ScreenWidth, 50);
    self.listView.tableView.tableFooterView = self.sloganView;
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetWorking:) name:@"networkErrorNotificationCenter" object:nil];
}

- (UIView *)sloganView {
    if (!_sloganView) {
        UIView * conView = [[UIView alloc] init];
        conView.backgroundColor = ESColor.systemBackgroundColor;
        conView.layer.masksToBounds = YES;
        conView.layer.cornerRadius = 10;
        [self.view addSubview:conView];

        UIView * view = [UIView es_sloganView:NSLocalizedString(@"common_encrypted_main", @"多重安全技术，保护数据隐私")];
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

- (void)addRefresh {
    
    [self.listView.tableView.mj_header endRefreshing];
    [self.listView.tableView.mj_footer endRefreshing];
    weakfy(self);
    // 下拉刷新
    self.listView.tableView.mj_header = [ESMJHeader headerWithRefreshingBlock:^{
        strongfy(self);
        if (self.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1];
            [self headerRefreshWithUUID:info.uuid];
            self.uuid = info.uuid;
        } else {
            [self headerRefreshWithUUID:@""];
        }
    }];

    // 上拉加载
    self.listView.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        strongfy(self);
        if (self.totalInt >= self.pageInt) {
            if (self.enterFileUUIDArray.count > 0) {
                ESFileInfoPub *info = self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1];
                [self loadMoreDataWithUUID:info.uuid];
            } else {
                [self loadMoreDataWithUUID:@""];
            }
        }
    }];
}

- (void)reloadFileBaseData {
    [self headerRefreshWithUUID:nil];
}

- (void)headerRefreshWithUUID:(NSString *)uuid {
    if(![self.category isEqual:@"v2FileListVC"]){
        [self.listView.tableView.mj_header endRefreshing];
        [self.listView.tableView.mj_footer endRefreshing];
        if (![self isConnectionAvailable]) {
            ESToast.networkError(TEXT_ERROR_BOX_NOT_CONNECTED_TO_INTERNET).show();
        }
        
        if ([self isConnectionAvailable]) {
            self.children = [[NSMutableArray alloc] init];
            self.pageInt = 1;
            [self loadDataWithUUID:uuid];
        }
    }
}

- (void)loadDataWithUUID:(NSString *)uuid {
    if ([self isConnectionAvailable]) {
        [self getFileRequestStart:uuid];
    }
    [self.listView.tableView.mj_header endRefreshing];
    [self.listView.tableView.mj_footer endRefreshing];
}

- (void)loadMoreDataWithUUID:(NSString *)uuid {
    [self.listView.tableView.mj_header endRefreshing];
    [self.listView.tableView.mj_footer endRefreshing];
    [self getFileRequestMoreStart:uuid];
}

- (void)createFolder {
    ESFileInfoPub *item = [ESFileInfoPub new];
    // item.name = @"新建文件夹";
    item.isDir = @(YES);
    [self.children addObject:item];
    self.current.children = self.children;
}

- (void)getFileRequestStart:(NSString *)fileUUID {

    if ([self.category isEqual:@"Folder"]) {
        self.category = @"";
    }

    
//    ESApiClient *apiClient = [ESApiClient es_box:ESBoxManager.activeBox];
//    apiClient.timeoutInterval = 60;
//        ESDeviceApi *api = [[ESDeviceApi alloc] initWithApiClient:apiClient];
    ESFileApi *api =  [ESFileApi new];//[[ESFileApi alloc] initWithApiClient:apiClient];
    [api spaceV1ApiFileListGetWithUuid:fileUUID
                                 isDir:nil
                                  page:@(1)
                              pageSize:@(20)
                               orderBy:self.sortType
                              category:self.category
                     completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                        //[ESToast dismiss];
                         if (!error) {
                  
                             self.children = [NSMutableArray new];
                             NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
                             fileListArray = output.results.fileList.mutableCopy;
                   
                             for (ESFileInfoPub *info in fileListArray) {
                                 [self.children addObject:info];
                             }
                             ESPageInfoExt *pageInfo = output.results.pageInfo;
                             self.totalInt = pageInfo.total.intValue;
                             self.listView.children = self.children;
                          
                             [self.listView reloadData];
                             if (self.children.count > 0) {
                                 [[ESFileCacheManager manager] deleteObjectsFromTable];
                                 [[ESFileCacheManager manager] saveFileList:self.children];
                                 self.blankSpaceView.hidden = YES;
                             } else {
                                 if (![self.category isEqual:@"search"]) {
                                     self.blankSpaceView.hidden = NO;
                                 }
                             }
                         } else {
                             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
//                             self.children = [[NSMutableArray alloc] init];
//                             [self.listView reloadData];
                             self.blankSpaceView.hidden = (self.listView.children.count > 0);
                         }
                     }];
}

- (void)getFileRequestMoreStart:(NSString *)fileUUID {
    ESFileApi *api = [ESFileApi new];
    [api spaceV1ApiFileListGetWithUuid:fileUUID
                                 isDir:nil
                                  page:@(self.pageInt + 1)
                              pageSize:@(20)
                               orderBy:self.sortType
                              category:self.category
                     completionHandler:^(ESRspGetListRspData *output, NSError *error) {
                         [self.listView.tableView.mj_header endRefreshing];
                         [self.listView.tableView.mj_footer endRefreshing];
                         if (!error) {
                             if (output.results.pageInfo.page.intValue > output.results.pageInfo.total.intValue) {
                                 [self.listView.tableView.mj_footer endRefreshingWithNoMoreData];
                                 if (self.delegate && [self.delegate respondsToSelector:@selector(isNomoreData)]) {
                                     [self.delegate isNomoreData];
                                 }
                                 return;
                             }
                             if (output.results.pageInfo.page.intValue == self.pageInt + 1) {
                                 self.pageInt = output.results.pageInfo.page.intValue;
                             }

                             NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
                             fileListArray = output.results.fileList.mutableCopy;
                             for (ESFileInfoPub *info in fileListArray) {
                                 [self.children addObject:info];
                             }
                             ESPageInfoExt *pageInfo = output.results.pageInfo;
                             self.totalInt = pageInfo.total.intValue;
                             self.listView.children = self.children;
                             if (self.delegate && [self.delegate respondsToSelector:@selector(fileListBaseVCReloadData)]) {
                                 [self.delegate fileListBaseVCReloadData];
                             }
                         
                             [self.listView reloadData];
                             if (self.children.count > 0) {
                                 self.blankSpaceView.hidden = YES;
                             } else {
                                 self.blankSpaceView.hidden = NO;
                             }
                         } else {
//                             self.children = [[NSMutableArray alloc] init];
//                             [self.listView reloadData];
//                             self.blankSpaceView.hidden = NO;
                             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                         }
                     }];
}

- (void)cancelSelected {
    [self.current selectedAll:NO];
}

- (void)selectAll:(BOOL)isAllSelect {
    [self.current selectedAll:isAllSelect];
}

#pragma mark - Lazy Load

- (ESTotalListVC *)listView {
    if (!_listView) {
        _listView = [ESTotalListVC new];
        [self.view addSubview:_listView.view];
        [self addChildViewController:_listView];
        __weak __typeof__(self) weak_self = self;
        _listView.selectedFolder = ^(ESFileInfoPub *folder) {
        };

        _listView.selectFile = ^(ESFileInfoPub *data) {
            __typeof__(self) self = weak_self;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:data forKey:@"fileInfo"];
            [dic setValue:@(self.listView.isCopyMove) forKey:@"isMoveCopy"];

            if ([data.isDir boolValue] && self.listView.isCopyMove) {
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
                self.listView.category = @"Search";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didSecrchEnterFolderClick" object:dic];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didEnterFolderClick" object:dic];
            }
        };
    }
    return _listView;
}

- (ESEmptyView *)blankSpaceView {
    if (!_blankSpaceView) {
        _blankSpaceView = [ESEmptyView new];
        ESEmptyItem *item = [ESEmptyItem new];

        if ([self.category isEqual:@"move"]) {
            item.icon = IMAGE_EMPTY_NO_FOLDER;
            item.content =  NSLocalizedString(@"You dont have a folder yet", @"您还没有文件夹哦～"); 
        }else if([self.category isEqual:@"RecycleBin"]){
            item.icon =  [UIImage imageNamed:@"empty_no_huishouzhan"];
            item.content = NSLocalizedString(@"The recycle bin is very clean", @"回收站很干净哦");
        }
        else {
            item.icon = IMAGE_EMPTY_NOFILE;
            item.content = NSLocalizedString(@"Dont have any files yet, lets upload them", @"还没有任何文件，快来上传吧~");
        }

        [self.view addSubview:_blankSpaceView];
        [_blankSpaceView reloadWithData:item];
        [_blankSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _blankSpaceView;
}

- (void)reRefresh {
    ESFileInfoPub *info = self.enterFileUUIDArray[self.enterFileUUIDArray.count - 1];
    if (info.uuid.length > 0) {
        [self headerRefreshWithUUID:info.uuid];
    } else {
        [self headerRefreshWithUUID:@""];
    }
}

-(void)noNetWorking:(NSNotification *)notifi{
    NSNumber *obj = [notifi object];
    self.isNotWorking = obj;
}

-(BOOL)isConnectionAvailable{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }

  if (!isExistenceNetwork) {
    
        return NO;
    }
    
    return isExistenceNetwork;
}
@end
