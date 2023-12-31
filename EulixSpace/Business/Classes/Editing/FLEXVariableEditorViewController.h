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
//  FLEXVariableEditorViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 5/16/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLEXFieldEditorView;
@class FLEXArgumentInputView;

NS_ASSUME_NONNULL_BEGIN

/// An abstract screen for editing or configuring one or more variables.
/// "Target" is the target of the edit operation, and "data" is the data
/// you want to mutate or pass to the target when the action is performed.
/// The action may be something like calling a method, setting an ivar, etc.
@interface FLEXVariableEditorViewController : UIViewController {
    @protected
    id _target;
    _Nullable id _data;
    void (^_Nullable _commitHandler)(void);
}

/// @param target The target of the operation
/// @param data The data associated with the operation
/// @param onCommit An action to perform when the data changes 
+ (instancetype)target:(id)target data:(nullable id)data commitHandler:(void(^_Nullable)(void))onCommit;
/// @param target The target of the operation
/// @param data The data associated with the operation
/// @param onCommit An action to perform when the data changes 
- (id)initWithTarget:(id)target data:(nullable id)data commitHandler:(void(^_Nullable)(void))onCommit;

@property (nonatomic, readonly) id target;

/// Convenience accessor since many subclasses only use one input view
@property (nonatomic, readonly, nullable) FLEXArgumentInputView *firstInputView;

@property (nonatomic, readonly) FLEXFieldEditorView *fieldEditorView;
/// Subclasses can change the button title via the button's \c title property
@property (nonatomic, readonly) UIBarButtonItem *actionButton;

/// Subclasses should override to provide "set" functionality.
/// The commit handler--if present--is called here.
- (void)actionButtonPressed:(nullable id)sender;

/// Pushes an explorer view controller for the given object
/// or pops the current view controller.
- (void)exploreObjectOrPopViewController:(nullable id)objectOrNil;

@end

NS_ASSUME_NONNULL_END
