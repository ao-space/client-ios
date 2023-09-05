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
//  ESScanQrJSBCommand.m
//  EulixSpace
//
//  Created by KongBo on 2023/3/28.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESScanQrJSBCommand.h"
#import "ESQRCodeScanViewController.h"

@implementation ESScanQrJSBCommand
/**
{
 参数：{from?:'',type: 1 , regExpStr?:"/\d{6,8}/"}
}*/

- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        if (![data isKindOfClass:[NSDictionary class]]) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        NSDictionary *params = (NSDictionary *)data;
        NSString *from = params[@"from"];
        NSInteger type = params[@"type"] ? [params[@"type"] intValue] : ESQRCodeScanActionDefault;
        NSString *regExpStr = params[@"regExpStr"];
        
        ESQRCodeScanViewController *next = [ESQRCodeScanViewController new];
        next.action = type;
        if (regExpStr.length > 0) {
            next.action = ESQRCodeScanActionDefault;
            next.regExpStr = regExpStr;
        }
        next.callback = ^(NSString *value) {
            responseCallback(@{ @"code" : @(200),
                                @"data" : @{@"content" : ESSafeString(value)},
                                @"msg" :  @{},
                                @"context" : @{
                                    @"platform" : @"iOS",
                                }
                             });
        };
        if (self.context.webVC.navigationController != nil) {
            [self.context.webVC.navigationController pushViewController:next animated:YES];
        } else {
            [self.context.webVC presentViewController:next animated:YES completion:^{
            }];
        }
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"scanQrCode";
}
@end
