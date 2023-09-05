//
//  YCForeverDAO.m
//  YCEasyTool
//
//  Created by YeTao on 2016/12/20.
//  Copyright © 2016年 ungacy. All rights reserved.
//

#import "YCForeverDAO.h"
#import "YCForeverSqlHelper.h"
#import "YCProperty.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

void YCBindStatementToObject(__unsafe_unretained id model,
                             __unsafe_unretained YCProperty *property,
                             int idx,
                             sqlite3_stmt *stmt) {
    switch (property.type) {
        case YCEncodingTypeBool: {
            bool value = sqlite3_column_int(stmt, idx);
            ((void (*)(id, SEL, bool))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeInt8: {
            int8_t value = sqlite3_column_int(stmt, idx);
            ((void (*)(id, SEL, int8_t))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeUInt8: {
            uint8_t value = sqlite3_column_int(stmt, idx);
            ((void (*)(id, SEL, uint8_t))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeInt16: {
            int16_t value = sqlite3_column_int(stmt, idx);
            ((void (*)(id, SEL, int16_t))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeUInt16: {
            uint16_t value = sqlite3_column_int(stmt, idx);
            ((void (*)(id, SEL, uint16_t))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeInt32: {
            int32_t value = sqlite3_column_int(stmt, idx);
            ((void (*)(id, SEL, int32_t))(void *)objc_msgSend)(model, property.setter, value);
        }
        case YCEncodingTypeUInt32: {
            uint32_t value = sqlite3_column_int(stmt, idx);
            ((void (*)(id, SEL, uint32_t))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeInt64: {
            int64_t value = sqlite3_column_int64(stmt, idx);
            ((void (*)(id, SEL, int64_t))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeUInt64: {
            uint64_t value = sqlite3_column_int64(stmt, idx);
            ((void (*)(id, SEL, uint64_t))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeFloat: {
            float value = sqlite3_column_int64(stmt, idx);
            if (isnan(value) || isinf(value)) {
                value = 0;
            }
            ((void (*)(id, SEL, float))(void *)objc_msgSend)(model, property.setter, value);
        } break;
        case YCEncodingTypeDouble: {
            double value = sqlite3_column_int64(stmt, idx);
            if (isnan(value) || isinf(value)) {
                value = 0;
            }
            ((void (*)(id, SEL, double))(void *)objc_msgSend)(model, property.setter, value);

        } break;
        case YCEncodingTypeLongDouble: {
            long double value = sqlite3_column_int64(stmt, idx);
            if (isnan(value) || isinf(value)) {
                value = 0;
            }
            ((void (*)(id, SEL, long double))(void *)objc_msgSend)(model, property.setter, value);
        }
        case YCEncodingTypeString: {
            const char *charValue = (const char *)sqlite3_column_text(stmt, idx);
            if (charValue != NULL) {
                id value = [NSString stringWithUTF8String:charValue];
                if ([property.objcType isEqualToString:@"NSNumber"]) {
                    if ([value rangeOfString:@"."].length == 0) {
                        value = @([value integerValue]);
                    } else {
                        value = @([value doubleValue]);
                    }
                }
                ((void (*)(id, SEL, id))(void *)objc_msgSend)(model, property.setter, value);
            }
        } break;
        default:
            break;
    }
}

static inline void YCBindObjectToStatement(__unsafe_unretained id model,
                                           __unsafe_unretained YCProperty *property,
                                           int idx,
                                           sqlite3_stmt *pStmt) {
    switch (property.type) {
        case YCEncodingTypeBool: {
            bool obj = ((bool (*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int(pStmt, idx, obj);
        } break;
        case YCEncodingTypeInt8: {
            int8_t obj = ((int8_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int(pStmt, idx, obj);
        } break;
        case YCEncodingTypeUInt8: {
            uint8_t obj = ((uint8_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int(pStmt, idx, obj);
        } break;
        case YCEncodingTypeInt16: {
            int16_t obj = ((int16_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int(pStmt, idx, obj);
        } break;
        case YCEncodingTypeUInt16: {
            uint16_t obj = ((uint16_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int(pStmt, idx, obj);
        } break;
        case YCEncodingTypeInt32: {
            int32_t obj = ((int32_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int(pStmt, idx, obj);
        } break;
        case YCEncodingTypeUInt32: {
            uint32_t obj = ((uint32_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int64(pStmt, idx, (int64_t)obj);
        } break;
        case YCEncodingTypeInt64: {
            int64_t obj = ((int64_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_int64(pStmt, idx, obj);
        } break;
        case YCEncodingTypeUInt64: {
            uint64_t obj = ((uint64_t(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            sqlite3_bind_double(pStmt, idx, (double)obj);
        } break;
        case YCEncodingTypeFloat: {
            float obj = ((float (*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            if (isnan(obj) || isinf(obj)) {
                obj = 0;
            }
            sqlite3_bind_double(pStmt, idx, (double)obj);
        } break;
        case YCEncodingTypeDouble: {
            double obj = ((double (*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            if (isnan(obj) || isinf(obj)) {
                obj = 0;
            }
            sqlite3_bind_double(pStmt, idx, obj);
        } break;
        case YCEncodingTypeLongDouble: {
            long double obj = ((long double (*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            if (isnan(obj) || isinf(obj)) {
                obj = 0;
            }
            sqlite3_bind_double(pStmt, idx, (double)obj);
        } break;
        case YCEncodingTypeString: {
            id obj = ((id(*)(id, SEL))(void *)objc_msgSend)(model, property.getter);
            if (!obj) {
                return;
            }
            if ([property.objcType isEqualToString:@"NSNumber"]) {
                obj = [NSString stringWithFormat:@"%@", obj];
            }
            sqlite3_bind_text(pStmt, idx, [obj description].UTF8String, -1, NULL);
        } break;
        default: {
            sqlite3_bind_int(pStmt, idx, 0);
            break;
        };
    }
}

static NSString *const kYCForeverDAODefaultKey = @"com.ungacy.forever";

@interface YCForeverDAO ()

@property (nonatomic, strong) NSString *dbPath;

@property (nonatomic, assign) sqlite3 *db;

@property (nonatomic, strong) NSMapTable *daoInstance;

@property (nonatomic, copy) NSString *key;

@end

@implementation YCForeverDAO {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
    NSMutableSet *_globalInstances;
    CFMutableDictionaryRef _dbStmtCache;
}

+ (instancetype)sharedInstance {
    static YCForeverDAO *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.daoInstance = [NSMapTable strongToStrongObjectsMapTable];
    });
    return instance;
}

+ (instancetype)instance:(NSString *)key {
    YCForeverDAO *shared = YCForeverDAO.sharedInstance;
    YCForeverDAO *some = [shared.daoInstance objectForKey:key];
    if (!some) {
        some = [[YCForeverDAO alloc] initWithKey:key];
        [shared.daoInstance setObject:some forKey:key];
    }
    return some;
}

- (instancetype)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        const char *_Nullable label = [key UTF8String];
        _queue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
        _globalInstances = [NSMutableSet setWithCapacity:0];
        _verbose = YES;
        _key = key;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillBeTerminated) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (instancetype)init {
    return [self initWithKey:kYCForeverDAODefaultKey];
}

- (void)_appWillBeTerminated {
    Lock();
    UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    }];
    [self _dbClose];
    if (taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
    }
    Unlock();
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

#pragma mark - db

- (BOOL)_dbOpen {
    if (_db) {
        return YES;
    }
    if (!_dbPath) {
        return NO;
    }
    int result = sqlite3_open(self.dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallbacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
        return YES;
    } else {
        _db = NULL;
        if (_dbStmtCache) {
            CFRelease(_dbStmtCache);
        }
        _dbStmtCache = NULL;
        if (self.verbose) {
            NSLog(@"%s line:%d sqlite open failed (%d).", __FUNCTION__, __LINE__, result);
        }
    }
    return NO;
}

- (BOOL)_dbClose {
    if (!_db) {
        return YES;
    }
    int result = 0;
    BOOL retry = NO;
    BOOL stmtFinalized = NO;
    if (_dbStmtCache) {
        CFRelease(_dbStmtCache);
    }
    _dbStmtCache = NULL;
    do {
        retry = NO;
        result = sqlite3_close(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
                    sqlite3_finalize(stmt);
                    retry = YES;
                }
            }
        } else if (result != SQLITE_OK) {
            if (self.verbose) {
                NSLog(@"%s line:%d sqlite close failed (%d).", __FUNCTION__, __LINE__, result);
            }
        }
    } while (retry);
    [_globalInstances removeAllObjects];
    _db = NULL;
    return YES;
}

- (BOOL)_dbExecute:(NSString *)sql {
    if (sql.length == 0) {
        return NO;
    }
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        if (self.verbose) {
            NSLog(@"%s line:%d sqlite failed to excute sql %@ due to error (%s).", __FUNCTION__, __LINE__, sql, error);
        }
        sqlite3_free(error);
    }
    return result == SQLITE_OK;
}

- (sqlite3_stmt *)_dbPrepareStmt:(NSString *)sql {
    if (sql.length == 0 || !_dbStmtCache) {
        return NULL;
    }
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)(sql));
    if (!stmt) {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            if (self.verbose) {
                NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s\n%@", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db), sql);
            }
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)(sql), stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}

- (BOOL)_dbCheckWithTable:(NSString *)table class:(Class)cls {
    if (![self _dbOpen] || !table || !cls) {
        return NO;
    }
    if (![_globalInstances containsObject:table]) {
        NSString *sql = [YCForeverSqlHelper createTableSqlWithTable:table class:cls];
        if (!sql) {
            return NO;
        }

        BOOL result = [self _dbExecute:sql];
        if (result) {
            [_globalInstances addObject:table];
        }
        return result;
    }
    return YES;
}

- (BOOL)_dbSetItemFromStmt:(sqlite3_stmt *)stmt item:(NSObject<YCForeverItemProtocol> *)item {
    NSArray *propertyArray = [item yc_propertyArray];
    for (NSUInteger idx = 0; idx < propertyArray.count; idx++) {
        YCProperty *obj = propertyArray[idx];
        YCBindStatementToObject(item, obj, (int)idx, stmt);
    }
    return YES;
}

#pragma mark - public

- (void)setupWithPath:(NSString *)path {
    YCForeverDAO *dao = self;
    if ([path isEqualToString:dao.dbPath]) {
        return;
    } else {
        [self close];
    }
    dao.dbPath = path;
}

- (void)close {
    [self _dbClose];
}

+ (void)close {
    [[YCForeverDAO sharedInstance] _dbClose];
}

- (NSArray<NSDictionary *> *)queryWithSql:(NSString *)sql {
    Lock();
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) {
        Unlock();
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (int column = 0; column < sqlite3_column_count(stmt); column++) {
            const char *charType = sqlite3_column_decltype(stmt, column);
            const char *charKey = (const char *)sqlite3_column_name(stmt, column);
            NSString *key = [NSString stringWithUTF8String:charKey];
            if (strcmp(charType, "text") == 0) {
                const char *charValue = (const char *)sqlite3_column_text(stmt, column);
                NSString *value = [NSString stringWithUTF8String:charValue];
                dict[key] = value;
            } else if (strcmp(charType, "real") == 0) {
                double value = sqlite3_column_double(stmt, column);
                dict[key] = @(value);
            } else if (strcmp(charType, "integer") == 0) {
                uint64_t value = sqlite3_column_int64(stmt, column);
                dict[key] = @(value);
            }
        }
        [array addObject:dict];
    }
    Unlock();
    return array;
}

- (void)clear {
    [self _dbOpen];
    NSString *sql = @"SELECT name FROM sqlite_master WHERE type='table';";
    NSArray *array = [self queryWithSql:sql];
    for (NSDictionary *dict in array) {
        NSString *name = dict[@"name"];
        [self dropTableWithTable:name];
    }
}

- (BOOL)addItem:(NSObject<YCForeverItemProtocol> *)item table:(NSString *)table {
    Lock();
    if (![self _dbCheckWithTable:table class:[item class]]) {
        Unlock();
        return NO;
    }
    NSString *sql = [YCForeverSqlHelper insertSqlWithItem:item table:table];
    if (!sql) {
        Unlock();
        return NO;
    }
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) {
        Unlock();
        return NO;
    }
    NSArray<YCProperty *> *propertyArray = [item yc_propertyArray];

    for (NSUInteger idx = 0; idx < propertyArray.count; idx++) {
        YCProperty *obj = propertyArray[idx];
        YCBindObjectToStatement(item, obj, (int)idx + 1, stmt);
    }
    BOOL result = YES;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        if (self.verbose) {
            NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
        result = NO;
    }
    Unlock();
    return result;
}

- (BOOL)updateItem:(id)item table:(NSString *)table where:(id)where overrideWhenUpdate:(BOOL)overrideWhenUpdate {
    Lock();
    if (![self _dbCheckWithTable:table class:[item class]]) {
        Unlock();
        return NO;
    }
    NSString *sql = [YCForeverSqlHelper updateSqlWithItem:item table:table where:where overrideWhenUpdate:overrideWhenUpdate];
    if (!sql) {
        Unlock();
        return NO;
    }
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) {
        Unlock();
        return NO;
    }
    NSArray<YCProperty *> *propertyArray = [item yc_propertyArray];

    for (NSUInteger idx = 0; idx < propertyArray.count; idx++) {
        YCProperty *obj = propertyArray[idx];
        YCBindObjectToStatement(item, obj, (int)idx + 1, stmt);
    }
    BOOL result = YES;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        if (self.verbose) {
            NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
        result = NO;
    }
    Unlock();
    return result;
}

- (NSArray *)loadItem:(id<YCForeverItemProtocol>)item table:(NSString *)table {
    Lock();
    if (![self _dbCheckWithTable:table class:[item class]]) {
        Unlock();
        return nil;
    }
    NSString *sql = [YCForeverSqlHelper selectSqlWithItem:item table:table];
    if (!sql) {
        Unlock();
        return nil;
    }
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) {
        Unlock();
        return nil;
    }
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:0];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        id<YCForeverItemProtocol> newItem = [[[item class] alloc] init];
        [self _dbSetItemFromStmt:stmt item:newItem];
        [itemArray addObject:newItem];
    }
    Unlock();
    return itemArray;
}

- (BOOL)removeItem:(id<YCForeverItemProtocol>)item table:(NSString *)table where:(id)where {
    Lock();
    if (![self _dbCheckWithTable:table class:[item class]]) {
        Unlock();
        return NO;
    }
    NSString *sql = [YCForeverSqlHelper removeSqlWithItem:item table:table where:(id)where];
    BOOL result = [self _dbExecute:sql];
    Unlock();
    return result;
}

- (BOOL)removeItemClass:(Class)itemClass table:(NSString *)table where:(id)where {
    Lock();
    if (![self _dbCheckWithTable:table class:itemClass]) {
        Unlock();
        return NO;
    }
    NSString *sql = [YCForeverSqlHelper removeSqlWithItemClass:itemClass table:table where:(id)where];
    BOOL result = [self _dbExecute:sql];
    Unlock();
    return result;
}

- (NSArray<id<YCForeverItemProtocol>> *)queryWithTable:(NSString *)table
                                                 class:(Class)cls
                                                 where:(NSString *)where
                                                 limit:(NSUInteger)limit
                                                offset:(NSUInteger)offset
                                                 order:(NSString *)order {
    if (![self _dbCheckWithTable:table class:cls]) {
        return nil;
    }

    NSString *sql = [YCForeverSqlHelper querySqlWithTable:table
                                                    class:cls
                                                    limit:limit
                                                    where:(NSString *)where
                                                   offset:offset
                                                    order:order];
    return [self queryWithSql:sql class:cls];
}

- (NSArray<id<YCForeverItemProtocol>> *)queryWithSql:(NSString *)sql
                                               class:(Class)cls {
    if (!sql) {
        return nil;
    }
    Lock();
    if (![self _dbOpen]) {
        Unlock();
        return nil;
    }
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) {
        Unlock();
        return nil;
    }
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:0];
    int count = sqlite3_column_count(stmt);
    if (count != [cls yc_propertyArray].count || !cls) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
            int columns = sqlite3_column_count(stmt);
            for (int i = 0; i < columns; i++) {
                char *name = (char *)sqlite3_column_name(stmt, i);
                NSString *key = [NSString stringWithUTF8String:name];
                switch (sqlite3_column_type(stmt, i)) {
                    case SQLITE_INTEGER: {
                        int num = sqlite3_column_int(stmt, i);
                        [itemDic setValue:[NSNumber numberWithInt:num] forKey:key];
                    } break;
                    case SQLITE_FLOAT: {
                        float num = sqlite3_column_double(stmt, i);
                        [itemDic setValue:[NSNumber numberWithFloat:num] forKey:key];
                    } break;
                    case SQLITE3_TEXT: {
                        char *text = (char *)sqlite3_column_text(stmt, i);
                        [itemDic setValue:[NSString stringWithUTF8String:text] forKey:key];
                    } break;
                    case SQLITE_BLOB: {
                        //Need to implement
                        [itemDic setValue:@"binary" forKey:key];
                    } break;
                    case SQLITE_NULL: {
                        [itemDic setValue:[NSNull null] forKey:key];
                    }
                    default:
                        break;
                }
            }
            [itemArray addObject:itemDic];
        }
        Unlock();
        return itemArray;
    }
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        id<YCForeverItemProtocol> newItem = [[cls alloc] init];
        [self _dbSetItemFromStmt:stmt item:newItem];
        [itemArray addObject:newItem];
    }
    Unlock();
    return itemArray;
}

- (BOOL)dropTableWithTable:(NSString *)table {
    Lock();
    NSString *sql = [YCForeverSqlHelper dropSqlWithTable:table];
    if (!sql) {
        Unlock();
        return NO;
    }
    if (![self _dbOpen]) {
        Unlock();
        return NO;
    }
    BOOL result = [self _dbExecute:sql];
    if (result) {
        [_globalInstances removeObject:table];
    }
    Unlock();
    return result;
}

- (BOOL)emptyTableWithTable:(NSString *)table {
    Lock();
    NSString *sql = [YCForeverSqlHelper emptySqlWithTable:table];
    if (!sql) {
        Unlock();
        return NO;
    }
    if (![self _dbOpen]) {
        Unlock();
        return NO;
    }
    BOOL result = [self _dbExecute:sql];
    Unlock();
    return result;
}

@end
