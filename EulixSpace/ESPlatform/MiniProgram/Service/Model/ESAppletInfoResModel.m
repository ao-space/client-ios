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
//  ESAppletInfoResModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletInfoResModel.h"

@implementation ESAppletInfoResModel

- (instancetype)init {
  self = [super init];
  return self;
}


/**
 * Maps json key to property name.
 * This method is used by `JSONModel`.
 */
+ (JSONKeyMapper *)keyMapper {
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"appletId": @"appletId",
                                                                 @"appletVersion": @"appletVersion",
                                                                 @"iconUrl": @"iconUrl",
                                                                 @"isForceUpdate": @"isForceUpdate",
                                                                 @"md5": @"md5",
                                                                 @"name": @"name",
                                                                 @"nameEn": @"nameEn",
                                                                 @"state": @"state",
                                                                 @"updateAt": @"updateAt",
                                                                 @"updateDesc": @"updateDesc",
                                                                 @"memPermission" : @"memPermission"
                                                              }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"appletId",
                                  @"appletVersion",
                                  @"iconUrl",
                                  @"isForceUpdate",
                                  @"md5",
                                  @"name",
                                  @"nameEn",
                                  @"state",
                                  @"updateAt",
                                  @"updateDesc",
                                  @"memPermission"];
  return [optionalProperties containsObject:propertyName];
}

@end
