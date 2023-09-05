//
//  YCMemeryCache.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/9.
//
//

#import <Foundation/Foundation.h>

@interface YCMemeryCache : NSObject

+ (void)cacheObject:(id)object forKey:(NSString *)key;

+ (id)cacheForKey:(NSString *)key;

@end
