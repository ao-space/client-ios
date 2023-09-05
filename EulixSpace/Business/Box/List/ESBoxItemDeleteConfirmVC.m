/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  ESBoxItemDeleteVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxItemDeleteConfirmVC.h"
#import "ESActionSheetView.h"
#import "NSString+ESTool.h"

@interface ESBoxItemDeleteConfirmVC ()

@property (nonatomic, strong)ESActionSheetView *actionSheetView;

@end

@implementation ESBoxItemDeleteConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)show {
    ESActionSheetButton *deleteBtn = [[ESActionSheetButton alloc] initWithTitle:NSLocalizedString(@"binding_cleardefinitively", @"确定清除")
                                                               titleColor:[ESColor colorWithHex:0xF6222D]
                                                                  handler:^(ESActionSheetView *actionSheet, ESActionSheetButton *actionSheetButton) {
        if (self.clearBlock) {
            self.clearBlock();
        }
    }];
 
    NSAttributedString *suTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"me_domain_name", @"域名"),   self.boxItem.prettyDomain]
                                                                         attributes:@{
                                                                             NSForegroundColorAttributeName: ESColor.labelColor,
                                                                             NSFontAttributeName : ESFontPingFangRegular(14)
                                                                         }];
    if (self.boxItem.prettyDomain.length <= 0 ||
        (self.boxItem.supportNewBindProcess && self.boxItem.enableInternetAccess == NO)) {
        suTitle = nil;
    }

    NSAttributedString *message = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"binding_afterclearing", @"清除后，下次使用需要重新绑定空间或扫码授权登录。")
                                                                         attributes:@{
                                                                             NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
                                                                             NSFontAttributeName : ESFontPingFangRegular(14)
                                                                         }];

    ESActionSheetView *actionSheet = [[ESActionSheetView alloc] initWithTitle:[self titleAttr]
                                                                     subtitle:suTitle
                                                                      message:message
                                                           actionSheetButtons:@[deleteBtn]];

    [actionSheet leftAlignmentStyle];
    actionSheet.leftAndRightMargin = 10;
    self.actionSheetView = actionSheet;
    [actionSheet show];
}

- (void)hidden {
    
}

- (NSAttributedString *)titleAttr {
    NSString *userName = self.boxItem.spaceName ?: self.boxItem.bindUserName;

    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"binding_suretoclear", @"确定清除 %@ 的傲空间？"), ESSafeString(userName)];
    NSMutableAttributedString *attributedString = [title match:ESSafeString(userName) highlightAttr:@{
        NSForegroundColorAttributeName: ESColor.primaryColor,
        NSFontAttributeName : ESFontPingFangMedium(16)
    } defaultAttr:@{
        NSForegroundColorAttributeName: ESColor.labelColor,
        NSFontAttributeName : ESFontPingFangMedium(16)
    }];
    return attributedString;
}

@end
