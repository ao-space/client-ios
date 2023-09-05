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
//  ESAuthenticationApplyController.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"
#import "ESSecurityEmailMamager.h"
#import "ESReTransmissionManager.h"
#import "ESNotifiResp.h"
#import "AAPLCustomPresentationController.h"
#import "UIFont+ESSize.h"
#import "UIColor+ESHEXTransform.h"
#import "ESTapTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESAuthenticationApplyController : YCViewController

@property (nonatomic, copy) void (^optBlock)(ESAuthApplyRsp * applyRsp);
@property (nonatomic, copy) void (^cancelBlock)(void);

@property (nonatomic, assign) ESAuthenticationType authType;

@property (nonatomic, strong) UIView * applyView;
@property (nonatomic, strong) UIView * failedView;
@property (nonatomic, strong) UIImageView * failedHintImageView;
@property (nonatomic, strong) UILabel * reasonTitleLabel;
@property (nonatomic, strong) UILabel * reasonLabel;
@property (nonatomic, strong) UILabel * reasonHintLabel;

+ (void)showAuthApplyView:(UIViewController *)srcCtl
                     type:(ESAuthenticationType)authType
                    block:(void(^)(ESAuthApplyRsp * applyRsp))optBlock
                   cancel:(void(^)(void))cancelBlock;


- (void)onUnavailable;
- (void)showRefuseView;
- (void)onCancelBtn;

@end

NS_ASSUME_NONNULL_END
