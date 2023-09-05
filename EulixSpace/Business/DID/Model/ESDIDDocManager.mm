//
//  ESDIDDocManager.m
//  EulixSpace
//
//  Created by Tim on 2023/8/7.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDIDDocManager.h"
#import "ESRSAPair+openssl.h"
#import "ESSafeCache.h"
#import <YYModel/YYModel.h>
#import "ESBoxManager.h"
#import "ESRSA.h"
#import "ESDIDDocDecoder.h"
#import <WCDB/WCDB.h>
#import "ESDIDDocDBModel.h"
#import "ESDIDDocDBModel+WCTTableCoding.h"
#import "ESAccountInfoStorage.h"
#import "NSData+Hashing.h"
#import "ESAES.h"
#import "NSString+ESTool.h"

@interface ESDIDDocManager ()

@property (nonatomic,strong) WCTDatabase *database;

@end

@interface ESRSAPair ()

@property (nonatomic, copy) NSString *peerId;
@property (nonatomic, readonly) NSDictionary *toJson;

@end

@implementation ESDIDDocManager

+ (instancetype)shareInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (ESDIDModel *)createClientRSADID {
    ESRSAPair *pair = [ESRSAPair generateRSAKeyPairWithKeySize:2048];
    ESDIDModel *didModel = [ESDIDModel new];
    didModel.clientKey = pair;
    
    return didModel;
}

- (BOOL)saveClientKey:(ESDIDModel *)pairDID password:(NSString *)password paringBoxUUID:(NSString *)boxUUId paringType:(ESBoxType)bindType {
    NSString *clientUUID = ESBoxManager.clientUUID;
    NSString *clientDIDUUID = [NSString stringWithFormat:@"%@-%zd%@", boxUUId, bindType, clientUUID];
   
    pairDID.clientPrivateKey = [self encryPlain:pairDID.clientKey.privateKey.pem withKey:password];
    NSString *json = [pairDID yy_modelToJSONString];
    if (json.length <= 0) {
        return NO;
    }
  
    [ESSafeCache.safeCache setObject:json forKey:clientDIDUUID];
    return YES;
}

- (ESDIDModel *)getCacheClientDIDModelWithBoxUUId:(NSString *)boxUUid paringType:(ESBoxType)bindType {
    NSString *clientUUID = ESBoxManager.clientUUID;
    NSString *clientDIDUUID = [NSString stringWithFormat:@"%@-%zd%@", boxUUid, ESBoxManager.activeBox.boxType, clientUUID];
    NSString *json = [ESSafeCache.safeCache objectForKey:clientDIDUUID];
    ESDIDModel *model = [ESDIDModel yy_modelWithJSON:json];
    return model;
}

- (BOOL)cleanClientKey {
    NSString *clientUUID = ESBoxManager.clientUUID;
    NSString *clientDIDUUID = [NSString stringWithFormat:@"%@-%zd%@", ESBoxManager.activeBox.boxUUID, ESBoxManager.activeBox.boxType, clientUUID];
    NSString *cacheJson = [ESSafeCache.safeCache objectForKey:ESSafeString(clientDIDUUID)];
    if (cacheJson.length <= 0) {
        return NO;
    }

    [ESSafeCache.safeCache setObject:@"" forKey:clientDIDUUID];
    return YES;
}

- (NSString *)encryPlain:(NSString *)plain withKey:(NSString *)key {
    if (key.length < 16) {
        key = [NSString stringWithFormat:@"%@%@", key, @"1234567890qwer"]  ;
    }
    NSMutableString *ivString = NSMutableString.string;
    for (NSUInteger index = 0; index < key.length; index++) {
        [ivString appendFormat:@"%C", 0];
    }
    NSString *aseEncrypt = [plain aes_cbc_encryptWithKey:key iv:ivString];
    return aseEncrypt;
}

- (NSString *)decryptWithEncryPlain:(NSString *)aseEncrypt withKey:(NSString *)key {
    if (key.length < 16) {
        key = [NSString stringWithFormat:@"%@%@", key, @"1234567890qwer"]  ;
    }
    NSMutableString *ivString = NSMutableString.string;
    for (NSUInteger index = 0; index < key.length; index++) {
        [ivString appendFormat:@"%C", 0];
    }
    NSString *aesDecrypt = [aseEncrypt aes_cbc_decryptWithKey:key iv:ivString];
    return aesDecrypt;
}


- (ESDIDModel *)clientDIDDocKey {
    NSString *json = [ESSafeCache.safeCache objectForKey:self.clientDIDUUID];
    
    if (json.length <= 0) {
        return nil;
    }
    ESDIDModel *peerDIDCache = [ESDIDModel yy_modelWithJSON:json];
    if (peerDIDCache == nil){
        return nil;
    }
    return peerDIDCache;
}

