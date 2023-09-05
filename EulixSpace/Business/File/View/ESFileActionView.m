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
//  ESFileActionView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileActionView.h"
#import "ESFileActionCell.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>
#import <YCEasyTool/NSArray+YCTools.h>
#import <YCEasyTool/YCCollectionView.h>

@interface ESFileActionView () <YCCollectionViewDelegate>

@property (nonatomic, strong) YCCollectionView *collection;

@end

@implementation ESFileActionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.backgroundColor = ESColor.systemBackgroundColor;
    self.collection.section = @[@(1)];
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(CGRectGetWidth(self.bounds) / 5 * 2);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    NSMutableArray *cellArray = [model.data yc_mapWithBlock:^id(NSUInteger idx, NSString *data) {
        ESFormItem *item = [ESFormItem new];
        item.title = data;
        return item;
    }];
    self.collection.dataSource[@(1)] = cellArray;
    [self.collection reloadData];
}

#pragma mark - Lazy Load

- (YCCollectionView *)collection {
    if (!_collection) {
        _collection = [[YCCollectionView alloc] initWithFrame:self.bounds];
        _collection.cellClass = [ESFileActionCell class];
        _collection.flowLayout.minimumLineSpacing = 0;
        _collection.flowLayout.minimumInteritemSpacing = 0;
        _collection.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat itemWidth = width / 5;
        itemWidth = ceil(itemWidth);
        _collection.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        _collection.backgroundColor = ESColor.systemBackgroundColor;
        _collection.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collection.collectionView.showsHorizontalScrollIndicator = NO;
        _collection.delegate = self;
        [self addSubview:_collection];
    }
    return _collection;
}

- (void)collectionView:(YCCollectionView *)collectionView action:(ESFormItem *)action atIndexPath:(NSIndexPath *)indexPath;
{
    if (self.actionBlock && [action isKindOfClass:[ESFormItem class]]) {
        self.actionBlock(action.title);
    }
}
@end
