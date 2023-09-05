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
//  ESFileHomePageVC.m
//  EulixSpace
//
//  Created by qu on 2021/7/19.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileHomePageVC.h"
#import "ESBottomDetailView.h"
#import "ESBottomMoreView.h"
#import "ESFIleDocumentVC.h"
#import "ESFileLoadingViewController.h"
#import "ESFileOtherVC.h"
#import "ESFilePhotoVC.h"
#import "ESFileVideoVC.h"
#import "ESFolderList.h"
#import "ESLocalPath.h"
#import "ESSearchListVC.h"
#import "ESTransferListViewController.h"
#import "ESTransferManager.h"
#import "ESRecycledApi.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import "Reachability.h"
#import "ESLocalNetworking.h"
#import "ESBoxManager.h"
#import "ESShareView.h"
#import "ESCommonToolManager.h"
#import "ESMeViewController.h"
#import "ESNetworkRequestManager.h"
#import "ESSearchBarView.h"
#import "ESCommentCachePlistData.h"
#import "ESCommonProcessStatusVC.h"
#import "UIView+Status.h"
#import "ESMJHeader.h"
#import "ESLoopPollManager.h"
#import "ESVersionInfoView.h"
#import "ESVersionManager.h"

#define kNavigationBarH (CGFloat)44
#define kTabBarH (CGFloat) self.tabBarHeight
#define kTitleViewH (CGFloat)56
#define kTitleViewW (CGFloat)280
#define kSearchViewH (CGFloat)46

@interface ESFileHomePageVC () <ESPageContentViewDelegate, ESPageTitleViewDelegate, ESFileBottomViewDelegate, ESBottomMoreViewDelegate, ESBottomDetailViewDelegate, ESBottomDetailViewDelegate, UIDocumentPickerDelegate, ESFileDelectViewDelegate, ESFileSortViewDelegate, EESFileListBaseVCDelegate,ESShareViewDelegate,UITabBarControllerDelegate, ESLocalNetworkingStatusProtocol>
// 标题栏

@property (nonatomic, strong) ESFileDelectView *delectView;

@property (assign, nonatomic) NSInteger targetIndex;

@property (nonatomic, strong) ESFileVideoVC *videoVC;
@property (nonatomic, strong) ESFilePhotoVC *photoVC;
@property (nonatomic, strong) ESFIleDocumentVC *documentVC;
@property (nonatomic, strong) ESFileOtherVC *otherVC;

@property (nonatomic, strong) ESBottomMoreView *moreView;

@property (nonatomic, strong) ESBottomDetailView *detailView;

@property (nonatomic, strong) ESFileInfoPub *selectedFile;

@property (nonatomic, assign) BOOL isEnterFile;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) UIView *backView;

@property (nonatomic, strong) ESShareView *shareView;

@property (nonatomic, strong) NSNumber *isNotWorking;
@property (nonatomic, strong) ESVersionInfoView *appUpdateHintView;

@end

@implementation ESFileHomePageVC

- (void)loadView {
    [super loadView];
    self.category = @"home";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isMoveCopy = NO;
    weakfy(self);
    NSString * name = [ESLocalNetworking getConnectionImageName];
    [self.transferListBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    if(ESLocalNetworking.shared.reachableBox){
//        [self.transferListBtn setBackgroundImage:IMAGE_MAIN_TRANSFER_LAN forState:UIControlStateNormal];
        [self.transferRotateImage setImage:IMAGE_MAIN_ROTATE_LAN];
    }else{
//        [self.transferListBtn setBackgroundImage:IMAGE_MAIN_TRANSFER_INTERNET forState:UIControlStateNormal];
        [self.transferRotateImage setImage:[UIImage imageNamed:@"main_shape"]];
    }
    if ([self.category isEqual:@"home"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"select_up_path"];

        [self loadMoreData];
        [ESTransferManager manager].taskCountBlock = ^(NSInteger count) {
            strongfy(self);
            if (count > 0) {
                self.transferListNumView.hidden = NO;
                self.transferRotateImage.hidden = NO;
                [self startAnimation];
                if (count > 99) {
                    self.numLable.text = [NSString stringWithFormat:@"99+"];
                } else {
                    self.numLable.text = [NSString stringWithFormat:@"%ld", (long)count];
                }
            } else {
                self.transferListNumView.hidden = YES;
                [self.transferRotateImage.layer removeAllAnimations];
                self.transferRotateImage.hidden = YES;
            }
        };
    }
    self.bottomView.hidden = YES;
    if(self.bottomView.hidden == YES && self.tabBarController.tabBar.hidden && self.navigationController.viewControllers.count == 1){
        self.tabBarController.tabBar.hidden = NO;
    }
    
}

- (void)localNetworkReachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    ESPerformBlockOnMainThread(^{
        NSString * name = [ESLocalNetworking getConnectionImageName];
        [self.transferListBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    });
}

- (void)localNetworkUnreachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    ESPerformBlockOnMainThread(^{
        NSString * name = [ESLocalNetworking getConnectionImageName];
        [self.transferListBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];
    ESBoxManager.manager.justLaunch = NO;
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [[ESLocalNetworking shared] addLocalNetworkStatusObserver:self];
    [self setupUI];
    self.bottomView.delegate = self;
    self.selectNum = 0;
    self.selectedTopView.hidden = YES;
    self.tabBarController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileListBottomHidden:) name:@"fileListBottomHidden" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isSelectAll:) name:@"isFileSelectAll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClicAllBtn:) name:@"topToolAllBtnNSNotification" object:nil];
    
    [[[UIApplication sharedApplication].keyWindow viewWithTag:100101] removeFromSuperview];
    
    [[[UIApplication sharedApplication].keyWindow viewWithTag:100103] removeFromSuperview];
    [[[UIApplication sharedApplication].keyWindow viewWithTag:100104] removeFromSuperview];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadMoreData) name:@"switchBoxNSNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    [[ESLoopPollManager Instance] start];
    [ESBoxManager.manager loadCurrentBoxOnlineState:nil];
    [self checkAppUpdateInfo];
}

