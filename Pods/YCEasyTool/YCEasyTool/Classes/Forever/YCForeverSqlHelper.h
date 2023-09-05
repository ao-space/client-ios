//
//  YCForeverSqlHelper.h
//  YCEasyTool
//
//  Created by YeTao on 2016/12/20.
//  Copyright © 2016年 ungacy. All rights reserved.
//

#import "YCForeverProtocol.h"
#import <Foundation/Foundation.h>

@interface YCForeverSqlHelper : NSObject

+ (NSString *)createTableSqlWithTable:(NSString *)table
                                class:(Class)cls;

+ (NSString *)insertSqlWithItem:(id<YCForeverItemProtocol>)item
                          table:(NSString *)table;

+ (NSString *)updateSqlWithItem:(id<YCForeverItemProtocol>)item
                          table:(NSString *)table
                          where:(id)where
             overrideWhenUpdate:(BOOL)overrideWhenUpdate;

+ (NSString *)removeSqlWithItem:(id<YCForeverItemProtocol>)item
                          table:(NSString *)table
                          where:(id)where;

+ (NSString *)removeSqlWithItemClass:(Class)itemClass
                               table:(NSString *)table
                               where:(NSString *)where;

+ (NSString *)selectSqlWithItem:(id<YCForeverItemProtocol>)item
                          table:(NSString *)table;

+ (NSString *)selectSqlWithItemArray:(NSArray<id<YCForeverItemProtocol>> *)itemArray
                               table:(NSString *)table;

+ (NSString *)querySqlWithTable:(NSString *)table
                          class:(Class)cls
                          limit:(NSUInteger)limit
                          where:(NSString *)where
                         offset:(NSUInteger)offset
                          order:(NSString *)order;

+ (NSString *)dropSqlWithTable:(NSString *)table;

+ (NSString *)emptySqlWithTable:(NSString *)table;

@end
