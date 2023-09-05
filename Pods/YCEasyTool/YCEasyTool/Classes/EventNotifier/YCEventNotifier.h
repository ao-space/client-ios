//
//  YCEventNotifier.h
//  YCEasyTool
//
//  Created by Ye Tao on 2021/12/3.
//

#import <Foundation/Foundation.h>

@protocol YCEventNotifierDelegate <NSObject>

- (void)eventOccured:(id)event;

@end

@class YCEventNotifier;
@interface NSObject (YCEventNotifier)

@property (nonatomic, weak) YCEventNotifier *yc_asNotifier;

- (void)yc_notifyListener:(id)event;

@end

@interface YCEventNotifier : NSObject

- (void)addListener:(id<YCEventNotifierDelegate>)listener event:(id)event;

- (void)removeListener:(id<YCEventNotifierDelegate>)listener;

- (void)notifyListener:(id)event;

@end
