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
//  ESCreateAlbumResponseModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/10/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESCreateAlbumResponseModel : NSObject

@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) BOOL collection;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval deleteAt;
@property (nonatomic, assign) NSTimeInterval modifyAt;
@property (nonatomic, assign) ESAlbumType type;
@property (nonatomic, assign) NSInteger userId;

@end

NS_ASSUME_NONNULL_END
