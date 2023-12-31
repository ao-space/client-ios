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
//  FLEXDBQueryRowCell.m
//  FLEX
//
//  Created by Peng Tao on 15/11/24.
//  Copyright © 2015年 f. All rights reserved.
//

#import "FLEXDBQueryRowCell.h"
#import "FLEXMultiColumnTableView.h"
#import "NSArray+FLEX.h"
#import "UIFont+FLEX.h"
#import "FLEXColor.h"

NSString * const kFLEXDBQueryRowCellReuse = @"kFLEXDBQueryRowCellReuse";

@interface FLEXDBQueryRowCell ()
@property (nonatomic) NSInteger columnCount;
@property (nonatomic) NSArray<UILabel *> *labels;
@end

@implementation FLEXDBQueryRowCell

- (void)setData:(NSArray *)data {
    _data = data;
    self.columnCount = data.count;
    
    [self.labels flex_forEach:^(UILabel *label, NSUInteger idx) {
        id content = self.data[idx];
        
        if ([content isKindOfClass:[NSString class]]) {
            label.text = content;
        } else if (content == NSNull.null) {
            label.text = @"<null>";
            label.textColor = FLEXColor.deemphasizedTextColor;
        } else {
            label.text = [content description];
        }
    }];
}

- (void)setColumnCount:(NSInteger)columnCount {
    if (columnCount != _columnCount) {
        _columnCount = columnCount;
        
        // Remove existing labels
        for (UILabel *l in self.labels) {
            [l removeFromSuperview];
        }
        
        // Create new labels
        self.labels = [NSArray flex_forEachUpTo:columnCount map:^id(NSUInteger i) {
            UILabel *label = [UILabel new];
            label.font = UIFont.flex_defaultTableCellFont;
            label.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:label];
            
            return label;
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = self.contentView.frame.size.height;
    
    [self.labels flex_forEach:^(UILabel *label, NSUInteger i) {
        CGFloat width = [self.layoutSource dbQueryRowCell:self widthForColumn:i];
        CGFloat minX = [self.layoutSource dbQueryRowCell:self minXForColumn:i];
        label.frame = CGRectMake(minX + 5, 0, (width - 10), height);
    }];
}

@end
