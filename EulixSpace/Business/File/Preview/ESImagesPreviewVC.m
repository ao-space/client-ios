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
//  ESImagesPreviewVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESImagesPreviewVC.h"
#import "ESBottomDetailView.h"
#import "ESBottomMoreView.h"
#import "ESCircleProgress.h"
#import "ESCommentToolVC.h"
#import "ESFileDefine.h"
#import "ESFileLoadingViewController.h"
#import "ESFormItem.h"
#import "ESLocalPath.h"
#import "ESPreviewItem.h"
#import "ESPreviewUnsupportFileView.h"
#import "ESThemeDefine.h"
#import "ESTransferManager.h"
#import "ESToast.h"
#import "ESCommentCachePlistData.h"
#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDAnimatedImage.h>
#import "ESCacheInfoDBManager.h"


@interface ESImagesPreviewVC () <ESBottomMoreViewDelegate,
                                           ESFileBottomViewDelegate,
                                           ESBottomDetailViewDelegate,
                                           ESCommentToolDelegate,
                                           GKPhotoBrowserDelegate>

@property (nonatomic, copy) NSMutableDictionary<NSNumber *, ESPreviewItem*> *itemsMap;
@property (nonatomic, copy) NSArray<ESFileInfoPub*> *files;

@property (nonatomic, strong) ESCommentToolVC *bottomTool;
@property (nonatomic, strong) UIButton *downloadOrigin;
@property (nonatomic, strong) ESCircleProgress *circleProgress;
@property (nonatomic, strong) ESFileLoadingViewController *loadingController;
@property (nonatomic, strong) ESPreviewUnsupportFileView *unsupportFileView;
@property (nonatomic, weak) ESTransferTask * downloadTask;
@property (nonatomic, weak) ESTransferTask * downloadPreTask;

@end

static NSInteger const ESPreviewPicCount = 8;
FOUNDATION_EXPORT NSString *const ESComeFromSmartPhotoPageTag;

@implementation ESImagesPreviewVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self photoBrowser:self didChangedIndex:self.currentIndex];
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadCompressedImage:(ESFileInfoPub *)file previewIndex:(NSUInteger)index {
    weakfy(self);
    self.circleProgress.hidden = NO;
    // 已无发送该通知的行为
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPross:) name:@"uploadProssNotification" object:nil];
    [ESTransferManager.manager preview:file
        progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
        }
        callback:^(NSURL *output, NSError *error) {
            strongfy(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.circleProgress.hidden = YES;
                if (output && index < self.files.count && CompressedImageExist(file)) {
                    NSURL *localPath = [self getLocalPathWithFile:file];

                    ESPreviewItem *item = [ESPreviewItem itemWithFile:file urlStr:localPath];
                    [self reloadItem:item.previewItemURL atIndex:index];
                    return;
                }
                
                if (IsVideoForFile(file)) {
                    return;
                }
                [self loadOriginFileData:file previewIndex:index];
                
            });
        }];
}

- (void)loadOriginFileData:(ESFileInfoPub *)file previewIndex:(NSUInteger)index {
    weakfy(self);
    self.downloadPreTask = [ESTransferManager.manager downloadPre:file
                                                         callback:^(NSURL *output, NSError *error) {
        strongfy(self);
        if (error) {
            return;
        }

        if (![self isValiedImagePath:output.absoluteString]) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadOrigin.hidden = YES;
                [self reloadItem:output atIndex:index];
                [self cacheOrginFile:file output:output];
            });
        }];
    
    self.downloadPreTask.updateProgressBlock = ^(ESTransferTask *task) {
        strongfy(self);
        CGFloat progress = [task getProgress];
        ESPerformBlockOnMainThread(^{
            [self.circleProgress reloadWithProgress:progress];
        });
    };
}

- (BOOL)isValiedImagePath:(NSString *)url {
    NSString *imagePath = url;
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    if ([imagePath containsString:@"%"]) {
        imagePath = [imagePath stringByRemovingPercentEncoding];
    }
    UIImage *placeholderImage = [UIImage imageWithContentsOfFile:imagePath];
    if (placeholderImage == nil) {
        placeholderImage = [SDAnimatedImage imageWithContentsOfFile:imagePath];
    }
    
    return placeholderImage != nil;
}

