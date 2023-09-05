//
//  YCSegmentItem.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/16.
//
//

#import "YCSegmentItem.h"

@implementation YCSegmentItem

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon {
    self = [super init];
    if (self) {
        self.title = title;
        self.icon = icon;
    }
    return self;
}

+ (instancetype)segmentItemWithTitle:(NSString *)title icon:(UIImage *)icon {
    return [[YCSegmentItem alloc] initWithTitle:title icon:icon];
}

@end
