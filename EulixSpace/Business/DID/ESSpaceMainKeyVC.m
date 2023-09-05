//
//  ESSpaceMainKeyVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceMainKeyVC.h"
#import "ESSpaceMainKeyModule.h"

@interface ESSpaceMainKeyVC ()

@property (nonatomic, strong) UIView *statusBar;

@end

@implementation ESSpaceMainKeyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ESColor secondarySystemBackgroundColor];
    self.listModule.listView.backgroundColor = [ESColor secondarySystemBackgroundColor];

    self.title = NSLocalizedString(@"account_information", @"凭证信息");
    if (self.keyTye == ESSpaceAccountKeyCellActionTag_MainKey1) {
        [self.listModule reloadData:[(ESSpaceMainKeyModule *)self.listModule mainKey1Data]];
    }
    if (self.keyTye == ESSpaceAccountKeyCellActionTag_MainKey2) {
        [self.listModule reloadData:[(ESSpaceMainKeyModule *)self.listModule mainKey2Data]];
    }
    if (self.keyTye == ESSpaceAccountKeyCellActionTag_SecondaryKey1) {
        [self.listModule reloadData:[(ESSpaceMainKeyModule *)self.listModule secondary1Data]];
    }
}

- (UIColor *)customeNavigationBarBackgroudColor {
    return [ESColor secondarySystemBackgroundColor];
}

- (Class)listModuleClass {
    return [ESSpaceMainKeyModule class];
}

- (UIEdgeInsets)listEdgeInsets {
    return UIEdgeInsetsMake(20, 10, 0, 10);
}

- (BOOL)haveHeaderPullRefresh {
    return NO;
}
@end
