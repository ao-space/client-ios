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
//  ESBottomToolVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ESMoreOperateSelectedBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ESMoreOperateComponentDelegate <NSObject>

@property (nonatomic, copy) dispatch_block_t actionBlock;

- (NSString *)title;
- (NSString *)iconName;
- (UIView *)menuView;
- (CGSize)viewSize;

@end

@protocol ESMoreOperateComponentSelectedDelegate <NSObject>

- (void)updateSelectedList:(NSArray *)selectedList;

@end

@protocol ESMoreOperateVCDelegate <NSObject>

- (void)showFrom:(UIViewController *)parentVC;
- (void)hidden;
- (void)cancelAction;

@end

@class ESPicModel;
@protocol ESParentVCDelegate <NSObject>

- (void)reloadDataByType;
- (void)reloadDataByTypeAndScrollToItem:(ESPicModel *)pic;
- (void)tryAsyncData;
- (void)tryAsyncDataWithRename:(NSString *)newName uuid:(NSString *)uuid;
- (void)deletePicItem:(id)itemModel index:(NSInteger)index;

- (void)finishActionAndStaySelecteStyleWithCleanSelected;
- (void)finishActionAndStaySelecteStyle;
- (void)finishActionShowNormalStyleWithCleanSelected;

@end

@interface ESMoreOperateComponentItem : UIViewController <ESMoreOperateComponentDelegate>

@property (nonatomic, copy) dispatch_block_t actionBlock;
@property (nonatomic, readonly) NSArray *selectedList;
@property (nonatomic, weak) UIViewController<ESMoreOperateVCDelegate> *moreOperateVC;
@property (nonatomic, weak) UIViewController<ESParentVCDelegate> *parentVC;
@property (nonatomic, strong) ESMoreOperateSelectedBaseModule *selectedModule;
@property (nonatomic, copy) NSString *albumId;

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC;
- (void)updateSelectedList:(NSArray *)selectedList;

@end

NS_ASSUME_NONNULL_END
