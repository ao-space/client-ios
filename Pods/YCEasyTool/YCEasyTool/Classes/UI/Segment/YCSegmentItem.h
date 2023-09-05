//
//  YCSegmentItem.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YCSegmentItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon;

+ (instancetype)segmentItemWithTitle:(NSString *)title icon:(UIImage *)icon;

@end
