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
//  ESGatewayRouter.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/2.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESGatewayRouter.h"
#import "NSString+ESTool.h"
#import <YYModel/YYModel.h>

@implementation ESGatewayRouterItem

- (NSString *)description {
    return [self yy_modelToJSONString];
}

@end

@interface ESGatewayRouter ()

@property (nonatomic, strong) NSDictionary *origin;

@property (nonatomic, strong) NSMutableDictionary *routerTable;

@end

@implementation ESGatewayRouter

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)parseRouter {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eulix" ofType:@"bundle"];
    path = [[NSBundle bundleWithPath:path] resourcePath];
    //ESDLog(@"path %@", path);
    NSString *json = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/routers.json", path] encoding:NSUTF8StringEncoding error:nil];
    self.origin = [json toJson];
    self.routerTable = [NSMutableDictionary dictionary];
    [self.origin[@"services"] enumerateKeysAndObjectsUsingBlock:^(id _Nonnull service,
                                                                  NSDictionary *_Nonnull serviceDict,
                                                                  BOOL *_Nonnull stop) {
        //        ESDLog(@"pem %@", service);
        [serviceDict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull api,
                                                         NSDictionary *_Nonnull apiDict,
                                                         BOOL *_Nonnull stop) {
            //            ESDLog(@"pem %@", api);
            ESGatewayRouterItem *item = [ESGatewayRouterItem new];
            item.serviceName = service;
            item.apiName = api;
            item.method = apiDict[@"method"];
            item.type = apiDict[@"type"];
            NSURL *url = [NSURL URLWithString:apiDict[@"url"]];
            item.url = url.path;
            item.key = [self prettyPath:item.url method:item.method];
            self.routerTable[item.key] = item;
        }];
    }];
    //    ESDLog(@"pem %@", self.routerTable);
}

- (NSString *)prettyPath:(NSString *)path method:(NSString *)method {
    path = [path stringByReplacingOccurrencesOfString:@"v1/api/" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"api/v1/" withString:@""];
    if ([path hasSuffix:@"/"]) {
        path = [path substringToIndex:path.length - 1];
    }
    return [path stringByAppendingFormat:@"-%@", method.lowercaseString];
}

- (ESGatewayRouterItem *)routerForPath:(NSString *)path method:(NSString *)method {
    if (!self.routerTable) {
        [self parseRouter];
    }
    return self.routerTable[[self prettyPath:path method:method]];
}

@end
