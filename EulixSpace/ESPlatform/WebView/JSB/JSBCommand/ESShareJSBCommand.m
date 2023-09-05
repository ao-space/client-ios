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
//  ESShareJSBCommand.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESShareJSBCommand.h"
#import "ESWebShareView.h"
#import "ESToast.h"

@interface ESShareJSBCommand () <ESWebShareViewDelegate>

@property (nonatomic, strong) ESWebShareView *shareView;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareDescription;
@property (nonatomic, copy) NSString *shareCopyString;

@end

@implementation ESShareJSBCommand


- (ESJBHandler)commandHander {
    ESJBHandler _commandHander = ^(id _Nullable data, ESJBResponseCallback _Nullable responseCallback) {
        if (![data isKindOfClass:[NSDictionary class]]) {
            responseCallback(@{ @"code" : @(-1),
                                @"data" : @{},
                                @"msg" : @"参数错误"
                             });
            return;
        }
        NSDictionary *params = (NSDictionary *)data;
        self.shareUrl = params[@"shareUrl"];
        self.shareTitle = params[@"title"];
        self.shareDescription = params[@"description"];
        self.shareCopyString = params[@"shareCopyString"];
        
        [self showSharePane];
        responseCallback(@{ @"code" : @(200),
                            @"data" : @{},
                            @"msg" :  @{},
                            @"context" : @{
                                @"platform" : @"iOS",
                            }
                         });
    };
    return _commandHander;
}

- (NSString *)commandName {
    return @"onShare";
}

- (void)showSharePane {
    self.shareView = [[ESWebShareView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.shareView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
    
    self.shareView.delegate = self;
    self.shareView.linkShareUrl = self.shareUrl;
    self.shareView.title = self.shareTitle;
    self.shareView.descriptionMessage = self.shareDescription;

    self.shareView.hidden = NO;
}

#pragma mark - share

- (void)shareView:(ESWebShareView *)shareView didClicCancelBtn:(UIButton *)button {
    
}

- (void)linkCopyBtnTap {
    UIPasteboard.generalPasteboard.string = self.shareCopyString ? : [NSString stringWithFormat:@"%@ %@ %@", self.shareTitle, self.shareDescription, self.shareUrl];
    [ESToast toastInfo: NSLocalizedString(@"Copy Link to Clipboard", @"复制链接到剪贴板")];
}

- (void)shareViewShareOther:(ESWebShareView *)shareView{
    NSString *shareStr = self.shareCopyString ? : [NSString stringWithFormat:@"%@ %@ %@", self.shareTitle, self.shareDescription, self.shareUrl];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[shareStr] applicationActivities:nil];
    [self.context.webVC presentViewController:vc animated:YES completion:nil];
}

@end
