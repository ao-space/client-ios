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
//  ESFilePreviewViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFilePreviewViewController.h"
#import "ESBottomDetailView.h"
#import "ESBottomMoreView.h"
#import "ESCircleProgress.h"
#import "ESCommentToolVC.h"
#import "ESFileDefine.h"
#import "ESFileLoadingViewController.h"
#import "ESFormItem.h"
#import "ESLocalPath.h"
#import "ESToast.h"
#import "ESPreviewItem.h"
#import "ESPreviewUnsupportFileView.h"
#import "ESThemeDefine.h"
#import "ESTransferManager.h"
#import "ESCommentCachePlistData.h"
#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>
#import "ESCacheInfoDBManager.h"


@interface ESFilePreviewViewController () <QLPreviewControllerDataSource,
                                           QLPreviewControllerDelegate,
                                           ESBottomMoreViewDelegate,
                                           ESFileBottomViewDelegate,
                                           ESBottomDetailViewDelegate,
                                           ESCommentToolDelegate>

@property (nonatomic, strong) QLPreviewController *previewController;

@property (nonatomic, strong) ESPreviewItem *item;

@property (nonatomic, strong) ESCommentToolVC *bottomTool;

@property (nonatomic, strong) UIButton *downloadOrigin;

@property (nonatomic, copy) ESFileInfoPub *file;

@property (nonatomic, copy) NSURL *localPath;

@property (nonatomic, strong) ESCircleProgress *circleProgress;

@property (nonatomic, strong) ESFileLoadingViewController *loadingController;

@property (nonatomic, strong) ESPreviewUnsupportFileView *unsupportFileView;
@property (nonatomic, weak) ESTransferTask * downloadTask;
@end

NSString *const ESComeFromSmartPhotoPageTag = @"ESComeFromSmartPhotoPageTag";


@implementation ESFilePreviewViewController

- (void)reloadFileInfo {
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSArray *fileNameArray = [self.file.name componentsSeparatedByString:@"."];
//    NSString *localPathString;
//    if (fileNameArray.count > 0) {
//        NSString *urlStr = fileNameArray[0];
//        localPathString = [NSString stringWithFormat:@"%@/%@/%@",cachesPath,urlStr,self.file.name];
//    }
    NSURL *localPath;
    NSString *localPathString = [self.file getOriginalFileSavePath];
    localPath = [NSURL fileURLWithPath:localPathString];
    
    if (!self.localPath) {
        self.localPath = localPath;
    }
    self.item = [ESPreviewItem itemWithFile:self.file urlStr:self.localPath];
    self.navigationItem.title = self.item.previewItemTitle;
    [self.previewController reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]||[obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            obj.backgroundColor = ESColor.systemBackgroundColor;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UnsupportFileForPreview(self.file)) {
        self.unsupportFileView.hidden = NO;
        ESFormItem *item = [ESFormItem new];
        item.title = self.file.name;
        item.content = FileSizeString(self.file.size.unsignedLongLongValue, YES);
        item.icon = IconForFile(self.file);
        [self.unsupportFileView reloadWithData:item];
        return;
    }
    [self.previewController didMoveToParentViewController:self];
    [self reloadFileInfo];
    //图片, 并且不是原图
    if (IsImageForFile(self.file)) {
        //图片预览    file.previewPic
        ///不是原图,显示下载按钮
        if (!self.item.origin) {
            self.downloadOrigin.hidden = NO;
            NSString *text = [NSString stringWithFormat:TEXT_FILE_ORIGIN_IMAGE, FileSizeString(self.file.size.unsignedLongLongValue, YES)];
            [self.downloadOrigin setTitle:text forState:UIControlStateNormal];
            CGFloat width = [text es_widthWithFont:[UIFont systemFontOfSize:10]];
            [self.downloadOrigin mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(width + 30);
            }];
            ///压缩图不存在, 自动下载压缩图
            if (!CompressedImageExist(self.file)) {
                [self loadCompressedImage];
            }
        }
    } else {
        //文件预览    file.previewDocument
        if (!LocalFileExist(self.file)) {
            [self.loadingController didMoveToParentViewController:self];
            return;
        }else{
            [self reloadFileInfo];
        }
    }
    if(!self.isHaveBottom){
        [self.bottomTool showSelectArray:[NSMutableArray arrayWithObject:self.file]];
    }
    
    // Do any additional setup after loading the view.
}

