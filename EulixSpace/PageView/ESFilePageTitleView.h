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
//  ESFilePageTitleView.m
//  EulixSpace
//
//  Created by qu on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESPageTitleViewDelegate <NSObject>

- (void)pageTitletView:(id)contentView selectedIndex:(NSInteger)targetIndex;

@end
@interface ESFilePageTitleView : UIView

@property (weak, nonatomic) id<ESPageTitleViewDelegate> delegate;

@property (nonatomic, assign) CGFloat titleW;

@property (nonatomic, assign) CGFloat titleH;

@property (nonatomic, assign) CGFloat fontOfSize;

@property (nonatomic, assign) CGFloat leftDistance;

@property (nonatomic, assign) CGFloat titleSpacing;

+ (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)array;

+ (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)array titleW:(CGFloat)titleW titleH:(CGFloat)titleH leftDistance:(CGFloat)leftDistance titleSpacing:(CGFloat)titleSpacing fontOfSize:(CGFloat)fontOfSize;

- (void)setTitleWithProgress:(CGFloat)progress sourceIndex:(NSInteger)index targetIndex:(NSInteger)index;

- (void)showHintPoint:(int)index show:(BOOL)show;
@end
