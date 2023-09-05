//
//  ESDIDDecoder.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/25.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDIDDocDecoder.h"
#import <YYModel.h>
#import "ESDIDModel.h"

@implementation ESDIDDocDecoder

+ (ESDIDDocModel *)decodeWithJson:(NSString *)didDocJson {
    NSData *didDocJsonData = [didDocJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *docMap = [NSJSONSerialization JSONObjectWithData:didDocJsonData options:kNilOptions error:nil];

    if (docMap.count <= 0) {
        return nil;
    }
    
    ESDIDDocModel *model = [ESDIDDocModel new];
    model.orginJson = didDocJson;
    
    if ([docMap.allKeys containsObject:@"@context"] && [docMap[@"@context"] isKindOfClass:[NSArray class]]) {
        model.context = docMap[@"@context"];
    }
    
    if ([docMap.allKeys containsObject:@"id"] && [docMap[@"id"] isKindOfClass:[NSString class]]) {
        model.pId = docMap[@"id"];
    }
    
    if ([docMap.allKeys containsObject:@"capabilityInvocation"] && [docMap[@"capabilityInvocation"] isKindOfClass:[NSArray class]]) {
        model.capabilityInvocation = docMap[@"capabilityInvocation"];
    }
    
    if ([docMap.allKeys containsObject:@"authentication"] && [docMap[@"authentication"] isKindOfClass:[NSArray class]]) {
        model.authentication = docMap[@"authentication"];
    }
    
    if ([docMap.allKeys containsObject:@"assertionMethod"] && [docMap[@"assertionMethod"] isKindOfClass:[NSArray class]]) {
        model.assertionMethod = docMap[@"assertionMethod"];
    }
    
    if ([docMap.allKeys containsObject:@"keyAgreement"] && [docMap[@"keyAgreement"] isKindOfClass:[NSArray class]]) {
        model.keyAgreement = docMap[@"keyAgreement"];
    }
    
    if ([docMap.allKeys containsObject:@"capabilityDelegation"] && [docMap[@"capabilityDelegation"] isKindOfClass:[NSArray class]]) {
        model.capabilityDelegation = docMap[@"capabilityDelegation"];
    }
    
    if ([docMap.allKeys containsObject:@"verificationMethod"] && [docMap[@"verificationMethod"] isKindOfClass:[NSArray class]]) {
        NSArray *verificationMethodList = docMap[@"verificationMethod"];
        NSMutableArray *methodList = [NSMutableArray array];
        [verificationMethodList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull methodMap, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([methodMap isKindOfClass:[NSDictionary class]] && [methodMap.allKeys containsObject:@"type"]) {
                NSString *type = methodMap[@"type"];
                if ([type isEqualToString:@"Ed25519VerificationKey2020"]) {
                    ESVerificationBaseMethod *verificationMethod = [ESVerificationMethodPublicKeyMultibase yy_modelWithDictionary:methodMap];
                    if (verificationMethod == nil) {
                        verificationMethod = [ESVerificationMethodPublicKeyPem yy_modelWithDictionary:methodMap];
                    }
                    
                    if (verificationMethod != nil) {
                        [methodList addObject:verificationMethod];
                    } else {
                        ESDLog(@"[verificationMethod] transfer error orgin info: %@", methodMap);
                    }
                    return;
                }
                
                if ([type isEqualToString:@"RsaVerificationKey2018"]) {
                    ESVerificationBaseMethod *verificationMethod = [ESVerificationMethodPublicKeyPem yy_modelWithDictionary:methodMap];
                    NSString *keyHash = [verificationMethod keyHash];
                    NSString *time = [verificationMethod keyTime];
                    NSString *type = [verificationMethod keyType];
                    NSString *keyNumber = [verificationMethod keyNumber];
                    
                    if (verificationMethod != nil) {
                        [methodList addObject:verificationMethod];
                    } else {
                        ESDLog(@"[verificationMethod] transfer error orgin info: %@", methodMap);
                    }
                    return;
                }
                
                if ([type isEqualToString:@"ConditionalProof2022"]) {
                    if ([methodMap.allKeys containsObject:@"conditionOr"]) {
                        ESVerificationBaseMethod *verificationMethod = [ESVerificationMethodConditionOr yy_modelWithDictionary:methodMap];
                        NSArray *deepCondition = [(ESVerificationMethodConditionOr *)verificationMethod conditionOr];
                       ((ESVerificationMethodConditionOr *)verificationMethod).conditionOr = [self transferDeepCondition:deepCondition preMethod:verificationMethod];
                        [methodList addObject:verificationMethod];
                    }
                    
                   else if ([methodMap.allKeys containsObject:@"conditionAnd"]) {
                        ESVerificationBaseMethod *verificationMethod = [ESVerificationMethodConditionAdd yy_modelWithDictionary:methodMap];
                        NSArray *deepCondition = [(ESVerificationMethodConditionAdd *)verificationMethod conditionAnd];
                       [self transferDeepCondition:deepCondition preMethod:verificationMethod];

                        [methodList addObject:verificationMethod];
                    }

                }
            }
        }];
        model.verificationMethod = methodList;
    }
    return model;
}

