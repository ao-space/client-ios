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
//  ESWebNavigationBar.h
//  EulixSpace
//
//  Created by KongBo on 2023/3/31.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESWebNavigationBarActionType) {
    ESWebNavigationBarActionTypeBack,
    ESWebNavigationBarActionTypeClose,
};

typedef void (^ESWebNavigationBarActionBlock)(id sender, ESWebNavigationBarActionType actionType);

@interface ESWebNavigationBar : UIView

@property (nonatomic, assign) BOOL isTranslucent; //透明模式

@property (nonatomic, copy) ESWebNavigationBarActionBlock actionBlock;
@property (nonatomic, copy) dispatch_block_t styleUpdateBlock;

- (void)setTitle:(NSString *)title;
- (void)setTitleColor:(UIColor *)titleColor;
- (void)setCanGoBack:(BOOL)canGoBack;

@end

NS_ASSUME_NONNULL_END
