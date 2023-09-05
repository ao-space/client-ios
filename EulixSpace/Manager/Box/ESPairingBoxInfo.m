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

#import "ESPairingBoxInfo.h"

@implementation ESPairingBoxInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialize property's default value, if any
    }
    return self;
}

/**
 * Maps json key to property name.
 * This method is used by `JSONModel`.
 */
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"authKey": @"authKey", @"boxName": @"boxName", @"boxPubKey": @"boxPubKey", @"boxUuid": @"boxUuid", @"regKey": @"regKey", @"userDomain": @"userDomain", @"spaceName" : @"spaceName"}];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    NSArray *optionalProperties = @[@"authKey", @"boxName", @"boxPubKey", @"boxUuid", @"regKey", @"userDomain", @"spaceName"];
    return [optionalProperties containsObject:propertyName];
}

@end
