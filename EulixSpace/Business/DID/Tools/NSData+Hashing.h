//
//  NSData+Hashing.h
//  BitcoinSwift
//

#import <Foundation/Foundation.h>
#import "NSData+Hashing.h"

@interface NSData (Hashing)

/// Returns the SHA-256 hash of self.
- (NSData *)SHA256Hash;
- (NSData *)SHA3_256Hash;

/// Returns the RIPEMD-160 hash of self.
- (NSData *)RIPEMD160Hash;

/// Performs the HMAC512-SHA256 algorithm on self using key and stores the result in digest.
- (void)HMACSHA512WithKey:(NSData *)key digest:(NSMutableData *)digest;

@end