// boxuuid + pairingType + clientUUID
//    ESBoxTypePairing, //配对的盒子
//    ESBoxTypeAuth,    //授权的盒子, 只有accesToken + {aeskey + iv }
//    ESBoxTypeMember,  //邀请的成员

- (NSString *)clientDIDUUID {
    if (ESBoxManager.activeBox == nil) {
//        ESDLog(@"[clientDIDUUID] ESBoxManager.activeBox == nil");
        return nil;
    }
    
    NSString *boxUUID = ESBoxManager.activeBox.boxUUID;
    ESBoxType type = ESBoxManager.activeBox.boxType;
    NSString *clientUUID = ESBoxManager.clientUUID;
    NSString *clientDIDUUID_ = [NSString stringWithFormat:@"%@-%zd%@", boxUUID,type,clientUUID];
//    ESDLog(@"[clientDIDUUID] %@", clientDIDUUID_);
    return clientDIDUUID_;
}

- (void)runTest {
    NSString *base64String = [self mockDIDDoc];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    jsonString = [self orginJsonString];
    
    
    NSDictionary *jsonMap = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    ESDIDDocModel *didDocModel = [ESDIDDocDecoder decodeWithJson:jsonString];
    ESVerificationBaseMethod *method = [didDocModel getVerificationMethodByType:@"device"];
    ESVerificationBaseMethod *method2 = [didDocModel getVerificationMethodByType:@"binder"];
    ESVerificationBaseMethod *method3 = [didDocModel getVerificationMethodByType:@"passwordondevice"];
    ESVerificationBaseMethod *method4 = [didDocModel getVerificationMethodByType:@"passwordonbinder"];

    NSLog(@"");
}
    
- (void)runTest2 {
    
    NSString *key = [NSString stringWithFormat:@"111111%@", @"2"]  ;
    NSString *plain = @"Hello world";
    NSMutableString *ivString = NSMutableString.string;
    for (NSUInteger index = 0; index < key.length; index++) {
        [ivString appendFormat:@"%C", 0];
    }
    NSString *aseEncrypt = [plain aes_cbc_encryptWithKey:key iv:ivString];
    NSString *aesDecrypt = [aseEncrypt aes_cbc_decryptWithKey:key iv:ivString];

    
    ESDIDModel *model = [[ESDIDDocManager shareInstance] createClientRSADID];
    [self saveClientKey:model password:key paringBoxUUID:@"12345678" paringType:ESBoxTypePairing];

    NSString *aesEncry = [self encryPlain:@"hello world" withKey:key];
    NSString *deEncry = [self decryptWithEncryPlain:aesEncry withKey:key];

    NSString *clientUUID = ESBoxManager.clientUUID;
    NSString *clientDIDUUID = [NSString stringWithFormat:@"%@-%zd%@", @"12345678", ESBoxTypePairing, clientUUID];
    
    NSString *cacheJson = [ESSafeCache.safeCache objectForKey:ESSafeString(clientDIDUUID)];
    ESDIDModel *peerDIDCache = [ESDIDModel yy_modelWithJSON:cacheJson];
    
    NSLog(@"");
}