- (void)cacheOrginFile:(ESFileInfoPub *)file  output:(NSURL *)output {
    NSError *error;

    NSString * fileDir = [file getOriginalFileSaveDir];
    NSString *localPathString = [file getOriginalFileSavePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *imagePath = output.absoluteString;
    if (imagePath.length <= 0) {
        return;
    }
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
   [NSFileManager.defaultManager copyItemAtPath:imagePath toPath:localPathString error:&error];
}

- (void)reloadItem:(NSURL *)itemUrl atIndex:(NSInteger)index {
    @autoreleasepool {
        if (index == self.currentIndex) {
            GKPhoto *photo = self.photos[index];
            photo.url = itemUrl;
            GKPhotoView *photoView = [self curPhotoView];
            [photoView setupPhoto:photo];
        }
    }
}

- (void)showDownloadProgress {
    NSUInteger progress = [self.downloadTask getProgress] * 100;
    NSString *text = [NSString stringWithFormat:TEXT_FILE_ORIGIN_IMAGE_DOWNLOADING, @(progress)];
    ESPerformBlockOnMainThread(^{
        [self.downloadOrigin setTitle:text forState:UIControlStateNormal];
    });
}

- (void)download {
    NSUInteger index = self.currentIndex;
    if (index > self.files.count) {
        return;
    }
    
    [self showDownloadProgress];
    self.downloadTask = [ESTransferManager.manager download:self.files[index]
                                visible:NO
        callback:^(NSURL *output, NSError *error) {
            if (output) {
                if (![self isValiedImagePath:output.absoluteString]) {
                    self.downloadOrigin.hidden = YES;
                    [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                    [NSFileManager.defaultManager removeItemAtURL:output error:nil];
                    return;
                }
               
                self.downloadOrigin.hidden = YES;
                [self reloadCurrentPreview];
                ESFileInfoPub *file = self.files[index];
                ESCacheInfoItem *item = [ESCacheInfoItem new];
                item.name = file.name;
                NSRange range = [output.absoluteString rangeOfString:@"Library/Caches/"];
                if (range.location != NSNotFound) {
                    item.path = [output.absoluteString substringFromIndex:(range.location + range.length)];
                }
                item.size = [file.size integerValue];
                item.uuid = file.uuid;
                item.cacheType = [self.comeFromTag isEqualToString:ESComeFromSmartPhotoPageTag] ? ESBusinessCacheInfoTypePhoto : ESBusinessCacheInfoTypeFile;
                [[ESCacheInfoDBManager shared] insertOrUpdatCacheInfoToDB:@[item]];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    
    self.downloadTask.updateProgressBlock = ^(ESTransferTask *task) {
        [self showDownloadProgress];
    };
}

-(void)setFiles:(NSArray<ESFileInfoPub *> *)files {
    _files = files;
    _itemsMap = [NSMutableDictionary dictionary];
    
}

- (ESPreviewItem *)getPreviewItemWithFileIndex:(NSUInteger)index {
    ESFileInfoPub *file = self.files[index];

    NSString *localPathString = [file getOriginalFileSavePath];
    NSURL *localPath;
    localPath = [NSURL fileURLWithPath:ESSafeString(localPathString)];
    ESPreviewItem *item = [ESPreviewItem itemWithFile:file urlStr:localPath];
    return item;
}

- (void)updatePreviewIfNeeded:(ESPreviewItem *)newItem withIndex:(NSUInteger)index {
    ESPreviewItem *item = self.itemsMap[@(index)];
    if (!item && newItem != nil) {
        self.itemsMap[@(index)] = newItem;
    }
}

- (void)photoBrowser:(ESPhotoBrowser *)browser didChangedIndex:(NSInteger)index {
   [self loadPreviewItemWithFileIndex:index];
}

- (void)loadPreviewItemWithFileIndex:(NSInteger)index {
    if (index >= self.files.count || index < 0) {
        return;
    }
    ESFileInfoPub *file = self.files[index];
    //update title
    self.navigationItem.title = file.name;

    //图片预览    file.previewPic
    ///不是原图,显示下载按钮
    if (!LocalFileExist(file)) {
        self.downloadOrigin.hidden = NO;
        NSString *text = [NSString stringWithFormat:TEXT_FILE_ORIGIN_IMAGE, FileSizeString(file.size.unsignedLongLongValue, YES)];
        [self.downloadOrigin setTitle:text forState:UIControlStateNormal];
        CGFloat width = [text es_widthWithFont:[UIFont systemFontOfSize:10]];
        [self.downloadOrigin mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width + 30);
        }];
        ///压缩图不存在, 自动下载压缩图
        if (!CompressedImageExist(file)) {
            [self loadCompressedImage:file previewIndex:index];
        }
    } else {
        self.downloadOrigin.hidden = YES;
    }
    
    if (file != nil) {
        [self bottomToolUpdateSelectItem:file index:index];
    }
}

- (void)reloadCurrentPreview {
    NSUInteger currentIndex = self.currentIndex;
    
    ESPreviewItem *item =  [self getPreviewItemWithFileIndex:currentIndex];
    if (item!= nil) {
        self.navigationItem.title = item.previewItemTitle;
        [self reloadItem:item.previewItemURL atIndex:currentIndex];
    }
}

- (NSURL *)getLocalPathWithFile:(ESFileInfoPub *)file {
    NSString *localPathString = [file getOriginalFileSavePath];
    NSURL *localPath = [NSURL fileURLWithPath: ESSafeString(localPathString)];
    return localPath;
}

#pragma mark - ESCommentToolDelegate

- (void)completeLoadData {
    [self reloadCurrentPreview];
}

- (void)onFileDelete:(NSMutableArray<ESFileInfoPub *> *)fileArray {
    if ([self.fromListVC respondsToSelector:@selector(headerRefreshWithUUID:)] && [self.fromListVC respondsToSelector:@selector(enterFileUUIDArray)]) {
        if (self.fromListVC.enterFileUUIDArray.count > 0) {
            ESFileInfoPub *info = self.fromListVC.enterFileUUIDArray[self.fromListVC.enterFileUUIDArray.count - 1];
            [self.fromListVC headerRefreshWithUUID:info.uuid];
        } else {
            [self.fromListVC headerRefreshWithUUID:@""];
        }
    }
//    [self goBack];
}

#pragma mark - Lazy Load

- (ESCommentToolVC *)bottomTool {
    if (!_bottomTool) {
        _bottomTool = [ESCommentToolVC new];
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
        NSUInteger currentIndex = self.currentIndex;
        ESFileInfoPub *file = self.files[currentIndex];
        _loadingController = [ESFileLoadingViewController asEmbed:file
                                                       completion:^{
                                                           strongfy(self);
            if (file) {
                [self bottomToolUpdateSelectItem:file index:currentIndex];
            }
                                                       
                                                           [self reloadCurrentPreview];
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

- (void)bottomToolUpdateSelectItem:(ESFileInfoPub *)file index:(NSInteger)index {
    [self.bottomTool showSelectArray:[@[file] mutableCopy]];
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
//    NSUInteger currentIndex = self.currentIndex;
//    ESFileInfoPub *file = self.files[currentIndex];
//    
//    long int total = file.size.integerValue/(4 * 1024 * 1024) + 1;
//    int progress = [[ESCommentCachePlistData manager] getDownPross:file.name total:total];
//    [self.circleProgress reloadWithProgress:progress];
//}


@end

extern GKPhoto* getPhotoModelWithFile(ESFileInfoPub *file) {
    GKPhoto *photo = [GKPhoto new];
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSArray *fileNameArray = [file.name componentsSeparatedByString:@"."];
//    NSString *localPathString;
//    if (fileNameArray.count > 0) {
//        NSString *urlStr = fileNameArray[0];
//        localPathString = [NSString stringWithFormat:@"%@/%@/%@",cachesPath,urlStr, file.name];
//    }
    NSString *localPathString = [file getOriginalFileSavePath];
    NSURL *localPath;
    localPath = [NSURL fileURLWithPath:localPathString];
    ESPreviewItem *item = [ESPreviewItem itemWithFile:file urlStr:localPath];
    NSString *imagePath = item.previewItemURL.absoluteString;
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    photo.url = [NSURL URLWithString:imagePath];
   
    return photo;
    
}

extern void ESImagesPreview(UIViewController *from, NSArray<ESFileInfoPub *> *imageFiles, ESFileInfoPub *selectFile) {
    NSMutableArray *imageFilesTemp = [NSMutableArray array];
    __block NSUInteger selectIndex = -1;
    __block NSUInteger index = 0;

    NSMutableArray *imageFilesFilter = [NSMutableArray array];

    [imageFiles enumerateObjectsUsingBlock:^(ESFileInfoPub * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        if (IsImageForFile(file)) {
            @autoreleasepool {
                GKPhoto *photo = [GKPhoto new];
                [imageFilesTemp addObject:photo];
                [imageFilesFilter addObject:file];
            }
            if ([file.uuid isEqual:selectFile.uuid]) {
                selectIndex = index;
            }
            index++;
        }
    }];
    
    
    ESImagesPreviewVC *phtoBrowser = [ESImagesPreviewVC photoBrowserWithPhotos:imageFilesTemp currentIndex:selectIndex];
    phtoBrowser.files = imageFilesFilter;
    phtoBrowser.hidesPageControl = YES;
    phtoBrowser.hidesCountLabel = YES;
    phtoBrowser.bgColor = ESColor.systemBackgroundColor;
    phtoBrowser.isSingleTapDisabled = YES;
    phtoBrowser.showStyle = GKPhotoBrowserShowStylePush;
    phtoBrowser.fromListVC = (UIViewController<ESListVCRereshProtocl> *)from;
    phtoBrowser.hidesBottomBarWhenPushed = YES;
    phtoBrowser.delegate = phtoBrowser;
    [phtoBrowser showFromVC:from];
    
}


