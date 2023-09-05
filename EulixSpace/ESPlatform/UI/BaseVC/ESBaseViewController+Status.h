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
//  ESBaseViewController+Status.h
//  EulixSpace
//
//  Created by KongBo on 2022/8/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESBaseViewController (Status)

- (void)showLoading:(BOOL)bShow;

// empty loading
- (void)showEmptyLoading:(BOOL)show;
- (NSString *)emptyLoadingMessage;

//loading有蒙层
- (void)showLoadingWithMask:(BOOL)bShow;

- (void)showEmpty:(BOOL)bShow;
- (void)showEmptyWithImage:(UIImage *)image
       withAttributedTitle:(NSAttributedString *)title
    withAttributedSubTitle:(NSAttributedString *)subTitle;

#pragma mark - loading page
- (NSString *)titleForLoading;

#pragma mark - empty page
- (UIImage *)imageForEmpty;
- (NSString *)titleForEmpty;
- (NSString *)subtitleForEmpty;

@end

NS_ASSUME_NONNULL_END
