//
//  YCCollectionView.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/21.
//
//

#import "YCCollectionViewDefine.h"
#import <UIKit/UIKit.h>

@interface YCCollectionView : UIView

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;

@property (nonatomic, strong) Class cellClass;

@property (nonatomic, strong) NSArray<Class> *cellClassArray;

@property (nonatomic, strong) NSArray<id> *section;

@property (nonatomic, strong) NSMutableDictionary<id, NSArray *> *dataSource;

@property (nonatomic, copy) YCCollectionCellReuseIdentifierBlock reuseIdentifierBlock;

@property (nonatomic, readonly) UICollectionView *collectionView;

@property (nonatomic, weak) id<YCCollectionViewDelegate> delegate;

@property (nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, copy) void (^actionBlock)(id action);

@property (nonatomic, copy) YCCollectionViewCustomCellBlock customCellBlock;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)silenceReloadAtIndexPath:(NSIndexPath *)indexPath;

- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath;

- (void)reloadData;

@end
