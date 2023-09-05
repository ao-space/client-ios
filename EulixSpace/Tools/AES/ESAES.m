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
//  ESAES.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAES.h"
#import <OpenSSL/evp.h>

@implementation NSData (ESAES)

///https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption
int aes_encrypt(unsigned char *plainText,
                int plainTextLength,
                unsigned char *key,
                unsigned char *initializationVector,
                unsigned char *cipherText,
                int bitLength) {
    EVP_CIPHER_CTX *ctx;

    int length;

    int cipherTextLength;

    /* Create and initialise the context */
    if (!(ctx = EVP_CIPHER_CTX_new())) {
        return -1;
    }

    /*
     * Initialise the encryption operation. IMPORTANT - ensure you use a key
     * and initializationVector size appropriate for your cipher
     * In this example we are using 256 bit AES (i.e. a 256 bit key). The
     * initializationVector size for *most* modes is the same as the block size. For AES this
     * is 128 bits
     */
    if (bitLength == 32) {
        if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, initializationVector)) {
            return -1;
        }
    } else {
        if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, initializationVector)) {
            return -1;
        }
    }

    /*
     * Provide the message to be encrypted, and obtain the encrypted output.
     * EVP_EncryptUpdate can be called multiple times if necessary
     */
    if (1 != EVP_EncryptUpdate(ctx, cipherText, &length, plainText, plainTextLength)) {
        return -1;
    }

    cipherTextLength = length;

    /*
     * Finalise the encryption. Further cipherText bytes may be written at
     * this stage.
     */
    if (1 != EVP_EncryptFinal_ex(ctx, cipherText + length, &length)) {
        return -1;
    }

    cipherTextLength += length;

    /* Clean up */
    EVP_CIPHER_CTX_free(ctx);

    return cipherTextLength;
}

int aes_decrypt(unsigned char *cipherText,
                int cipherTextLength,
                unsigned char *key,
                unsigned char *initializationVector,
                unsigned char *plainText,
                int bitLength) {
    EVP_CIPHER_CTX *ctx;

    int length;

    int plainTextLength;

    /* Create and initialise the context */
    if (!(ctx = EVP_CIPHER_CTX_new())) {
        return -1;
    }

    /*
     * Initialise the decryption operation. IMPORTANT - ensure you use a key
     * and initializationVector size appropriate for your cipher
     * In this example we are using 256 bit AES (i.e. a 256 bit key). The
     * initializationVector size for *most* modes is the same as the block size. For AES this
     * is 128 bits
     */
    if (bitLength == 32) {
        if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, initializationVector)) {
            return -1;
        }
    } else {
        if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, initializationVector)) {
            return -1;
        }
    }

    /*
     * Provide the message to be decrypted, and obtain the plainText output.
     * EVP_DecryptUpdate can be called multiple times if necessary.
     */
    if (1 != EVP_DecryptUpdate(ctx, plainText, &length, cipherText, cipherTextLength)) {
        return -1;
    }
    plainTextLength = length;

    /*
     * Finalise the decryption. Further plainText bytes may be written at
     * this stage.
     */
    if (1 != EVP_DecryptFinal_ex(ctx, plainText + length, &length)) {
        return -1;
    }
    plainTextLength += length;

    /* Clean up */
    EVP_CIPHER_CTX_free(ctx);

    return plainTextLength;
}

- (NSData *)aes_cbc_encryptWithKey:(NSData *)keyData iv:(NSData *)ivData {
    /* Message to be encrypted */
    unsigned char *plainText = (unsigned char *)self.bytes;
    unsigned char *key = (unsigned char *)keyData.bytes;
    unsigned char *ivText = (unsigned char *)ivData.bytes;
    /*
     * Buffer for cipherText. Ensure the buffer is long enough for the
     * cipherText which may be longer than the plainText, depending on the
     * algorithm and mode.
     */
    unsigned char cipherText[self.length + keyData.length];
    /* Encrypt the plainText */
    int cipherTextLength = aes_encrypt(plainText, (int)self.length, key, ivText, cipherText, (int)keyData.length);
    if (cipherTextLength == -1) {
        return nil;
    }
    return [NSData dataWithBytes:cipherText length:cipherTextLength];
}

- (NSData *)aes_cbc_decryptWithKey:(NSData *)keyData iv:(NSData *)ivData {
    unsigned char *cipherText = (unsigned char *)self.bytes;
    unsigned char *key = (unsigned char *)keyData.bytes;
    unsigned char *ivText = (unsigned char *)ivData.bytes;

    /* Buffer for the decrypted text */
    unsigned char decryptedText[self.length + keyData.length];
    int cipherTextLength = (int)self.length;
    int decryptedTextLength;
    /* Decrypt the cipherText */
    decryptedTextLength = aes_decrypt(cipherText, cipherTextLength, key, ivText, decryptedText, (int)keyData.length);
    if (decryptedTextLength == -1) {
        return nil;
    }
    return [NSData dataWithBytes:decryptedText length:decryptedTextLength];
}

- (NSData *)aes_cbc_multipart_decryptWithKey:(NSData *)keyData iv:(NSData *)ivData {
    NSMutableData *plainData = NSMutableData.data;
    UInt64 totalSize = self.length;
    if (totalSize == 0) {
        return plainData;
    }
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
        return plainData;
    }
    if (keyData.length == 32) {
        if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, ivText)) {
            return plainData;
        }
    } else {
        if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, ivText)) {
            return plainData;
        }
    }

    while (offset < totalSize) {
        @autoreleasepool {
            NSInteger fixedSize = MIN(totalSize - offset, bufferSize);
            NSData *buffer = [self subdataWithRange:NSMakeRange(offset, fixedSize)];

            unsigned char *cipherText = (unsigned char *)buffer.bytes;

            /* Buffer for the decrypted text */
            unsigned char plainText[fixedSize + keyData.length];
            int cipherTextLength = (int)buffer.length;

            if (1 != EVP_DecryptUpdate(ctx, plainText, &length, cipherText, cipherTextLength)) {
                return nil;
            }
            plainTextLength = length;
            offset += fixedSize;
            if (offset >= totalSize) {
                if (1 != EVP_DecryptFinal_ex(ctx, plainText + length, &length)) {
                    return nil;
                }
                plainTextLength += length;

                /* Clean up */
                EVP_CIPHER_CTX_free(ctx);
            }

            NSData *output = [NSData dataWithBytes:plainText length:plainTextLength];
            [plainData appendData:output];
        }
    }
    return plainData;
}

@end

@implementation NSString (ESAES)

//自定义的IV
- (NSString *)aes_cbc_decryptWithKey:(NSString *)keyString iv:(NSString *)ivString {
    if (keyString.length == 0 || ivString.length == 0) {
        return nil;
    }
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    data = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedData:[ivString dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *result = [data aes_cbc_multipart_decryptWithKey:keyData iv:ivData];
    //NSData *result = [data aes_cbc_decryptWithKey:keyData iv:ivData];
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

- (NSString *)aes_cbc_encryptWithKey:(NSString *)keyString iv:(NSString *)ivString {
    if (keyString.length == 0 || ivString.length == 0) {
        return nil;
    }
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedData:[ivString dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *result = [data aes_cbc_encryptWithKey:keyData iv:ivData];
    return [result base64EncodedStringWithOptions:0];
}

@end
