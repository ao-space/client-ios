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
//  ESTransferListDefine.h
//  ESTransferListDefine
//
//  Created by Ye Tao on 2021/8/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESTransferListDefine_h
#define ESTransferListDefine_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESTransferHeaderAction) {
    ESTransferHeaderActionExpand = 200,
    ESTransferHeaderActionShrink,
    ESTransferHeaderActionPause,
    ESTransferHeaderActionResume,
    ESTransferHeaderActionClear,
};

typedef NS_ENUM(NSUInteger, ESTransferCellAction) {
    ESTransferCellActionPause = 100,
    ESTransferCellActionResume,
    ESTransferCellActionSelect,
    ESTransferCellActionLongPress,
};

typedef NS_ENUM(NSUInteger, ESTransferSelectionState) {
    ESTransferSelectionStateSelectedNone = 100,
    ESTransferSelectionStateSelectedAll,
    ESTransferSelectionStateSelectedPart,
};

@protocol ESTransferListSelectionProtocol <NSObject>

@property (nonatomic, assign) BOOL inSelectionMode;

- (void)selectAllItem:(BOOL)flag;

- (void)removeTaskAction;

@end

@protocol ESTransferListSelectionParentProtocol <NSObject>

@property (nonatomic, assign) BOOL inSelectionMode;

- (void)reloadSelectionState:(ESTransferSelectionState)state num:(NSUInteger)num;

@end

extern void ESTransferDeleteHistoryAlert(UIViewController *from, NSString *message, void (^callback)(UIAlertAction *action));

#endif /* ESTransferListDefine_h */
