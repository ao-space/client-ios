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
//  ESNetworkRequestServiceTask+ESLocalAccess.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESNetworkRequestServiceTask+ESLocalAccess.h"
#import "ESBoxManager.h"
#import "ESToast.h"

@implementation ESNetworkRequestServiceTask (ESLocalAccess)

- (BOOL)localAccess {
//    return ![self.baseURL.absoluteString containsString:@"https"];
    return YES;
}

//- (BOOL)boxCheckingLocalAcesss {
//    ESBoxItem *box = ESBoxManager.activeBox;
//    return box.checkingLocalAcesss;
//}

- (BOOL)clientNotConnectedToInternet:(NSError *)error {
    return error.code == kCFURLErrorNotConnectedToInternet;
}

- (BOOL)pathIngore:(NSString *)path {
    static NSSet *_set = nil;
    if (!_set) {
        _set = [NSSet setWithArray:@[
            @"/agent/v1/api/device/localips", ///agent/v1/api/device/localips
        ]];
    }
    return path && [_set containsObject:path];
}

- (BOOL)boxNotConnectedToInternet:(NSError *)error {
    NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
    if ([response isKindOfClass:NSHTTPURLResponse.class] && response.statusCode == 405) { //Method Not Allowed
        return YES;
    }
    return NO;
}
@end