- (NSString *)orginJsonString {
    return @"{    \"@context\": [\"https://www.w3.org/ns/did/v1\", \"https://w3id.org/security/v1\"],    \"capabilityInvocation\": [\"#multisig-0\"],    \"id\": \"did:aospace:11CuBEw6NMVZ5pbqxd5aoHFhrLNuBzsPXQo#did0\",    \"verificationMethod\": [{        \"controller\": \"#did0\",        \"id\": \"did:aospacekey:AADZpg+I98BojgvqUn0=?versionTime=2023-08-11T09:39:06Z&credentialType=device#key-0\",        \"publicKeyPem\": \"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwbOdGxi9gXyzITvBXy35\\naeHBkwjz75LXmjOzpPr1lmWySjkJYobgQ8IAZCaMvbMwXCpvkgAZ2kO1cIlekOgT\\n4SpGL1zgxasgQlsLfo/FL7vaqH0ocqXiNgTEUYFVZib6b2WiM8gBPqqpwWItI20F\\nFgJlPhmUBE/GTBqk21RPEmN552Gt5S4H2I/ZJ6596eZAocNxeyLQ1uziZxaU7Cti\\nkujtW/2ObKsIqjB+mfZMOdi9eySrrgggG0FD+nPowmY+IGoFjcRCeFzEnaLTNZTw\\n4nDD7mX5Uj+mMWPMfq8po04qaFb1/5/+FAjKwAUiogFpg9gLGppl4BoZMzLrFeJL\\nOQIDAQAB\\n-----END PUBLIC KEY-----\\n\",        \"type\": \"RsaVerificationKey2018\"    }, {        \"controller\": \"#did0\",        \"id\": \"did:aospacekey:AAB1WynbKNTT7YObZiY=?versionTime=2023-08-11T09:39:06Z&?credentialType=binder#key-1\",        \"publicKeyPem\": \"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArVclpqyEqAC036tDoqwA\\n8VVuzcisq5iEpIsjpon8076nw73smjsvW4Z8Js3xqwjv4SpQlIzOVy7TD2XadncT\\n70zHJ5fXygUKLZYPx8fkr57DrMnvjAwfeeLU8f3fwhGwUPPpymOnoklR64onLElU\\nMga2T2MZm03pNtdBZoHcVbMwB3a7wP69Niapu83gtuyIF47S0k5O5jDv2EG0E2PT\\nhXRk81jmI3JJWpZT5QnLO59PRyNglSDLEDO8u0pZmIBfZjVkCapjHUQFTI5OR5yx\\nTlpP6s6bnPiL6HYQhR/HBxY9KApwOkLHAEbK8WHNYXuh7idDsY3TDdMBu935Rfch\\nbQIDAQAB\\n-----END PUBLIC KEY-----\\n\",        \"type\": \"RsaVerificationKey2018\"    }, {        \"controller\": \"#did0\",        \"id\": \"did:aospacekey:AABx9IudbcTNgx+gzHE=?versionTime=2023-08-11T09:39:06Z&credentialType=passwordondevice#key-2\",        \"publicKeyPem\": \"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAusqbSyGsMMn2Y3H2Sy0R\\nvyCgDUY+I8JbzV1PuTH2ICHkU+R4P1XC/QF9TiGSvbNjspdNAz/B+9nh6gPXCnjQ\\ndOatVS+W2lVKMU6WBcMGIE7dDyK/ubsK+dWQEPNxyCddBPovG0LokoytjUEh5CE9\\nn4RNdSj8niqZpfG7e74O0FFGx80gR7l/ljgNIHPDjJeNdtixtFKZVlQYz4akEJET\\n73UJ2l3b1xOMUqTyJL/9SvRC/BchqasMZTiHc9rYh/5CdBbqEnNaR82XVRaZmGeu\\ngwNgxpwLlLvEP0aXfEecIkDXeJaOgLG6na0z4mMATzUus1M7QQadfPEtTfKNxzWS\\n9wIDAQAB\\n-----END PUBLIC KEY-----\\n\",        \"type\": \"RsaVerificationKey2018\"    }, {        \"controller\": \"#did0\",        \"id\": \"did:aospacekey:AACsjBSI9RBJonpabZc=?versionTime=2023-08-11T09:39:06Z&?credentialType=passwordonbinder#key-3\",        \"publicKeyPem\": \"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuKZ6AIKAFGGPVxqUlsfj\\nCLFMPyRO2bNjzS0xrze3BJ/aLuxRvmUX/vZhw6FoFVf0bbdJshYsV8Ib7m+a/vu0\\n3opza1aGL09WhTzLyCkzMsCNq9ABAydN+qTsblPCwyPqQDMXfQEqLDYo1WGz2ZKo\\ngLHIKIqYQ2qceUNN7DkHUogz/E7kK3oUsGd2F+ACfetHZE+2X5AG9W5MoWCJ6Kkf\\neWtxpoHwJdV26LkLAVZUiKFeAHxSI9kLXRbce8hwsn2VcQdttfTotXhjIV4Xp0h2\\na++YbAeccIv2XnzNr6uBddmC3KuWNEgegfBjaeb9TAdiwFbWIuuFTup1CLJPDfxk\\ndwIDAQAB\\n-----END PUBLIC KEY-----\\n\",        \"type\": \"RsaVerificationKey2018\"    }, {        \"conditionOr\": [{            \"conditionAnd\": [\"key-0\", {                \"conditionOr\": [\"key-1\", \"key-2\", \"key-3\"],                \"controller\": \"#did0\",                \"id\": \"AABoWl7BU87IPUh5fdE=\",                \"type\": \"ConditionalProof2022\"            }],            \"controller\": \"#did0\",            \"id\": \"AACXz/X+BYIjEwWKhiU=\",            \"type\": \"ConditionalProof2022\"        }, {            \"conditionAnd\": [\"key-1\", {                \"conditionOr\": [\"key-0\", \"key-2\", \"key-3\"],                \"controller\": \"#did0\",                \"id\": \"AABj79tdVe7MhoOpdP4=\",                \"type\": \"ConditionalProof2022\"            }],            \"controller\": \"#did0\",            \"id\": \"AABahjboT2CZUeAdwrM=\",            \"type\": \"ConditionalProof2022\"        }],        \"controller\": \"#did0\",        \"id\": \"AAA2ns+MgW4TwVFW/xE=#multisig-0\",        \"type\": \"ConditionalProof2022\"    }]}";
}

