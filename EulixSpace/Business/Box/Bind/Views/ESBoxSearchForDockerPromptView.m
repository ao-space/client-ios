//
//  ESBoxSearchForDockerPromptView.m
//  EulixSpace
//
//  Created by dazhou on 2023/7/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBoxSearchForDockerPromptView.h"
#import "UIColor+ESHEXTransform.h"

@implementation ESBoxSearchForDockerPromptView

- (void)initUI {
    [super initUI];
    self.title.font = ESFontPingFangRegular(14);
    // 硬件设备验证需要通过局域网连接设备，请用手机扫描电脑浏览器上的二维码，并确保手机和电脑在同一网络。
    self.content.text = NSLocalizedString(@"es_docker_search_box_hint", @"");
}

- (void)reloadWithState:(ESBoxBindState)state {
    if (state == ESBoxBindStateScaning) {
        self.title.text = NSLocalizedString(@"es_docker_search_box_connect_box", @"正在连接设备…");
        self.title.textColor = ESColor.primaryColor;
        self.title.font = ESFontPingFangRegular(14);

        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        paragraphStyle.minimumLineHeight = 20;
        paragraphStyle.maximumLineHeight = 20;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{
            NSFontAttributeName: ESFontPingFangRegular(14),
            NSForegroundColorAttributeName: [UIColor es_colorWithHexString:@"#85899C"],
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        NSDictionary *highlightAttr = @{
            NSFontAttributeName: ESFontPingFangMedium(14),
            NSForegroundColorAttributeName: [UIColor es_colorWithHexString:@"#333333"],
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        NSMutableAttributedString *content = [NSLocalizedString(@"es_docker_searching_box_hint", @"请确保设备已接通电源\n请将手机与设备连接到同一网络") es_toAttr:attributes];
        [content matchPattern:NSLocalizedString(@"es_docker_searching_box_hint_1", @"请将手机与设备连接到同一网络") highlightAttr:highlightAttr];
        self.content.attributedText = content;
        
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
        NSMutableAttributedString *content = [NSLocalizedString(@"es_docker_searching_box_not_found_hint", @"无法连接设备，请确保手机和设备在同一网络，\n确认无误后，点击”重新扫描”") es_toAttr:attributes];
        [content matchPattern:NSLocalizedString(@"box_scan_again", @"重新扫描") highlightAttr:highlightAttr];
        self.content.attributedText = content;
    } else {
        self.title.text = nil;
        // 硬件设备验证需要通过局域网连接设备，请用手机扫描电脑浏览器上的二维码，并确保手机和电脑在同一网络。
        self.content.text = NSLocalizedString(@"es_docker_search_box_hint", @"请确保手机与傲空间设备连接的是同一个网络");
    }

    if (state == ESBoxBindStateScaning) {
        [self.animation play];
    } else {
        [self.animation stop];
    }
}

@end
