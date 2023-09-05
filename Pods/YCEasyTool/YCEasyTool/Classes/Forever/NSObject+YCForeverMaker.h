//
//  NSObject+YCForeverMaker.h
//  YCEasyTool
//
//  Created by Ye Tao on 2018/4/3.
//

#import <Foundation/Foundation.h>

@interface YCForeverMaker : NSObject

#pragma mark - Condition

/**
 set table name
 */
- (YCForeverMaker * (^)(NSString *table))table;

/**
 set where conditions
 1. Just where condition in SQL without `where`, like `somekey = '1'`
 2. [String] like [@"key1", @"key2"]
 */
- (YCForeverMaker * (^)(id where))where;

/**
 set specific sql ONLY for `query`
 */
- (YCForeverMaker * (^)(NSString *sql))sql;

/**
 set limit
 */
- (YCForeverMaker * (^)(NSUInteger limit))limit;

/**
 set offset
 */
- (YCForeverMaker * (^)(NSUInteger offset))offset;

/**
 set order .
 Just where condition in SQL without "Order By"
 Like `somekey desc`
 */
- (YCForeverMaker * (^)(NSString *order))order;

#pragma mark - Operation

//局部更新
- (YCForeverMaker * (^)(void))update;

//会保存NULL
- (YCForeverMaker * (^)(void))save;

- (YCForeverMaker * (^)(void))remove;

- (NSArray * (^)(void))load;

- (NSArray * (^)(void))query;

- (YCForeverMaker * (^)(void))drop;

- (YCForeverMaker * (^)(void))empty;

#pragma mark - DAO Instance

- (YCForeverMaker * (^)(NSString *daoKey))dao;

@end

@interface NSObject (YCForeverMaker)

- (YCForeverMaker *)ycf;

@end
