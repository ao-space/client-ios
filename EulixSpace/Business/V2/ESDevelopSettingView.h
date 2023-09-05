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
//  ESFileSortVC.h
//  EulixSpace
//
//  Created by qu on 2021/11/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESSortClass) {
    ESSortClassName,
    ESSortClassTime,
    ESSortClassType
};

@class ESDevelopSettingView;

@protocol ESDevelopSettingViewDelegate <NSObject>

@optional

- (void)fileSortView:(ESDevelopSettingView *_Nullable)fileSortView didClicCancelBtn:(UIButton *_Nullable)button;

- (void)fileSortView:(ESDevelopSettingView *_Nullable)fileSortView didSortType:(ESSortClass)type isUpSort:(BOOL)isUpSort;

- (void)fileSortView:(ESDevelopSettingView *_Nullable)fileSortView moreTag:(NSString *_Nonnull)moreTag;

@end
NS_ASSUME_NONNULL_BEGIN

@interface ESDevelopSettingView : UIView

@property (nonatomic, copy) void (^actionPostBlock)(id action,int tag);

@property (nonatomic, copy) void (^actionHttpBlock)(id action,int tag);

@property (nonatomic, weak) id<ESDevelopSettingViewDelegate> delegate;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *value;

@end

NS_ASSUME_NONNULL_END
