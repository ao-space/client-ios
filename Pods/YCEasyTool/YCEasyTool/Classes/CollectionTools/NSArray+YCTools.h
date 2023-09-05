//
//  NSArray+YCTools.h
//  Pods
//
//  Created by Ye Tao on 2017/6/23.
//
//

#import <Foundation/Foundation.h>

@interface NSArray <ObjectType>(YCTools)

- (void)yc_each:(void(NS_NOESCAPE ^)(ObjectType obj))block;

- (void)yc_eachIndex:(void(NS_NOESCAPE ^)(NSUInteger idx, ObjectType obj))block;

- (NSMutableArray *)yc_mapWithBlock:(id(NS_NOESCAPE ^)(NSUInteger idx, ObjectType obj))block;

- (NSMutableArray<ObjectType> *)yc_selectWithBlock:(BOOL(NS_NOESCAPE ^)(NSUInteger idx, ObjectType obj))block;

- (NSMutableArray<ObjectType> *)yc_flattern;

- (NSSet *)yc_toSet;

- (NSArray *)yc_reverse;

@property (nonatomic, readonly) NSArray * (^yc_forEach)(void (^)(NSUInteger idx, ObjectType obj));

@property (nonatomic, readonly) NSMutableArray * (^yc_map)(id (^)(NSUInteger idx, ObjectType obj));

@end
