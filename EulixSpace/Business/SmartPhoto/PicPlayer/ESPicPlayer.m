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
//  ESPicPlayer.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPicPlayer.h"
#import "ESPicModel.h"
#import "ESPlayerHeaderToolView.h"
#import "ESPlayerBottomToolView.h"
#import <AVFoundation/AVFoundation.h>

@interface ESPicPlayer ()

@property (nonatomic, strong) UIView *playerMaskView;
@property (nonatomic, strong) UIImageView *frontImageView;
@property (nonatomic, strong) UIImageView *nextImageView;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) ESPlayerHeaderToolView *headerView;
@property (nonatomic, strong) ESPlayerBottomToolView *bottomView;
@property (nonatomic, assign) BOOL controlPanShowing;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation ESPicPlayer

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = ESColor.darkTextColor;
    [self.view addSubview:self.playerMaskView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.playerMaskView addGestureRecognizer:tapGesture];
    
    if ([self isPicReady]) {
        [self startPlay];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 
}

- (BOOL)isPicReady {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self finishPlay];
}

- (void)resetPlayList:(NSArray<ESPicModel *> *)picList {
    self.picList = picList;
    
    if (self.isViewLoaded && self.view.window) {
        [self stopTimer];
        if (self.frontImageView.superview) {
            [self.frontImageView stopAnimating];
            [self.frontImageView removeFromSuperview];
        }
        if  (self.nextImageView.superview) {
            [self.nextImageView removeFromSuperview];
        }
        self.currentIndex = 0;
        [self startPlay];
    }
}

- (void)updateTitleText:(NSString *)title message:(NSString *)messageText {
    [self.headerView updateTitleText:title message:messageText];
}

- (void)startPlay {
    [self setupFirstImageView];
    [self startTimer];
    [self.audioPlayer play];
    self.playerStatus = ESPlayerStatusPlaying;
    [self.bottomView updatePlayBtWithPlayerStatus];
}

- (void)resumePlay {
    [self startTimer];
    [self.audioPlayer play];
    self.playerStatus = ESPlayerStatusPlaying;
    [self.bottomView updatePlayBtWithPlayerStatus];
}

- (void)pausePlay {
    [self stopTimer];
    [self.audioPlayer pause];
    self.playerStatus = ESPlayerStatusPause;
    [self.bottomView updatePlayBtWithPlayerStatus];
}

- (void)stopPlay {
    [self stopTimer];
    [self.audioPlayer stop];
    self.playerStatus = ESPlayerStatusStop;
    [self.bottomView updatePlayBtWithPlayerStatus];
}

- (void)finishPlay {
    [self stopTimer];
    [self.audioPlayer stop];
    self.playerStatus = ESPlayerStatusFinish;
    [self.bottomView updatePlayBtWithPlayerStatus];
}

- (void)setupFirstImageView {
    if (self.currentIndex >= self.picList.count) {
        return;
    }
    CGRect rect = [UIScreen mainScreen].bounds;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:imageView belowSubview:self.playerMaskView];

    self.frontImageView = imageView;
    ESPicModel *pic = self.picList[self.currentIndex];
    NSString *url = [self getUrlPathWith:pic];
    if (url.length > 0) {
        [self updateImage:self.frontImageView contentPath:url];
    }
}

- (NSString *)getUrlPathWith:(ESPicModel *)pic {
    return pic.cacheUrl;
}

- (void)updateImage:(UIImageView *)imageView contentPath:(NSString *)path {
    @autoreleasepool {
        UIImage *image = image = [UIImage imageWithContentsOfFile:path];
        CGSize size = image.size;
        if (size.width > 2000 || size.height > 2000) {
            image = [self kj_QuartzChangeImage:image scale: 2000 / (MAX(size.width, size.height))];
            size = CGSizeMake( (2000 * size.width) / (MAX(size.width, size.height)) , (2000 * size.height) / (MAX(size.width, size.height)) );
        }
        CGRect rect = [UIScreen mainScreen].bounds;
   
        imageView.image = image;
//        imageView.frame = CGRectMake(0, 0, size.width, size.height);
//        imageView.center = self.view.center;
        [self playScaleAnimation];
    }
}

- (UIImage*)kj_QuartzChangeImage:(UIImage *)image scale:(CGFloat)scale {
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height *scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)startTimer {
    if (self.picList.count > 0) {
        [self stopTimer];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)playScaleAnimation {
    if (self.frontImageView) {
        [UIView animateWithDuration:3 animations:^{
            self.frontImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
        }];
    }
}

- (void)timerUpdate {
    self.currentIndex++;
    
    if (self.currentIndex >= self.picList.count) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
        [self finishPlay];
        [self showControlPan];
        return;
    }
    
    CGRect rect = [UIScreen mainScreen].bounds;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:imageView belowSubview:self.frontImageView];
    self.nextImageView = imageView;
    
    ESPicModel *pic = self.picList[self.currentIndex];
    NSString *url = [self getUrlPathWith:pic];
    if (url.length > 0) {
        [self updateImage:self.nextImageView contentPath:url];
    }
    
    [self.frontImageView removeFromSuperview];
    self.frontImageView = self.nextImageView;
    [self playScaleAnimation];
}

- (void)showControlPan {
    [self.headerView showFrom:self.view];
    [self.bottomView showFrom:self.view];
    self.controlPanShowing = YES;
}

- (void)hiddenControlPan {
    [self.headerView hidden];
    [self.bottomView hidden];
    self.controlPanShowing = NO;
}

- (ESPlayerHeaderToolView *)headerView {
    if (!_headerView) {
        _headerView = [[ESPlayerHeaderToolView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kStatusBarHeight)];
        _headerView.backgroundColor = ESColor.darkTextColor;

         weakfy(self)
        _headerView.goActionBlock = ^() {
            strongfy(self)
         [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _headerView;
}

- (ESPlayerBottomToolView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[ESPlayerBottomToolView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kStatusBarHeight)];
        _bottomView.backgroundColor = ESColor.darkTextColor;

        _bottomView.player = self;
        
        weakfy(self)
        _bottomView.actionBlock = ^(ESPlayerActionType action) {
            strongfy(self)
            if (action == ESPlayerActionTypePause) {
                [self pausePlay];
                return;
            }
            
            if (action == ESPlayerActionTypeResume) {
                [self resumePlay];
                return;
            }
        };
    }
    return _bottomView;
}

- (UIView *)playerMaskView {
    if (!_playerMaskView) {
        _playerMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    }
    return _playerMaskView;
}

- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:[self randomBackAudioFile] withExtension:@"mp3"];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        [_audioPlayer prepareToPlay];
        _audioPlayer.numberOfLoops = -1;
    }
    return _audioPlayer;
}

- (NSString *)randomBackAudioFile {
    NSArray *audioFileList = @[ @"bg_music_1", @"bg_music_2", @"bg_music_3", @"bg_music_4"];
    int index = arc4random() % audioFileList.count;
    return audioFileList[index];
}

- (void)tapAction:(id)sender {
    if (self.controlPanShowing) {
        [self hiddenControlPan];
        return;
    }
    
    [self showControlPan];
    return;
}

@end
