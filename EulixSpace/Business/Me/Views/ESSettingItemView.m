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
//  ESSettingItemView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/2.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSettingItemView.h"
#import "ESFormItem.h"
#import "ESFormView.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESSettingItemView ()

@property (nonatomic, strong) UIView *contentView;

//@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) NSArray<ESFormView *> *cells;

@property (nonatomic, strong) NSArray<ESFormItem *> *data;

@end

@implementation ESSettingItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (long)getDataNum {
    return self.data.count;
}

- (void)initUI {
//    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.contentView).inset(16);
//        make.top.mas_equalTo(self.contentView).inset(10);
//        make.height.mas_equalTo(25);
//    }];

    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).inset(0);
        make.height.mas_equalTo(180);
    }];
}
- (void)reloadWithData:(NSArray *)data {
    if (![data isKindOfClass:[NSArray class]]) {
        return;
    }
    self.data = data;
    if (self.cells.count != self.data.count) {
        [self initCells];
    }
    [self.cells enumerateObjectsUsingBlock:^(ESFormView *_Nonnull cell, NSUInteger idx, BOOL *_Nonnull stop) {
        ESFormItem *item = data[idx];
        [cell reloadWithData:item];
    }];
}

- (void)initCells {
    NSMutableArray *cells = NSMutableArray.array;
    [self.cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat height = 60;
    for (NSUInteger index = 0; index < self.data.count; index++) {
        ESFormView *view = [ESFormView new];
        view.tag = index;
        [self.container addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.container);
            make.top.mas_equalTo(self.container).inset(height * index);
            make.height.mas_equalTo(height);
        }];
        weakfy(self);
        view.actionBlock = ^(id action) {
            strongfy(self);
            if (index >= self.data.count) {
                return;
            }
            if (self.actionBlock) {
                self.actionBlock(self.data[index], action);
            }
        };
        [cells addObject:view];
    }
    self.cells = cells;
    [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height * self.data.count);
    }];
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = ESColor.systemBackgroundColor;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(0, 10, 0, 10));
        }];
    }
    return _contentView;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [self.contentView addSubview:_container];
    }
    return _container;
}

//- (UILabel *)title {
//    if (!_title) {
//        _title = [[UILabel alloc] init];
//        _title.text = TEXT_COMMON_SETTING;
//        _title.textColor = ESColor.labelColor;
//        _title.textAlignment = NSTextAlignmentLeft;
//        _title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
//        [self.contentView addSubview:_title];
//    }
//    return _title;
//}

@end