- (void)checkAppUpdateInfo {
    weakfy(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [ESVersionManager checkAppVersion:^(ESPackageCheckRes *info) {
            if (info.varNewVersionExist.boolValue) {
                NSString * key = @"IsShownAppUpdateForVersionKey";
                NSString * latestVersion = info.latestAppPkg.pkgVersion;
                NSString * savedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                if (latestVersion == nil || latestVersion.length == 0) {
                    return;
                }
                // 一个版本只提示一次
                if (savedVersion && latestVersion && [savedVersion isEqualToString:latestVersion]) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongfy(self);
                    [self showAppUpdateView:info];
                    [[NSUserDefaults standardUserDefaults] setObject:latestVersion forKey:key];
                });
            }
        }];
    });
}

- (void)showAppUpdateView:(ESPackageCheckRes *)info {
    self.appUpdateHintView.hidden = NO;
    ESFormItem *item = [ESFormItem new];
    item.title = TEXT_ME_UPGRADE;
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:TEXT_ME_LATEST_VERSION, info.latestAppPkg.pkgVersion];
    [content appendString:@"\n"];
    [content appendFormat:TEXT_ME_VERSION_DESC, info.latestAppPkg.updateDesc];
    item.content = content;
    [self.appUpdateHintView reloadWithData:item];
    weakfy(self);
    self.appUpdateHintView.actionBlock = ^(id action) {
        strongfy(self);
        self.appUpdateHintView.hidden = YES;
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:info.latestAppPkg.downloadUrl] options:@{} completionHandler:nil];
    };
}

- (ESVersionInfoView *)appUpdateHintView {
    if (!_appUpdateHintView) {
        _appUpdateHintView = [[ESVersionInfoView alloc] initWithFrame:self.view.window.bounds];
        [self.view.window addSubview:_appUpdateHintView];
    }
    return _appUpdateHintView;
}

- (void)didBecomeActive {
    self.shareView.hidden = YES;
    if (self.selectedInfoArray.count > 0) {
        self.bottomView.hidden = NO;
    } else {
        self.bottomView.hidden = YES;
    }
    UIViewController *vc = [self topViewController];
    if ([vc isKindOfClass:[ESFileHomePageVC class]] ||[vc isKindOfClass:[ESMeViewController class]]){
        if (self.bottomView.hidden == YES && [self.category isEqual:@"home"]&& self.tabBarController.tabBar.hidden && self.navigationController.viewControllers.count == 1) {
            self.tabBarController.tabBar.hidden = NO;
        }
    }else{
        self.tabBarController.tabBar.hidden = YES;
    }
}

#pragma 初期化UI
- (void)setupUI {
    self.hideNavigationBar = YES;
    self.searchBar.hidden = NO;
    
    [self.transferListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 5);
        make.left.mas_equalTo(self.searchBar.mas_right).offset(15.0f);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];
    
    
    [self.transferRotateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 5);
        make.left.mas_equalTo(self.searchBar.mas_right).offset(15.0f);
        make.height.mas_equalTo(44.0f);
        make.width.mas_equalTo(44.0f);
    }];
    
    
    self.transferListNumView.hidden = YES;
    [self.transferListNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 13);
        make.left.mas_equalTo(self.transferListBtn.mas_right).offset(-16.0f);
        make.height.mas_equalTo(13.0f);
        make.width.mas_greaterThanOrEqualTo(13.0f);
    }];
    
    if([self.category isEqual:@"home"]){
        [self.recycleBinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 5);
            make.right.mas_equalTo(self.view.mas_right).offset(-14.0f);
            make.height.mas_equalTo(44.0f);
            make.width.mas_equalTo(44.0f);
        }];
    }else{
        [self.recycleBinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 5);
            make.right.mas_equalTo(self.view.mas_right).offset(-14.0f);
            make.height.mas_equalTo(44.0f);
            make.width.mas_equalTo(44.0f);
        }];
    }

    if ([self.category isEqual:@"Search"] || [self.category isEqual:@"Folder"] || [self.category isEqual:@"recycleBinVC"] || [self.category isEqual:@"shareVC"]|| [self.category isEqual:@"v2FileVC"]) {
        return;
    }
    [self fileMianUI];
    [self pageTitleView];
}

- (void)fileMianUI {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFolderClick:) name:@"didEnterFolderClick" object:nil];
    self.view.backgroundColor = [ESColor secondarySystemBackgroundColor];
    self.pageContentView.hidden = NO;

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(22.0f);
        make.right.mas_equalTo(self.view).offset(-127.0f);
        make.height.mas_equalTo(46.0f);
        make.top.mas_equalTo(self.view).offset(kStatusBarHeight + 4.0f);
    }];
    
    [self.pageTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchBar.mas_bottom).offset(5);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(56);
    }];

    [self.pageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pageTitleView.mas_bottom).offset(5);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
    }];

    [self.pageContentView.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pageContentView.mas_top).offset(0);
        make.left.mas_equalTo(self.pageContentView.mas_left).offset(0);
        make.right.mas_equalTo(self.pageContentView.mas_right).offset(0);
        make.bottom.mas_equalTo(self.pageContentView.mas_bottom).offset(0);
    }];
}

