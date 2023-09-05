//
//  ESInputPlatformAddressController.h
//  EulixSpace
//
//  Created by dazhou on 2023/7/28.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESInputPlatformAddressController : YCViewController
+ (BOOL)showView:(UIViewController *)srcCtl url:(NSString *)urlString block:(void(^)(NSString * urlString))sureBlock;

@end

NS_ASSUME_NONNULL_END
