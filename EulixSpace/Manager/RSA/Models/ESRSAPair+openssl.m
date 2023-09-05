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
//  ESRSAPair+openssl.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESRSA.h"
#import "ESRSAPair+openssl.h"
#import <OpenSSL/bn.h>
#import <OpenSSL/pem.h>

@interface ESRSA ()

@property (nonatomic, copy) NSString *pem;

@property (nonatomic, assign) RSA *rsaKey;

+ (instancetype)fromRSA:(RSA *)rsa pem:(NSString *)pem;

@end

@implementation ESRSAPair (ESOpenssl)

#pragma mark - 生成密钥对

+ (ESRSAPair *)generateRSAKeyPairWithKeySize:(int)keySize {
    if (keySize == 512 || keySize == 1024 || keySize == 2048) {
        /* 产生RSA密钥 */
        RSA *rsa = RSA_new();
        BIGNUM *e = BN_new();
        /* 设置随机数长度 */
        BN_set_word(e, 65537);
        /* 生成RSA密钥对 RSA_generate_key_ex()新版本方法 */
        RSA_generate_key_ex(rsa, keySize, e, NULL);
        if (rsa) {
            RSA *publicKey = RSAPublicKey_dup(rsa);
            RSA *privateKey = RSAPrivateKey_dup(rsa);
            NSString *publicPEM = [self PEMKeyFromBase64:[self base64EncodedStringKey:publicKey isPubkey:YES] isPubkey:YES];
            NSString *privatePEM = [self PEMKeyFromBase64:[self base64EncodedStringKey:privateKey isPubkey:NO] isPubkey:NO];
            ESRSAPair *pair = [ESRSAPair pairWithPublicKey:[ESRSA fromRSA:publicKey pem:publicPEM] privateKey:[ESRSA fromRSA:privateKey pem:privatePEM]];
            return pair;
        }
    }
    return nil;
}

#pragma - Base64 Text

- (NSString *)publicEncrypt:(NSString *)plainText {
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    data = [self RSAPublicEncrypt:data];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)privateDecrypt:(NSString *)cipherText {
    NSData *data = [cipherText dataUsingEncoding:NSUTF8StringEncoding];
    data = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];

    return [[NSString alloc] initWithData:[self RSAPrivateDecrypt:data] encoding:NSUTF8StringEncoding];
}

- (NSString *)privateEncrypt:(NSString *)plainText {
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    data = [self RSAPrivateEncrypt:data];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)publicDecrypt:(NSString *)cipherText {
    NSData *data = [cipherText dataUsingEncoding:NSUTF8StringEncoding];
    data = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc] initWithData:[self RSAPublicDecrypt:data] encoding:NSUTF8StringEncoding];
}

#pragma mark -

+ (NSString *)base64EncodedStringKey:(RSA *)rsaKey
                            isPubkey:(BOOL)isPubkey {
    if (!rsaKey) {
        return nil;
    }
    BIO *bio = BIO_new(BIO_s_mem());

    if (isPubkey) {
        PEM_write_bio_RSA_PUBKEY(bio, rsaKey);
    } else {
        //此方法生成的是pkcs1格式的,IOS中需要pkcs8格式的,因此通过PEM_write_bio_PrivateKey 方法生成
        // PEM_write_bio_RSAPrivateKey(bio, rsaKey, NULL, NULL, 0, NULL, NULL);
        EVP_PKEY *key = NULL;
        key = EVP_PKEY_new();
        EVP_PKEY_assign_RSA(key, rsaKey);
        PEM_write_bio_PrivateKey(bio, key, NULL, NULL, 0, NULL, NULL);
    }

    BUF_MEM *bptr;
    BIO_get_mem_ptr(bio, &bptr);
    BIO_set_close(bio, BIO_NOCLOSE); /* So BIO_free() leaves BUF_MEM alone */
    BIO_free(bio);
    NSString *res = [[NSString alloc] initWithBytes:bptr->data length:bptr->length encoding:NSUTF8StringEncoding];
    //将PEM格式转换为base64格式
    return [self base64EncodedStringFromPEM:res];
}

