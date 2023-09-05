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
//  ESBoxSearchWiredConnectionPromptView.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBoxSearchWiredConnectionPromptView.h"

@implementation ESBoxSearchWiredConnectionPromptView


- (void)reloadWithState:(ESBoxBindState)state {
    if (state == ESBoxBindStateScaning) {
        self.title.text = NSLocalizedString(@"LAN search in progress", @"局域网搜索中…");
        self.title.textColor = ESColor.primaryColor;
        self.title.font = [UIFont systemFontOfSize:12];
        self.content.text = NSLocalizedString(@"same LAN hint", @"请确保手机与傲空间设备连接的是同一个网络");
    } else if (state == ESBoxBindStateNotFound) {
        self.title.text = TEXT_BOX_BIND_NOT_FOUND;
        self.title.textColor = ESColor.labelColor;
        self.title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        paragraphStyle.minimumLineHeight = 20;
        paragraphStyle.maximumLineHeight = 20;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        NSDictionary *highlightAttr = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
            NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        NSMutableAttributedString *content = [NSLocalizedString(@"lan search faild hint", @"无法连接设备，请确保傲空间设备在旁边且正常联网，\n确认无误后，点击”重新扫描”") es_toAttr:attributes];
        [content matchPattern:NSLocalizedString(@"box_scan_again", @"重新扫描") highlightAttr:highlightAttr];
        self.content.attributedText = content;
    } else {
        self.title.text = nil;
        self.content.text = NSLocalizedString(@"same LAN hint", @"请确保手机与傲空间设备连接的是同一个网络");
    }

    if (state == ESBoxBindStateScaning) {
        [self.animation play];
    } else {
        [self.animation stop];
    }
}

@end
