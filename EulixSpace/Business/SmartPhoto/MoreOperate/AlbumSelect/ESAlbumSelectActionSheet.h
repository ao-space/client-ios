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
//  ESAddPhoto2AlbumActionSheet.h
//  EulixSpace
//
//  Created by KongBo on 2022/11/2.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseActionSheetVC.h"

NS_ASSUME_NONNULL_BEGIN

@class ESAlbumModel;
@class ESPicModel;
@protocol ESAlbumSelectActionSheetProtocol <NSObject>

- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet selectAlbum:(ESAlbumModel *)albumModel;
- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet createNewAlbum:(ESAlbumModel * _Nullable)albumModel;

@optional
- (void)actionSheet:(ESBaseActionSheetVC *)actionSheet cancelCreateNewAlbum:(ESAlbumModel * _Nullable)albumModel;

@end

@interface ESAlbumSelectActionSheet : ESBaseActionSheetVC

@property (nonatomic, weak) id<ESAlbumSelectActionSheetProtocol> selectAlbumDelegate;
@property (nonatomic, copy) NSString *needFiltAlbumId;
@property (nonatomic, copy) NSArray<ESPicModel *> *selectedArray;

- (void)reloadAlbumData;

@end

NS_ASSUME_NONNULL_END
