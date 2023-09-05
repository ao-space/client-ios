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
//  ESNetServiceBrowser.h
//  EulixSpace
//
//  Created by qu on 2021/6/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kESBoxServiceType = @"_eulixspace-sd._tcp.";


@interface ESNetServiceItem : NSObject

@property (nonatomic, strong) NSString * btidhash;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSString *ipv4;

@property (nonatomic, readonly) int port;

- (instancetype)initWithName:(NSString *)name ipv4:(NSString *)ipv4 port:(int)port;

@property (nonatomic, assign) int webport;
@property (nonatomic, assign) int sslport;
@property (nonatomic, assign) long devicemodel;

@end

@interface ESNetServiceBrowser : NSObject

@property (nonatomic, copy) void (^didFindService)(NSArray<ESNetServiceItem *> *serviceList);

- (void)startSearch:(NSString *)type inDomain:(NSString *)domain target:(NSString *)target;

- (void)startSearchAvailableBox;

- (void)stopSearch;

@end
