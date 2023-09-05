//
//  YCEventNotifier.m
//  YCEasyTool
//
//  Created by Ye Tao on 2021/12/3.
//

#import "YCEventNotifier.h"
#import "YCProperty.h"

@interface YCEventNotifier ()

@property (nonatomic, strong) NSMapTable *listenerToEvent;

@end

@implementation YCEventNotifier

- (instancetype)init {
    self = [super init];
    if (self) {
        _listenerToEvent = NSMapTable.weakToStrongObjectsMapTable;
    }
    return self;
}

- (void)addListener:(id<YCEventNotifierDelegate>)listener event:(id)event {
    [self.listenerToEvent setObject:event forKey:listener];
}

- (void)removeListener:(id<YCEventNotifierDelegate>)listener {
    for (id key in [self.listenerToEvent keyEnumerator]) {
        if (key == listener) {
            [self.listenerToEvent removeObjectForKey:key];
            break;
        }
    }
}

- (void)notifyListener:(id)event {
    for (id<YCEventNotifierDelegate> listener in [self.listenerToEvent keyEnumerator]) {
        if ([self.listenerToEvent objectForKey:listener] == event) {
            if ([listener respondsToSelector:@selector(eventOccured:)]) {
                [listener eventOccured:event];
            }
        }
    }
}

@end

@implementation NSObject (YCEventNotifier)

@dynamic yc_asNotifier;

- (YCEventNotifier *)yc_asNotifier {
    NSString *key = NSStringFromSelector(_cmd);
    YCEventNotifier *notifier = self.yc_store(key, nil);
    if (!notifier) {
        notifier = YCEventNotifier.new;
        self.yc_store(key, notifier);
    }
    return notifier;
}

- (void)yc_notifyListener:(id)event {
    YCEventNotifier *notifier = self.yc_asNotifier;
    [notifier notifyListener:event];
}

@end
