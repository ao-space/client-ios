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
//  ESBottomMoreView.h
//  EulixSpace
//
//  Created by qu on 2021/8/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESMoveCopyView.h"
#import "ESFileInfoPub.h"
#import <UIKit/UIKit.h>

@class ESBottomMoreView;

@protocol ESBottomMoreViewDelegate <NSObject>

@optional

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickDelectBtn:(UIButton *)button;

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickCompleteBtn:(UIButton *)button;

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickReNameCompleteInfo:(ESFileInfoPub *)info fileName:(NSString *)fileName category:(NSString *)category;

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickNewFolderWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category;

- (void)fileBottomToolMoreView:(ESBottomMoreView *)fileBottomToolMoreView didClickCopyCompleteWithPathName:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category;
@end

@interface ESBottomMoreView : UIView

@property (nonatomic, weak) id<ESBottomMoreViewDelegate> delegate;

@property (nonatomic, strong) ESFileInfoPub *fileInfo;

@property (nonatomic, strong) NSMutableArray *isSelectUUIDSArray;

@property (nonatomic, strong) ESMoveCopyView *movecopyView;

@property (nonatomic, strong) UIView *reNameView;

@property (nonatomic, strong) UIView *reNameCellView;
@end
