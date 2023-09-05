//
//  ESDIDModel.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/24.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESDIDModel.h"
#import "NSData+Hashing.h"
#import "NS+BTCBase58.h"
#import "ESRSA.h"

@implementation ESDIDModel

//did:aospace:11Aw2mJ7RwVyMCuGM493JrL9mu5Eh2kwzh9
//aospace-did = "did:aospace:" idstring
//idstring = Base58(Version + RIPEMD-160(SHA3-256(public-key)) + CheckSum)

- (NSString *)boxIdString {
    if (self.boxPublicKey.length <= 0) {
        return nil;
    }
    if (self.boxVersion.length <= 0) {
        Byte byte[] = {0x00,0x00};
        self.boxVersion = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    }
    
    NSData *publicKeyData = [self.boxPublicKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *versionData = self.boxVersion;
    
    if (publicKeyData.length <= 0 || versionData.length <= 0) {
        return nil;
    }
    
    NSData *SHA3_256_public_key = [publicKeyData  SHA256Hash];
    NSData *RIPEMD_160_data = [SHA3_256_public_key RIPEMD160Hash];

    NSMutableData *idStringForBase58Data = [[NSMutableData alloc] initWithData:versionData];
    [idStringForBase58Data appendData:RIPEMD_160_data];
    
    return [idStringForBase58Data base58CheckString];
}

- (NSString *)boxPublicKey {
    if (self.boxKey == nil) {
        return nil;
    }
    return self.boxKey.publicKey.pem;
}

- (NSString *)boxDid {
    return [NSString stringWithFormat:@"did:aospace:%@", [self boxIdString]];
}

//idstring = Base64(Version + SHA3-256(public-key)[0:8] + CheckSum)
- (NSString *)clientPublicKey {
    if (self.clientKey == nil) {
        return nil;
    }
    return self.clientKey.publicKey.pem;
}

- (NSString *)clientIdString {
    if (self.clientPublicKey.length <= 0 ) {
        return nil;
    }
    if (self.clientVersion.length <= 0) {
        Byte byte[] = {0x00,0x00};
        self.clientVersion = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    }

    NSData *publicKeyData = [self.clientPublicKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *versionData = self.clientVersion;
    
    if (publicKeyData.length <= 0 || versionData.length <= 0) {
        return nil;
    }
    
    NSData *SHA3_256_public_key = [publicKeyData  SHA3_256Hash];
    if (SHA3_256_public_key.length < 8) {
        return nil;
    }
    NSMutableData *hash_sha256_cutted = [NSMutableData data];
    [hash_sha256_cutted appendBytes:SHA3_256_public_key.bytes length:8];
    
    NSMutableData* idData = [versionData mutableCopy];
    [idData appendData:hash_sha256_cutted];
    
    [idData appendBytes:[idData SHA3_256Hash].bytes length:4];
    
    return [idData base64EncodedStringWithOptions:0];
}

- (NSString *)clientDid {
    return [NSString stringWithFormat:@"did:aospacekey:%@", [self clientIdString]];
}

@end


@implementation ESVerificationBaseMethod

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"pId"  : @"id",
            };
}


- (NSString *)keyHash {
   NSRange rangPre = [self.pId rangeOfString:@"did:aospacekey:"];
   NSRange rangSuf = [self.pId rangeOfString:@"?versionTime"];
    if (rangPre.location != NSNotFound && rangSuf.location != NSNotFound) {
        NSString *keyHash = [ self.pId substringWithRange:NSMakeRange(rangPre.location + rangPre.length, rangSuf.location - rangPre.location - rangPre.length)];
        return keyHash;
    }
    return nil;
}

- (NSString *)keyType {
    NSRange rangPre = [self.pId rangeOfString:@"credentialType="];
    if (rangPre.location != NSNotFound) {
        NSString *subIdString = [self.pId substringFromIndex:rangPre.location + rangPre.length];
        NSRange rangSuf = [subIdString rangeOfString:@"&"];
        if (rangSuf.location != NSNotFound) {
            NSString *keyType = [subIdString substringWithRange:NSMakeRange(0, rangSuf.location)];
            return keyType;
        }
            
        rangSuf = [subIdString rangeOfString:@"#"];
        if (rangSuf.location != NSNotFound) {
            NSString *keyType = [subIdString substringWithRange:NSMakeRange(0, rangSuf.location)];
            return keyType;
        }
    }
    
    return nil;
}
- (NSString *)keyTime {
    NSRange rangPre = [self.pId rangeOfString:@"versionTime="];
    if (rangPre.location != NSNotFound) {
        NSString *subIdString = [self.pId substringFromIndex:rangPre.location + rangPre.length];
        NSRange rangSuf = [subIdString rangeOfString:@"&"];

        if (rangSuf.location != NSNotFound) {
            NSString *keyTime = [subIdString substringWithRange:NSMakeRange(0, rangSuf.location)];
            return keyTime;
        }
    }
     return nil;
}

static NSDateFormatter *dateFormatter= nil;

+ (NSDateFormatter *)cachedDateFormatter{
   if (!dateFormatter) {
    dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
    dateFormatter.timeZone = timeZone;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  }
  return dateFormatter;
}

static NSDateFormatter *dateFormatterTransfer= nil;

+ (NSDateFormatter *)dateFormatterTransfer{
   if (!dateFormatterTransfer) {
       dateFormatterTransfer = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
       dateFormatterTransfer.timeZone = timeZone;
    [dateFormatterTransfer setDateFormat:@"yyyy-MM-dd HH:mm"];
  }
  return dateFormatterTransfer;
}

- (NSString *)keyTimeNormal {
    NSString *str = [self.keyTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *sss = [str substringToIndex:19];
    NSDate *date = [self.class.cachedDateFormatter dateFromString:sss];
    NSDate *newDate = [[NSDate date] initWithTimeInterval:8 * 60 * 60 sinceDate:date];
    NSString *newTime = [self.class.dateFormatterTransfer stringFromDate:newDate];
    return newTime;
}

- (NSString *)keyNumber {
    NSRange rangPre = [self.pId rangeOfString:@"#"];
    if (rangPre.location != NSNotFound) {
        NSString *keyNumber = [self.pId substringFromIndex:rangPre.location + 1];
        return keyNumber;
    }
    return nil;
}
@end

@implementation ESVerificationMethodPublicKeyMultibase

@end

@implementation ESVerificationMethodPublicKeyPem

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"publicKeyPem"  : @"PublicPem",
//             @"pId"  : @"id",
//            };
//}

@end

@implementation ESVerificationMethodConditionOr

@end

@implementation ESVerificationMethodConditionAdd

@end

@implementation ESDIDDocModel

- (NSString *)pIdHash {
    NSRange rangPre = [self.pId rangeOfString:@"did:aospace:"];
    NSRange rangSuf = [self.pId rangeOfString:@"#"];
     if (rangPre.location != NSNotFound && rangSuf.location != NSNotFound) {
         NSString *keyType = [ self.pId substringWithRange:NSMakeRange(rangPre.location + rangPre.length, rangSuf.location - rangPre.location - rangPre.length)];
         return keyType;
     }
     return nil;
}

// device binder password
- (ESVerificationBaseMethod *)getVerificationMethodByType:(NSString *)type {
    __block ESVerificationBaseMethod *match;
    [self.verificationMethod enumerateObjectsUsingBlock:^(ESVerificationBaseMethod * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.keyType isEqualToString:ESSafeString(type)]) {
            match = obj;
            *stop = YES;
        }
    }];
    return match;
}
@end