- (void)shareFile:(NSURL *)localPath {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[localPath] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)shareLink:(NSString *)shareLinkStr {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[shareLinkStr] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -ESFileBottomView delegate method

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDownBtn:(UIButton *)button {

    [ESToast toastSuccess:TEXT_ADDED_TO_TRANSFER_LIST];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject error:&error];
    if (dictionary) {
        NSNumber *free = dictionary[NSFileSystemFreeSize];
        long long int size = 0;
        for(int i = 0; i < self.selectedInfoArray.count; i++){
            ESFileInfoPub *info = self.selectedInfoArray[i];
            size = size + info.size.unsignedLongLongValue;
        }
        if(free.unsignedLongLongValue < size*2){
            [ESToast toastError:@"手机空间不足"];
            return;
        }
    }
    

    [self.selectedInfoArray enumerateObjectsUsingBlock:^(ESFileInfoPub *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.isDir.boolValue) {
            return;
        }
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                        apiName:@"history_record_add"                                  queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                         header:@{}
                                                           body:@{@"phoneType" : @"ios",
                                                                  @"uuid" : obj.uuid,
                                                                  @"fileName" : obj.name,
                                                                  @"category" :obj.category,
                                                                  @"opType" : @(1),
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
              NSLog(@"%@",response);
          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@",response);
         }];
        
        [ESTransferManager.manager download:obj
                                   callback:^(NSURL *output, NSError *error){

                                   }];
    }];

    [self cancelAction];
}

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didTransferListClickButton:(UIButton *)button {
}

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickShareBtn:(UIButton *)button {
    ESFileInfoPub *file = self.selectedInfoArray.firstObject;
    if (!file) {
        return;
    }
    NSString *path = [file getOriginalFileSavePath];
    if (LocalFileExist(file)) {
        [self shareFile:[NSURL fileURLWithPath:path]];
        return;
    }
    ESFileShowLoading(self, file, NO, ^{
        NSString *path = [file getOriginalFileSavePath];
        [self shareFile:[NSURL fileURLWithPath:path]];
    });
}

/// 点击删除
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDelectBtn:(UIButton *)button {
    self.delectView.hidden = NO;
}



- (void)otherShareLinkBtnTap:(NSString *)linkStr{
    [self shareLink:linkStr];
     [self cancelAction];
}

/// 点击查看更多
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickMoreBtn:(UIButton *)button {
    self.moreView.hidden = NO;
    self.moreView.reNameView.hidden = YES;
    if (self.selectedInfoArray.count > 0) {
        self.moreView.fileInfo = self.selectedInfoArray[0];
    }

    if (self.isSelectUUIDSArray.count > 0) {
        self.moreView.isSelectUUIDSArray = self.isSelectUUIDSArray;
    }
    //  self.bottomView.hidden = YES;
}

/// 点击重命名
- (void)fileBottomToolMoreView:(ESBottomMoreView *_Nullable)fileBottomToolMoreView didClickReNameCompleteInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName category:(NSString *_Nullable)category {
    [self reNameInfo:info fileName:fileName];
}

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickReNameCompleteInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName category:(NSString *)category {
    [self reNameInfo:info fileName:fileName];
}

