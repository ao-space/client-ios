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
//  FullScreenHelperViewController.m
//  PlayerDemo
//
//  Created by apple on 2020/5/18.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "FullScreenHelperViewController.h"

@interface FullScreenHelperViewController ()<WMPlayerDelegate>

@end

@implementation FullScreenHelperViewController

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.wmPlayer.delegate = self;
    self.view.backgroundColor = ESColor.darkTextColor;;
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(onDeviceOrientationChange:)
        name:UIDeviceOrientationDidChangeNotification
      object:nil];
}
///播放器CloseButton
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
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
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    
}
-(void)exitFullScreen{
    self.wmPlayer.isFullscreen = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        self.wmPlayer.viewState = PlayerViewStateSmall;
    }];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.isLockScreen){
        return;
    }
    if (self.wmPlayer.viewState!=PlayerViewStateFullScreen) {
                   return;
               }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            self.wmPlayer.viewState = PlayerViewStateAnimating;
            [self exitFullScreen];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
        }
            break;
        default:
            break;
    }
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"FullScreenHelperViewController dealloc");
}
@end

