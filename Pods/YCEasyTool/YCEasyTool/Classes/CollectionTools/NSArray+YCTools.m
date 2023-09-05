//
//  NSArray+YCTools.m
//  Pods
//
//  Created by Ye Tao on 2017/6/23.
//
//

#import "NSArray+YCTools.h"

typedef id (^YCToolsMapBlock)(NSUInteger index, id origin);

typedef BOOL (^YCToolsSelectBlock)(NSUInteger index, id origin);

@implementation NSArray (YCTools)

@dynamic yc_forEach;
@dynamic yc_map;

- (void)yc_each:(void(NS_NOESCAPE ^)(id origin))block {
    if (!block) {
        return;
    }
    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        block(obj);
    }];
}

- (void)yc_eachIndex:(void(NS_NOESCAPE ^)(NSUInteger idx, id origin))block {
    if (!block) {
        return;
    }
    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        block(idx, obj);
    }];
}

- (NSMutableArray *)yc_mapWithBlock:(id(NS_NOESCAPE ^)(NSUInteger idx, id origin))block {
    if (!block) {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [result addObject:[obj yc_mapWithBlock:block]];
        } else {
            id some = block(idx, obj);
            if (some) {
                [result addObject:some];
            }
        }
    }];
    return result;
}

- (NSMutableArray *)yc_flattern {
    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [result addObjectsFromArray:[obj yc_flattern]];
        } else {
            [result addObject:obj];
        }
    }];
    return result;
}

- (NSMutableArray *)yc_selectWithBlock:(BOOL(NS_NOESCAPE ^)(NSUInteger idx, id origin))block {
    if (!block) {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (!block(idx, obj)) {
            return;
        }
        if ([obj isKindOfClass:[NSArray class]]) {
            [result addObject:[obj yc_selectWithBlock:block]];
        } else {
            [result addObject:obj];
        }
    }];
    return result;
}

- (NSSet *)yc_toSet {
    return [NSSet setWithArray:self];
}

- (NSArray *)yc_reverse {
    return [[self reverseObjectEnumerator] allObjects];
}

- (NSArray * (^)(void (^)(NSUInteger, id)))forEach {
    return ^(void (^block)(NSUInteger idx, id obj)) {
        [self enumerateObjectsUsingBlock:^(id _Nonnull obj,
                                           NSUInteger idx,
                                           BOOL *_Nonnull stop) {
            if (block) {
                block(idx, obj);
            }
        }];
        return self;
    };
}

- (NSMutableArray * (^)(id (^)(NSUInteger, id)))yc_map {
    return ^(id (^block)(NSUInteger idx, id obj)) {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
        [self enumerateObjectsUsingBlock:^(id _Nonnull obj,
                                           NSUInteger idx,
                                           BOOL *_Nonnull stop) {
            if (block) {
                id some = block(idx, obj);
                if (some) {
                    [result addObject:some];
                }
            }
        }];
        return result;
    };
}

@end
