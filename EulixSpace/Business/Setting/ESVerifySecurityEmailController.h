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
//  ESVerifySecurityEmailController.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBindSecurityEmailBySecurityCodeController.h"

NS_ASSUME_NONNULL_BEGIN


@interface ESVerifySecurityEmailController : ESBindSecurityEmailBySecurityCodeController
@property (nonatomic, strong) NSString * oldEmailAccount;

// code:0 表示验证成功，code：1 表示失败次数超限
@property (nonatomic, copy) void (^verifySecurityEmailBlock)(int code, NSString * expiredAt, NSString * securityToken);

@end

NS_ASSUME_NONNULL_END
