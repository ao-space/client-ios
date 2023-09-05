//
//  ESSpaceAccountInfoVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceKeyInfoVC.h"
#import "ESSpaceKeyInfoModule.h"

@interface ESSpaceKeyInfoVC ()

@end

@implementation ESSpaceKeyInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor systemBackgroundColor];
    self.title = NSLocalizedString(@"space_account", @"空间账号");
    [self.listModule reloadData:[(ESSpaceKeyInfoModule *)self.listModule defaultListData]];
}

- (Class)listModuleClass {
    return [ESSpaceKeyInfoModule class];
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}

@end
