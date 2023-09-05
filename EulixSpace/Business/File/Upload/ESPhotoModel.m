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
//  ESPhotoModel.m
//  EulixSpace
//
//  Created by qu on 2021/9/4.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPhotoModel.h"

@implementation ESPhotoModel

- (void)setCollection:(PHAssetCollection *)collection {
    _collection = collection;

    if ([collection.localizedTitle isEqualToString:@"All Photos"]) {
        self.collectionTitle = @"全部相册";
    } else {
        self.collectionTitle = collection.localizedTitle;
    }

    self.collectionTitle = collection.localizedTitle;
    PHFetchOptions *options = [PHFetchOptions new];
    if ([self.category isEqual:@"video|picture"]) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d || mediaType == %d", PHAssetMediaTypeVideo, PHAssetMediaTypeImage];
    }
    else if ([self.category isEqual:@"video"]) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
    } else {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];

    if (self.assets.count > 0) {
        self.firstAsset = self.assets[0];
    }
    self.collectionNumber = [NSString stringWithFormat:@"%ld", self.assets.count];
}

#pragma mark - Get方法
- (NSMutableSet<NSNumber *> *)selectRows {
    if (!_selectRows) {
        _selectRows = [NSMutableSet set];
    }

    return _selectRows;
}

@end
