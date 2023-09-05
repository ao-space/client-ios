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
//  ESSessionMessage.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSessionMessage.h"
#import "NSString+ESTool.h"

@interface ESSessionMessage ()

@property (nonatomic, strong) NSDictionary *dict;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *method;

@property (nonatomic, strong) NSString *messageId;

@property (nonatomic, strong) NSDictionary *parameters;

@property (nonatomic, strong) NSDictionary *result;

@end

@implementation ESSessionMessage

+ (instancetype)fromMessage:(NSString *)message {
    ESSessionMessage *msg = [ESSessionMessage new];
    msg.message = message;
    [msg fillData];
    return msg;
}

+ (instancetype)fromDict:(NSDictionary *)dict {
    ESSessionMessage *msg = [ESSessionMessage new];
    msg.message = [NSString convertToJsonData:dict];
    msg.dict = dict;
    return msg;
}

- (void)fillData {
    self.dict = [self.message toJson];
    self.method = self.dict[@"method"];
    self.messageId = self.dict[@"messageId"];
    self.parameters = self.dict[@"parameters"];
    self.result = self.dict[@"result"];
}

@end
