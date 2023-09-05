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
//  ESCacheInfoDBManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESCacheInfoDBManager.h"
#import <WCDB/WCDB.h>
#import "ESCacheInfoItem+WCTTableCoding.h"

@interface ESCacheInfoDBManager ()

@property (nonatomic,strong) WCTDatabase *database;

@end

@implementation ESCacheInfoDBManager

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        [instance createDataBase];
    });
    return instance;
}

- (BOOL)cleanDBCache {
    BOOL result = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESCacheInfoItem.class)];
    return result;
}

- (WCTDatabase *)createDataBase {
    if (_database) {
        return _database;
    }
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //注意，此处数据库名字不要带sqlite的后缀名，恢复数据库的时候如果有这个后缀名，会造成无法恢复的情况。这是一个坑啊，大家千万要注意
    NSString *path = [NSString stringWithFormat:@"%@/chatDB_%@",docDir, @"cacheInfo"];
    _database = [[WCTDatabase alloc] initWithPath:path];
   
    BOOL result = [_database isTableExists:NSStringFromClass(ESCacheInfoItem.class)];
    if (!result) {
        result = [_database createTableAndIndexesOfName:NSStringFromClass(ESCacheInfoItem.class)
                                                        withClass:ESCacheInfoItem.class];
    }
    
    if (result) {
        return _database;
    }
    return nil;
}

+ (void)cleanAllDB {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //注意，此处数据库名字不要带sqlite的后缀名，恢复数据库的时候如果有这个后缀名，会造成无法恢复的情况。这是一个坑啊，大家千万要注意
    NSString *path = [NSString stringWithFormat:@"%@/chatDB_%@",docDir, @"cacheInfo"];
    WCTDatabase *database = [[WCTDatabase alloc] initWithPath:path];
    [database close];
    NSError *error;
    [database removeFilesWithError:&error];
}

#pragma mark - smartPhoto cache
- (NSArray<ESCacheInfoItem *> *)getCaheInfoFromDBType:(ESBusinessCacheInfoType)type {
    NSArray *ary = [self.database getObjectsOfClass:ESCacheInfoItem.class
                                             fromTable:NSStringFromClass(ESCacheInfoItem.class)
                                                 where:ESCacheInfoItem.cacheType == type];
    return ary;
}

- (NSInteger)cacheSizeByType:(ESBusinessCacheInfoType)type {
    NSArray<ESCacheInfoItem *> *cacheItemList = [self getCaheInfoFromDBType:type];
    __block  NSInteger totalSize = 0;
    [cacheItemList enumerateObjectsUsingBlock:^(ESCacheInfoItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        totalSize += item.size;
    }];
    return totalSize;
}


- (BOOL)insertOrUpdatCacheInfoToDB:(NSArray<ESCacheInfoItem *> *)infoItemList {
    BOOL result = [self.database insertOrReplaceObjects:infoItemList into:NSStringFromClass(ESCacheInfoItem.class)];
    return result;
}

- (BOOL)removeCacheInfoFromDBByUUId:(NSString *)uuid {
    BOOL result = [self.database deleteObjectsFromTable:NSStringFromClass(ESCacheInfoItem.class) where:ESCacheInfoItem.uuid == uuid];
    return result;
}

- (BOOL)deleteCacheDBDataByType:(ESBusinessCacheInfoType)type {
    BOOL result = [self.database deleteObjectsFromTable:NSStringFromClass(ESCacheInfoItem.class) where:ESCacheInfoItem.cacheType == type];
    return result;
}

- (BOOL)deleteAllCacheDBData {
    BOOL result = [self.database deleteAllObjectsFromTable:NSStringFromClass(ESCacheInfoItem.class)];
    return result;
}

@end

