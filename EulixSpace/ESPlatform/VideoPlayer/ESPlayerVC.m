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
//  ESPlayerVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/12/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPlayerVC.h"
#import "Masonry.h"
#import "FullScreenHelperViewController.h"
#import "LandscapeRightViewController.h"
#import "LandscapeLeftViewController.h"
#import "EnterFullScreenTransition.h"
#import "ExitFullScreenTransition.h"
#import "ESLocalNetworking.h"
#import "ESGCDWebServerManager.h"
#import "ESBoxManager.h"

@interface ESPlayerModel ()

@property (nonatomic, strong)WMPlayerModel* currentPlayerModel;

@end

@implementation ESPlayerModel

@end

@interface ESPlayerVC () <WMPlayerDelegate, UIViewControllerTransitioningDelegate, ESLocalNetworkingStatusProtocol>

@property (nonatomic, strong) WMPlayer  *wmPlayer;
@property (nonatomic, assign) BOOL networkChangeLock;
@property (nonatomic, assign) NSInteger retryCount;

@end

@implementation ESPlayerVC

//全屏的时候hidden底部homeIndicator
- (BOOL)prefersHomeIndicatorAutoHidden{
    return self.wmPlayer.isFullscreen;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden{
    return self.wmPlayer.prefersStatusBarHidden;
}
//视图控制器实现的方法
- (BOOL)shouldAutorotate{
     return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

///播放器CloseButton
- (void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    if (wmplayer.isFullscreen) {
        [self exitFullScreen];
    }else{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

///全屏按钮
- (void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wmPlayer.viewState==PlayerViewStateSmall) {
         [self enterFullScreen];
    }
}

- (void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state {
    ESDLog(@"[ESPlayerVC] FailedPlay");
}

- (void)enterFullScreen{
    if (self.wmPlayer.viewState!=PlayerViewStateSmall) {
        return;
    }
    LandscapeRightViewController *rightVC = [[LandscapeRightViewController alloc] init];
    [self presentToVC:rightVC];
}

- (void)exitFullScreen{
    if (self.wmPlayer.viewState!=PlayerViewStateFullScreen) {
              return;
          }
    self.wmPlayer.isFullscreen = NO;
    self.wmPlayer.viewState = PlayerViewStateAnimating;
    [self dismissViewControllerAnimated:YES completion:^{
       self.wmPlayer.viewState  = PlayerViewStateSmall;
    }];
}

- (void)presentToVC:(FullScreenHelperViewController *)aHelperVC{
     self.wmPlayer.viewState = PlayerViewStateAnimating;
       self.wmPlayer.beforeBounds = self.wmPlayer.bounds;
       self.wmPlayer.beforeCenter = self.wmPlayer.center;
       self.wmPlayer.parentView = self.wmPlayer.superview;
       self.wmPlayer.isFullscreen = YES;

       aHelperVC.wmPlayer = self.wmPlayer;
        aHelperVC.modalPresentationStyle = UIModalPresentationFullScreen;
       aHelperVC.transitioningDelegate = self;
       [self presentViewController:aHelperVC animated:YES completion:^{
           self.wmPlayer.viewState = PlayerViewStateFullScreen;
       }];
}


/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.viewState!=PlayerViewStateSmall) {
        return;
    }
    if (self.wmPlayer.isLockScreen){
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
        }
            break;
        case UIInterfaceOrientationPortrait:{

        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            [self presentToVC:[LandscapeLeftViewController new]];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            [self presentToVC:[LandscapeRightViewController new]];
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.frame = UIScreen.mainScreen.bounds;
     self.wmPlayer.delegate = self;
    
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)setPlayerModel:(ESPlayerModel *)playerModel {
    _playerModel = playerModel;
    _playerModel.currentPlayerModel = [WMPlayerModel new];
               
    NSURL *liveURL;
    if ([ESLocalNetworking isLANReachable]) {
        liveURL = [NSURL URLWithString:playerModel.lanM3U8Url];
//        _playerModel.currentPlayerModel.videoURL = [NSURL URLWithString:playerModel.lanM3U8Url];
    } else {
        liveURL = [NSURL URLWithString:playerModel.wanM3U8Url];
//        _playerModel.currentPlayerModel.videoURL = [NSURL URLWithString:playerModel.wanM3U8Url];
    }

    NSDictionary *header = @{@"Cookie": [NSString stringWithFormat:@"client_uuid=%@", ESBoxManager.clientUUID]};
    AVAsset*liveAsset = [AVURLAsset URLAssetWithURL:liveURL options:@{@"AVURLAssetHTTPHeaderFieldsKey" : header}];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
    _playerModel.currentPlayerModel.playerItem = playerItem;
    _playerModel.currentPlayerModel.title = playerModel.videoName;
    _playerModel.currentPlayUrl = [liveURL absoluteString];
    ESDLog(@"[ESPlayerVC] current Item url %@", liveURL);
}

#pragma mark
#pragma mark viewDidLoad
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = ESColor.darkTextColor;
    
    self.wmPlayer = [[WMPlayer alloc] initWithFrame:CGRectMake(0,
                                                               kStatusBarHeight,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height - 2 * kStatusBarHeight)];
    self.wmPlayer.delegate = self;
    self.wmPlayer.playerModel = self.playerModel.currentPlayerModel;
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer play];
    
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [ESLocalNetworking.shared addLocalNetworkStatusObserver:self];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[EnterFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[ExitFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}
- (void)dealloc{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    [self.wmPlayer resetWMPlayer];
    self.wmPlayer = nil;
    [[NSNotificationCenter defaultCenter]   removeObserver:self];
    [ESGCDWebServerManager removeAllHandler];
    ESDLog(@"ESPlayerVC dealloc");
}

- (void)localNetworkReachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    [self reloadM3U8FileByNetWorkStatus];
}

- (void)localNetworkUnreachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem {
    weakfy(self)
    ESPerformBlockAfterDelay(1, ^{
        strongfy(self)
        [self reloadM3U8FileByNetWorkStatus];
    });
}

- (void)reloadM3U8FileByNetWorkStatus {
    if (self.wmPlayer.currentTime > 0) {
        self.playerModel.currentTime = self.wmPlayer.currentTime;
    }
    NSURL *liveURL;
    if ([ESLocalNetworking isLANReachable]) {
        liveURL = [NSURL URLWithString:_playerModel.lanM3U8Url];
    } else {
        liveURL = [NSURL URLWithString:_playerModel.wanM3U8Url];
    }
    ESDLog(@"[ESPlayerVC] reloadM3U8FileByNetWorkStatus current Item url %@", liveURL);
    if ([_playerModel.currentPlayUrl isEqualToString:[liveURL absoluteString]]) {
        ESDLog(@"[ESPlayerVC] reloadM3U8FileByNetWorkStatus current Item url is equal");
        return;
    }
    _playerModel.currentPlayUrl = [liveURL absoluteString];
    NSDictionary *header = @{@"Cookie": [NSString stringWithFormat:@"client_uuid=%@", ESBoxManager.clientUUID]};
    AVAsset*liveAsset = [AVURLAsset URLAssetWithURL:liveURL options:@{@"AVURLAssetHTTPHeaderFieldsKey" : header}];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
    _playerModel.currentPlayerModel = [WMPlayerModel new];
    _playerModel.currentPlayerModel.playerItem = playerItem;
    _playerModel.currentPlayerModel.title = _playerModel.videoName;
    _playerModel.currentPlayerModel.seekTime = self.playerModel.currentTime;
    self.wmPlayer.playerModel = self.playerModel.currentPlayerModel;
    [self.wmPlayer play];
}

- (void)nextVideo:(id)sender {
    [self reloadM3U8FileByNetWorkStatus];
}

- (void)willResignActive:(id _Nullable)sender {
    self.networkChangeLock = YES;
}

- (void)didBecomeActive:(id _Nullable)sender {
//    weakfy(self)
//    ESPerformBlockAfterDelay(0.1, ^{
//        strongfy(self)
//        self.networkChangeLock = NO;
//    });
    if (self.viewLoaded && self.view.window) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

@end
