//
//  YCTreeMenuView.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/13.
//
//

#import "YCTreeMenuProtocol.h"
#import <UIKit/UIKit.h>

@interface YCTreeMenuView : UIView

@property (nonatomic, strong, readonly) UITableView *tableView;

- (void)reloadData:(NSArray<id<YCTreeMenuNodeProtocol>> *)nodeArray;

@property (nonatomic, strong, readonly) NSMutableArray<id<YCTreeMenuNodeProtocol>> *dataSource;

- (void)registerMenuCell:(Class)cls;

@property (nonatomic, weak) id<YCTreeMenuViewDelegate> delegate;

@property (nonatomic, copy) YCTreeMenuCellConfigureBlock cellConfigureBlock;

- (void)didChangeNode:(id<YCTreeMenuNodeProtocol>)node;

@end
