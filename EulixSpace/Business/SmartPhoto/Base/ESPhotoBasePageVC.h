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
//  ESPhotoBasePageVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/24.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseViewController.h"
#import "ESSmartPhotoListModule.h"
#import "ESAlbumModel.h"
#import "ESTimeSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPhotoBasePageVC : ESBaseViewController

@property (nonatomic, readonly) UICollectionView *listView;
@property (nonatomic, readonly) ESSmartPhotoListModule *listModule;
@property (nonatomic, strong) ESAlbumModel *albumModel;
@property (nonatomic, strong) ESTimeSlider *timeSlider;

- (void)reloadDataByType;
- (void)updateShowStyle;
- (UIColor *)customBackgroudColor;


- (void)topSelecteToolCancel;

- (void)setupPullRefresh;
- (void)removePullRefresh;

@end

NS_ASSUME_NONNULL_END
