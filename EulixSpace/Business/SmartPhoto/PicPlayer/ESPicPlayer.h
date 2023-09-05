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
//  ESPicPlayer.h
//  EulixSpace
//
//  Created by KongBo on 2022/11/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseViewController.h"

typedef NS_ENUM(NSUInteger, ESPlayerStatus) {
    ESPlayerStatusUnStart,
    ESPlayerStatusPlaying,
    ESPlayerStatusPause,
    ESPlayerStatusStop,
    ESPlayerStatusFinish,
};

NS_ASSUME_NONNULL_BEGIN
@class ESPicModel;

@interface ESPicPlayer : ESBaseViewController

@property (nonatomic, copy) NSArray<ESPicModel *> *picList;
@property (nonatomic, assign) ESPlayerStatus playerStatus;

- (void)resetPlayList:(NSArray<ESPicModel *> *)picList;

- (void)updateTitleText:(NSString *)title message:(NSString *)messageText;

- (BOOL)isPicReady;

- (void)startPlay;
- (void)pausePlay;

//over write
- (NSString *)getUrlPathWith:(ESPicModel *)pic;

@end

NS_ASSUME_NONNULL_END
