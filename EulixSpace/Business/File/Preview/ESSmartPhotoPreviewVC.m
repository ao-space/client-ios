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
//  ESSmartPhotoPreviewVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/7.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSmartPhotoPreviewVC.h"
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
#import "ESCommentCachePlistData.h"
#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDAnimatedImage.h>
#import "ESBottomSelectedOperateVC.h"
#import "GKPhotoView+ESLoadPhoto.h"
#import "ESFilePreviewViewController.h"
#import "ESPlayerVC.h"
#import "ESToast.h"
#import "ESVideoPreviewController.h"

@interface ESImagesPreviewVC () <GKPhotoBrowserDelegate>

@property (nonatomic, copy) NSMutableDictionary<NSNumber *, ESPreviewItem*> *itemsMap;
@property (nonatomic, copy) NSArray<ESFileInfoPub*> *files;

@property (nonatomic, strong) ESCommentToolVC *bottomTool;
@property (nonatomic, strong) UIButton *downloadOrigin;
@property (nonatomic, strong) ESCircleProgress *circleProgress;
@property (nonatomic, strong) ESFileLoadingViewController *loadingController;
@property (nonatomic, strong) ESPreviewUnsupportFileView *unsupportFileView;

- (void)loadPreviewItemWithFileIndex:(NSInteger)index;
- (void)loadCompressedImage:(ESFileInfoPub *)file previewIndex:(NSUInteger)index;
- (void)reloadItem:(NSURL *)itemUrl atIndex:(NSInteger)index;
- (void)reloadCurrentPreview;

@end

@interface ESSmartPhotoPreviewVC ()

@property (nonatomic, strong) NSArray<ESPicModel *> *picList;
@property (nonatomic, strong) ESBottomSelectedOperateVC *bottomMoreToolVC;
@property (nonatomic, copy) NSString *albumId;

@end

FOUNDATION_EXPORT NSString *const ESComeFromSmartPhotoPageTag;

@implementation ESSmartPhotoPreviewVC

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.bottomMoreToolVC hidden];
    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]||[obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
        obj.backgroundColor = nil;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]||[obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            obj.backgroundColor = ESColor.systemBackgroundColor;
        }
    }];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)photoBrowser:(ESPhotoBrowser *)browser didChangedIndex:(NSInteger)index {
        //update title
    if (index < 0) {
        return;
    }

    [self updateTitle];
    
    if (IsVideoForFile(self.files[index])) {
        [[self curPhotoView] showPlayIcon];
    } else {
        [[self curPhotoView] hiddenPlayIcon];
    }
    
   [self loadPreviewItemWithFileIndex:index];
}

- (void)updateTitle {
    NSInteger totalCount = self.files.count;
    self.navigationItem.title = [NSString stringWithFormat:@"%lu/%lu",self.currentIndex + 1, totalCount];
}

