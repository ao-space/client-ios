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
//  MJRefreshConfig.h
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJRefreshConfig : NSObject

/** 默认使用的语言版本, 默认为 nil. 将随系统的语言自动改变 */
@property (copy, nonatomic, nullable) NSString *languageCode;

/** 默认使用的语言资源文件名, 默认为 nil, 即默认的 Localizable.strings.
 
 - Attention: 文件名不包含后缀.strings
 */
@property (copy, nonatomic, nullable) NSString *i18nFilename;
/** i18n 多语言资源加载自定义 Bundle.
 
 - Attention: 默认为 nil 采用内置逻辑. 这里设置后将忽略内置逻辑的多语言模式, 采用自定义的多语言 bundle
 */
@property (nonatomic, nullable) NSBundle *i18nBundle;

/** Singleton Config instance */
@property (class, nonatomic, readonly) MJRefreshConfig *defaultConfig;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
