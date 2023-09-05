//
//  ESLoopPollManager.h
//  EulixSpace
//
//  Created by dazhou on 2023/7/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESLoopPollManager : NSObject

+ (ESLoopPollManager *)Instance;

-(void)start;
- (void)processRevoke;

- (void)setSystemInfo:(BOOL)isReceive;
- (BOOL)isReceiveSystemInfo;
- (void)setBusinessInfo:(BOOL)isReceive;
- (BOOL)isReceiveBusinessInfo;

@end

NS_ASSUME_NONNULL_END
