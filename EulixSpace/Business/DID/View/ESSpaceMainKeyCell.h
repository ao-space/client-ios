//
//  ESMainKeyCell.h
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESSpaceMainKeyItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *publicKeyHash;
@property (nonatomic, copy) NSString *cacheLocation;
@property (nonatomic, strong) NSString *lastUpdateTime;

@end

@interface ESSpaceMainKeyCell : ESBaseCell

@end

NS_ASSUME_NONNULL_END
