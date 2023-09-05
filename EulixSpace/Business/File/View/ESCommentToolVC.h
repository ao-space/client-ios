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
//  ESCommentToolVC.h
//  EulixSpace
//
//  Created by qu on 2021/10/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileBottomView.h"
#import "ESFileInfoPub.h"
#import <UIKit/UIKit.h>

@protocol ESCommentToolDelegate <NSObject>

@optional

- (void)completeLoadData;

- (void)onFileDelete:(NSMutableArray<ESFileInfoPub *> *)fileArray;

@end

@interface ESCommentToolVC : NSObject

@property (nonatomic, weak) UIViewController<ESCommentToolDelegate> *delegate;

@property (nonatomic, assign) BOOL alwaysShow;

@property (nonatomic, strong) UIView *specificView;

@property (nonatomic, strong) ESFileBottomView *bottomView;

@property (nonatomic, strong) UIWindow *currentWindow;

@property (nonatomic, strong) NSString *comeFromTag;
@property (nonatomic, weak) UIViewController * parentVC;

+ (UIViewController *)topViewController;

- (void)showSelectArray:(NSMutableArray<ESFileInfoPub *> *)selectedInfoSArray;

- (void)showSelectArray:(NSMutableArray<ESFileInfoPub *> *)selectedInfoSArray currentDirUUID:(NSString *)currentDirUUID;

- (void)hidden;

@end
