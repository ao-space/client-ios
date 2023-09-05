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
//  ESPushWaitView.h
//  EulixSpace
//
//  Created by qu on 2022/6/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESPushWaitView : UIView
@property(nonatomic) NSString* clientUUID;

@property(nonatomic) NSString* aoid;

@property(nonatomic) NSString* nameStr;

@property(nonatomic) NSString* domainStr;

@property(nonatomic) NSString* imagePath;
@property (nonatomic, copy) void (^actionBlock)(id action);

@end

NS_ASSUME_NONNULL_END