- (void)reNameInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName {
    if ([info.name isEqual:fileName]) {

        [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
        self.bottomView.hidden = NO;
        return;
    }

    NSArray *array = [info.name componentsSeparatedByString:@"."];
    if (array.count > 1) {
        fileName = [NSString stringWithFormat:@"%@.%@", fileName, array[1]];
    }

    ESFileApi *api = [[ESFileApi alloc] init];
    self.bottomView.hidden = YES;
    self.moreView.hidden = YES;
    if (info.uuid.length > 0 && fileName.length > 0) {
        ESModifyFileReq *req = [ESModifyFileReq new];
        req.fileName = fileName;
        req.uuid = info.uuid;
        [api spaceV1ApiFileRenamePostWithModifyFileReq:req
                                     completionHandler:^(ESRspDbAffect *output, NSError *error) {
    
                                         if (!error) {
                                             if (output.code.intValue == 1013) {
                                                 [ESToast toastError:NSLocalizedString(@"A file with the same name already exists", @"当前目录已存在同名称文件")];
                                                 [self cancelAction];
                                                 self.bottomView.hidden = NO;
                                                 self.moreView.hidden = YES;
                                                 return;
                                             }
                                             if (![self.category isEqual:@"Search"]) {
                                                 [self loadMoreData];
                                             }
                                             [ESToast toastSuccess:NSLocalizedString(@"Modified successfully", @"修改成功")];
                                             return;
                                         } else {
                                              [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                             self.bottomView.hidden = NO;
                                         }
                                     }];
    }
}
/// 点击详情
- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDetailsBtn:(UIButton *)button {
    if (self.selectedInfoArray.count > 0) {
        self.detailView.fileInfo = self.selectedInfoArray[0];
    }
    self.detailView.hidden = NO;
    self.bottomView.hidden = YES;
}
/// 点击查看
- (void)fileBottomToolMoreView:(ESBottomMoreView *_Nullable)fileBottomToolMoreView didClickDelectBtn:(UIButton *)button {
    self.moreView.hidden = YES;
    self.bottomView.hidden = NO;
}

- (void)fileBottomToolMoreView:(ESBottomMoreView *_Nullable)fileBottomToolMoreView didClickCompleteBtn:(UIButton *_Nullable)button {
    self.delectView.hidden = YES;
}

/// 点击取消底部view
- (void)fileBottomDetailView:(ESBottomDetailView *_Nullable)fileBottomDetailView didClickDelectBtn:(UIButton *)button {
    self.detailView.hidden = YES;
    self.bottomView.hidden = NO;
}

#pragma mark -delectView view's delegate method
- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCancelBtn:(UIButton *_Nullable)button {
    self.delectView.hidden = YES;
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button {
    if([self.category isEqual:@"home"]&& self.tabBarController.tabBar.hidden && self.navigationController.viewControllers.count == 1){
        self.tabBarController.tabBar.hidden = NO;
    }

    NSArray *uuids = [self.isSelectUUIDSArray yc_mapWithBlock:^id(NSUInteger idx, NSString *uuid) {
        return uuid;
    }];
    
    [self.view showLoading:YES message:NSLocalizedString(@"delete_loading_message", @"正在删除")];
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"delete_file"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{@"uuids" : uuids ?: @""}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self.view showLoading:NO];
        [self deleteSuccess];
       
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        strongfy(self)
      
        [self.view showLoading:NO];
        //show 异步删除进度条
        if ([error.userInfo[@"code"] intValue] == 201) {
            NSDictionary *results = error.userInfo[ESNetworkErrorUserInfoResposeResultKey];
            if ([results[@"results"] isKindOfClass:[NSDictionary class]] && results[@"results"][@"taskId"] != nil) {
                NSString *taskId = results[@"results"][@"taskId"];
                ESCommonProcessStatusVC *processVC = [[ESCommonProcessStatusVC alloc] init];
                processVC.taskId = taskId;
                processVC.customProcessTitle = NSLocalizedString(@"delete_loading_message", @"正在删除");

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

    self.delectView.hidden = YES;
    self.bottomView.hidden = YES;
}

- (void)deleteSuccess {
    [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
    self.delectView.hidden = YES;
    if (![self.category isEqual:@"Search"]) {
        [self loadMoreData];
    }
}

- (void)deleteFail {
     [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
}

#pragma mark -title view's delegate method

- (void)pageTitletView:(id)contentView selectedIndex:(NSInteger)targetIndex {
    [self.pageContentView setCurrentIndex:targetIndex];
}

#pragma mark -content view's delegate
/// 滑动代理
- (void)pageContentView:(id)contentView progress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setTitleWithProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
    if(self.targetIndex == targetIndex){
        return;
    }
    [self cancelAction];
    if([self isConnectionAvailable]){
        [self.categoryVC addRefresh];
        
        [self loadMoreData];
    }
    self.targetIndex = targetIndex;
}

- (void)cancelAction {
    if (self.fileVC.enterFileUUIDArray.count > 0 && ![self.category isEqual:@"Search"]) {
        ESFileInfoPub *info = self.fileVC.enterFileUUIDArray[self.fileVC.enterFileUUIDArray.count - 1];
        [self.categoryVC headerRefreshWithUUID:info.uuid];
        self.searchBar.hidden = YES;
        [self.fileVC cancelSelected];
    } else {
        if ([self.category isEqual:@"Search"] && [self.category isEqual:@"Folder"]) {
            self.pageTitleView.hidden = YES;
            self.view.backgroundColor = ESColor.systemBackgroundColor;
            self.searchBar.hidden = YES;
        } else {
            self.view.backgroundColor = [ESColor secondarySystemBackgroundColor];
            self.pageTitleView.hidden = NO;
            self.searchBar.hidden = NO;
            [self.categoryVC cancelSelected];
        }
        self.selectNum = 0;
    }

    // self.isSelectUUIDSArray = [NSMutableArray new];
    self.bottomView.hidden = YES;
    self.moreView.hidden = YES;
    self.selectedTopView.hidden = YES;
}

- (void)totalAllSlelectedAction {
    if ([self.topViewselelctBtn.titleLabel.text isEqual:NSLocalizedString(@"select_all", @"全选")]) {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
        [self.categoryVC selectAll:YES];
    } else {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];
        [self.categoryVC selectAll:NO];
        self.bottomView.hidden = YES;
    }
}

- (void)totalNoSlelectedAction {
    self.selectNum = 0;
    [self.fileVC cancelSelected];
}

/// 进入文件夹
- (void)didEnterFolderClick:(NSNotification *)notifi {
    NSDictionary *dic = notifi.object;
    ESFileInfoPub *fileInfo = dic[@"fileInfo"];
    BOOL isMoveCopy = [dic[@"isMoveCopy"] boolValue];
    self.selectedFile = fileInfo;
    self.isEnterFile = [fileInfo.isDir boolValue];
    if (isMoveCopy) {
        self.isEnterFile = NO;
    } else {
        NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path"];
        path = [NSString stringWithFormat:@"%@/%@", path, fileInfo.name];
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"select_up_path"];
        [[NSUserDefaults standardUserDefaults] setObject:fileInfo.uuid forKey:@"select_up_path_uuid"];
    }

    if ([fileInfo.isDir boolValue] && !isMoveCopy) {
        ESFolderList *listVC = [ESFolderList new];
        listVC.hidesBottomBarWhenPushed = NO;
        listVC.isSourceSearch = NO;
        listVC.fileInfo = fileInfo;
        [self.navigationController pushViewController:listVC animated:YES];
    }
}

/// 传输列表
- (void)didClickTransferListBtn:(UIButton *)transferListBtn {
    ESTransferListViewController *next = [ESTransferListViewController new];
    [self.navigationController pushViewController:next animated:YES];
}

/// 方法
- (void)didClickRecycleBinBtn:(UIButton *)transferListBtn {
    ESRecycledPhyDeleteReq *uuids = [ESRecycledPhyDeleteReq new];
    uuids.uuids = @[];
    [[ESRecycledApi new] spaceV1ApiRecycledClearPostWithUuids:uuids
                                            completionHandler:^(ESRsp *output, NSError *error){
                                            }];
}

/// 是否有文件被选中
- (void)fileListBottomHidden:(NSNotification *)notifi {
    
    NSDictionary *dic = notifi.object;
    self.isSelectUUIDSArray = dic[@"isSelectUUIDSArray"];
    self.selectedInfoArray = dic[@"selectedInfoArray"];
    self.selectLable.text = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), (unsigned long)self.isSelectUUIDSArray.count];
    if (self.categoryVC.children.count == 1 && self.isSelectUUIDSArray.count == 1) {
        [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
    }
    BOOL isHaveDir = NO;
    for (ESFileInfoPub *fileInfo in self.selectedInfoArray) {
        if (fileInfo.isDir.boolValue) {
            isHaveDir = YES;
        }
    }
    
    if (self.isSelectUUIDSArray.count > 0) {
    
        [self isSelected];
        if (self.selectedInfoArray.count == 1) {
            self.bottomView.fileInfo = self.selectedInfoArray[0];
            self.bottomView.isMoreSelect = NO;
        }
        if (self.isSelectUUIDSArray.count > 1) {
            self.bottomView.isMoreSelect = YES;
            self.bottomView.isHaveDir = isHaveDir;
        } else {
            self.bottomView.isMoreSelect = NO;
        }
        if (self.isSelectUUIDSArray.count != self.categoryVC.children.count) {
            [self.topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];
        }else{
            [self.topViewselelctBtn setTitle:NSLocalizedString(@"unselect_all", @"全不选") forState:UIControlStateNormal];
        }
    } else {
        if ([self.category isEqual:@"home"]) {
            [self noSelected];
        }
    }
}

- (void)isSelectAll:(NSNotification *)notifi {
    NSDictionary *dic = notifi.object;
    self.isSelectUUIDSArray = dic[@"isSelectUUIDSArray"];
    self.selectLable.text = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), (unsigned long)self.isSelectUUIDSArray.count];
}
- (void)isSelected {
    [self.categoryVC.listView.tableView.mj_header endRefreshing];
    [self.categoryVC.listView.tableView.mj_header removeFromSuperview];
    self.pageContentView.collectionView.scrollEnabled = NO;
    self.searchBar.hidden = YES;
    self.selectedTopView.hidden = NO;
    self.bottomView.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.bottomView.isSelectUUIDSArray = self.isSelectUUIDSArray;
    CGFloat height = 50 + kBottomHeight;
    self.bottomView.frame = CGRectMake(0, ScreenHeight - height- 20, ScreenWidth, height + 20);
}

