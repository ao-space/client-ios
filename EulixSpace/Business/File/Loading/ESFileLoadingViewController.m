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
//  ESFileLoadingViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/8/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileLoadingViewController.h"
#import "ESFileDefine.h"
#import "ESFilePreviewViewController.h"
#import "ESThemeDefine.h"
#import "ESTransferManager.h"
#import "ESTransferProgressView.h"
#import "ESCommentCachePlistData.h"

#import <Masonry/Masonry.h>
#import "ESToast.h"


@interface ESFileLoadingViewController ()

@property (nonatomic, weak) UIViewController *from;

@property (nonatomic, strong) ESFileInfoPub *file;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *name;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) ESTransferProgressView *progress;

@property (nonatomic, assign) BOOL preview;

@property (nonatomic, copy) void (^completion)(void);

@property (nonatomic, assign) BOOL embed;

@property (nonatomic, weak) ESTransferTask * downloadTask;
@end

@implementation ESFileLoadingViewController

+ (instancetype)asEmbed:(ESFileInfoPub *)file completion:(void (^)(void))completion {
    NSParameterAssert(file && completion);
    ESFileLoadingViewController *content = [ESFileLoadingViewController new];
    content.file = file;
    content.embed = YES;
    content.completion = completion;
    return content;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [self barItemWithImage:IMAGE_IC_BACK_CHEVRON selector:@selector(goBack)];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)loadCompressImage {
    weakfy(self);
    [ESTransferManager.manager preview:self.file
        progress:^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
            strongfy(self);
            self.content.text = FileSizeString(totalBytesExpected, YES);
            [self.progress reloadWithRate:(totalBytes * 1.0 / totalBytesExpected)];
        }
        callback:^(NSURL *output, NSError *error) {
            strongfy(self);
            if (output) {
                [self previewFile];
            } else {
                [self loadOriginFileData];
            }
        }];
}

- (void)previewFile {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *from = self.from;
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     if (!self.completion) {
                                         ESFilePreview(from, self.file);
                                     } else {
                                         self.completion();
                                     }
                                 }];
    });
}

- (void)loadData {
    if (IsImageForFile(self.file) && self.preview) {
        [self loadCompressImage];
        return;
    }
    [self loadOriginFileData];
}

- (void)loadOriginFileData {
    self.content.text = FileSizeString(self.file.size.unsignedLongLongValue, YES);

    weakfy(self);
    self.downloadTask = [ESTransferManager.manager download:self.file
                                                    visible:NO callback:^(NSURL *output, NSError *error) {
        ESDLog(@"[上传下载] 视频预览下载 error:%@, url:%@", error, output);
        if (error || output == nil) {
            [ESToast toastError:NSLocalizedString(@"transfer_download_failed", @"下载失败")];
            return;
        }
        strongfy(self);
        [self previewFile];
    }];
    self.downloadTask.updateProgressBlock = ^(ESTransferTask *task) {
        strongfy(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshPross];
        });
    };
}

#pragma mark - initUI

- (void)initUI {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).inset(112);
        make.height.width.mas_equalTo(40);
    }];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).inset(20);
        make.left.mas_equalTo(self.contentView).inset(68);
        make.right.mas_equalTo(self.contentView).inset(67);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name.mas_bottom).inset(10);
        make.left.right.mas_equalTo(self.contentView).inset(86);
        make.height.mas_equalTo(17);
    }];

    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.content.mas_bottom).inset(30);
        make.left.mas_equalTo(self.contentView).inset(68);
        make.right.mas_equalTo(self.contentView).inset(67);
        make.height.mas_equalTo(6);
    }];

    self.icon.image = IconForFile(self.file);
    self.name.text = self.file.name;
    self.content.text = FileSizeString(self.file.size.unsignedLongLongValue, YES);
    
    
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    return self.view;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.textColor = [ESColor labelColor];
        _name.textAlignment = NSTextAlignmentCenter;
        _name.font = [UIFont systemFontOfSize:16];
        _name.numberOfLines = 0;
        [self.contentView addSubview:_name];
    }
    return _name;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = [ESColor secondaryLabelColor];
        _content.textAlignment = NSTextAlignmentCenter;
        _content.font = [UIFont systemFontOfSize:12];
        _content.numberOfLines = 2;
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (ESTransferProgressView *)progress {
    if (!_progress) {
        _progress = [ESTransferProgressView new];
        [self.contentView addSubview:_progress];
    }
    return _progress;
}

- (void)downCompleteNotification:(NSNotification *)notifi {
    [self previewFile];
}


- (void)refreshPross {
    CGFloat progress = [self.downloadTask getProgress];
    [self.progress reloadWithRate:progress];
}

@end

extern void ESFileShowLoading(UIViewController *from, ESFileInfoPub *file, BOOL preview, void (^completion)(void)) {
    ESFileLoadingViewController *next = [ESFileLoadingViewController new];
    next.file = file;
    next.from = from;
    next.preview = preview;
    next.completion = completion;
    YCNavigationController *navi = [[YCNavigationController alloc] initWithRootViewController:next];
    [from.navigationController presentViewController:navi animated:YES completion:nil];
}

