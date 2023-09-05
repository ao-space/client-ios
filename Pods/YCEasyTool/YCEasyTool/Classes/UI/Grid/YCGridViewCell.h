//
//  YCGridViewCell.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/22.
//
//

#import "YCGridViewDefine.h"
#import <UIKit/UIKit.h>

@class YCGridViewItem;
@interface YCGridViewPosition : NSObject

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, assign) NSInteger column;

@property (nonatomic, weak) YCGridViewItem *item;

@end

@interface YCGridViewItem : NSObject

@property (nonatomic, assign) YCGridViewCellTableColumnPosition columnPosition;

@property (nonatomic, strong) YCGridViewPosition *position;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) id data;

@property (nonatomic, readonly) NSDictionary *themeAttributes;

@end

@interface YCGridViewLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets insets;

@end

@interface YCGridViewCell : UICollectionViewCell <YCCollectionViewCellProtocol>

/**
 Call back if there is some action
 */
@property (nonatomic, copy) void (^actionBlock)(id action);

/**
 Just after get data from `UICollectionView`
 */
@property (nonatomic, copy) void (^willDisplayBlock)(void);

/**
 You can modify it before it will display
 */
@property (nonatomic, readonly) NSMutableDictionary *attributes;

/**
 Just the data
 */
@property (nonatomic, readonly) YCGridViewItem *data;

/**
 OK, it's just a `UILabel` with extra insets property
 */
@property (nonatomic, readonly) YCGridViewLabel *content;

/**
 In case of Cell hasn't been set data.

 @param data Just the data
 */
- (void)presetData:(YCGridViewItem *)data;

/**
 You can update the label or separator after it will display

 @param attributes the very attributes you want
 */
- (void)updateContentWithAttributes:(NSDictionary *)attributes;

/**
 You can update separator after it will display

 @param attributes attributes the very attributes you want
 */
- (void)updateSeparator:(NSDictionary *)attributes;

@end
