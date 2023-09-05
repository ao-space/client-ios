//
//  YCForeverProtocol.h
//  YCEasyTool
//
//  Created by YeTao on 2016/12/20.
//  Copyright © 2016年 ungacy. All rights reserved.
//

#ifndef YCForeverProtocol_h
#define YCForeverProtocol_h

#import <Foundation/Foundation.h>

@protocol YCForeverItemProtocol <NSObject>

@optional
/**
 Primary Key In Table

 @return Primary Key
 */
+ (NSString *)primaryKey;

+ (NSString *)tableName;

+ (NSArray *)primaryKeyArray;

@end

#endif /* YCForeverProtocol_h */
