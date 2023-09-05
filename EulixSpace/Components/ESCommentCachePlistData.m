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
//  ESCommentCachePlistData.m
//  EulixSpace
//
//  Created by qu on 2021/10/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCommentCachePlistData.h"
#include <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
@interface ESCommentCachePlistData ()

@end

@implementation ESCommentCachePlistData

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 后期抽出
- (void)plistWriteDate:(NSMutableDictionary *)writeDate plistName:(NSString *)plistName {
    NSString *plistPath = [self getPathWithPistName:plistName];
    [writeDate writeToFile:plistPath atomically:YES];
}

- (NSDictionary *)getPlistDataWithPistName:(NSString *)plistName {
    NSString *plistPath = [self getPathWithPistName:plistName];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return dic;
}

- (NSString *)getPathWithPistName:(NSString *)plistName {
    // 获取应用程序沙盒的Documents目录
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // 也可以这样添加后缀，plistName是文件名
    NSString *name = [plistName stringByAppendingPathExtension:@"plist"];
    // 得到完整的文件路径
    NSString *plistPath = [documentPath stringByAppendingPathComponent:name];
    
    return plistPath;
}

-(NSDictionary *)getDictionary:(NSString *)filePath{

    NSString *path = [self md5:filePath];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pathMd5 =[NSString stringWithFormat:@"%@/%@",documentPath,path];
    
//        NSData *dataFile = [NSDate alloc] initWithContentsOfFile:pathMd5];

    NSString *plistName = [[NSString stringWithFormat:@"%@", path] stringByAppendingPathExtension:@"plist"];
    NSString *plistPath = [pathMd5 stringByAppendingPathComponent:plistName];
    
    NSDictionary *beTagDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

    return beTagDic;
}

- (NSString *)md5:(NSString *)str
{
    if(str.length < 1){
        return @"";
    }
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

-(BOOL)isConnectionAvailable {
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }

  if (!isExistenceNetwork) {
    
        return NO;
    }
    
    return isExistenceNetwork;
}



/// 后期抽出
//- (BOOL)plistWriteDatePlatformApis:(NSMutableDictionary *)writeDate {
//    NSString *plistPath = [self getPath];
//    BOOL isSucess = [writeDate writeToFile:plistPath atomically:YES];
//    if (isSucess) {
//        NSLog(@"存储信息成功");
//    }
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBoxInfo" object:nil];
//    return isSucess;
// }

- (NSDictionary *)getPlistPlatformApis {
    NSString *plistPath = [self getPathPlatformApis];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return dic;
}

- (NSString *)getPathPlatformApis {
    // 获取应用程序沙盒的Documents目录
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // 也可以这样添加后缀，plistName是文件名
    NSString *plistName = [[NSString stringWithFormat:@"platformApis"] stringByAppendingPathExtension:@"plist"];
    // 得到完整的文件路径
    NSString *plistPath = [documentPath stringByAppendingPathComponent:plistName];
    return plistPath;
}

@end
