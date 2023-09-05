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
//  ESFilePageContentView.m
//  EulixSpace
//
//  Created by qu on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol ESPageContentViewDelegate <NSObject>

- (void)pageContentView:(id)contentView progress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex;

@end

@interface ESFilePageContentView : UIView
@property (weak, nonatomic) id<ESPageContentViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGRect vcFrame;

+ (instancetype)initWithFrame:(CGRect)frame ChildViewControllers:(NSMutableArray *)controllers parentViewController:(UIViewController *)parentVc;
- (void)setCurrentIndex:(NSInteger)index;

- (void)childViewControllers:(NSMutableArray *)controllers parentViewController:(UIViewController *)parentVc;
@end
