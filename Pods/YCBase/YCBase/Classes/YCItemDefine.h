//
//  YCItemDefine.h
//  YCBase
//
//  Created by Ye Tao on 05/23/2021.
//  Copyright (c) 2021 Ye Tao. All rights reserved.
//

#ifndef YCItemDefine_h
#define YCItemDefine_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol YCItemProtocol <NSObject>

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, copy) NSString *identifier;

@end

@protocol YCActionCallbackProtocol <NSObject>

@property (nonatomic, copy) void (^actionBlock)(id action);

- (void)reloadWithData:(id<YCItemProtocol>)data;

@end

#endif /* YCItemDefine_h */