- (void)loadCompressedImage {
    weakfy(self);
    self.circleProgress.hidden = NO;
    // 已无发送该通知的行为
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPross:) name:@"uploadProssNotification" object:nil];
    [ESTransferManager.manager preview:self.file
                              progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
    }
                              callback:^(NSURL *output, NSError *error) {
        strongfy(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.circleProgress.hidden = YES;
            if (output) {
                self.item = [ESPreviewItem itemWithFile:self.file urlStr:self.localPath];
                [self.previewController reloadData];
            } else {
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        });
    }];
}

- (void)loadOriginFileData {
//    weakfy(self);
//    [ESTransferManager.manager downloadPre:self.file
//                                   visible:NO
//                                  progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
//        strongfy(self);
//        CGFloat progress = totalBytes * 1.0 / totalBytesExpected;
//        [self.circleProgress reloadWithProgress:progress];
//    }
//                                  callback:^(NSURL *output, NSError *error) {
//        strongfy(self);
//        if (error) {
//            return;
//        }
//        self.downloadOrigin.hidden = YES;
//        self.item = [ESPreviewItem itemWithFile:self.file];
//        [self.previewController reloadData];
//    }];
}

- (void)showDownloadProgress {
    NSUInteger progress = [self.downloadTask getProgress] * 100;
    NSString *text = [NSString stringWithFormat:TEXT_FILE_ORIGIN_IMAGE_DOWNLOADING, @(progress)];
    ESPerformBlockOnMainThread(^{
        [self.downloadOrigin setTitle:text forState:UIControlStateNormal];
    });
}

- (void)download {
    [self showDownloadProgress];
    self.downloadTask = [ESTransferManager.manager download:self.file
                                visible:NO
                               callback:^(NSURL *output, NSError *error) {
        if (output) {
            self.downloadOrigin.hidden = YES;
            [self reloadFileInfo];
            
            ESCacheInfoItem *item = [ESCacheInfoItem new];
            item.name = self.file.name;
            NSRange range = [output.absoluteString rangeOfString:@"Library/Caches/"];
            if (range.location != NSNotFound) {
                item.path = [output.absoluteString substringFromIndex:(range.location + range.length)];
            }
            item.size = [self.file.size integerValue];
            item.uuid = self.file.uuid;
            item.cacheType = [self.comeFromTag isEqualToString:ESComeFromSmartPhotoPageTag] ? ESBusinessCacheInfoTypePhoto : ESBusinessCacheInfoTypeFile;
            [[ESCacheInfoDBManager shared] insertOrUpdatCacheInfoToDB:@[item]];
            
        }
    }];
    self.downloadTask.updateProgressBlock = ^(ESTransferTask *task) {
        [self showDownloadProgress];
    };
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                    previewItemAtIndex:(NSInteger)index {
    return self.item;
}

#pragma mark - ESCommentToolDelegate

- (void)completeLoadData {
    [self reloadFileInfo];
}

- (void)onFileDelete:(NSMutableArray<ESFileInfoPub *> *)fileArray {
    [self goBack];
}

#pragma mark - Lazy Load

- (QLPreviewController *)previewController {
    if (!_previewController) {
        _previewController = [[QLPreviewController alloc] init];
        _previewController.dataSource = self;
        _previewController.delegate = self;
        [self addChildViewController:_previewController];
        [self.view addSubview:_previewController.view];
        [_previewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view).inset(50 + kBottomHeight);
        }];
    }
    return _previewController;
}

- (ESCommentToolVC *)bottomTool {
    if (!_bottomTool) {
        _bottomTool = [ESCommentToolVC new];
        _bottomTool.parentVC = self;
        _bottomTool.alwaysShow = YES;
        _bottomTool.specificView = self.view;
        _bottomTool.delegate = self;
        _bottomTool.comeFromTag = self.comeFromTag;
    }
    return _bottomTool;
}

- (UIButton *)downloadOrigin {
    if (!_downloadOrigin) {
        _downloadOrigin = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadOrigin.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.5];
        _downloadOrigin.layer.cornerRadius = 14;
        _downloadOrigin.layer.masksToBounds = YES;
        _downloadOrigin.titleLabel.font = [UIFont systemFontOfSize:10];
        [_downloadOrigin setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_downloadOrigin];
        [_downloadOrigin mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(94);
            make.height.mas_equalTo(28);
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).inset(20 + 50 + kBottomHeight);
        }];
        [_downloadOrigin addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadOrigin;
}

