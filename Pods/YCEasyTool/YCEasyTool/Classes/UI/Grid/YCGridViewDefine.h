//
//  YCGridViewDefine.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/6/21.
//
//

#ifndef YCGridViewDefine_h
#define YCGridViewDefine_h

#import "YCCollectionViewDefine.h"

#pragma mark - Const

static const NSInteger YCGridViewNoSelection = NSNotFound;

static const NSInteger YCGridViewTitleColumnIndex = -1; //the first column

static const NSInteger YCGridViewTitleRowIndex = -1; //the first row

#pragma mark - Attribute

/**
 
 
                  |             |
  LeftTitle       |  RightTitle |
                  |             | -> title
 -----------------|-------------|
                  |             |
                  |             | -> cell
  LeftCell        |  RightCell  |
                  |             |
 -----------------|-------------|
 
 only NSFontAttributeName & NSForegroundColorAttributeName is for the text
 
 */

static NSString *const YCGridViewLeftTitleAttributeName = @"YCGridViewLeftTitle";

static NSString *const YCGridViewRightTitleAttributeName = @"YCGridViewRightTitle";

static NSString *const YCGridViewLeftCellAttributeName = @"YCGridViewLeftCelle";

static NSString *const YCGridViewRightCellAttributeName = @"YCGridViewRightCell";

static NSString *const YCGridViewRowAttributeName = @" YCGridViewRow";

static NSString *const YCGridViewColumnAttributeName = @"YCGridViewColumn";

static NSString *const YCGridViewRowAndColumnAttributeName = @"YCGridViewRowAndColumn";

#pragma mark - Possible Attribute

static NSString *const YCGridViewBackgroundColorAttributeName = @"YCGridViewBackgroundColor";

static NSString *const YCGridViewSeparatorStyleAttributeName = @"YCGridViewSeparatorStyle";

static NSString *const YCGridViewSeparatorColorAttributeName = @"YCGridViewSeparatorColor";

static NSString *const YCGridViewSeparatorWidthAttributeName = @"YCGridViewSeparatorWidth";

static NSString *const YCGridViewWidthAttributeName = @"YCGridViewWidth";

#pragma mark - Block & Protocol

@class YCGridViewCell;
typedef void (^YCGridViewCustomCellBlock)(NSInteger row, NSInteger column, YCGridViewCell *cell);

@class YCGridView;
@protocol YCGridViewDelegate <NSObject>

@optional
- (void)gridView:(YCGridView *)gridView didSelectRow:(NSInteger)row column:(NSInteger)column data:(id)data;

- (void)gridView:(YCGridView *)gridView willDisplayCell:(YCGridViewCell *)cell row:(NSInteger)row column:(NSInteger)column;

- (void)gridView:(YCGridView *)gridView didDisplayCell:(YCGridViewCell *)cell row:(NSInteger)row column:(NSInteger)column;

@end

typedef NS_OPTIONS(NSUInteger, YCGridViewSelectionMode) {
    YCGridViewSelectionModeNone = 0,
    /**
     when touch `cell` in cell area, highlight the column
     
     row title | col0 title |  col1 title | col2 title
     ---------------------------------------------------
     row0      | cell0-0    |  cell0-1    | cell0-2
     ---------------------------------------------------
     row1      | cell1-0    |  cell1-1    | cell1-2
     ---------------------------------------------------
     row2      | cell2-0    |██cell2-1████| cell2-2
     ---------------------------------------------------
     row3      | cell3-0    |  cell3-1    | cell3-2
     ---------------------------------------------------
     row4      | cell4-0    |  cell4-1    | cell4-2
     ---------------------------------------------------
     */
    YCGridViewSelectionModeCell = 1 << 0,
    /**
     when touch `cell` in cell area, highlight the column
     
     row title | col0 title |  col1 title | col2 title
     ---------------------------------------------------
     row0      | cell0-0    |  cell0-1    | cell0-2
     ---------------------------------------------------
     row1      | cell1-0    |  cell1-1    | cell1-2
     ---------------------------------------------------
     row2██████|█cell2-0████|██cell2-1████|█cell2-2█████
     ---------------------------------------------------
     row3      | cell3-0    |  cell3-1    | cell3-2
     ---------------------------------------------------
     row4      | cell4-0    |  cell4-1    | cell4-2
     ---------------------------------------------------
     */
    YCGridViewSelectionModeRow = 1 << 1,
    /**
     when touch `cell` in cell area, highlight the column
     
     row title | col0 title |██col1█title█| col2 title
     ---------------------------------------------------
     row0      | cell0-0    |██cell0-1████| cell0-2
     ---------------------------------------------------
     row1      | cell1-0    |██cell1-1████| cell1-2
     ---------------------------------------------------
     row2      | cell2-0    |██cell2-1████| cell2-2
     ---------------------------------------------------
     row3      | cell3-0    |██cell3-1████| cell3-2
     ---------------------------------------------------
     row4      | cell4-0    |██cell4-1████| cell4-2
     ---------------------------------------------------
     */
    YCGridViewSelectionModeColumn = 1 << 2,
};

typedef NS_OPTIONS(NSUInteger, YCGridViewCellSeparatorStyle) {
    YCGridViewCellSeparatorStyleNone = 0,
    YCGridViewCellSeparatorStyleLineBottom = 1 << 0,
    YCGridViewCellSeparatorStyleLineRight = 1 << 1,
    YCGridViewCellSeparatorStyleLineLeft = 1 << 2,
    YCGridViewCellSeparatorStyleLineTop = 1 << 3,
    YCGridViewCellSeparatorStyleLineAll = YCGridViewCellSeparatorStyleLineBottom | YCGridViewCellSeparatorStyleLineRight | YCGridViewCellSeparatorStyleLineLeft | YCGridViewCellSeparatorStyleLineTop,
};

typedef NS_ENUM(NSUInteger, YCGridViewCellTableColumnPosition) {
    YCGridViewCellTableColumnPositionMiddle,
    YCGridViewCellTableColumnPositionFirst, //will add a extra width to the column 0
    YCGridViewCellTableColumnPositionLast,
};

static const CGFloat kYCGridViewExtraOffset = 200;

#endif /* YCGridViewDefine_h */
