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
//  ESPicBottomMoreView.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESFileInfoPub.h"

NS_ASSUME_NONNULL_BEGIN

@class ESPicBottomMoreView;
@protocol ESPicBottomMoreViewDelegate <NSObject>

@optional

- (void)bottomMoreViewShowDetail:(ESPicBottomMoreView *)bottomMoreView;

- (void)bottomMoreViewDidClickCancel:(ESPicBottomMoreView *)bottomMoreView;

- (void)bottomMoreView:(ESPicBottomMoreView *)bottomMoreView reNameFileInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName;

@end


@interface ESPicBottomMoreView : UIView

@property (nonatomic, weak) id<ESPicBottomMoreViewDelegate> delegate;

@property (nonatomic, strong) ESFileInfoPub *fileInfo;

@property (nonatomic, strong) NSMutableArray *isSelectUUIDSArray;

@property (nonatomic, strong) UIView *reNameView;
@property (nonatomic, strong) UIView *reNameCellView;
@property (nonatomic, strong) UIView *mCopyCellView;
@property (nonatomic, strong) UIView *moveCellView;

@end

NS_ASSUME_NONNULL_END

