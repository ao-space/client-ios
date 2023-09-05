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
//  Realm.h
//  FLEX
//
//  Created by Tim Oliver on 16/02/2016.
//  Copyright © 2016 Realm. All rights reserved.
//

#if __has_include(<Realm/Realm.h>)
#else

@class RLMObject, RLMResults, RLMRealm, RLMRealmConfiguration, RLMSchema, RLMObjectSchema, RLMProperty;

@interface RLMRealmConfiguration : NSObject
@property (nonatomic, copy) NSURL *fileURL;
@end

@interface RLMRealm : NSObject
@property (nonatomic, readonly) RLMSchema *schema;
+ (RLMRealm *)realmWithConfiguration:(RLMRealmConfiguration *)configuration error:(NSError **)error;
- (RLMResults *)allObjects:(NSString *)className;
@end

@interface RLMSchema : NSObject
@property (nonatomic, readonly) NSArray<RLMObjectSchema *> *objectSchema;
- (RLMObjectSchema *)schemaForClassName:(NSString *)className;
@end

@interface RLMObjectSchema : NSObject
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSArray<RLMProperty *> *properties;
@end

@interface RLMProperty : NSString
@property (nonatomic, readonly) NSString *name;
@end

@interface RLMResults : NSObject <NSFastEnumeration>
@property (nonatomic, readonly) NSInteger count;
@end

@interface RLMObject : NSObject

@end

#endif
