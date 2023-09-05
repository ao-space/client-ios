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
//  ESRedirectManage.m
//  EulixSpace
//
//  Created by Ye qu on 2023/6/29.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//
#import "ESRedirectManage.h"
#import "ESBoxManager.h"

@interface ESRedirectManage()<NSURLSessionDelegate>

@property (nonatomic, strong) ESBoxItem *activeBox;
@end


@implementation ESRedirectManage

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)getRedirectWithBox:(ESBoxItem *)box{
    self.activeBox = box;

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    BOOL containsHTTPS = [self.activeBox.info.userDomain rangeOfString:@"https"].location != NSNotFound;
    NSString *urlString;
    if (containsHTTPS) {
        urlString = [NSString stringWithFormat:@"%@/space/status", self.activeBox.info.userDomain];
    } else {
        urlString =  [NSString stringWithFormat:@"https://%@/space/status", self.activeBox.info.userDomain];
    }
    
    
    NSURL *url = [NSURL URLWithString:urlString];
 
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];

    [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    NSURL *redirectURL = [request URL];
    if(self.activeBox.boxType != ESBoxTypePairing){
        if(ESBoxManager.activeBox == self.activeBox){
            if (redirectURL) {
                NSString *hostname = [[NSURLComponents componentsWithURL:redirectURL resolvingAgainstBaseURL:NO] host];
                self.activeBox.info.userDomain = hostname;
                [[ESBoxManager manager] saveBoxUserDomain:self.activeBox];
            }
        }
    }
    completionHandler(request);
}

@end
