//
//  ESSpaceAccountInfoCell.h
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ESSpaceAccountKeyCellStyle_Top,
    ESSpaceAccountKeyCellStyle_Center,
    ESSpaceAccountKeyCellStyle_Bottom,
    ESSpaceAccountKeyCellStyle_Single
} ESSpaceAccountKeyCellStyle;


typedef enum : NSUInteger {
    ESSpaceAccountKeyCellActionTag_MainKey1, //服务器Key
    ESSpaceAccountKeyCellActionTag_MainKey2, //手机Key
    ESSpaceAccountKeyCellActionTag_SecondaryKey1, //安全密码Key
    ESSpaceAccountKeyCellActionTag_SecondaryKey2, //授权手机Key
    ESSpaceAccountKeyCellActionTag_SecondaryKey3 //好友Key
} ESSpaceAccountKeyTypeTag;

@interface ESSpaceAccountKeyItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSetted;
@property (nonatomic, assign) BOOL hasNextStep;
@property (nonatomic, assign) ESSpaceAccountKeyCellStyle style;
@property (nonatomic, assign) NSInteger actionTag;

@end

@interface ESSpaceAccountKeyCell : ESBaseCell

@end

NS_ASSUME_NONNULL_END
