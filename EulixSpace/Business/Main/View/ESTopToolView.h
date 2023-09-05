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
//  ESTopToolView.h
//  EulixSpace
//
//  Created by qu on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ESTopToolView;

@protocol ESTopToolViewDelegate <NSObject>

@optional
- (void)topToolView:(ESTopToolView *)topToolView didScanboxTitleSelectClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didscanQRCodeClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didTransferListClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didSearchBarClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didIntoPhotoBtnClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didIntoVideoBtnClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didIntoOtherBtnClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didIntoFileBtnClickButton:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didClickDelectBtn:(UIButton *)button;

- (void)topToolView:(ESTopToolView *)topToolView didClickSearchBar:(id _Nullable *_Nullable)searchBar;

- (void)topToolView:(ESTopToolView *)topToolView didGuidance:(NSInteger)index;
@end

@interface ESTopToolView : UIView

@property (nonatomic, weak) id<ESTopToolViewDelegate> delegate;

/// 旋转图标
@property (nonatomic, strong) UIImageView *transferRotateImage;

@property NSUInteger angle;
-(void)reloadWithData;
-(void)startAnimation;

- (void)setNum:(NSInteger)num;
@end

NS_ASSUME_NONNULL_END
