//
//  ESDIDDecoder.h
//  EulixSpace
//
//  Created by KongBo on 2023/7/25.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDIDModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESDIDDocDecoder : NSObject

+ (ESDIDDocModel *)decodeWithJson:(NSString *)didDocJson;

@end

NS_ASSUME_NONNULL_END
