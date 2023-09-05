//
//  ESBindNotMatchHintView.m
//  EulixSpace
//
//  Created by dazhou on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBindNotMatchHintView.h"
#import "UIColor+ESHEXTransform.h"
#import "UILabel+ESTool.h"
#import "ESTapTextView.h"

@interface ESBindNotMatchHintView()
@property (nonatomic, strong) NSMutableArray * tapList;
@property (nonatomic, strong) ESTapTextView * tapView;
@end

@implementation ESBindNotMatchHintView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    [self.tapView setShowData:content tap:self.tapList];
}

- (void)setupViews {
    UILabel * label = [UILabel createLabel:NSLocalizedString(@"introduce", @"说明") font:ESFontPingFangMedium(14) color:@"#333333"];
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(5);
    }];

    [self.tapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom);
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-5);
    }];
}

- (ESTapTextView *)tapView {
    if (!_tapView) {
        ESTapTextView * tapView = [[ESTapTextView alloc] init];
        [tapView setTextFont:ESFontPingFangRegular(14)];
        [tapView setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:tapView];
        
        //服务端和客户端版本一致才能绑定成功，请下载使用傲空间（开源版）重新尝试。\n下载地址：https://ao.space/download
        NSString * content = NSLocalizedString(@"es_app_download_address", @"");
        [tapView setShowData:content tap:self.tapList];
        _tapView = tapView;
    }
    
    return _tapView;
}

- (NSMutableArray *)tapList {
    if (!_tapList) {
        NSMutableArray * tapList = [NSMutableArray array];
        ESTapModel * model = [[ESTapModel alloc] init];
        model.text = @"https://ao.space/download";
        model.textColor = [UIColor es_colorWithHexString:@"#337AFF"];
        model.underlineColor = [UIColor es_colorWithHexString:@"#337AFF"];
        model.textFont = ESFontPingFangRegular(14);
        model.onTapTextBlock = ^{
            NSURL * url = [NSURL URLWithString:@"https://ao.space/download"];
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
        };
        [tapList addObject:model];
        _tapList = tapList;
    }
    return _tapList;
}

@end
