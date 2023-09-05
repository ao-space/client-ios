//
//  YCMemeryCache.m
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/9.
//
//

#import "YCMemeryCache.h"

@interface YCMemeryCache ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation YCMemeryCache {
    dispatch_semaphore_t _lock;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)cacheForKey:(NSString *)key {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id object = [self.cache objectForKey:key];
    dispatch_semaphore_signal(_lock);
    return object;
}

- (void)cacheObject:(id)object forKey:(NSString *)key {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.cache setObject:object forKey:key];
    dispatch_semaphore_signal(_lock);
}

+ (id)cacheForKey:(NSString *)key {
    return [[YCMemeryCache sharedInstance] cacheForKey:key];
}

+ (void)cacheObject:(id)object forKey:(NSString *)key {
    [[YCMemeryCache sharedInstance] cacheObject:object forKey:key];
}

- (NSMutableDictionary *)cache {
    if (!_cache) {
        _cache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _cache;
}

@end
