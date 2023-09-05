//
//  YCTreeMenuProtocol.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/13.
//
//

#ifndef YCTreeMenuProtocol_h
#define YCTreeMenuProtocol_h

#import <UIKit/UIKit.h>

@protocol YCTreeMenuNodeProtocol <NSObject>

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) id data;

@property (nonatomic, weak) id<YCTreeMenuNodeProtocol> parent;

@property (nonatomic, strong) NSArray<id<YCTreeMenuNodeProtocol>> *children;

@property (nonatomic, assign) BOOL expanded;

@property (nonatomic, assign) NSUInteger depth;

- (CGFloat)height;

@optional

@property (nonatomic, copy) NSString *identifier;

@end

typedef void (^YCTreeMenuCellActionBlock)(void);

typedef void (^YCTreeMenuCellConfigureBlock)(UITableViewCell *cell, NSIndexPath *indexPath);

@protocol YCTreeMenuCellProtocol <NSObject>

- (void)reloadData:(id<YCTreeMenuNodeProtocol>)node;

@property (nonatomic, copy) YCTreeMenuCellActionBlock actionBlock;

@end

@class YCTreeMenuView;
@protocol YCTreeMenuViewDelegate <NSObject>

- (void)treeMenu:(YCTreeMenuView *)treeMenuView didSelectNode:(id<YCTreeMenuNodeProtocol>)node;
@optional
- (void)treeMenu:(YCTreeMenuView *)treeMenuView didChangeNode:(id<YCTreeMenuNodeProtocol>)node;

- (BOOL)treeMenu:(YCTreeMenuView *)treeMenuView shouldChangeNode:(id<YCTreeMenuNodeProtocol>)node;
@end

#endif /* YCTreeMenuProtocol_h */
