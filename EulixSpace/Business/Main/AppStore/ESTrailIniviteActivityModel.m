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
//  ESTrailIniviteActivityModel.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/6.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESTrailIniviteActivityModel.h"

@implementation ESTrailIniviteActivityItem

@end

@interface ESTrailIniviteActivityModel ()
@property (nonatomic, copy) NSArray<ESTrailIniviteActivityItem *> *items;
@property (nonatomic, copy) NSString *versionMaxMatch;

@end
    
@implementation ESTrailIniviteActivityModel

NSString * const ESTrailInviteAcitivty = @"ESTrailInviteAcitivty";
NSString * const ESProposalFeedbackAcitivty = @"ProposalFeedbackAcitivty";

+ (NSArray<NSString *> *)fetchItemNames {
    return @[
        @"trial.invite.activity.image",
        @"trial.invite.activity.name",
        @"trial.invite.activity.display",
        @"proposal.feedback.activity.image",
        @"proposal.feedback.activity.name",
        @"proposal.feedback.activity.display",
    ];
}

- (instancetype)initWithDicList:(NSArray *)dicList {
    if (self = [super init]) {
        NSMutableArray *items = [NSMutableArray array];
        
        if ([dicList isKindOfClass:[NSArray class]]) {
            [dicList enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([dic isKindOfClass:[NSDictionary class]] && [dic.allValues containsObject:@"activity.display.version.max"]) {
                    self.versionMaxMatch = dic[@"value"];
                }
            }];
        
            ESTrailIniviteActivityItem *traiItem = [ESTrailIniviteActivityItem new];
            traiItem.identifier = ESTrailInviteAcitivty;
            [dicList enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([dic isKindOfClass:[NSDictionary class]] && [dic.allValues containsObject:@"trial.invite.activity.image"]) {
                    traiItem.image = dic[@"value"];
                }
                if ([dic isKindOfClass:[NSDictionary class]] && [dic.allValues containsObject:@"trial.invite.activity.name"]) {
                    traiItem.name = dic[@"value"];
                }
                if ([dic isKindOfClass:[NSDictionary class]] && [dic.allValues containsObject:@"trial.invite.activity.display"]) {
                    traiItem.display = [dic[@"value"] isEqual:@"true"];
                }
            }];
            [items addObject:traiItem];
            
            ESTrailIniviteActivityItem *proposalItem = [ESTrailIniviteActivityItem new];
            proposalItem.identifier = ESProposalFeedbackAcitivty;
            [dicList enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([dic isKindOfClass:[NSDictionary class]] && [dic.allValues containsObject:@"proposal.feedback.activity.image"]) {
                    proposalItem.image = dic[@"value"];
                }
                if ([dic isKindOfClass:[NSDictionary class]] && [dic.allValues containsObject:@"proposal.feedback.activity.name"]) {
                    proposalItem.name = dic[@"value"];
                }
                if ([dic isKindOfClass:[NSDictionary class]] && [dic.allValues containsObject:@"proposal.feedback.activity.display"]) {
                    proposalItem.display = [dic[@"value"] isEqual:@"true"];
                }
            }];
            [items addObject:proposalItem];
            self.items = [items copy];
        }
    }
    return self;
}

- (BOOL)needShowByVersionMath {
    if (self.versionMaxMatch.length <= 0) {
        return YES;
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if ([appVersion compare:self.versionMaxMatch options:NSNumericSearch] == NSOrderedDescending) {
        return NO;
    }

    return YES;
}

- (NSArray<ESTrailIniviteActivityItem *> *)needShowItems {
    if (![self needShowByVersionMath]) {
        return @[];
    }
    __block NSMutableArray *list = [NSMutableArray array];
    [_items enumerateObjectsUsingBlock:^(ESTrailIniviteActivityItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.display) {
            [list addObject:obj];
        }
    }];
    return [list copy];
}

@end
