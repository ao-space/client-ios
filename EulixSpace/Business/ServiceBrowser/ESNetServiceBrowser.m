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
//  ESNetServiceBrowser.m
//  EulixSpace
//
//  Created by qu on 2021/6/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESNetServiceBrowser.h"
#import "ESGlobalMacro.h"
#include <arpa/inet.h>

typedef NS_ENUM(NSUInteger, ESNetSearchType) {
    ESNetServiceTypeSpecified = 0, // 通过 btid 搜索指定的
    ESNetServiceTypeAll, // 搜索所有的盒子
};

@interface ESNetServiceItem ()

@property (nonatomic, copy) NSString *domain;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *ipv4;

@property (nonatomic, copy) NSString *ipv6;

@property (nonatomic, assign) int port;

@end

@implementation ESNetServiceItem

- (instancetype)initWithName:(NSString *)name ipv4:(NSString *)ipv4 port:(int)port {
    if (self = [super init]) {
        _name = name;
        _ipv4 = ipv4;
        _port = port;
    }
    return self;
}

@end

@interface ESNetServiceBrowser () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, strong) NSNetServiceBrowser *serviceBrowser;

@property (nonatomic, strong) NSMutableArray<NSNetService *> *serviceList;

@property (nonatomic, strong) NSMutableArray<ESNetServiceItem *> *kownServiceList;

@property (nonatomic, copy) NSString *target;

@property (nonatomic, assign) ESNetSearchType searchType;
@end

@implementation ESNetServiceBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)startSearch:(NSString *)type inDomain:(NSString *)domain target:(NSString *)target {
    ESDLog(@"[MDNS] startSearch---------=%@  =%@  =%@", type, domain, target);
    self.searchType = ESNetServiceTypeSpecified;
    [self stopSearch];
    self.target = target;
    [self.serviceBrowser searchForServicesOfType:type ?: @"_eulixspace-sd._tcp." inDomain:domain ?: @""];
}

- (void)startSearchAvailableBox {
    ESDLog(@"[MDNS] startSearchAvailableBox");
    self.searchType = ESNetServiceTypeAll;
    [self stopSearch];
    [self.serviceBrowser searchForServicesOfType:@"_eulixspace-sd._tcp." inDomain:@""];
}

- (void)stopSearch {
    self.serviceList = NSMutableArray.array;
    self.kownServiceList = NSMutableArray.array;
    [self.serviceBrowser stop];
}

- (void)setup {
    self.serviceList = NSMutableArray.array;
    self.kownServiceList = NSMutableArray.array;

    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    ESDLog(@"[MDNS] didFindService---------=%@  =%@  =%@ =%@", service.name, service.addresses, service.hostName, [[NSString alloc] initWithData:service.TXTRecordData encoding:NSUTF8StringEncoding]);
    [self.serviceList addObject:service];
    service.delegate = self;
    [service resolveWithTimeout:5];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    ESNetServiceItem *item = [self parsingIP:service];
    NSDictionary<NSString *, NSData *> *dataDict = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
    ESDLog(@"[MDNS] freshly resolved netService has TXTRecordData: %@", dataDict);
    
    if (self.searchType == ESNetServiceTypeSpecified) {
        NSArray *array = [self.target componentsSeparatedByString:@"="];
        NSString *key = array.firstObject;
        NSString *value = array.lastObject;
        
        NSData *data = dataDict[key];
        NSString *some = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (![some isEqualToString:value]) {
            return;
        }
    }
    
    if (item.ipv4) {
        [self parseTXTRecordData:dataDict item:item];
        __block BOOL hasItem = NO;
        [self.kownServiceList enumerateObjectsUsingBlock:^(ESNetServiceItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([item.btidhash isEqualToString:obj.btidhash]) {
                hasItem = YES;
                *stop = YES;
                ESDLog(@"[MDNS] already has same box--------- \n%@", item.ipv4);
            }
        }];
        if (hasItem == NO) {
            [self.kownServiceList addObject:item];
        }
        if (self.didFindService) {
            self.didFindService(self.kownServiceList);
        }
        ESDLog(@"[MDNS] netServiceDidResolveAddress--------- \n%@", item.ipv4);
    }
}

- (void)parseTXTRecordData:(NSDictionary<NSString *, NSData *> *)dataDict item:(ESNetServiceItem *)item {
    if ([dataDict.allKeys containsObject:@"btidhash"]) {
        NSData *data = dataDict[@"btidhash"];
        NSString *some = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        item.btidhash = some;
    }
    if ([dataDict.allKeys containsObject:@"webport"]) {
        NSData *data = dataDict[@"webport"];
        NSString *some = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        item.webport = some.intValue;
    }
    if ([dataDict.allKeys containsObject:@"sslport"]) {
        NSData *data = dataDict[@"sslport"];
        NSString *some = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        item.sslport = some.intValue;
    }
    if ([dataDict.allKeys containsObject:@"devicemodel"]) {
        NSData *data = dataDict[@"devicemodel"];
        NSString *some = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        item.devicemodel = some.longLongValue;
    }
}

