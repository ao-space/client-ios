//
//  ESDIDDocDBModel.m
//  EulixSpace
//
//  Created by Tim on 2023/8/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDIDDocDBModel.h"
#import <WCDB/WCDB.h>

@implementation ESDIDDocDBModel

WCDB_IMPLEMENTATION(ESDIDDocDBModel)
WCDB_SYNTHESIZE(ESDIDDocDBModel, preHash)
WCDB_SYNTHESIZE(ESDIDDocDBModel, orginJson)
WCDB_SYNTHESIZE(ESDIDDocDBModel, pId)
WCDB_SYNTHESIZE(ESDIDDocDBModel, keyId)
WCDB_SYNTHESIZE(ESDIDDocDBModel, encryptedPriKeyBytes)
WCDB_SYNTHESIZE(ESDIDDocDBModel, boxKey)

WCDB_PRIMARY(ESDIDDocDBModel, keyId) //主键

@end

