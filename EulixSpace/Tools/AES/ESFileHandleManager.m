/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  ESFileHandleManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/19.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileHandleManager.h"
#include <CommonCrypto/CommonDigest.h>
#import <OpenSSL/evp.h>

@implementation ESFileHandleManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 解密文件
/// @param filePath 文件本地路径
/// @param target 解密后的文件路径
/// @param keyString aes解密密钥
/// @param ivString aes解密iv
- (void)decryptFile:(NSString *)filePath target:(NSString *)target key:(NSString *)keyString iv:(NSString *)ivString {
    NSFileHandle *read = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [NSFileManager.defaultManager removeItemAtPath:target error:nil];
    [NSFileManager.defaultManager createFileAtPath:target contents:nil attributes:nil];
    NSFileHandle *write = [NSFileHandle fileHandleForWritingAtPath:target];
    UInt64 totalSize = [[NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil] fileSize];
    if (totalSize == 0) {
        [read closeFile];
        [write closeFile];
        return;
    }

    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedData:[ivString dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];

    UInt64 offset = 0;
    ///512KB
    long bufferSize = 0x80000;

    unsigned char *key = (unsigned char *)keyData.bytes;
    unsigned char *ivText = (unsigned char *)ivData.bytes;
    EVP_CIPHER_CTX *ctx;
    int length;
    int plainTextLength;
    /* Create and initialise the context */
    if (!(ctx = EVP_CIPHER_CTX_new())) {
        return;
    }
    if (keyString.length == 32) {
        if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, ivText)) {
            return;
        }
    } else {
        if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, ivText)) {
            return;
        }
    }

    while (offset < totalSize) {
        @autoreleasepool {
            NSInteger fixedSize = MIN(totalSize - offset, bufferSize);
            NSData *buffer = [read readDataOfLength:fixedSize];

            unsigned char *cipherText = (unsigned char *)buffer.bytes;

            /* Buffer for the decrypted text */
            unsigned char plainText[fixedSize + keyString.length];
            int cipherTextLength = (int)buffer.length;

            if (1 != EVP_DecryptUpdate(ctx, plainText, &length, cipherText, cipherTextLength)) {
                ESDLog(@"### fail decryptFile pic %@", filePath);
                return;
            }
            plainTextLength = length;
            offset += fixedSize;
            if (offset >= totalSize) {
                if (1 != EVP_DecryptFinal_ex(ctx, plainText + length, &length)) {
                    return;
                }
                plainTextLength += length;

                /* Clean up */
                EVP_CIPHER_CTX_free(ctx);
            }

            NSData *output = [NSData dataWithBytes:plainText length:plainTextLength];
            [write seekToEndOfFile];
            [write writeData:output];

            [read seekToFileOffset:offset];
        }
    }

    [read closeFile];
    [write closeFile];
}



/// 加密文件
/// @param filePath 文件本地路径
/// @param target 加密后的文件路径
/// @param keyString aes加密密钥
/// @param ivString aes加密iv
- (UInt64)encryptFile:(NSString *)filePath target:(NSString *)target key:(NSString *)keyString iv:(NSString *)ivString {
    NSFileHandle *read = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [NSFileManager.defaultManager removeItemAtPath:target error:nil];
    [NSFileManager.defaultManager createFileAtPath:target contents:nil attributes:nil];
    NSFileHandle *write = [NSFileHandle fileHandleForWritingAtPath:target];

    UInt64 totalSize = [[NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil] fileSize];
    if (totalSize == 0) {
        return 0;
    }

    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedData:[ivString dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];

    UInt64 offset = 0;
    ///512KB
    long bufferSize = 0x80000;

    unsigned char *key = (unsigned char *)keyData.bytes;
    unsigned char *ivText = (unsigned char *)ivData.bytes;
    EVP_CIPHER_CTX *ctx;
    int length;
    int cipherTextLength;
    UInt64 totalCipherTextLength = 0;
    /* Create and initialise the context */
    if (!(ctx = EVP_CIPHER_CTX_new())) {
        return 0;
    }
    if (keyString.length == 32) {
        if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, ivText)) {
            return 0;
        }
    } else {
        if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, ivText)) {
            return 0;
        }
    }

    while (offset < totalSize) {
        @autoreleasepool {
            NSInteger fixedSize = MIN(totalSize - offset, bufferSize);
            NSData *buffer = [read readDataOfLength:fixedSize];

            unsigned char *plainText = (unsigned char *)buffer.bytes;

            /* Buffer for the decrypted text */
            unsigned char cipherText[fixedSize + keyString.length];
            int plainTextLength = (int)buffer.length;

            if (1 != EVP_EncryptUpdate(ctx, cipherText, &length, plainText, plainTextLength)) {
                return 0;
            }
            cipherTextLength = length;
            offset += fixedSize;
            if (offset >= totalSize) {
                if (1 != EVP_EncryptFinal_ex(ctx, cipherText + length, &length)) {
                    return 0;
                }
                cipherTextLength += length;

                /* Clean up */
                EVP_CIPHER_CTX_free(ctx);
            }

            NSData *output = [NSData dataWithBytes:cipherText length:cipherTextLength];
            totalCipherTextLength += cipherTextLength;
            [write seekToEndOfFile];
            [write writeData:output];

            [read seekToFileOffset:offset];
        }
    }

    [read closeFile];
    [write closeFile];
    return totalCipherTextLength;
}

- (NSString *)betagOfFile:(NSString *)filePath {
    NSFileHandle *read = [NSFileHandle fileHandleForReadingAtPath:filePath];
    UInt64 totalSize = [[NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil] fileSize];
    if (totalSize == 0) {
        return nil;
    }
    UInt64 offset = 0;
    ///4M
    long bufferSize = 4194304; // 4 * 1024 * 1024;
    NSMutableData *md5OfAllParts = NSMutableData.data;
    while (offset < totalSize) {
        @autoreleasepool {
            NSInteger fixedSize = MIN(totalSize - offset, bufferSize);
            NSData *buffer = [read readDataOfLength:fixedSize];
            NSData *md5Data = [self MD5DataFromData:buffer];
            [md5OfAllParts appendData:md5Data];
            [read seekToFileOffset:offset];
            offset += fixedSize;
        }
    }
    [read closeFile];
    ///只有一片
    if (md5OfAllParts.length == CC_MD5_DIGEST_LENGTH) {
        return [self md5StringOfMD5Data:md5OfAllParts];
    }

    return [self md5StringOfMD5Data:[self MD5DataFromData:md5OfAllParts]];
}

- (NSString *)md5StringOfMD5Data:(NSData *)md5Data {
    if (md5Data.length != CC_MD5_DIGEST_LENGTH) {
        return @"";
    }
    unsigned char *digest = (unsigned char *)md5Data.bytes;
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

- (NSData *)MD5DataFromData:(NSData *)data {
    if (data == nil) {
        return nil; // 如果文件不存在
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, digest);
    return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

@end