- (void)noSelected {
    [self.categoryVC addRefresh];
    self.pageContentView.collectionView.scrollEnabled = YES;
    self.selectedTopView.hidden = YES;
    self.bottomView.hidden = YES;
    self.searchBar.hidden = NO;
    if ([self.category isEqualToString: @"home"] && self.navigationController.viewControllers.count == 1)  {
        self.tabBarController.tabBar.hidden = NO;
    }
}


#pragma mark - Lazy Load

- (UIButton *)transferListBtn {
    if (nil == _transferListBtn) {
        _transferListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transferListBtn addTarget:self action:@selector(didClickTransferListBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_transferListBtn];
    }
    return _transferListBtn;
}

- (UIImageView *)transferRotateImage {
    if (nil == _transferRotateImage) {
        _transferRotateImage = [UIImageView new];
        _transferRotateImage.hidden = YES;
        _transferRotateImage.animationDuration=1;
        [self.view addSubview:_transferRotateImage];
    }
    return _transferRotateImage;
}

- (UIButton *)recycleBinBtn {
    if (nil == _recycleBinBtn) {
        _recycleBinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recycleBinBtn addTarget:self action:@selector(didClickRecycleBinBtn) forControlEvents:UIControlEventTouchUpInside];
        [_recycleBinBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [self.view addSubview:_recycleBinBtn];
    }
    return _recycleBinBtn;
}

- (void)didClickRecycleBinBtn {
    self.sortView.hidden = NO;
}

- (ESFileBottomView *)bottomView {
    if (nil == _bottomView && (![self.category isEqual:@"Folder"] && ![self.category isEqual:@"recycleBinVC"] && ![self.category isEqual:@"shareVC"] && ![self.category isEqual:@"v2FileVC"])) {
        _bottomView = [[ESFileBottomView alloc] init];

    }
    return _bottomView;
}