- (ESCircleProgress *)circleProgress {
    if (!_circleProgress) {
        _circleProgress = [[ESCircleProgress alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.view addSubview:_circleProgress];
        [_circleProgress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
            make.right.mas_equalTo(self.view).inset(20);
            make.bottom.mas_equalTo(self.view).inset(20 + 50 + kBottomHeight);
        }];
    }
    return _circleProgress;
}

- (ESFileLoadingViewController *)loadingController {
    if (!_loadingController) {
        weakfy(self);
        _loadingController = [ESFileLoadingViewController asEmbed:self.file
                                                       completion:^{
            strongfy(self);
            if (self.file) {
                [self.bottomTool showSelectArray:[NSMutableArray arrayWithObject:self.file]];
            }
            
            [self reloadFileInfo];
            [self.loadingController.view removeFromSuperview];
            [self.loadingController removeFromParentViewController];
            [self.loadingController didMoveToParentViewController:nil];
        }];
        [self.view addSubview:_loadingController.view];
        _loadingController.view.frame = self.view.bounds;
        [self addChildViewController:_loadingController];
    }
    return _loadingController;
}

- (ESPreviewUnsupportFileView *)unsupportFileView {
    if (!_unsupportFileView) {
        _unsupportFileView = [[ESPreviewUnsupportFileView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_unsupportFileView];
        [_unsupportFileView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _unsupportFileView;
}

//- (void)refreshPross:(NSNotification *)notifi {
//    long int total = self.file.size.integerValue/(4 * 1024 * 1024) + 1;
//    int progress = [[ESCommentCachePlistData manager] getDownPross:self.file.name total:total];
//    [self.circleProgress reloadWithProgress:progress];
//}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bottomTool hidden];
}

@end

//// 浏览文件
extern void ESFilePreview(UIViewController *from, ESFileInfoPub *file) {

//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSArray *fileNameArray = [file.name componentsSeparatedByString:@"."];
//    NSString *localPathString;
//    if (fileNameArray.count > 0) {
//        NSString *urlStr = fileNameArray[0];
//        localPathString = [NSString stringWithFormat:@"%@/%@/%@",cachesPath,urlStr,file.name];
//    }
    NSString *localPathString = [file getOriginalFileSavePath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFileMgr = [fileMgr fileExistsAtPath:localPathString];
    NSURL * localPath = [NSURL fileURLWithPath:ESSafeString(localPathString)];

    if (IsVideoForFile(file) && !UnsupportFileForPreview(file)) {
        AVPlayer *player = [AVPlayer playerWithURL:localPath];
        AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
        [from.navigationController presentViewController:controller animated:YES completion:nil];
        controller.player = player;
        [player play];
        return;
    }
    
    ESFilePreviewViewController *next = [ESFilePreviewViewController new];
    next.file = file;
    next.hidesBottomBarWhenPushed = YES;
    next.localPath = localPath;
    [from.navigationController pushViewController:next animated:YES];

}

extern void ESFilePreviewWithTag(UIViewController *from, ESFileInfoPub *file, NSString *comeFromTag) {
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSArray *fileNameArray = [file.name componentsSeparatedByString:@"."];
//    NSString *localPathString;
//    if (fileNameArray.count > 0) {
//        NSString *urlStr = fileNameArray[0];
//        localPathString = [NSString stringWithFormat:@"%@/%@/%@",cachesPath,urlStr,file.name];
//    }
    NSString *localPathString = [file getOriginalFileSavePath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSURL * localPath = [NSURL fileURLWithPath:ESSafeString(localPathString)];
    

    if (IsVideoForFile(file) && !UnsupportFileForPreview(file)) {
        AVPlayer *player = [AVPlayer playerWithURL:localPath];
        AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
        [from.navigationController presentViewController:controller animated:YES completion:nil];
        controller.player = player;
        [player play];
        return;
    }
    
    ESFilePreviewViewController *next = [ESFilePreviewViewController new];
    next.comeFromTag = comeFromTag;
    next.file = file;
    next.hidesBottomBarWhenPushed = YES;
    next.localPath = localPath;
    [from.navigationController pushViewController:next animated:YES];
}






