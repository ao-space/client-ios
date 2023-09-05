//
//  ESDIDModel.h
//  EulixSpace
//
//  Created by KongBo on 2023/7/24.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRSAPair.h"
#import "ESBoxItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESDIDModel : NSObject

@property (nonatomic, copy) NSData *boxVersion;
@property (nonatomic, readonly) NSString *boxPublicKey;
@property (nonatomic, strong) ESRSAPair *boxKey;

@property (nonatomic, copy) NSData *clientVersion;
@property (nonatomic, readonly) NSString *clientPublicKey;
@property (nonatomic, copy) NSString *clientPrivateKey; // 加密
@property (nonatomic, strong) ESRSAPair *clientKey;


- (NSString *)boxIdString;
- (NSString *)boxDid;

- (NSString *)clientIdString;
- (NSString *)clientDid;

@end


@interface ESVerificationBaseMethod : NSObject

@property (nonatomic, copy) NSString *pId;   // id
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *controller;

//id取值hash部分
- (NSString *)keyHash;
- (NSString *)keyType;
- (NSString *)keyTime;
//标准化时间
- (NSString *)keyTimeNormal;

- (NSString *)keyNumber;

@end

@interface ESVerificationMethodPublicKeyMultibase : ESVerificationBaseMethod

@property (nonatomic, copy) NSString *publicKeyMultibase;

@end

@interface ESVerificationMethodPublicKeyPem : ESVerificationBaseMethod

@property (nonatomic, copy) NSString *publicKeyPem;

@end

@interface ESVerificationMethodConditionOr : ESVerificationBaseMethod

@property (nonatomic, copy) NSArray *conditionOr;

@end

@interface ESVerificationMethodConditionAdd : ESVerificationBaseMethod

@property (nonatomic, copy) NSArray *conditionAnd;

@end

@interface ESDIDDocModel : NSObject

@property (nonatomic, copy) NSString *orginJson;

@property (nonatomic, copy) NSArray<NSString *> *context; //@context
@property (nonatomic, copy) NSString *pId;   // id

@property (nonatomic, copy) NSArray<ESVerificationBaseMethod *> *verificationMethod;
@property (nonatomic, copy) NSArray<NSString *> *capabilityInvocation;
@property (nonatomic, copy) NSArray<NSString *> *authentication;
@property (nonatomic, copy) NSArray<NSString *> *assertionMethod;
@property (nonatomic, copy) NSArray<NSString *> *keyAgreement;
@property (nonatomic, copy) NSArray<NSString *> *capabilityDelegation;

- (NSString *)pIdHash;

//
- (ESVerificationBaseMethod *)getVerificationMethodByType:(NSString *)type;

@end


NS_ASSUME_NONNULL_END