+ (NSString *)base64EncodedStringFromPEM:(NSString *)PEMFormat {
    return [[PEMFormat componentsSeparatedByString:@"-----"][2] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

+ (NSString *)PEMKeyFromBase64:(NSString *)base64Key isPubkey:(BOOL)isPubkey {
    NSMutableString *result = [NSMutableString string];
    if (isPubkey) {
        [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    } else {
        [result appendString:@"-----BEGIN RSA PRIVATE KEY-----\n"];
    }
    int count = 0;
    for (int i = 0; i < [base64Key length]; ++i) {
        unichar c = [base64Key characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == 64) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    if (isPubkey) {
        [result appendString:@"\n-----END PUBLIC KEY-----"];
    } else {
        [result appendString:@"\n-----END RSA PRIVATE KEY-----"];
    }
    return result;
}

+ (NSString *)checkPublicKey:(NSString *)KeyPEM {
    if (!KeyPEM) {
        return nil;
    }
    NSMutableString * result = [[NSMutableString alloc] init];
    if (![KeyPEM hasPrefix:@"-----BEGIN PUBLIC"]) {
        [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    }
    [result appendString:KeyPEM];
    
    if (![KeyPEM hasSuffix:@"-----END PUBLIC KEY-----"]) {
        [result appendString:@"\n-----END PUBLIC KEY-----"];
    }
    return result;
}

+ (RSA *)rsaFromBase64:(NSString *)base64Key isPubkey:(BOOL)isPubkey {
    NSString *result = [self PEMKeyFromBase64:base64Key isPubkey:isPubkey];
    return [self rsaFromPEM:result isPubkey:isPubkey];
}

#pragma mark - 密钥格式转换

+ (RSA *)rsaFromPEM:(NSString *)KeyPEM isPubkey:(BOOL)isPubkey {
    const char *buffer = [KeyPEM UTF8String];
    BIO *keyBio = BIO_new_mem_buf(buffer, (int)strlen(buffer));
    RSA *rsa;
    if (isPubkey) {
        rsa = PEM_read_bio_RSA_PUBKEY(keyBio, NULL, NULL, NULL);
    } else {
        rsa = PEM_read_bio_RSAPrivateKey(keyBio, NULL, NULL, NULL);
    }
    BIO_free_all(keyBio);
    return rsa;
}

+ (ESRSA *)keyFromPEM:(NSString *)KeyPEM isPubkey:(BOOL)isPubkey {
    if (KeyPEM.length == 0) {
        return nil;
    }
    RSA *rsa = [self rsaFromPEM:KeyPEM isPubkey:isPubkey];
    return [ESRSA fromRSA:rsa pem:KeyPEM];
}

#pragma mark - 加解密

/// 用公钥解密
/// @param plainData 明文
- (NSData *)RSAPublicEncrypt:(NSData *)plainData {
    RSA *publicKey = self.publicKey.rsaKey;
    if (!publicKey || !plainData) {
        return nil;
    }
    int padding = self.publicKey.padding;
    int paddingSize = padding;
    int publicRSALength = RSA_size(publicKey);
    double totalLength = [plainData length];
    int blockSize = publicRSALength - paddingSize;
    int blockCount = ceil(totalLength / blockSize);
    size_t publicEncryptSize = publicRSALength;
    NSMutableData *encryptData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        char *publicEncrypt = malloc(publicRSALength);
        memset(publicEncrypt, 0, publicRSALength);
        const unsigned char *str = [dataSegment bytes];
        int r = RSA_public_encrypt(dataSegmentRealSize, str, (unsigned char *)publicEncrypt, publicKey, padding);
        if (r < 0) {
            free(publicEncrypt);
            return nil;
        }
        NSData *blockData = [[NSData alloc] initWithBytes:publicEncrypt length:publicEncryptSize];
        [encryptData appendData:blockData];

        free(publicEncrypt);
    }
    return encryptData;
}

/// 用私钥解密
/// @param cipherData 密文
- (NSData *)RSAPrivateDecrypt:(NSData *)cipherData {
    RSA *privateKey = self.privateKey.rsaKey;
    int padding = self.privateKey.padding;
    if (!privateKey || !cipherData) {
        return nil;
    }
    int privateRSALenght = RSA_size(privateKey);
    double totalLength = [cipherData length];
    int blockSize = privateRSALenght;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *decrypeData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        long dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        const unsigned char *str = [dataSegment bytes];
        unsigned char *privateDecrypt = malloc(privateRSALenght);
        memset(privateDecrypt, 0, privateRSALenght);
        int ret = RSA_private_decrypt(privateRSALenght, str, privateDecrypt, privateKey, padding);
        if (ret >= 0) {
            NSData *data = [[NSData alloc] initWithBytes:privateDecrypt length:ret];
            [decrypeData appendData:data];
        }
        free(privateDecrypt);
    }

    return decrypeData;
}

/// 用私钥加密
/// @param plainData 明文
- (NSData *)RSAPrivateEncrypt:(NSData *)plainData {
    RSA *privateKey = self.privateKey.rsaKey;
    int padding = self.privateKey.padding;
    if (!privateKey || !plainData) {
        return nil;
    }
    int paddingSize = padding;

    int privateRSALength = RSA_size(privateKey);
    double totalLength = [plainData length];
    int blockSize = privateRSALength - paddingSize;
    int blockCount = ceil(totalLength / blockSize);
    size_t privateEncryptSize = privateRSALength;
    NSMutableData *encryptData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        char *privateEncrypt = malloc(privateRSALength);
        memset(privateEncrypt, 0, privateRSALength);
        const unsigned char *str = [dataSegment bytes];
        int r = RSA_private_encrypt(dataSegmentRealSize, str, (unsigned char *)privateEncrypt, privateKey, padding);
        if (r < 0) {
            free(privateEncrypt);
            return nil;
        }

        NSData *blockData = [[NSData alloc] initWithBytes:privateEncrypt length:privateEncryptSize];
        [encryptData appendData:blockData];

        free(privateEncrypt);
    }
    return encryptData;
}

/// 用公钥解密
/// @param cipherData 密文
- (NSData *)RSAPublicDecrypt:(NSData *)cipherData {
    RSA *publicKey = self.publicKey.rsaKey;
    int padding = self.publicKey.padding;
    //异常处理
    if (!publicKey || !cipherData) {
        return nil;
    }
    int publicRSALenght = RSA_size(publicKey);
    double totalLength = [cipherData length];
    int blockSize = publicRSALenght;
    int blockCount = ceil(totalLength / blockSize);
    NSMutableData *decrypeData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        long dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        const unsigned char *str = [dataSegment bytes];
        unsigned char *publicDecrypt = malloc(publicRSALenght);
        memset(publicDecrypt, 0, publicRSALenght);
        int ret = RSA_public_decrypt(publicRSALenght, str, publicDecrypt, publicKey, padding);
        if (ret < 0) {
            free(publicDecrypt);
            return nil;
        }
        NSData *data = [[NSData alloc] initWithBytes:publicDecrypt length:ret];
        if (padding == RSA_NO_PADDING) {
            Byte flag[] = {0x00};
            NSData *startData = [data subdataWithRange:NSMakeRange(0, 1)];
            if ([[startData description] isEqualToString:@"<00>"]) {
                NSRange startRange = [data rangeOfData:[NSData dataWithBytes:flag length:1] options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
                NSUInteger rangeLength = startRange.location + startRange.length;
                if (startRange.location != NSNotFound && rangeLength < data.length) {
                    data = [data subdataWithRange:NSMakeRange(rangeLength, data.length - rangeLength)];
                }
            }
        }
        [decrypeData appendData:data];
        free(publicDecrypt);
    }
    return decrypeData;
}

/// Inspired by  https://gist.github.com/irbull/08339ddcd5686f509e9826964b17bb59
static bool RSASign(RSA *rsa,
                    const unsigned char *Msg,
                    size_t MsgLen,
                    unsigned char **EncMsg,
                    size_t *MsgLenEnc) {
    EVP_MD_CTX *m_RSASignCtx = EVP_MD_CTX_create();
    EVP_PKEY *priKey = EVP_PKEY_new();
    EVP_PKEY_assign_RSA(priKey, rsa);
    if (EVP_DigestSignInit(m_RSASignCtx, NULL, EVP_sha256(), NULL, priKey) <= 0) {
        return false;
    }
    if (EVP_DigestSignUpdate(m_RSASignCtx, Msg, MsgLen) <= 0) {
        return false;
    }
    if (EVP_DigestSignFinal(m_RSASignCtx, NULL, MsgLenEnc) <= 0) {
        return false;
    }
    *EncMsg = (unsigned char *)malloc(*MsgLenEnc);
    if (EVP_DigestSignFinal(m_RSASignCtx, *EncMsg, MsgLenEnc) <= 0) {
        return false;
    }
    EVP_MD_CTX_destroy(m_RSASignCtx);
    return true;
}

static bool RSAVerifySignature(RSA *rsa,
                               unsigned char *MsgHash,
                               size_t MsgHashLen,
                               const char *Msg,
                               size_t MsgLen,
                               bool *Authentic) {
    *Authentic = false;
    EVP_PKEY *pubKey = EVP_PKEY_new();
    EVP_PKEY_assign_RSA(pubKey, rsa);
    EVP_MD_CTX *m_RSAVerifyCtx = EVP_MD_CTX_create();

    if (EVP_DigestVerifyInit(m_RSAVerifyCtx, NULL, EVP_sha256(), NULL, pubKey) <= 0) {
        return false;
    }
    if (EVP_DigestVerifyUpdate(m_RSAVerifyCtx, Msg, MsgLen) <= 0) {
        return false;
    }
    int AuthStatus = EVP_DigestVerifyFinal(m_RSAVerifyCtx, MsgHash, MsgHashLen);
    if (AuthStatus == 1) {
        *Authentic = true;
        EVP_MD_CTX_destroy(m_RSAVerifyCtx);
        return true;
    } else if (AuthStatus == 0) {
        *Authentic = false;
        EVP_MD_CTX_destroy(m_RSAVerifyCtx);
        return true;
    } else {
        *Authentic = false;
        EVP_MD_CTX_destroy(m_RSAVerifyCtx);
        return false;
    }
}

///RSASign
- (NSString *)sign:(NSString *)plainText {
    RSA *privateKey = self.privateKey.rsaKey;
    unsigned char *encMessage;
    size_t encMessageLength;
    RSASign(privateKey, (unsigned char *)plainText.UTF8String, plainText.length, &encMessage, &encMessageLength);
    NSData *data = [[NSData alloc] initWithBytes:encMessage length:encMessageLength];
    return [data base64EncodedStringWithOptions:0];
}

//RSAVerifySignature
- (BOOL)verifySignature:(NSString *)cipherText plainText:(NSString *)plainText {
    RSA *publicKey = self.publicKey.rsaKey;
    bool authentic;
    NSData *data = [cipherText dataUsingEncoding:NSUTF8StringEncoding];
    data = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    bool result = RSAVerifySignature(publicKey, (unsigned char *)data.bytes, data.length, plainText.UTF8String, plainText.length, &authentic);
    return result & authentic;
}

@end