+ (NSArray *)transferDeepCondition:(NSArray *)conditions preMethod:(ESVerificationBaseMethod *)method {
    if (![conditions isKindOfClass:[NSArray class]]) {
        return @[];
    }
    
    NSMutableArray *arry = [NSMutableArray array];
    [conditions enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull map, NSUInteger idx, BOOL * _Nonnull stop) {
//         map Dictionary  or String
        if ([map isKindOfClass:[NSDictionary class]]) {
            if ([map.allKeys containsObject:@"conditionOr"]) {
                ESVerificationBaseMethod *verificationMethod = [ESVerificationMethodConditionOr yy_modelWithDictionary:map];
                if (verificationMethod) {
                    NSArray *deepCondition = [(ESVerificationMethodConditionOr *)verificationMethod conditionOr];
                   ((ESVerificationMethodConditionOr *)verificationMethod).conditionOr = [self transferDeepCondition:deepCondition preMethod:verificationMethod];
                    [arry addObject:verificationMethod];
                }
            }
            
           else if ([map.allKeys containsObject:@"conditionAnd"]) {
                ESVerificationBaseMethod *verificationMethod = [ESVerificationMethodConditionAdd yy_modelWithDictionary:map];
               if (verificationMethod) {
                   NSArray *deepCondition = [(ESVerificationMethodConditionAdd *)verificationMethod conditionAnd];
                  ((ESVerificationMethodConditionAdd *)verificationMethod).conditionAnd = [self transferDeepCondition:deepCondition preMethod:verificationMethod];
                   [arry addObject:verificationMethod];
               }
            }
        } else {
                [arry addObject:map];
            }
        }];
    return arry;
}
    
    
- (NSString *)demoJson {
    return @"{\"@context\":[\"https://www.w3.org/ns/did/v1\",\"https://w3id.org/security/v1\"],\"id\":\"did:aospace:11Aw2mJ7RwVyMCuGM493JrL9mu5Eh2kwzh9#did0\",\"verificationMethod\":[{\"id\":\"did:aospacekey:AABudy/cL721qhHezvw=#key-0\",\"type\":\"Ed25519VerificationKey2020\",\"controller\":\"#did0\",\"publicKeyMultibase\":\"uZOIa8/axvB2/n76mUD7B1ZOmXYcRjLjcaNPewUxPkhvIAYr1VlKfLbb0FgrKCKMIO/vpR9ia/nGrZECOHPe/w==\"},{\"id\":\"did:aospacekey:AAB4szY08e2ONvd6yxI=#key-1\",\"type\":\"RsaVerificationKey2018\",\"controller\":\"#did0\",\"publicKeyMultibase\":\"-----BEGIN RSA PUBLIC KEY-----\\nMIIBCgKCAQEAobVv58Ico6H3CAo3xcMlZdd/bk+xF3KtyPHL5URnMmXaXOMbOqKn\\nYi2p69Sl1JihiHzRUYCSNaQsLL936vBSB7WwUXZ80qDmXcwkJJySj4W4xiU2fo9A\\nkateGkaxpWneBhIF5mHO1yNgtwrW5n6Lwyn5RNf8Tl7FtpR/vKPOTXpbWp5qRjHz\\nLQcaxxKl27P15WDajaYNHkSYxMAbHT0syutk5ttNHQLTtlp4+6i02smsNWY6O2UA\\ndxzB2ns6IYoGOANuKNcJisemdG85z9OCdS0nHRqN8CJ63EweCpCXmHz698b/ninw\\nsz4PyipI4dszrbcn46GvIQcSRvjGSUBkhwIDAQAB\\n-----END RSA PUBLIC KEY-----\\n\"},{\"id\":\"did:aospacekey:AADI3hST0FE3s2rcMX4=#multisig-0\",\"controller\":\"#did0\",\"type\":\"ConditionalProof2022\",\"conditionAnd\":[\"#key-0\",\"#key-1\"]}]}";
}

@end
