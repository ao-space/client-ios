//
//  NSObject+YCForeverMaker.m
//  YCEasyTool
//
//  Created by Ye Tao on 2018/4/3.
//

#import "NSObject+YCForeverMaker.h"
#import "YCForeverDAO.h"

@interface YCForeverMaker ()

@property (nonatomic, strong) NSArray *itemArray;

@property (nonatomic, strong) id item;

@property (nonatomic, strong) Class itemClass;

@property (nonatomic, strong) NSMutableDictionary *sqlMap;

@property (nonatomic, weak) YCForeverDAO *daoInstance;

@end

@implementation YCForeverMaker

- (instancetype)init {
    self = [super init];
    if (self) {
        _sqlMap = [NSMutableDictionary dictionary];
        _daoInstance = [YCForeverDAO sharedInstance];
    }
    return self;
}

- (NSString *)tableName {
    NSString *custom = self.sqlMap[@"table"];
    if (custom) {
        return custom;
    }
    Class someClass = self.itemClass;
    if (!someClass) {
        someClass = [self.item class];
    }
    if ([someClass respondsToSelector:@selector(tableName)]) {
        return [someClass tableName];
    }
    return NSStringFromClass(someClass);
}

- (id)whereCondition {
    return self.sqlMap[@"where"];
}

/**
 set where conditions
 */
- (YCForeverMaker * (^)(id where))where {
    return ^YCForeverMaker *(id where) {
        if ([where isKindOfClass:[NSString class]]) {
            NSString *whereString = [where uppercaseString];
            if (![whereString hasPrefix:@"WHERE"]) {
                where = [@"WHERE " stringByAppendingString:where];
            }
        }
        self.sqlMap[@"where"] = where;
        return self;
    };
}

/**
 set table name
 */
- (YCForeverMaker * (^)(NSString *table))table {
    return ^YCForeverMaker *(NSString *table) {
        self.sqlMap[@"table"] = table;
        return self;
    };
}

/**
 set sql
 */
- (YCForeverMaker * (^)(NSString *sql))sql {
    return ^YCForeverMaker *(NSString *sql) {
        self.sqlMap[@"sql"] = sql;
        return self;
    };
}

/**
 set limit
 */
- (YCForeverMaker * (^)(NSUInteger limit))limit {
    return ^YCForeverMaker *(NSUInteger limit) {
        self.sqlMap[@"limit"] = @(limit);
        return self;
    };
}

/**
 set offset
 */
- (YCForeverMaker * (^)(NSUInteger offset))offset {
    return ^YCForeverMaker *(NSUInteger offset) {
        self.sqlMap[@"offset"] = @(offset);
        return self;
    };
}

/**
 set order
 */
- (YCForeverMaker * (^)(NSString *order))order {
    return ^YCForeverMaker *(NSString *order) {
        NSString *orderString = [order uppercaseString];
        if (![orderString hasPrefix:@"ORDER BY"]) {
            order = [@"ORDER BY " stringByAppendingString:order];
        }
        self.sqlMap[@"order"] = order;
        return self;
    };
}

#pragma mark - Operation

- (YCForeverMaker * (^)(void))update {
    return ^YCForeverMaker *(void) {
        [self.daoInstance updateItem:self.item table:self.tableName where:self.whereCondition overrideWhenUpdate:NO];
        return self;
    };
}

- (YCForeverMaker * (^)(void))save {
    return ^YCForeverMaker *() {
        if (self.itemArray) {
            for (NSObject *obj in self.itemArray) {
                self.item = obj;
                [self.daoInstance addItem:obj table:self.tableName];
            }
        } else {
            [self.daoInstance addItem:self.item table:self.tableName];
        }
        return self;
    };
}

- (YCForeverMaker * (^)(void))remove {
    return ^YCForeverMaker *() {
        if (self.itemClass) {
            [self.daoInstance removeItemClass:self.itemClass table:self.tableName where:self.whereCondition];
        } else {
            if (self.itemArray) {
                for (NSObject *obj in self.itemArray) {
                    self.item = obj;
                    [self.daoInstance removeItem:self.item table:self.tableName where:self.whereCondition];
                }
            } else if (self.item) {
                [self.daoInstance removeItem:self.item table:self.tableName where:self.whereCondition];
            }
        }
        return self;
    };
}

- (NSArray * (^)(void))load {
    return ^NSArray *() {
        NSParameterAssert(self.item);
        return [self.daoInstance loadItem:self.item table:self.tableName];
    };
}

- (NSArray * (^)(void))query {
    return ^NSArray *() {
        NSParameterAssert(self.itemClass);
        NSString *sql = self.sqlMap[@"sql"];
        if (sql) {
            return [self.daoInstance queryWithSql:sql class:self.itemClass];
        }
        return [self.daoInstance queryWithTable:self.tableName
                                          class:self.itemClass
                                          where:self.whereCondition
                                          limit:[self.sqlMap[@"limit"] integerValue]
                                         offset:[self.sqlMap[@"offset"] integerValue]
                                          order:self.sqlMap[@"order"]];
    };
}

- (YCForeverMaker * (^)(void))drop {
    return ^YCForeverMaker *() {
        [self.daoInstance dropTableWithTable:self.tableName];
        return self;
    };
}

- (YCForeverMaker * (^)(void))empty {
    return ^YCForeverMaker *() {
        [self.daoInstance emptyTableWithTable:self.tableName];
        return self;
    };
}

- (YCForeverMaker * (^)(NSString *daoKey))dao {
    return ^YCForeverMaker *(NSString *daoKey) {
        if (daoKey) {
            self.daoInstance = [YCForeverDAO instance:daoKey];
        }
        return self;
    };
}

@end

@implementation NSObject (YCForeverMaker)

- (YCForeverMaker *)ycf {
    YCForeverMaker *maker = [YCForeverMaker new];
    if ([self isKindOfClass:[NSArray class]]) {
        maker.itemArray = (NSArray *)self;
    } else {
        maker.item = self;
    }
    return maker;
}

+ (YCForeverMaker *)ycf {
    YCForeverMaker *maker = [YCForeverMaker new];
    maker.itemClass = self;
    return maker;
}

@end
