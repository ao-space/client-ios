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
//  ESPlayerBottomToolView.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPlayerBottomToolView.h"
#import "UIButton+ESTouchArea.h"
#import "ESPicPlayer.h"

@interface ESPlayerBottomToolView ()

@property (nonatomic, strong) UIButton *playBtn;

@end

static  CGFloat const kBottomViewH = 50.0f;
static  CGFloat const kTitleViewW = 280.0f;
static  CGFloat const kSearchViewH = 46.0f;
static  CGFloat const kESViewDefaultMargin = 26.0f;

@implementation ESPlayerBottomToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)showFrom:(UIView *)view {
    if (self.superview) {
        return;
    }
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
}

- (void)hidden {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)setupViews {
    self.frame = CGRectMake(0, ScreenHeight - kBottomHeight -kBottomViewH, ScreenWidth, kBottomHeight + kBottomViewH);
    self.backgroundColor = ESColor.systemBackgroundColor;
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 44) / 2, 10.0f , 44, 44)];
    [playBtn setImage:[UIImage imageNamed:@"player_stop"] forState:UIControlStateNormal];
    [playBtn setTitle:nil forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    self.playBtn = playBtn;
    [self.playBtn setEnlargeEdge:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self addSubview:playBtn];
}

- (void)updatePlayBtWithPlayerStatus {
    if (!self.player) {
        return;
    }
    if (self.player.playerStatus == ESPlayerStatusPlaying) {
        [self.playBtn setImage:[UIImage imageNamed:@"player_stop"] forState:UIControlStateNormal];
        return;
    }
    
    if (self.player.playerStatus == ESPlayerStatusStop ||
        self.player.playerStatus == ESPlayerStatusFinish ||
        self.player.playerStatus == ESPlayerStatusPause) {
        [self.playBtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        return;
    }
}

- (void)playAction {
    ESPlayerActionType actionType = ESPlayerActionTypeUnkown;
    if (self.player.playerStatus == ESPlayerStatusPlaying) {
        actionType = ESPlayerActionTypePause;
    } else if (self.player.playerStatus == ESPlayerStatusPause) {
        actionType = ESPlayerActionTypeResume;
    }
    
    if (self.actionBlock) {
        self.actionBlock(actionType);
    }
}

@end
