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
//  ESGCDWebServerManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/12/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESGCDWebServerManager.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@interface ESGCDWebServerManager ()

@property (nonatomic, strong) GCDWebServer* webServer;

@end

@implementation ESGCDWebServerManager

+ (instancetype)shareInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)startServer {
    if (![ESGCDWebServerManager shareInstance].webServer.isRunning) {
        [[ESGCDWebServerManager shareInstance].webServer startWithPort:8080 bonjourName:nil];
    }
}

- (GCDWebServer *)webServer {
    if (_webServer == nil) {
        _webServer = [[GCDWebServer alloc] init];
    }
    return _webServer;
}

+ (void)startSeviceWithFilePathList:(NSArray<NSString *> *)filePathList {
    ESDLog(@"[ESGCDWebServerManager] startSeviceWithFilePathList: %@", filePathList);
    [filePathList enumerateObjectsUsingBlock:^(NSString  *_Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![filePath isKindOfClass:[NSString class]]) {
            return;
        }
        NSString *fileName = [filePath lastPathComponent];
        NSString *dir = [filePath stringByDeletingLastPathComponent];
        [[ESGCDWebServerManager shareInstance].webServer addGETHandlerForBasePath:@"/" directoryPath:dir indexFilename:fileName cacheAge:3600 allowRangeRequests:YES];
    }];
    [[ESGCDWebServerManager shareInstance].webServer startWithPort:8080 bonjourName:nil];
}

+ (void)removeAllHandler {
    ESDLog(@"[ESGCDWebServerManager] removeAllHandler");

    [[ESGCDWebServerManager shareInstance].webServer stop];
    [[ESGCDWebServerManager shareInstance].webServer removeAllHandlers];
}

+ (void)addGETHandlerForFilePath:(NSString *)filePath {
    NSString *fileName = [filePath lastPathComponent];
    NSString *dir = [filePath stringByDeletingLastPathComponent];
    [[ESGCDWebServerManager shareInstance].webServer stop];
    [[ESGCDWebServerManager shareInstance].webServer addGETHandlerForBasePath:@"/" directoryPath:dir indexFilename:fileName cacheAge:3600 allowRangeRequests:YES];
    [[ESGCDWebServerManager shareInstance].webServer startWithPort:8080 bonjourName:nil];
}

@end
