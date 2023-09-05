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
//  FLEXTableContentHeaderCell.h
//  FLEX
//
//  Created by Peng Tao on 15/11/26.
//  Copyright © 2015年 f. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FLEXTableColumnHeaderSortType) {
    FLEXTableColumnHeaderSortTypeNone = 0,
    FLEXTableColumnHeaderSortTypeAsc,
    FLEXTableColumnHeaderSortTypeDesc,
};

NS_INLINE FLEXTableColumnHeaderSortType FLEXNextTableColumnHeaderSortType(
    FLEXTableColumnHeaderSortType current) {
    switch (current) {
        case FLEXTableColumnHeaderSortTypeAsc:
            return FLEXTableColumnHeaderSortTypeDesc;
        case FLEXTableColumnHeaderSortTypeNone:
        case FLEXTableColumnHeaderSortTypeDesc:
            return FLEXTableColumnHeaderSortTypeAsc;
    }
    
    return FLEXTableColumnHeaderSortTypeNone;
}

@interface FLEXTableColumnHeader : UIView

@property (nonatomic) NSInteger index;
@property (nonatomic, readonly) UILabel *titleLabel;

@property (nonatomic) FLEXTableColumnHeaderSortType sortType;

@end

