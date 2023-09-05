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
//  ESWebContainerViewController.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/17.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <YCBase/YCBase.h>

/**
 ! @abstract The body of the message.
@discussion Allowed types are NSNumber, NSString, NSDate, NSArray,
NSDictionary, and NSNull.
*/
typedef void (^ESWebContainerCallback)(id body);

@interface ESWebContainerViewController : YCViewController

@property (nonatomic, copy) NSString *webUrl;

@property (nonatomic, copy) NSString *webTitle;

@property (nonatomic, assign) UIEdgeInsets insets;

@property (nonatomic, assign) BOOL notSetIphoneOffSet;
@property (nonatomic, assign) BOOL notSetNavigationBarBackgroundColor;

- (void)registerAction:(NSString *)action callback:(ESWebContainerCallback)callback;

@end
