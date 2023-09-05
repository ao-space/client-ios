//
//  ESDIDDocManager.h
//  EulixSpace
//
//  Created by Tim on 2023/8/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBoxItem.h"
#import "ESDIDModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESDIDDocManager : NSObject

+ (instancetype)shareInstance;

- (ESDIDModel *)createClientRSADID;
- (BOOL)saveClientKey:(ESDIDModel *)pairDID password:(NSString *)password paringBoxUUID:(NSString *)boxUUId paringType:(ESBoxType)bindType;

- (ESDIDModel *)getCacheClientDIDModelWithBoxUUId:(NSString *)boxUUid paringType:(ESBoxType)bindType;

//需配置完activeBox后调用
- (ESDIDModel *)clientDIDDocKey;
//需配置完activeBox后调用
// boxuuid + pairingType + clientUUID
- (NSString *)clientDIDUUID;

// mock
- (void)runTest;
- (void)runTest2;

- (BOOL)saveOrUpdateDIDDocBase64Str:(NSString *)base64DIDDoc
               encryptedPriKeyBytes:(NSString *)encryptedPriKeyBytes
                                box:(ESBoxItem *)box;


- (ESDIDDocModel * _Nullable)getDIDDocModelById:(NSString *)pId;
//boxUid box 唯一Id
- (ESDIDDocModel * _Nullable)getLatestDIDDocModelByBoxUId:(NSString *)boxUid;

- (BOOL)resetDIDDocInfo;

@end

NS_ASSUME_NONNULL_END