- (UIView *)selectedTopView {
    if (nil == _selectedTopView) {
        _selectedTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kStatusBarHeight + kTitleViewH)];
        _selectedTopView.backgroundColor = ESColor.systemBackgroundColor;

        UIButton *cancelBtn;
        if([ESCommonToolManager isEnglish]){
          cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 25 - 10, 60, 25)];
        }else{
          cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 25 - 10, 40, 25)];
        }
    
        [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [cancelBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [cancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectedTopView addSubview:cancelBtn];

        UILabel *selectLable = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 200, kStatusBarHeight + kTitleViewH - 25 - 10, 400, 25)];
        selectLable.textAlignment = NSTextAlignmentCenter;

        self.selectLable = selectLable;
        [_selectedTopView addSubview:selectLable];

        UIButton *topViewselelctBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 40 - kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 25 - 10, 60, 25)];
        
        if([ESCommonToolManager isEnglish]){
            topViewselelctBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 40 - kESViewDefaultMargin - 40, kStatusBarHeight + kTitleViewH - 25 - 10, 100, 25)];
          }else{
              topViewselelctBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 40 - kESViewDefaultMargin, kStatusBarHeight + kTitleViewH - 25 - 10, 60, 25)];
          }
         

        [topViewselelctBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [topViewselelctBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [topViewselelctBtn setTitle:NSLocalizedString(@"select_all", @"全选") forState:UIControlStateNormal];
        [topViewselelctBtn addTarget:self action:@selector(totalAllSlelectedAction) forControlEvents:UIControlEventTouchUpInside];
        self.topViewselelctBtn = topViewselelctBtn;
        [_selectedTopView addSubview:topViewselelctBtn];

        [self.view addSubview:_selectedTopView];
        [self.view bringSubviewToFront:_selectedTopView];
    }
    return _selectedTopView;
}

- (ESBottomMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[ESBottomMoreView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _moreView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _moreView.delegate = self;
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
        [_moreView addGestureRecognizer:delectActionTapGesture];
        _moreView.userInteractionEnabled = YES;
        [self.view.window addSubview:_moreView];
    }
    return _moreView;
}

