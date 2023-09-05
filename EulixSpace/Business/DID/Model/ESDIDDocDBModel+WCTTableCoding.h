//
//  ESDIDDocDBModel+WCTTableCoding.h
//  EulixSpace
//
//  Created by Tim on 2023/8/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDIDDocDBModel.h"
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESDIDDocDBModel (WCTTableCoding)  <WCTTableCoding>

WCDB_PROPERTY(preHash)
WCDB_PROPERTY(orginJson)
WCDB_PROPERTY(pId)
WCDB_PROPERTY(encryptedPriKeyBytes)
WCDB_PROPERTY(keyId)
WCDB_PROPERTY(boxKey)

@end

NS_ASSUME_NONNULL_END
