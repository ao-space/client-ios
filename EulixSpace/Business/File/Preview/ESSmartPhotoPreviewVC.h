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
//  ESSmartPhotoPreviewVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/11/7.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESImagesPreviewVC.h"
#import "ESPicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESSmartPhotoPreviewVC : ESImagesPreviewVC

extern void ESPhotoPreview(UIViewController *from, NSArray<ESPicModel *> *imageFiles, ESPicModel *selectPic, NSString *albumId, NSString *comeFromTag);
extern void ESPhotoPreviewWithFiles(UIViewController *from, NSArray<ESFileInfoPub *> *imageFiles, NSString *selectPicUuid, NSString *albumId, NSString *comeFromTag);

@end

NS_ASSUME_NONNULL_END
