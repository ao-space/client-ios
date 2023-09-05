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
//  ESAppInstalledCache.m
//  EulixSpace
//
//  Created by qu on 2023/5/4.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESAppInstalledCache.h"
#import "ESNetworkRequestManager.h"
#import "ESCache.h"
#import "ESBoxManager.h"

@implementation ESAppInstalledCache

static ESAppInstalledCache *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//- (void)getManagementServiceApi {
//    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
//                                                    apiName:@"appstore_installed"
//                                                queryParams:@{}
//                                                     header:@{}
//                                                       body:@{}
//                                                  modelName:nil
//                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
//        NSMutableArray<ESFormItem *> *data = NSMutableArray.array;
//        if([response isKindOfClass:[NSArray class]]){
//
//            NSMutableArray *dataList = [[NSMutableArray alloc] init];
//            NSArray *array = [NSArray new];
//            array = response;
//
//        }
//    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        };
//    }];
//}
- (void)getManagementServiceApi {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"getManagementServiceApi"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        if([response isKindOfClass:[NSArray class]]){
            [self saveAppInstalledCache:response];
        }
    }
        failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {

     }];
}


-(void)saveAppInstalledCache:(NSArray *)results{
    NSString *appIntalledKey = [NSString stringWithFormat:@"%@appstore_installed",ESBoxManager.activeBox.boxUUID];
    [[ESCache defaultCache] setObject:results forKey:appIntalledKey];
}
@end


