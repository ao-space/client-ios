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
//  ESFileBottomView.h
//  EulixSpace
//
//  Created by qu on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESMoveCopyView.h"
#import "ESFileInfoPub.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ESFileBottomView;

@protocol ESFileBottomViewDelegate <NSObject>

@optional

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDownBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickShareBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDelectBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickMoreBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDetailsBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickCopyBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickMoveBtn:(UIButton *)button;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickCopyCompleteWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category;

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickReNameCompleteInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName category:(NSString *)category;

@end

@interface ESFileBottomView : UIView

@property (nonatomic, weak) id<ESFileBottomViewDelegate> delegate;

@property (nonatomic, assign) BOOL isMoreSelect;

@property (nonatomic, assign) BOOL isHaveDir;

@property (nonatomic, assign) BOOL isDir;

@property (nonatomic, strong) ESFileInfoPub *fileInfo;

@property (nonatomic, strong) NSMutableArray *isSelectUUIDSArray;

@property (nonatomic, strong) ESMoveCopyView *movecopyView;

@end

NS_ASSUME_NONNULL_END