- (BOOL)saveOrUpdateDIDDocBase64Str:(NSString *)base64DIDDoc
               encryptedPriKeyBytes:(NSString *)encryptedPriKeyBytes
                                box:(ESBoxItem *)box {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64DIDDoc options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ESDIDDocModel *didDocModel = [ESDIDDocDecoder decodeWithJson:jsonString];

    if (didDocModel == nil) {
        // 解析失败
        return NO;
    }
    ESDIDDocDBModel *didDocDBModel = [ESDIDDocDBModel new];
    didDocDBModel.orginJson = jsonString;
    didDocDBModel.encryptedPriKeyBytes = encryptedPriKeyBytes;
    didDocDBModel.boxKey = [box uniqueKey];
    didDocDBModel.pId = didDocModel.pId;
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *SHA3_256_Json = [jsonData  SHA256Hash];
    didDocDBModel.keyId = [SHA3_256_Json base64EncodedStringWithOptions:0];
    
    return [self insertOrUpdateDIDDocDB:didDocDBModel];
    
}

- (NSString *)mockDIDDoc {
    return @"ewogICJAY29udGV4dCI6IFsKICAgICJodHRwczovL3d3dy53My5vcmcvbnMvZGlkL3YxIiwKICAgICJodHRwczovL3czaWQub3JnL3NlY3VyaXR5L3YxIgogIF0sCiAgImlkIjogImRpZDphb3NwYWNlOjExTDM0RWRSTG9IYXBBZEYzbTNYYUhxS1lkWU5XazFocWJ6IiwKICAidmVyaWZpY2F0aW9uTWV0aG9kIjogWwogICAgewogICAgICAiaWQiOiAiZGlkOmFvc3BhY2VrZXk6QUFDWXNwK2NIN3FoSm9yU3FhMD0/dmVyc2lvblRpbWU9MjAyMy0wOC0xMFQwMzoyODowOVpcdTAwMjZjcmVkZW50aWFsVHlwZT1kZXZpY2Uja2V5LTAiLAogICAgICAidHlwZSI6ICJSc2FWZXJpZmljYXRpb25LZXkyMDE4IiwKICAgICAgImNvbnRyb2xsZXIiOiAiI2RpZDAiLAogICAgICAiUHVibGljUGVtIjogIi0tLS0tQkVHSU4gUFVCTElDIEtFWS0tLS0tXG5NSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTRQcWYwSDdSWjRpaUx0em5jQzlIXG5VV2xwQkZUS01teDB0SlBYYnhmQWF0Y1MxUFBLcTJUR3Z3TW1MczlqeDFFUG1wSXo3OXBBMGVGU2JLOEs4U3gvXG5sK2VlV25sdDZobkFrcS9lMjVhOEEzS3B2Q1NRWTNtTlh1Uk9pVDBPUElKcnFHUG80SHpzYnh4ald4V0VMdFA2XG5qZG45cUs1QTd3bFF6Mnh5UFFvajYraVZRL1QzRHRUOFJ5bC96anJEZjdvZ1pyYVZiOEVDSDVUVjlhQUNrblVxXG5uYVBnVVhLQlg2WEloRFRqclFRdmhjN3diUmFZZ0pobTVaNWNhTkkxaWRGS05ya0VFVU1PVys3QlhKM0MxOFVyXG42S1IzazlDMlZVTWVZN09mU1hWcEJzNzlrYTRBWTlvMUpnTUJNcnRLakMyNkFuY29GSWhwL0tHeVJ1eTF5YlljXG52UUlEQVFBQlxuLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tXG4iCiAgICB9LAogICAgewogICAgICAiaWQiOiAiZGlkOmFvc3BhY2VrZXk6QUFBSHRNV0NQbnZ6MnE1T052dz0/dmVyc2lvblRpbWU9MjAyMy0wOC0xMFQwMzoyODowOVpcdTAwMjZjcmVkZW50aWFsVHlwZT1iaW5kZXIja2V5LTEiLAogICAgICAidHlwZSI6ICJSc2FWZXJpZmljYXRpb25LZXkyMDE4IiwKICAgICAgImNvbnRyb2xsZXIiOiAiI2RpZDAiLAogICAgICAiUHVibGljUGVtIjogIi0tLS0tQkVHSU4gUFVCTElDIEtFWS0tLS0tXG5NSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW5ONWphcDdDR2NxWVVSYkxEVlVhXG5MYzlrTXhPeUNNRXlrZndiUUtYdlRrUE1rUjl0S1ptcThFcWZHMmQyT3lVcEYxVElmcUhLN1E2ZDMzeUQwMm9PXG5CVFhadzFJamtmeHZ1MEt3RzJ6TFYwMkZUdXdaemdZYS9BYVA1aVJaRHg1R3dUay9ZRncrTlRxVDhHZjI5YS9MXG4vSXRjQ2ZzRUZMcjN6TURYVWNVOUE3ckJFeTVuY3ZhNlJMTnBYYXdlZ0ZHbENaYTUrR2FoOHZvS2w4WkdwSWd0XG5sU2MxSWRuYlBiQkNZWWxVQVRXTENMZVlsK1E5L0xzbGJwa0Z0ZFIrNE04dlU3RzFIK0FRWjVmcjJFOXFYMzZJXG56Y25jaERtS3E1YmtiV1E5R0plWktxWlRraHRDUEJ5NGNwaE04Zkh0WnVvaDFmQTNWZkYwMU40S0hUMmJVZHRwXG5Kd0lEQVFBQlxuLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tIgogICAgfSwKICAgIHsKICAgICAgImlkIjogImRpZDphb3NwYWNla2V5OkFBQUh0TVdDUG52ejJxNU9Odnc9P3ZlcnNpb25UaW1lPTIwMjMtMDgtMTBUMDM6Mjg6MDlaXHUwMDI2Y3JlZGVudGlhbFR5cGU9cGFzc3dvcmQja2V5LTIiLAogICAgICAidHlwZSI6ICJSc2FWZXJpZmljYXRpb25LZXkyMDE4IiwKICAgICAgImNvbnRyb2xsZXIiOiAiI2RpZDAiLAogICAgICAiUHVibGljUGVtIjogIi0tLS0tQkVHSU4gUFVCTElDIEtFWS0tLS0tXG5NSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW5ONWphcDdDR2NxWVVSYkxEVlVhXG5MYzlrTXhPeUNNRXlrZndiUUtYdlRrUE1rUjl0S1ptcThFcWZHMmQyT3lVcEYxVElmcUhLN1E2ZDMzeUQwMm9PXG5CVFhadzFJamtmeHZ1MEt3RzJ6TFYwMkZUdXdaemdZYS9BYVA1aVJaRHg1R3dUay9ZRncrTlRxVDhHZjI5YS9MXG4vSXRjQ2ZzRUZMcjN6TURYVWNVOUE3ckJFeTVuY3ZhNlJMTnBYYXdlZ0ZHbENaYTUrR2FoOHZvS2w4WkdwSWd0XG5sU2MxSWRuYlBiQkNZWWxVQVRXTENMZVlsK1E5L0xzbGJwa0Z0ZFIrNE04dlU3RzFIK0FRWjVmcjJFOXFYMzZJXG56Y25jaERtS3E1YmtiV1E5R0plWktxWlRraHRDUEJ5NGNwaE04Zkh0WnVvaDFmQTNWZkYwMU40S0hUMmJVZHRwXG5Kd0lEQVFBQlxuLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tIgogICAgfSwKICAgIHsKICAgICAgImlkIjogIkFBQ2pFSURJa3BZaXA5OXk0Q289IiwKICAgICAgInR5cGUiOiAiQ29uZGl0aW9uYWxQcm9vZjIwMjIiLAogICAgICAiY29udHJvbGxlciI6ICIjZGlkMCIsCiAgICAgICJjb25kaXRpb25PciI6IFsKICAgICAgICB7CiAgICAgICAgICAiaWQiOiAiQUFCOUY1Q2VMVzhtUDNGdllYMD0iLAogICAgICAgICAgInR5cGUiOiAiQ29uZGl0aW9uYWxQcm9vZjIwMjIiLAogICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICJjb25kaXRpb25BbmQiOiBbCiAgICAgICAgICAgICIja2V5LTAiLAogICAgICAgICAgICB7CiAgICAgICAgICAgICAgImlkIjogIkFBQnM2R2FFZnhKSGVpSGM2UFU9IiwKICAgICAgICAgICAgICAidHlwZSI6ICJDb25kaXRpb25hbFByb29mMjAyMiIsCiAgICAgICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICAgICAiY29uZGl0aW9uT3IiOiBbCiAgICAgICAgICAgICAgICAiI2tleS0xIiwKICAgICAgICAgICAgICAgICIja2V5LTIiCiAgICAgICAgICAgICAgXQogICAgICAgICAgICB9CiAgICAgICAgICBdCiAgICAgICAgfSwKICAgICAgICB7CiAgICAgICAgICAiaWQiOiAiQUFCN2tQRzg3QmRqUlVPbDhxbz0iLAogICAgICAgICAgInR5cGUiOiAiQ29uZGl0aW9uYWxQcm9vZjIwMjIiLAogICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICJjb25kaXRpb25BbmQiOiBbCiAgICAgICAgICAgICIja2V5LTEiLAogICAgICAgICAgICB7CiAgICAgICAgICAgICAgImlkIjogIkFBRFBxdnVldng4cDFoM0l4TUE9IiwKICAgICAgICAgICAgICAidHlwZSI6ICJDb25kaXRpb25hbFByb29mMjAyMiIsCiAgICAgICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICAgICAiY29uZGl0aW9uT3IiOiBbCiAgICAgICAgICAgICAgICAiI2tleS0wIiwKICAgICAgICAgICAgICAgICIja2V5LTIiCiAgICAgICAgICAgICAgXQogICAgICAgICAgICB9CiAgICAgICAgICBdCiAgICAgICAgfQogICAgICBdCiAgICB9CiAgXQp9";
    
    NSDictionary *didDocResponse =  @{@"didDoc":@"ewogICJAY29udGV4dCI6IFsKICAgICJodHRwczovL3d3dy53My5vcmcvbnMvZGlkL3YxIiwKICAgICJodHRwczovL3czaWQub3JnL3NlY3VyaXR5L3YxIgogIF0sCiAgImlkIjogImRpZDphb3NwYWNlOjExMk1pN0VncUZoUVNYNU1ZOWNZZzlmUXFTdTNLRjROMk5WIiwKICAidmVyaWZpY2F0aW9uTWV0aG9kIjogWwogICAgewogICAgICAiaWQiOiAiZGlkOmFvc3BhY2VrZXk6QUFEcXZxTUZDN0Q2WGpyVDl1TT0/dmVyc2lvblRpbWU9MjAyMy0wNy0yOFQwMzo0Mjo1N1pcdTAwMjZjcmVkZW50aWFsVHlwZT1kZXZpY2Uja2V5LTAiLAogICAgICAidHlwZSI6ICJSc2FWZXJpZmljYXRpb25LZXkyMDE4IiwKICAgICAgImNvbnRyb2xsZXIiOiAiI2RpZDAiLAogICAgICAiUHVibGljUGVtIjogIi0tLS0tQkVHSU4gUFVCTElDIEtFWS0tLS0tXG5NSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTQwbDhYTW9WYzZHL2lEM1ZWS09uXG5iblFRWTFhRGU1NFJDQjF2cStKSGZydkRoeFBubzB1MHM4L05yY3pXYWsrczEzd0RTOGhyV29SZmpEbU5wN1AzXG5QUEp5c0JYS2k0ZUp2eG1FT3hJY3ZZWUFwSXMySU93RUh2RDJwVnJIZGtPZFZmSEh3Z09LeWtkRUZEYkkzSDNMXG5keEZVVW9qQ09wYVBoNlY2V0pjTmsvWEFDdjJpa3h4RTNqeUlYNkw5dVlNRGZpNjJGUUpUOHlwR3pmeTVhYjRaXG4vZDNSUG53Z0N1WlFZakxDdGNNRGZsTlBUUzJoaGtBM2pqT2hWQW4rUW1OZmYvOHlRN285NEllRzR0c1FNZ1pjXG41Q0M0aXczZC80amE0bWc0M2xqeGtEMDZhZVE0YzQyd1VpNS9nQUtwZjZaTXBVRVpFaERaSVlEdzY1MllCQm9nXG5qUUlEQVFBQlxuLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tXG4iCiAgICB9LAogICAgewogICAgICAiaWQiOiAiZGlkOmFvc3BhY2VrZXk6QUFBSHRNV0NQbnZ6MnE1T052dz0/dmVyc2lvblRpbWU9MjAyMy0wNy0yOFQwMzo0Mjo1N1pcdTAwMjZjcmVkZW50aWFsVHlwZT1iaW5kZXIja2V5LTEiLAogICAgICAidHlwZSI6ICJSc2FWZXJpZmljYXRpb25LZXkyMDE4IiwKICAgICAgImNvbnRyb2xsZXIiOiAiI2RpZDAiLAogICAgICAiUHVibGljUGVtIjogIi0tLS0tQkVHSU4gUFVCTElDIEtFWS0tLS0tXG5NSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW5ONWphcDdDR2NxWVVSYkxEVlVhXG5MYzlrTXhPeUNNRXlrZndiUUtYdlRrUE1rUjl0S1ptcThFcWZHMmQyT3lVcEYxVElmcUhLN1E2ZDMzeUQwMm9PXG5CVFhadzFJamtmeHZ1MEt3RzJ6TFYwMkZUdXdaemdZYS9BYVA1aVJaRHg1R3dUay9ZRncrTlRxVDhHZjI5YS9MXG4vSXRjQ2ZzRUZMcjN6TURYVWNVOUE3ckJFeTVuY3ZhNlJMTnBYYXdlZ0ZHbENaYTUrR2FoOHZvS2w4WkdwSWd0XG5sU2MxSWRuYlBiQkNZWWxVQVRXTENMZVlsK1E5L0xzbGJwa0Z0ZFIrNE04dlU3RzFIK0FRWjVmcjJFOXFYMzZJXG56Y25jaERtS3E1YmtiV1E5R0plWktxWlRraHRDUEJ5NGNwaE04Zkh0WnVvaDFmQTNWZkYwMU40S0hUMmJVZHRwXG5Kd0lEQVFBQlxuLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tIgogICAgfSwKICAgIHsKICAgICAgImlkIjogImRpZDphb3NwYWNla2V5OkFBQUh0TVdDUG52ejJxNU9Odnc9P3ZlcnNpb25UaW1lPTIwMjMtMDctMjhUMDM6NDI6NTdaXHUwMDI2Y3JlZGVudGlhbFR5cGU9cGFzc3dvcmQja2V5LTIiLAogICAgICAidHlwZSI6ICJSc2FWZXJpZmljYXRpb25LZXkyMDE4IiwKICAgICAgImNvbnRyb2xsZXIiOiAiI2RpZDAiLAogICAgICAiUHVibGljUGVtIjogIi0tLS0tQkVHSU4gUFVCTElDIEtFWS0tLS0tXG5NSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW5ONWphcDdDR2NxWVVSYkxEVlVhXG5MYzlrTXhPeUNNRXlrZndiUUtYdlRrUE1rUjl0S1ptcThFcWZHMmQyT3lVcEYxVElmcUhLN1E2ZDMzeUQwMm9PXG5CVFhadzFJamtmeHZ1MEt3RzJ6TFYwMkZUdXdaemdZYS9BYVA1aVJaRHg1R3dUay9ZRncrTlRxVDhHZjI5YS9MXG4vSXRjQ2ZzRUZMcjN6TURYVWNVOUE3ckJFeTVuY3ZhNlJMTnBYYXdlZ0ZHbENaYTUrR2FoOHZvS2w4WkdwSWd0XG5sU2MxSWRuYlBiQkNZWWxVQVRXTENMZVlsK1E5L0xzbGJwa0Z0ZFIrNE04dlU3RzFIK0FRWjVmcjJFOXFYMzZJXG56Y25jaERtS3E1YmtiV1E5R0plWktxWlRraHRDUEJ5NGNwaE04Zkh0WnVvaDFmQTNWZkYwMU40S0hUMmJVZHRwXG5Kd0lEQVFBQlxuLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tIgogICAgfSwKICAgIHsKICAgICAgImlkIjogIkFBRHBlaTdTNXlVTGQrN3d0WGs9IiwKICAgICAgInR5cGUiOiAiQ29uZGl0aW9uYWxQcm9vZjIwMjIiLAogICAgICAiY29udHJvbGxlciI6ICIjZGlkMCIsCiAgICAgICJjb25kaXRpb25PciI6IFsKICAgICAgICB7CiAgICAgICAgICAiaWQiOiAiQUFEbUNIVnRwMERYL1Q4TEVFTT0iLAogICAgICAgICAgInR5cGUiOiAiQ29uZGl0aW9uYWxQcm9vZjIwMjIiLAogICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICJjb25kaXRpb25BbmQiOiBbCiAgICAgICAgICAgICIja2V5LTAiLAogICAgICAgICAgICB7CiAgICAgICAgICAgICAgImlkIjogIkFBRDJwc0pxTDA4VjEzbnp1QlU9IiwKICAgICAgICAgICAgICAidHlwZSI6ICJDb25kaXRpb25hbFByb29mMjAyMiIsCiAgICAgICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICAgICAiY29uZGl0aW9uT3IiOiBbCiAgICAgICAgICAgICAgICAiI2tleS0xIiwKICAgICAgICAgICAgICAgICIja2V5LTIiCiAgICAgICAgICAgICAgXQogICAgICAgICAgICB9CiAgICAgICAgICBdCiAgICAgICAgfSwKICAgICAgICB7CiAgICAgICAgICAiaWQiOiAiQUFCTU5TT1k2SitNZVJpQnN4TT0iLAogICAgICAgICAgInR5cGUiOiAiQ29uZGl0aW9uYWxQcm9vZjIwMjIiLAogICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICJjb25kaXRpb25BbmQiOiBbCiAgICAgICAgICAgICIja2V5LTEiLAogICAgICAgICAgICB7CiAgICAgICAgICAgICAgImlkIjogIkFBQmEzY3doOXVINXRDck1ZR3M9IiwKICAgICAgICAgICAgICAidHlwZSI6ICJDb25kaXRpb25hbFByb29mMjAyMiIsCiAgICAgICAgICAgICAgImNvbnRyb2xsZXIiOiAiIiwKICAgICAgICAgICAgICAiY29uZGl0aW9uT3IiOiBbCiAgICAgICAgICAgICAgICAiI2tleS0wIiwKICAgICAgICAgICAgICAgICIja2V5LTIiCiAgICAgICAgICAgICAgXQogICAgICAgICAgICB9CiAgICAgICAgICBdCiAgICAgICAgfQogICAgICBdCiAgICB9CiAgXQp9Cg=="};
    return didDocResponse[@"didDoc"];
}

