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
//  ESFormItem.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/14.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YCBase/YCItemDefine.h>

@interface ESFormItem : NSObject <YCItemProtocol>

#pragma mark - YCItemProtocol

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, copy) NSString *identifier;

#pragma mark - Index

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign) NSInteger row;

#pragma mark - UI

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, strong) NSString *iconURL;

@property (nonatomic, strong) UIImage *arrowImage;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) BOOL selection;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *appId;


@property (nonatomic, assign) BOOL isCopyMove;

@property (nonatomic, assign) BOOL showSwitch;

@property (nonatomic, assign) NSInteger badge;

#pragma mark - Custom UI

@property (nonatomic, assign) BOOL hideLine; ////默认是false

@property (nonatomic, assign) NSInteger lineHeight; //默认是1

@property (nonatomic, copy) NSString *category;

#pragma mark - Custom UI

@property (nonatomic, assign) NSInteger lineMargin; //默认是26

@property (nonatomic, assign) NSInteger arrowRight; //默认是26

@property (nonatomic, assign) NSInteger arrowLeft; //默认是10

@property (nonatomic, assign) NSInteger arrowWidth; //默认是16

@property (nonatomic, assign) NSInteger arrowHeight; //默认是16

@property (nonatomic, assign) BOOL dot; ////默认是false

@property (nonatomic, strong) UIColor *contentColor;

#pragma mark - Data

@property (nonatomic, strong) id data;

@property (nonatomic, copy) NSString *version;

@property (nonatomic, copy) NSString *installedAppletVersion;

@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) NSString *packageId;

@property (nonatomic, assign) BOOL isNewVersion;

@property (nonatomic, copy) NSString *deployMode;

@property (nonatomic, copy) NSString *containerWebUrl;

@property (nonatomic, strong) NSNumber *uninstallType;


@property (nonatomic, copy) NSString *searchKey;

@property (nonatomic, copy) NSString *webUrl;

@property (nonatomic, assign) BOOL isHiddenArrowBtn;

@property (nonatomic, assign) NSInteger state;

@property (nonatomic, copy) NSString *source;

@property (nonatomic, copy) NSString *installSource;

@end