- (ESBottomDetailView *)detailView {
    if (!_detailView) {
        _detailView = [[ESBottomDetailView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _detailView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _detailView.delegate = self;
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
        [_detailView addGestureRecognizer:delectActionTapGesture];
        _detailView.userInteractionEnabled = YES;
        [self.view.window addSubview:_detailView];
    }
    return _detailView;
}

- (ESFileDelectView *)delectView {
    if (!_delectView) {
        _delectView = [[ESFileDelectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _delectView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _delectView.delegate = self;
        [self.view.window addSubview:_delectView];
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
        [_delectView addGestureRecognizer:delectActionTapGesture];
      _delectView.userInteractionEnabled = YES;
    }
    return _delectView;
}
// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)delectTapGestureAction:(UITapGestureRecognizer *)tap {
    self.delectView.hidden = YES;
    self.detailView.hidden = YES;
    self.moreView.hidden = YES;
    self.bottomView.hidden = NO;
}

- (ESFilePageTitleView *)pageTitleView {
    CGRect frame = CGRectMake(0, kStatusBarHeight, ScreenWidth, kTitleViewH);
    NSArray *titles = @[TEXT_HOME_ALL, TEXT_HOME_PHOTO, TEXT_HOME_VIDEO, TEXT_HOME_DOS, TEXT_HOME_OTHER];
    if (!_pageTitleView) {
        __weak typeof(self) weakSelf = self;
        _pageTitleView = [ESFilePageTitleView initWithFrame:frame titles:titles];
        _pageTitleView.delegate = weakSelf;
        [self.view addSubview:_pageTitleView];
    }
    return _pageTitleView;
}

- (ESFilePageContentView *)pageContentView {
    if (!_pageContentView) {
        NSMutableArray *childVcs = [NSMutableArray array];

        _pageContentView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        self.fileVC = [[ESFileTotalVC alloc] init];
        self.photoVC = [[ESFilePhotoVC alloc] init];
        self.videoVC = [[ESFileVideoVC alloc] init];
        self.documentVC = [[ESFIleDocumentVC alloc] init];
        self.otherVC = [[ESFileOtherVC alloc] init];

        self.fileVC.delegate = self;
        self.photoVC.delegate = self;
        self.videoVC.delegate = self;
        self.documentVC.delegate = self;
        self.otherVC.delegate = self;

        [childVcs addObject:self.fileVC];
        [childVcs addObject:self.photoVC];
        [childVcs addObject:self.videoVC];
        [childVcs addObject:self.documentVC];
        [childVcs addObject:self.otherVC];

        self.fileVC.view.layer.masksToBounds = YES;
        self.fileVC.view.layer.cornerRadius = 10;

        __weak typeof(self) weakSelf = self;
        _pageContentView = [ESFilePageContentView initWithFrame:CGRectMake(0, 169, ScreenWidth, ScreenHeight - kTopHeight - kTitleViewH - kBottomHeight - self.tabBarHeight + 15) ChildViewControllers:childVcs parentViewController:self];
        _pageContentView.delegate = weakSelf;
        [self.view addSubview:self.pageContentView];
    }
    return _pageContentView;
}

- (void)loadMoreData {
    if (self.targetIndex == 0) {
        if (self.fileVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.fileVC.enterFileUUIDArray[self.fileVC.enterFileUUIDArray.count - 1];
            [self.fileVC headerRefreshWithUUID:info.uuid];
        } else {
            [self.fileVC headerRefreshWithUUID:nil];
        }   
        self.fileVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        self.categoryVC = self.fileVC;
        self.isMoveCopy = self.fileVC.listView.isCopyMove;
    } else if (self.targetIndex == 1) {
        if (self.photoVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.photoVC.enterFileUUIDArray[self.photoVC.enterFileUUIDArray.count - 1];
            [self.photoVC headerRefreshWithUUID:info.uuid];
        } else {
            [self.photoVC headerRefreshWithUUID:nil];
        }
        self.photoVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        self.categoryVC = self.photoVC;
    } else if (self.targetIndex == 2) {
        if (self.videoVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.videoVC.enterFileUUIDArray[self.videoVC.enterFileUUIDArray.count - 1];
            [self.videoVC headerRefreshWithUUID:info.uuid];
        } else {
            [self.videoVC headerRefreshWithUUID:nil];
        }
        self.videoVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        self.categoryVC = self.videoVC;
    } else if (self.targetIndex == 3) {
        if (self.documentVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.documentVC.enterFileUUIDArray[self.documentVC.enterFileUUIDArray.count - 1];
            [self.documentVC headerRefreshWithUUID:info.uuid];
        } else {
            [self.documentVC headerRefreshWithUUID:nil];
        }
        self.documentVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        self.categoryVC = self.documentVC;
    } else if (self.targetIndex == 4) {
        if (self.otherVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.documentVC.enterFileUUIDArray[self.documentVC.enterFileUUIDArray.count - 1];
            [self.otherVC headerRefreshWithUUID:info.uuid];
        } else {
            [self.otherVC headerRefreshWithUUID:nil];
        }
        self.otherVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        self.categoryVC = self.otherVC;
    }
}

- (void)fileBottomToolMoreView:(ESBottomMoreView *_Nullable)fileBottomToolMoreView didClickCopyCompleteWithPathName:(NSString *_Nullable)pathName selectUUID:(NSString *_Nullable)uuid category:(NSString *_Nullable)category {
    [self copyMoveApiWithPathName:pathName selectUUID:uuid category:category];
}

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickCopyCompleteWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category {
    [self copyMoveApiWithPathName:pathName selectUUID:uuid category:category];
}

- (void)copyMoveApiWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category {
    self.moreView.hidden = YES;
    self.moreView.movecopyView.hidden = YES;
    self.bottomView.movecopyView.hidden = YES;
    ESFileApi *api = [[ESFileApi alloc] init];

    if ([category isEqual:@"copy"]) {
        if ([pathName isEqual:@"/"] && ([uuid isEqual:@"/"] || [uuid isEqual:@""] || uuid.length < 1)) {
            [ESToast toastError:NSLocalizedString(@"Move Fail", @"移动失败")];
        }

        if (self.categoryVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.categoryVC.enterFileUUIDArray[self.categoryVC.enterFileUUIDArray.count - 1];
            if ([uuid isEqual:info.uuid]) {
                [ESToast toastError:NSLocalizedString(@"Move Fail", @"移动失败")];
            }
        }
        ESCopyFileReq *req = [[ESCopyFileReq alloc] init];
        req.dstPath = uuid;
        req.uuids = self.isSelectUUIDSArray;

        [api spaceV1ApiFileCopyPostWithVarCopyFilesReq:req
                                     completionHandler:^(ESRspCopyRsp *output, NSError *error) {
                                         if (!error) {
                                             if (output.code.intValue == 1022) {
                                                 [ESToast toastError:NSLocalizedString(@"Copy Fail", @"复制失败")];
                                             }
                                             [ESToast toastSuccess:NSLocalizedString(@"Copy Success", @"复制成功")];
                                         } else {
                                              [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                         }
                                         if (![self.category isEqual:@"Search"]) {
                                             [self loadMoreData];
                                             [self noSelected];
                                         }
                                     }];
    }
    if ([category isEqual:@"move"]) {
        if ([pathName isEqual:@"/"] && ([uuid isEqual:@"/"] || [uuid isEqual:@""] || uuid.length < 1)) {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }

        if (self.categoryVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.categoryVC.enterFileUUIDArray[self.categoryVC.enterFileUUIDArray.count - 1];
            if ([uuid isEqual:info.uuid]) {
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }
        ESMoveFileReq *req = [[ESMoveFileReq alloc] init];
        if (uuid.length > 0) {
            req.destPath = uuid;
        } else {
            req.destPath = @"";
        }
        req.uuids = self.isSelectUUIDSArray;
        [api spaceV1ApiFileMovePostWithMoveFilesReq:req
                                  completionHandler:^(ESRspDbAffect *output, NSError *error) {
                                      if (!error) {
                                          if (output.code.intValue == 1022) {
                                               [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                          }
                                          [ESToast toastSuccess:NSLocalizedString(@"Move Successful", @"移动成功")];
                                          if (![self.category isEqual:@"Search"]) {
                                              [self cancelAction];
                                              [self loadMoreData];
                                          }
                                          return;
                                      } else {
                                           [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                      }
                                  }];
    }
}

- (void)hiddenView {
    self.bottomView.hidden = YES;
}

- (ESSearchBarView *)searchBar {
    if (!_searchBar) {
        _searchBar = [[ESSearchBarView alloc] init];
//        _searchBar.layer.masksToBounds = YES;
//        _searchBar.layer.cornerRadius = 10;
//        UIImageView *fineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 14, 18, 18)];
//        fineImageView.image = IMAGE_MAIN_SEARCH;
//        _searchBar.backgroundColor = [ESColor systemBackgroundColor];
//        [_searchBar addSubview:fineImageView];
//        UILabel *pointOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 13, 100, 20)];
//        pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//        pointOutLabel.textColor = ESColor.placeholderTextColor;
//        pointOutLabel.text = TEXT_FILE_SEARCH_ALL;
//        [_searchBar addSubview:pointOutLabel];
        _searchBar = [[ESSearchBarView alloc] initWithSearchDelegate:self];
        _searchBar.searchInput.userInteractionEnabled = NO;
        _searchBar.placeholderName = TEXT_FILE_SEARCH_ALL;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarTap:)];
        [_searchBar addGestureRecognizer:tapGesture];
        [self.view addSubview:self.searchBar];

        //        _searchBar = [[ESSearchBarView alloc] init];

    }
    return _searchBar;
}

- (UIView *)transferListNumView {
    if (!_transferListNumView) {
        _transferListNumView = [[UIView alloc] init];
        _transferListNumView.backgroundColor = ESColor.redColor;
        _transferListNumView.layer.masksToBounds = YES;
        _transferListNumView.layer.cornerRadius = 6.5;
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.textColor = ESColor.lightTextColor;
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLable = numLabel;
        [_transferListNumView addSubview:numLabel];
        [self.view addSubview:_transferListNumView];
        
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_transferListNumView);
            make.height.mas_equalTo(13);
            make.width.mas_equalTo(_transferListNumView);
        }];
    }
    return _transferListNumView;
}

- (void)searchBarTap:(UITapGestureRecognizer *)tag {
    ESSearchListVC *vc = [[ESSearchListVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (ESFileListBaseVC *)categoryVC {
    if (self.targetIndex == 0) {
        _categoryVC = self.fileVC;
        self.isMoveCopy = self.fileVC.listView.isCopyMove;
    } else if (self.targetIndex == 1) {
        self.photoVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        _categoryVC = self.photoVC;
    } else if (self.targetIndex == 2) {
        self.videoVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        _categoryVC = self.videoVC;
    } else if (self.targetIndex == 3) {
        self.documentVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        _categoryVC = self.documentVC;
    } else if (self.targetIndex == 4) {
        self.otherVC.listView.isSelectUUIDSArray = [NSMutableArray new];
        _categoryVC = self.otherVC;
    }
    return _categoryVC;
}

- (ESFileSortView *)sortView {
    if (!_sortView) {
        _sortView = [[ESFileSortView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _sortView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _sortView.delegate = self;
        weakfy(self);
        _sortView.actionBlock = ^(id action) {
            strongfy(self);
            self.searchBar.hidden = YES;
            self.selectedTopView.hidden = NO;
//            self.bottomView.hidden = NO;
//            self.tabBarController.tabBar.hidden = YES;
          //  [self isSelected];
        };
        [self.view.window addSubview:_sortView];
    }
    return _sortView;
}

- (void)fileSortView:(ESFileSortView *_Nullable)fileSortView didClicCancelBtn:(UIButton *_Nullable)button {
    self.sortView.hidden = YES;
}

- (void)fileSortView:(ESFileSortView *_Nullable)fileSortView didSortType:(ESSortClass)type isUpSort:(BOOL)isUpSort {
    if (type == ESSortClassName) {
        if (isUpSort) {
            self.categoryVC.sortType = @"is_dir desc,name asc";
        } else {
            self.categoryVC.sortType = @"is_dir desc,name desc";
        }
    } else if (type == ESSortClassTime) {
        if (isUpSort) {
            self.categoryVC.sortType = @"is_dir desc,operation_time asc";
        } else {
            self.categoryVC.sortType = @"is_dir desc,operation_time desc";
        }
    } else if (type == ESSortClassType) {
        if (isUpSort) {
            self.categoryVC.sortType = @"mime asc";
        } else {
            self.categoryVC.sortType = @"mime desc";
        }
    }

    [self loadMoreData];
    self.sortView.hidden = YES;
}

- (UIWindow *)lastWindow {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (void)didClicAllBtn:(NSNotification *)notifi {
    ESFileInfoPub *fileInfo = notifi.object;
    ESFolderList *listVC = [ESFolderList new];
    listVC.hidesBottomBarWhenPushed = NO;
    listVC.isSourceSearch = NO;
    listVC.fileInfo = fileInfo;
    [self.navigationController pushViewController:listVC animated:YES];
}

- (void)fileListBaseVCReloadData {
    [self.topViewselelctBtn setTitle:TEXT_COMMON_SELECT_ALL forState:UIControlStateNormal];
}

-(void)noNetWorking:(NSNotification *)notifi{
    NSNumber *obj = [notifi object];
    self.isNotWorking =obj;
}

-(BOOL)isConnectionAvailable{
 
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"ao."];
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

//旋转动画
- (void)startAnimation  {
CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 1;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [self.transferRotateImage.layer addAnimation:animation forKey:nil];
}

- (void)shareView:(ESShareView *)shareView didClicCancelBtn:(UIButton *)button{
    self.bottomView.hidden = NO;
}

- (UIViewController *)topViewController{
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] || [vc isKindOfClass:[UITabBarController class]] ) {
        if ( [vc isKindOfClass:[UINavigationController class]] ) vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] ) vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController ) vc = vc.presentedViewController;
    }
    return vc;
}

- (BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController*)viewController {
    if([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)viewController;
        if([nav.viewControllers count] > 1 && tabBarController.selectedViewController == viewController) {
                return NO;
        }
    }
    return YES;
}

- (void)shareViewShareOther:(ESShareView *)shareView{
    ESFileInfoPub *file = self.selectedInfoArray.firstObject;
    if (!file) {
        return;
    }
    NSString *path =[file getOriginalFileSavePath];
    if (LocalFileExist(file)) {
        [self shareFile:[NSURL fileURLWithPath:path]];
        return;
    }
    ESFileShowLoading(self, file, NO, ^{
        [file getOriginalFileSavePath];
        [self shareFile:[NSURL fileURLWithPath:path]];
    });
}

@end
