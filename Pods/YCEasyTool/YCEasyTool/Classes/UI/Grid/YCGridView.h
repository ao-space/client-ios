//
//  YCGridView.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/21.
//
//

#import "YCGridViewCell.h"
#import "YCGridViewDefine.h"
#import <UIKit/UIKit.h>

/**
 
 row title | col0 title |  col1 title | col2 title
 ---------------------------------------------------
 row0      | cell0-0    |  cell0-1    | cell0-2
 ---------------------------------------------------
 row1      | cell1-0    |  cell1-1    | cell1-2
 ---------------------------------------------------
 row2      | cell2-0    |  cell2-1    | cell2-2
 ---------------------------------------------------
 row3      | cell3-0    |  cell3-1    | cell3-2
 ---------------------------------------------------
 row4      | cell4-0    |  cell4-1    | cell4-2
 ---------------------------------------------------
 */
@interface YCGridView : UIView

+ (instancetype)gridViewWithCellClass:(Class)cellClass;

/**

 -----------------|-------------|
  title           |             | -> titleRowHeight
                  |             |
 -----------------|-------------|
                  |             |
                  |             |
  cell            |             | -> cellRowHeight
                  |             |
 -----------------|-------------|
        ↓                ↓
 titleColumnWidth  cellColumnWidth
 
 all default is `40`
 
 */

@property (nonatomic, assign) CGFloat titleRowHeight;

@property (nonatomic, assign) CGFloat cellRowHeight;

@property (nonatomic, assign) CGFloat titleColumnWidth;

@property (nonatomic, assign) CGFloat cellColumnWidth;

#pragma mark - Theme

@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, strong) UIColor *selectedCellColor;

@property (nonatomic, strong) NSDictionary *themeAttributes;

/**
You can set some specific row or column ,even one cell theme
NSString *leftBottomIndex = [NSString stringWithFormat:@"-1-%zd", lastRowIndex];
@{
   YCGridViewRowAttributeName: @{
       @(0):
           @{YCGridViewWidthAttributeName: @(58)}//the first row is set to 58.
   },
   YCGridViewRowAndColumnAttributeName: @{
       leftBottomIndex: @{
           NSFontAttributeName: [UIFont systemFontOfSize:14],
       }
   },
};
*/
@property (nonatomic, strong) NSDictionary *extraThemeAttributes; //priority is higher than `themeAttributes` up

#pragma mark - Data Source

/**
 row title | col0 title | col1 title | col2 title
 ---------------------------------------------------
 row0      | cell0-0    | cell0-1    | cell0-2
 ---------------------------------------------------
 row1      | cell1-0    | cell1-1    | cell1-2
 ---------------------------------------------------
 row2      | cell2-0    | cell2-1    | cell2-2
 ---------------------------------------------------
 row3      | cell3-0    | cell3-1    | cell3-2
 ---------------------------------------------------
 row4      | cell4-0    | cell4-1    | cell4-2
 ---------------------------------------------------
 */

@property (nonatomic, strong) NSArray<NSArray *> *data;

@property (nonatomic, readonly) NSUInteger rowCount;

@property (nonatomic, readonly) NSUInteger columnCount;

#pragma mark - Delegate

@property (nonatomic, weak) id<YCGridViewDelegate> delegate;

#pragma mark - Reload

/**
 row and column are just postion of center cells
 @param row -1 mean reload all `column` you set
 @param column -1 mean all `row` you set
 */
- (void)reloadRow:(NSInteger)row column:(NSInteger)column;

- (void)reloadData;

#pragma mark -  Selection

@property (nonatomic, assign) YCGridViewSelectionMode selectionMode; //default is `YCGridViewSelectionModeNone`

@property (nonatomic, readonly) NSInteger selectedRow; //-1 means the first row

@property (nonatomic, readonly) NSInteger selectedColumn; //-1 means the first column

@property (nonatomic, assign) BOOL bounces;

@end
