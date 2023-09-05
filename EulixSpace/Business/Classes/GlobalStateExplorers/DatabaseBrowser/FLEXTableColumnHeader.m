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
//  FLEXTableContentHeaderCell.m
//  FLEX
//
//  Created by Peng Tao on 15/11/26.
//  Copyright © 2015年 f. All rights reserved.
//

#import "FLEXTableColumnHeader.h"
#import "FLEXColor.h"
#import "UIFont+FLEX.h"
#import "FLEXUtility.h"

static const CGFloat kMargin = 5;
static const CGFloat kArrowWidth = 20;

@interface FLEXTableColumnHeader ()
@property (nonatomic, readonly) UILabel *arrowLabel;
@property (nonatomic, readonly) UIView *lineView;
@end

@implementation FLEXTableColumnHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = FLEXColor.secondaryBackgroundColor;
        
        _titleLabel = [UILabel new];
        _titleLabel.font = UIFont.flex_defaultTableCellFont;
        [self addSubview:_titleLabel];
        
        _arrowLabel = [UILabel new];
        _arrowLabel.font = UIFont.flex_defaultTableCellFont;
        [self addSubview:_arrowLabel];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = FLEXColor.hairlineColor;
        [self addSubview:_lineView];
        
    }
    return self;
}

- (void)setSortType:(FLEXTableColumnHeaderSortType)type {
    _sortType = type;
    
    switch (type) {
        case FLEXTableColumnHeaderSortTypeNone:
            _arrowLabel.text = @"";
            break;
        case FLEXTableColumnHeaderSortTypeAsc:
            _arrowLabel.text = @"⬆️";
            break;
        case FLEXTableColumnHeaderSortTypeDesc:
            _arrowLabel.text = @"⬇️";
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    
    self.titleLabel.frame = CGRectMake(kMargin, 0, size.width - kArrowWidth - kMargin, size.height);
    self.arrowLabel.frame = CGRectMake(size.width - kArrowWidth, 0, kArrowWidth, size.height);
    self.lineView.frame = CGRectMake(size.width - 1, 2, FLEXPointsToPixels(1), size.height - 4);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat margins = kArrowWidth - 2 * kMargin;
    size = CGSizeMake(size.width - margins, size.height);
    CGFloat width = [_titleLabel sizeThatFits:size].width + margins;
    return CGSizeMake(width, size.height);
}

@end
