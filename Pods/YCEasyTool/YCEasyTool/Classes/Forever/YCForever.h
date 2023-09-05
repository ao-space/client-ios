//
//  YCForever.h
//  YCEasyTool
//
//  Created by YeTao on 2016/12/20.
//  Copyright © 2016年 ungacy. All rights reserved.
//

#import "NSObject+YCForeverMaker.h"
#import "YCForeverProtocol.h"
#import <Foundation/Foundation.h>

@interface YCForever : NSObject

+ (void)setupWithPath:(NSString *)path;

+ (void)setupWithName:(NSString *)name;

+ (void)setupWithName:(NSString *)name key:(NSString *)key;

+ (void)close;

@end
