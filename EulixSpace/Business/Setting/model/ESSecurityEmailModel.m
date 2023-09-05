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
//  ESSecurityEmailModel.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityEmailModel.h"

@implementation ESSecurityEmailModel

- (instancetype)init {
    if (self = [super init]) {
        self.emailAccount = @"example@company.com";
        self.host = @"smtp.company.com";
        self.sslEnable = true;
    }
    return self;
}

@end


@implementation ESSecurityEmailConfigModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"configurations" : [ESSecurityEmailConfigItemModel class] };
}

- (ESSecurityEmailServersModel *)getServers:(NSString *)emailType smtp:(BOOL)isSMTP {
    if (emailType == nil) {
        return nil;
    }
    
    NSString * lowKey = [emailType lowercaseString];
    ESSecurityEmailConfigItemModel * item = self.configurations[lowKey];
    if (item == nil || item.servers == nil) {
        return nil;
    }
    
    if (isSMTP) {
        return item.servers[@"smtp"];
    }
    return item.servers[@"pop3"];
}

@end


@implementation ESSecurityEmailConfigItemModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"servers" : [ESSecurityEmailServersModel class] };
}
@end

@implementation ESSecurityEmailInfosModel


@end


@implementation ESSecurityEmailServersModel

@end
