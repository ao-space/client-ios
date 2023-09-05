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
//  ESAuthenticationApplyForNewDeviceController.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAuthenticationApplyController.h"
#import "ESBoxBindViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESAuthenticationApplyForNewDeviceController : ESAuthenticationApplyController

+ (void)showAuthApplyView:(UIViewController<ESBoxBindViewModelDelegate> *)srcCtl
                     type:(ESAuthenticationType)authType
                viewModel:(ESBoxBindViewModel * _Nullable)viewModel
                    email:(ESSecurityEmailModel * _Nullable)emailInfo
                    block:(void(^)(ESAuthApplyRsp * applyRsp))optBlock
                   cancel:(void(^)(void))cancelBlock;

@end

NS_ASSUME_NONNULL_END