- (void)photoBrowser:(ESPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index {
    if (index < self.files.count &&
        UnsupportFileForPreview(self.files[index]) == NO &&
        IsVideoForFile(self.files[index])) {
        ESFileInfoPub *file = self.files[index];
        ESVideoPreviewController *vc = [[ESVideoPreviewController alloc] init];
        vc.previewUuid = self.files[index].uuid;
        weakfy(self)
        vc.supportBlock = ^(NSString *uuid, BOOL support, ESPlayerModel *playerModel) {
            strongfy(self)
            if (!support) {
                ESFileShowLoading(self, file, NO, ^(void) {
                ESFilePreviewWithTag(self, file, ESComeFromSmartPhotoPageTag);
                });
              return;
            }
            
            playerModel.videoName = self.files[index].name;
            ESPlayerVC *detailVC = [ESPlayerVC new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.playerModel = playerModel;
            [self.navigationController pushViewController:detailVC animated:NO];
        };
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return;
       }
}

- (void)loadPreviewItemWithFileIndex:(NSInteger)index {
    if (index >= self.files.count || index < 0 ||  index >= self.picList.count) {
        return;
    }
    ESFileInfoPub *file = self.files[index];
    ESPicModel *pic = self.picList[index];
    /// 更新 bottomMoreToolVC info
    if (pic != nil) {
        self.bottomMoreToolVC.albumId = self.albumId;
        [self.bottomMoreToolVC showFrom:self];
        [self.bottomMoreToolVC updateSelectedList:@[pic]];
    }
    
    NSURL *previewUrl = [self getPhotoOriginOrCompressUrlWithFile:file];
    if (previewUrl == nil) {
        previewUrl = [NSURL URLWithString:pic.cacheUrl];
    }
    [self reloadItem:previewUrl atIndex:index];

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
        if (IsVideoForFile(file)) {
            self.downloadOrigin.hidden = YES;
        }
        if (!CompressedImageExist(file)) {
            [self loadCompressedImage:file previewIndex:index];
            return;
        }
    } else {
        self.downloadOrigin.hidden = YES;
    }
    BOOL unsupportForPreview = UnsupportFilePhotoForPreview(pic);
    if (unsupportForPreview) {
        ESFormItem *item = [ESFormItem new];
        item.title = pic.name;
        item.content = FileSizeString(pic.size, YES);
        item.icon = IconForFile(pic.name);
        [[self curPhotoView] showUnsupportFileView:item];
        self.downloadOrigin.hidden = YES;
    } else {
        [[self curPhotoView] hiddenUnsupportFileView];
    }
}

- (void)reloadCurrentPreview {
    NSUInteger currentIndex = self.currentIndex;
    
    if (currentIndex >= self.files.count || index < 0 ||  currentIndex >= self.picList.count) {
        return;
    }
    ESFileInfoPub *file = self.files[currentIndex];
    ESPicModel *pic = self.picList[currentIndex];
    
    NSURL *previewUrl = [self getPhotoOriginOrCompressUrlWithFile:file];
    if (previewUrl == nil) {
        previewUrl = [NSURL URLWithString:pic.cacheUrl];
    }
    [self reloadItem:previewUrl atIndex:currentIndex];
}

- (NSURL * _Nullable) getPhotoOriginOrCompressUrlWithFile:(ESFileInfoPub *)file {
    NSURL *previewItemURL;
    
    if (LocalFileExist(file) && !IsVideoForFile(file)) {
//        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        NSArray *fileNameArray = [file.name componentsSeparatedByString:@"."];
//        NSString *localPathString;
//        if (fileNameArray.count > 0) {
//            NSString *urlStr = fileNameArray[0];
//            localPathString = [NSString stringWithFormat:@"%@/%@/%@",cachesPath,urlStr,file.name];
//        }
        NSString *localPathString = [file getOriginalFileSavePath];
        if (localPathString.length > 0) {
            previewItemURL = [NSURL fileURLWithPath:localPathString];
        }
    } else if (CompressedImageExist(file)) {
        previewItemURL = [NSURL fileURLWithPath:CompressedPathForFile(file).fullCachePath];
    }
    
    return previewItemURL;
    
}

- (void)bottomToolUpdateSelectItem:(ESFileInfoPub *)file index:(NSInteger)index {
    ESPicModel *pic = self.picList[index];
    if (pic != nil) {
        [self.bottomMoreToolVC showFrom:self];
        [self.bottomMoreToolVC updateSelectedList:@[pic]];
    }
}

- (ESBottomSelectedOperateVC *)bottomMoreToolVC {
    if (!_bottomMoreToolVC) {
        _bottomMoreToolVC = [[ESBottomSelectedOperateVC alloc] init];
    }
    return _bottomMoreToolVC;
}

- (void)deletePicItem:(id)itemModel index:(NSInteger)index {
    if ([itemModel isKindOfClass:[ESFileInfoPub class]] || [itemModel isKindOfClass:[ESPicModel class]]) {
        NSString *uuid = [(ESFileInfoPub *)itemModel uuid];
        if (self.currentIndex < self.files.count && [self.files[self.currentIndex].uuid isEqualToString:ESSafeString(uuid)]) {
            [self removeItemAtIndex:self.currentIndex];
            return;
        }
        __block NSUInteger index = NSNotFound;
        [self.files enumerateObjectsUsingBlock:^(ESFileInfoPub * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.uuid isEqualToString:ESSafeString(uuid)]) {
                index = idx;
                *stop = YES;
            }
        }];
        
        [self removeItemAtIndex:index];
    }
}

- (void)tryAsyncDataWithRename:(NSString *)newName uuid:(NSString *)uuid {
    __block NSUInteger index = NSNotFound;
    [self.files enumerateObjectsUsingBlock:^(ESFileInfoPub * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.uuid isEqualToString:ESSafeString(uuid)]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index != NSNotFound) {
        ESFileInfoPub *file = self.files[index];
        file.name = newName;
    }
    if (index < self.picList.count) {
        ESPicModel *pic = self.picList[index];
        pic.name = newName;
        [self.bottomMoreToolVC updateSelectedList:@[pic]];
    }
}

