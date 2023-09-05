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
//  ESMoreFunctionView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/22.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESMoreFunctionView.h"
#import "ESBoxManager.h"
#import "ESFormItem.h"
#import "ESToast.h"
#import "ESFunctionView.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESCommonToolManager.h"
#import "ESPlatformQuestionnaireManagementServiceApi.h"
#import <Masonry/Masonry.h>

@interface ESMoreFunctionView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIView *tryUserInfoNumView;

@property (nonatomic, strong) NSArray<ESFunctionView *> *cells;

@property (nonatomic, strong) NSArray<ESFormItem *> *data;

@property (nonatomic, strong) ESFunctionView *tryUserView;

@property (nonatomic, strong) UILabel *numLabel;

@end

@implementation ESMoreFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).inset(16);
        make.top.mas_equalTo(self.contentView).inset(10);
        make.height.mas_equalTo(25);
    }];

    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.title.mas_bottom).inset(20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).inset(20);
    }];
}
- (void)reloadWithData:(NSArray *)data {
    if (![data isKindOfClass:[NSArray class]]) {
        return;
    }
    self.data = data;
    if (self.cells.count != self.data.count) {
        [self initCells];
    }
    [self.cells enumerateObjectsUsingBlock:^(ESFunctionView *_Nonnull cell, NSUInteger idx, BOOL *_Nonnull stop) {
        ESFormItem *item = data[idx];
        [cell reloadWithData:item];
    }];
}

- (void)initCells {
    NSMutableArray *cells = NSMutableArray.array;
    [self.cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat height = 60;
    if ([ESCommonToolManager isEnglish]) {
        height = 80;
    }else{
        height = 60;
    }
   
    CGFloat width = floor((ScreenWidth - 20) / 4);
    CGFloat left = 0, top = 0;
    for (NSUInteger index = 0; index < self.data.count; index++) {
        ESFunctionView *cellView = [ESFunctionView new];
        cellView.tag = index;
        [self.container addSubview:cellView];
        ESFormItem *item = self.data[index];

        if(index > 3){
            [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.container).inset(width * (index - 4));
                make.top.mas_equalTo(self.title.mas_bottom).offset(100);
                make.height.mas_equalTo(height);
                make.width.mas_equalTo(width);
            }];
        }else{
            [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.container).inset(width * index);
                make.top.mas_equalTo(self.container);
                make.height.mas_equalTo(height);
                make.width.mas_equalTo(width);
            }];
        }
        
        if (item.title == TEXT_ME_TRIAL_FEEDBACK) {
            self.tryUserView = cellView;
//            self.tryUserInfoNumView.hidden = YES;
            if(index > 3){
                [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.container).offset(0);
                    make.top.mas_equalTo(self.title.mas_bottom).offset(100);
                    make.height.mas_equalTo(height);
                    make.width.mas_equalTo(width);
                }];
            }
          
            [self checkquestionnaireListApi];
        }
        
        [cellView addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [cells addObject:cellView];
    }
    self.cells = cells;
    [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height * self.data.count + 80);
    }];
}

- (void)action:(UIControl *)sender {
    ESFormItem *item = self.data[sender.tag];
    if (self.actionBlock) {
        self.actionBlock(item, @(item.row));
    }
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = ESColor.systemBackgroundColor;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(0, 10, 0, 10));
        }];
    }
    return _contentView;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [self.contentView addSubview:_container];
    }
    return _container;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.text = TEXT_ME_SETTING_AND_SERVICE;
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UIView *)tryUserInfoNumView {
    if (!_tryUserInfoNumView) {
        _tryUserInfoNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        _tryUserInfoNumView.layer.masksToBounds = YES;
        _tryUserInfoNumView.layer.cornerRadius = 8;
        _tryUserInfoNumView.backgroundColor = ESColor.redColor;
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        numLabel.textColor = ESColor.lightTextColor;
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.text = @"1";
        self.numLabel = numLabel;
        [_tryUserInfoNumView addSubview:numLabel];
        [self.tryUserView addSubview:_tryUserInfoNumView];
    }
    return _tryUserInfoNumView;
}

- (void)checkquestionnaireListApi {
    NSString *path = ESPlatformClient.platformClient.baseURL.absoluteString;
    NSURL *requesetUrl = [NSURL URLWithString:path];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *userId = dic[@"aoId"];
    ESPlatformQuestionnaireManagementServiceApi *api = [[ESPlatformQuestionnaireManagementServiceApi alloc] initWithApiClient:client];
    [api questionnaireListWithCurrentPage:@(1)
                                 pageSize:@(100)
                                 userId: userId
                                 boxUuid: ESBoxManager.activeBox.boxUUID
                        completionHandler:^(ESPageListResultQuestionnaireRes *output, NSError *error) {
                            if (!error) {
                                NSArray *dataList = output.list;
                                int num = 0;
                                for (ESQuestionnaireRes *questionnaireRes in dataList) {
                                    if ([questionnaireRes.state isEqual:@"in_process"]) {
                                        num = num + 1;
                                    }
                                }
                                if (num > 0) {
//                                    self.tryUserInfoNumView.hidden = NO;
//                                    self.numLabel.text = [NSString stringWithFormat:@"%d", num];
                                    [self.tryUserView setBadgeNum:num];
                                }
                            }else{
                                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                            }
                        }];
}

@end
