//
//  YCCollectionViewController.h
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#import "YCViewController.h"
#import <UIKit/UIKit.h>

@interface YCCollectionViewController : YCViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithCollectionViewLayout:(__kindof UICollectionViewLayout *)layout;

@property (nonatomic, strong) Class cellClass;

@property (nonatomic, strong) NSArray<Class> *cellClassArray;

@property (nonatomic, strong) NSArray<id> *section;

@property (nonatomic, strong) NSMutableDictionary<id, NSArray *> *dataSource;

@property (nonatomic, readonly) UICollectionView *collectionView;

@property (nonatomic, readonly) __kindof UICollectionViewFlowLayout *flowLayout;

- (void)silenceReloadAtIndexPath:(NSIndexPath *)indexPath;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath;

- (void)reloadData;

@end
