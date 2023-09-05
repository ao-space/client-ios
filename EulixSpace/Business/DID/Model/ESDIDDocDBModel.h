//
//  ESDIDDocDBModel.h
//  EulixSpace
//
//  Created by Tim on 2023/8/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESDIDDocDBModel : NSObject

@property (nonatomic, copy) NSString *preHash;
@property (nonatomic, copy) NSString *orginJson;
@property (nonatomic, copy) NSString *pId;
@property (nonatomic, copy) NSString *encryptedPriKeyBytes;
@property (nonatomic, copy) NSString *keyId; // orginJson hash
@property (nonatomic, copy) NSString *boxKey;

@end

NS_ASSUME_NONNULL_END