- (WCTDatabase *)createDataBase {
    if (_database) {
        return _database;
    }
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //注意，此处数据库名字不要带sqlite的后缀名，恢复数据库的时候如果有这个后缀名，会造成无法恢复的情况。这是一个坑啊，大家千万要注意
    NSString *path = [NSString stringWithFormat:@"%@/chatDB_KeyList_%@",docDir, ESSafeString([ESAccountInfoStorage userUniqueKey])];
    _database = [[WCTDatabase alloc] initWithPath:path];
    BOOL result = [_database createTableAndIndexesOfName:NSStringFromClass(ESDIDDocDBModel.class)
                                                    withClass:ESDIDDocDBModel.class];
    if (result) {
        return _database;
    }
    return nil;
}

- (ESDIDDocModel * _Nullable)getDIDDocModelById:(NSString *)pId {
    if (pId.length <= 0) {
        return nil;
    }
    [self createDataBase];
    NSArray *ary = [self.database getObjectsOfClass:ESDIDDocDBModel.class
                                          fromTable:NSStringFromClass(ESDIDDocDBModel.class)
                                              where:ESDIDDocDBModel.pId == pId];
    if (ary.count > 0) {
        ESDIDDocDBModel *dbModel = ary[0];
        ESDIDDocModel *didDocModel = [ESDIDDocDecoder decodeWithJson:dbModel.orginJson];
        return didDocModel;
    }
    return nil;
}


