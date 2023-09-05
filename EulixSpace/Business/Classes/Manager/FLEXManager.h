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
//  FLEXManager.h
//  Flipboard
//
//  Created by Ryan Olson on 4/4/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXExplorerToolbar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLEXManager : NSObject

@property (nonatomic, readonly, class) FLEXManager *sharedManager;

@property (nonatomic, readonly) BOOL isHidden;
@property (nonatomic, readonly) FLEXExplorerToolbar *toolbar;

- (void)showExplorer;
- (void)hideExplorer;
- (void)toggleExplorer;

/// Programmatically dismiss anything presented by FLEX, leaving only the toolbar visible.
- (void)dismissAnyPresentedTools:(void (^_Nullable)(void))completion;
/// Programmatically present something on top of the FLEX toolbar.
/// This method will automatically dismiss any currently presented tool,
/// so you do not need to call \c dismissAnyPresentedTools: yourself.
- (void)presentTool:(UINavigationController *(^)(void))viewControllerFuture
         completion:(void (^_Nullable)(void))completion;

/// Use this to present the explorer in a specific scene when the one
/// it chooses by default is not the one you wish to display it in.
- (void)showExplorerFromScene:(UIWindowScene *)scene API_AVAILABLE(ios(13.0));

#pragma mark - Misc

/// Default database password is @c nil by default.
/// Set this to the password you want the databases to open with.
@property (copy, nonatomic) NSString *defaultSqliteDatabasePassword;

@end


typedef UIViewController * _Nullable(^FLEXCustomContentViewerFuture)(NSData *data);

NS_ASSUME_NONNULL_END