- (ESNetServiceItem *)parsingIP:(NSNetService *)sender {
    int sPort = 0;
    NSString *ipv4;
    NSString *ipv6;

    for (NSData *address in [sender addresses]) {
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;

        struct sockaddr *socketAddr = (struct sockaddr *)[address bytes];
        if (socketAddr->sa_family == AF_INET) {
            sPort = ntohs(((struct sockaddr_in *)socketAddr)->sin_port);
            struct sockaddr_in *pV4Addr = (struct sockaddr_in *)socketAddr;
            int ipAddr = pV4Addr->sin_addr.s_addr;
            char str[INET_ADDRSTRLEN];
            ipv4 = [NSString stringWithUTF8String:inet_ntop(AF_INET, &ipAddr, str, INET_ADDRSTRLEN)];
        }

        else if (socketAddr->sa_family == AF_INET6) {
            sPort = ntohs(((struct sockaddr_in6 *)socketAddr)->sin6_port);
            struct sockaddr_in6 *pV6Addr = (struct sockaddr_in6 *)socketAddr;
            char str[INET6_ADDRSTRLEN];
            ipv6 = [NSString stringWithUTF8String:inet_ntop(AF_INET6, &pV6Addr->sin6_addr, str, INET6_ADDRSTRLEN)];
        } else {
            ESDLog(@"[MDNS] Socket Family neither IPv4 or IPv6, can't handle...");
        }
    }

    ESNetServiceItem *item = [ESNetServiceItem new];
    item.domain = [sender domain];
    item.name = [sender name];
    item.ipv4 = ipv4;
    item.ipv6 = ipv6;
    item.port = sPort;
    return item;
}

- (void)parsingIP2:(NSNetService *)sender {
    ESDLog(@"[MDNS] %@", NSStringFromSelector(_cmd));

    ESDLog(@"[MDNS] ----netService didResolveAddress %@ %@ %@ %@", sender.name, sender.addresses, sender.hostName, [sender.addresses firstObject]);

    NSArray *addresses = sender.addresses;
    [sender startMonitoring];

    NSString *ip;
    char addressBuffer[INET6_ADDRSTRLEN];
    //服务的IP地址
    for (NSData *data in addresses) {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);

        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;

        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];

        if (socketAddress && (socketAddress->sa.sa_family == AF_INET || socketAddress->sa.sa_family == AF_INET6)) {
            const char *addressStr = inet_ntop(
                socketAddress->sa.sa_family,
                (socketAddress->sa.sa_family == AF_INET ? (void *)&(socketAddress->ipv4.sin_addr) : (void *)&(socketAddress->ipv6.sin6_addr)),
                addressBuffer,
                sizeof(addressBuffer));

            int port = ntohs(socketAddress->sa.sa_family == AF_INET ? socketAddress->ipv4.sin_port : socketAddress->ipv6.sin6_port);

            if (addressStr && port) {
                port = port;
                ip = [NSString stringWithCString:addressStr encoding:NSASCIIStringEncoding];
                ESDLog(@"[MDNS] Found service at %s:%d", addressStr, port);
            }
        }
    }
}

/*
 * 即将查找服务
 */
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    ESDLog(@"[MDNS] -----------------netServiceBrowserWillSearch");
}

/*
 * 停止查找服务
 */
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    ESDLog(@"[MDNS] -----------------netServiceBrowserDidStopSearch");
}

/*
 * 查找服务失败
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    ESDLog(@"[MDNS] ----------------netServiceBrowser didNotSearch");
}

/*
 * 发现域名服务
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    ESDLog(@"[MDNS] ---------------netServiceBrowser didFindDomain");
}

/*
 * 域名服务移除
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    ESDLog(@"[MDNS] ---------------netServiceBrowser didRemoveDomain");
}

/*
 * 客户端服务移除
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    ESDLog(@"[MDNS] ---------------netServiceBrowser didRemoveService");
}

#pragma mark - NSNetServiceDelegate Methods

- (void)netServiceWillResolve:(NSNetService *)netService {
    ESDLog(@"[MDNS] netServiceWillResolve");
}

- (void)netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict {
    ESDLog(@"[MDNS] didNotResolve: %@", errorDict);
}

- (void)netServiceDidStop:(NSNetService *)sender {
}

@end
