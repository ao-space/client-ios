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
//  ESRecycleReductionPopUp.h
//  EulixSpace
//
//  Created by qu on 2022/3/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESFileDelectView.h"
NS_ASSUME_NONNULL_BEGIN
@class ESRecycleReductionPopUp;

@protocol ESRecycleReductionPopUpDelegate <NSObject>

@optional

- (void)recycleReductionPopUp:(ESRecycleReductionPopUp *_Nullable)recycleReductionPopUp didClickCancelBtn:(UIButton *_Nullable)button;

- (void)recycleReductionPopUp:(ESRecycleReductionPopUp *_Nullable)reductionPopUpView didClickCompleteBtn:(UIButton *_Nullable)button;

@end

@interface ESRecycleReductionPopUp : ESFileDelectView

@property (nonatomic, weak) id<ESRecycleReductionPopUpDelegate> popUpdelegate;

@end

NS_ASSUME_NONNULL_END
