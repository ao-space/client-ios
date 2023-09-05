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
//  ESDatabaseManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESDatabaseManager.h"
#import "ESAccount+WCTTableCoding.h"
#import "ESBoxManager.h"
#import "ESFileDataList+WCTTableCoding.h"
#import "ESGlobalMacro.h"
#import "ESLocalPath.h"
#import "ESTableFileInfo.h"
#import "ESUploadMetadata.h"

extern NSString *const kESDatabaseAccount = @"account";

extern NSString *const kESDatabaseUploadMetadata = @"uploadMetadata";

extern NSString *const kESDatabaseFileInfo = @"file_info";

extern NSString *const kESDatabaseFilelist = @"fileDataList";

@interface ESDatabaseManager ()

@property (nonatomic, strong) WCTDatabase *database;

@property (nonatomic, strong) NSDictionary<NSString *, Class> *tableToClassMap;

@end

@implementation ESDatabaseManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)isReady {
    return self.database != nil;
}

- (void)close:(void (^)(void))onClosed {
    if (_database) {
        [_database close:onClosed];
    } else {
        onClosed();
    }
}

- (void)setupDatabase:(NSString *)boxUUID onCreate:(void (^)(void))onCreate {
    weakfy(self);
    [self close:^{
        strongfy(self);
        NSString *name = [NSString stringWithFormat:@"%@.db", boxUUID];
        NSString *directory = [ESLocalPath.applicationSupportDirectory stringByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier];
        self.database = [[WCTDatabase alloc] initWithPath:[directory stringByAppendingPathComponent:name]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableToClassMap enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, Class _Nonnull obj, BOOL *_Nonnull stop) {
                [self.database createTableAndIndexesOfName:key withClass:obj];
            }];
            if (onCreate) {
                onCreate();
            }
        });
    }];
}

///Common

- (void)save:(NSArray *)data {
    NSString *table = [self.tableToClassMap allKeysForObject:[data.firstObject class]].firstObject;
    if (!table) {
        return;
    }
    [self.database insertOrReplaceObjects:data into:table];
}

- (NSArray *)query:(Class)some {
    NSString *table = [self.tableToClassMap allKeysForObject:some].firstObject;
    if (!table) {
        return nil;
    }
    return [self.database getObjectsOfClass:some fromTable:table where:1 == 1];
}

- (WCTSelect *)select:(Class)some {
    NSString *table = [self.tableToClassMap allKeysForObject:some].firstObject;
    if (!table) {
        return nil;
    }
    return [self.database prepareSelectObjectsOfClass:some fromTable:table];
}

- (WCTDelete *)delete:(Class)some {
    NSString *table = [self.tableToClassMap allKeysForObject:some].firstObject;
    if (!table) {
        return nil;
    }
    return [self.database prepareDeleteFromTable:table];
}

- (WCTUpdate *)update:(Class)some {
    NSString *table = [self.tableToClassMap allKeysForObject:some].firstObject;
    if (!table) {
        return nil;
    }
    return [self.database prepareUpdateTable:table onProperties:[some AllProperties]];
}

#pragma mark - Lazy Load

- (BOOL)insertObjects:(NSArray<WCTObject *> *)array into:(NSString *)tableName {
    BOOL result = [_database insertObjects:array into:tableName];
    return result;
}

- (BOOL)createTableAndIndexesOfName:(NSString *)tableName withClass:(Class)cls {
    BOOL result = [self.database createTableAndIndexesOfName:tableName
                                                   withClass:cls];
    return result;
}

- (BOOL)deleteObjectsFromTable:(NSString *)tableName {
    BOOL result = [self.database deleteAllObjectsFromTable:tableName];
    return result;
}

- (NSArray *)getFilesByUids:(NSString *)tableName withClass:(Class)cls category:(NSString *)category {
    NSArray *tem = [NSArray new];
    if ([cls isEqual:ESFileDataList.class]) {
        if (category.length < 1) {
            tem = [self.database getAllObjectsOfClass:cls fromTable:tableName];
        } else {
            tem = [self.database getObjectsOfClass:cls fromTable:tableName where:ESFileDataList.category == category];
        }
    }
    return tem;
}

- (void)reset {
    [self.tableToClassMap.allKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull tableName, NSUInteger idx, BOOL *_Nonnull stop) {
        [self deleteObjectsFromTable:tableName];
    }];
}

#pragma mark - Lazy Load

- (NSDictionary *)tableToClassMap {
    if (!_tableToClassMap) {
        _tableToClassMap = @{
            kESDatabaseAccount: ESAccount.class,
            kESDatabaseFilelist: ESFileDataList.class,
            kESDatabaseUploadMetadata: ESUploadMetadata.class,
            kESDatabaseFileInfo: ESTableFileInfo.class,
        };
    }
    return _tableToClassMap;
}

@end
