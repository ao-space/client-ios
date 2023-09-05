//
//  YCPollingEntity.m
//  YCEasyTool
//
//  Created by YeTao on 16/5/19.
//
//

#import "YCPollingEntity.h"

@interface YCPollingEntity ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, assign) NSTimeInterval max;

@property (nonatomic, assign) NSTimeInterval current;

@property (nonatomic, copy) YCPollingEntityRunningBlock block;

@property (nonatomic, assign) BOOL running;

@end

@implementation YCPollingEntity

+ (instancetype)pollingEntityWithTimeInterval:(NSTimeInterval)timeInterval {
    return [self pollingEntityWithTimeInterval:timeInterval max:0];
}

+ (instancetype)pollingEntityWithTimeInterval:(NSTimeInterval)timeInterval max:(NSTimeInterval)max {
    YCPollingEntity *polling = [[YCPollingEntity alloc] init];
    polling.timeInterval = timeInterval;
    polling.max = max;
    polling.current = max;
    return polling;
}

- (void)timerHandler {
    if (self.max > 0) {
        self.current -= self.timeInterval;
        if (self.block) {
            self.block(MAX(self.current, 0));
        }
        if (self.current <= 0) {
            [self stopRunning];
        }
    } else {
        self.current += self.timeInterval;
        if (self.block) {
            self.block(self.current);
        }
    }
}

- (void)startRunningWithBlock:(YCPollingEntityRunningBlock)block {
    [self stopRunning];
    self.block = block;
    [self resume];
}

- (void)stopRunning {
    [self pause];
    self.block = nil;
    self.current = self.max;
}

- (void)pause {
    [self.timer invalidate];
    self.timer = nil;
    self.running = NO;
}

- (void)resume {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                  target:self
                                                selector:@selector(timerHandler)
                                                userInfo:nil
                                                 repeats:YES];
    self.running = YES;
}

@end
