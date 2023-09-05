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
//  ESAlertViewController.h
//  EulixSpace
//
//  Created by KongBo on 2022/6/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESAlertActionOrientationStyle) {
    ESAlertActionOrientationStyleHorizontal,
    ESAlertActionOrientationStyleVertical,
};

@class ESAlertAction;
@protocol ESAlertVCCustomProtocol <NSObject>

@optional

- (UIView * _Nullable)headerView;
- (CGFloat)headerViewHeight;

- (UIView * _Nullable)customContentView;
- (CGFloat)contentViewWidth;

- (UIEdgeInsets)contentViewContentInsets;
- (UIEdgeInsets)actionViewContentInsets;

- (void)preAddAction;

@end

@interface ESAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^ __nullable)(ESAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIImage *backgroudImage;
@property (nonatomic, strong) UIColor *backgroudColor;

@end

@interface ESAlertViewController : UIViewController

@property (nonatomic, assign) ESAlertActionOrientationStyle  actionOrientationStyle;

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
- (void)addAction:(ESAlertAction *)action;

- (void)show;

@end

NS_ASSUME_NONNULL_END