- (ESDIDDocModel * _Nullable)getLatestDIDDocModelByBoxUId:(NSString *)boxUid {
    if (boxUid.length <= 0) {
        return nil;
    }
    [self createDataBase];

    NSArray *ary = [self.database getObjectsOfClass:ESDIDDocDBModel.class
                                          fromTable:NSStringFromClass(ESDIDDocDBModel.class)
                                              where:ESDIDDocDBModel.boxKey == boxUid];
    if (ary.count > 0) {
        ESDIDDocDBModel *dbModel = [ary lastObject];
        ESDIDDocModel *didDocModel = [ESDIDDocDecoder decodeWithJson:dbModel.orginJson];
        return didDocModel;
    }
    return nil;
}


- (ESDIDDocDBModel * _Nullable)getDIDDocById:(NSString *)pId {
    if (pId.length <= 0) {
        return nil;
    }
    [self createDataBase];

    NSArray *ary = [self.database getObjectsOfClass:ESDIDDocDBModel.class
                                          fromTable:NSStringFromClass(ESDIDDocDBModel.class)
                                              where:ESDIDDocDBModel.pId == pId];
    if (ary.count > 0) {
        return ary[0];
    }
    return nil;
}


- (BOOL)insertOrUpdateDIDDocDB:(ESDIDDocDBModel *)didDoc {
    [self createDataBase];

    BOOL result = [self.database insertOrReplaceObjects:@[didDoc] into:NSStringFromClass(ESDIDDocDBModel.class)];
    return result;
}

- (BOOL)resetDIDDocInfo {
    BOOL cleanClientKey = [self cleanClientKey];
    
    [self createDataBase];
    BOOL result = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESDIDDocDBModel.class)];
    return cleanClientKey && result;
}
@end