- (void)removeItemAtIndex:(NSInteger)index {
    if (index < self.files.count) {
        [self removePhotoAtIndex:self.currentIndex];
        
        NSMutableArray *fileTemp = [NSMutableArray arrayWithArray:self.files];
        [fileTemp removeObjectAtIndex:index];
        self.files = [fileTemp copy];
    }
    
    if (index < self.picList.count) {
        NSMutableArray *fileTemp = [NSMutableArray arrayWithArray:self.picList];
        [fileTemp removeObjectAtIndex:index];
        self.picList = [fileTemp copy];
    }
    [self updateTitle];
}
@end

extern void ESPhotoPreview(UIViewController *from, NSArray<ESPicModel *> *imageFiles, ESPicModel *selectPic, NSString *albumId, NSString *comeFromTag) {
    NSMutableArray *imageFilesTemp = [NSMutableArray array];
    __block NSUInteger selectIndex = 0;
    __block NSUInteger index = 0;

    NSMutableArray *imageFilesFilter = [NSMutableArray array];

    [imageFiles enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
        ESFileInfoPub *file = [[ESFileInfoPub alloc] init];
        file.name = pic.name;
        file.size = @(pic.size);
        file.uuid = pic.uuid;
        file.path = pic.path;
        file.category = pic.category;
        file.operationAt = @(pic.shootAt);
        if (IsImageForFile(file) || IsVideoForFile(file)) {
            @autoreleasepool {
                GKPhoto *photo = [GKPhoto new];
                photo.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cloud_image_default" ofType:@"png"]];
                [imageFilesTemp addObject:photo];
                [imageFilesFilter addObject:file];
            }
            if ([file.uuid isEqual:selectPic.uuid]) {
                selectIndex = index;
            }
            index++;
        }
    }];
    
    
    ESSmartPhotoPreviewVC *phtoBrowser = [ESSmartPhotoPreviewVC photoBrowserWithPhotos:imageFilesTemp currentIndex:selectIndex];
    phtoBrowser.files = imageFilesFilter;
    phtoBrowser.picList = imageFiles;
    phtoBrowser.comeFromTag = comeFromTag;
    phtoBrowser.albumId = albumId;
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

extern void ESPhotoPreviewWithFiles(UIViewController *from, NSArray<ESFileInfoPub *> *imageFiles, NSString *selectPicUuid, NSString *albumId, NSString *comeFromTag) {
    NSMutableArray *imageFilesTemp = [NSMutableArray array];
    __block NSUInteger selectIndex = 0;
    __block NSUInteger index = 0;

    NSMutableArray *imageFilesFilter = [NSMutableArray array];
    NSMutableArray *imagesFilter = [NSMutableArray array];

    [imageFiles enumerateObjectsUsingBlock:^(ESFileInfoPub * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        ESPicModel *pic = [[ESPicModel alloc] init];
        pic.name = file.name;
        pic.size = [file.size floatValue];
        pic.uuid = file.uuid;
        pic.path = file.path;
        pic.category = file.category;
        pic.shootAt = [file.operationAt doubleValue];
        if (IsImageForFile(file) || IsVideoForFile(file)) {
            @autoreleasepool {
                GKPhoto *photo = [GKPhoto new];
                photo.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cloud_image_default" ofType:@"png"]];
//                if (IsVideoForFile(file)) {
//                    photo.url = [NSURL URLWithString:pic.cacheUrl];
//                }
                [imageFilesTemp addObject:photo];
                [imageFilesFilter addObject:file];
                [imagesFilter addObject:pic];
            }
            if ([file.uuid isEqual:ESSafeString(selectPicUuid)]) {
                selectIndex = index;
            }
            index++;
        }
    }];
    
    
    ESSmartPhotoPreviewVC *phtoBrowser = [ESSmartPhotoPreviewVC photoBrowserWithPhotos:imageFilesTemp currentIndex:selectIndex];
    phtoBrowser.files = imageFilesFilter;
    phtoBrowser.picList = imagesFilter;
    phtoBrowser.comeFromTag = comeFromTag;
    phtoBrowser.albumId = albumId;
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
