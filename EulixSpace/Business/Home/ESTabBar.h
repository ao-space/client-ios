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
//  ESTabBar.h
//  EulixSpace
//
//  Created by qu on 2021/9/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
//tab页面个数
typedef NS_ENUM(NSInteger, kTbaBarItemUIType) {
    kTbaBarItemUIType_Three = 3, //底部3个选项
    kTbaBarItemUIType_Five = 5,  //底部5个选项
};

@class ESTabBar;

@protocol ESTabBarDelegate <NSObject>

- (void)tabBar:(ESTabBar *)tabBar clickCenterButton:(UIButton *)sender;

@end

@interface ESTabBar : UITabBar

@property (nonatomic, weak) id<ESTabBarDelegate> tabDelegate;

@property (nonatomic, strong) NSString *centerBtnTitle;
@property (nonatomic, strong) NSString *centerBtnIcon;

+ (instancetype)instanceCustomTabBarWithType:(kTbaBarItemUIType)type;

@end
