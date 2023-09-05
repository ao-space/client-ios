//
//  NSData+Hashing.m
//  BitcoinSwift
//

#import "NSData+Hashing.h"

#import <OpenSSL/hmac.h>
#import <OpenSSL/ripemd.h>
#import <OpenSSL/sha.h>
#import "sha3.h"

@implementation NSData (Hashing)

- (NSData *)SHA256Hash {
  SHA256_CTX ctx;
  unsigned char hash[32];
  SHA256_Init(&ctx);
  SHA256_Update(&ctx, self.bytes, self.length);
  SHA256_Final(hash, &ctx);
  return [NSData dataWithBytes:hash length:32];
}

- (NSData *)SHA3_256Hash {
    sha3_context c;
    uint8_t *hash;
    
    sha3_Init256(&c);
    sha3_Update(&c, self.bytes, self.length);
    hash = sha3_Finalize(&c);
    return [NSData dataWithBytes:hash length:32];
}

- (NSData *)RIPEMD160Hash {
  RIPEMD160_CTX ctx;
  unsigned char hash[20];
  RIPEMD160_Init(&ctx);
  RIPEMD160_Update(&ctx, self.bytes, self.length);
  RIPEMD160_Final(hash, &ctx);
  return [NSData dataWithBytes:hash length:20];
}

- (void)HMACSHA512WithKey:(NSData *)key digest:(NSMutableData *)digest {
  unsigned int length = 64;
  NSAssert(digest.length == 64, @"Invalid output length for HMACSHA512");
  HMAC(EVP_sha512(),
       key.bytes,
       (int)key.length,
       self.bytes,
       (int)self.length,
       [digest mutableBytes],
       &length);
}

@end
