//
//  YCCollectionViewDefine.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/21.
//
//

#ifndef YCCollectionViewDefine_h
#define YCCollectionViewDefine_h

#define YCCollectionViewSingleSectionKey @"SingleSection"

#import <UIKit/UIKit.h>

typedef NSString * (^YCCollectionCellReuseIdentifierBlock)(NSIndexPath *indexPath);

typedef void (^YCCollectionViewCustomCellBlock)(NSIndexPath *indexPath, __kindof UICollectionViewCell *cell);

@protocol YCCollectionViewCellProtocol <NSObject>

- (void)reloadWithData:(id)data;

@optional
@property (nonatomic, copy) void (^actionBlock)(id action);

@property (nonatomic, copy) void (^willDisplayBlock)(void);

@end

@class YCCollectionView;
@protocol YCCollectionViewDelegate <NSObject>

@optional

- (NSInteger)collectionView:(YCCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

- (void)collectionView:(YCCollectionView *)collectionView willDisplayCell:(__kindof UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(YCCollectionView *)collectionView didDisplayCell:(__kindof UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath;

- (id)collectionView:(YCCollectionView *)collectionView objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(YCCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(YCCollectionView *)collectionView action:(id)action atIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(YCCollectionView *)collectionView layout:(__kindof UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(YCCollectionView *)collectionView layout:(__kindof UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

- (CGSize)collectionView:(YCCollectionView *)collectionView layout:(__kindof UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (UICollectionReusableView *)collectionView:(YCCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* YCCollectionViewDefine_h */
