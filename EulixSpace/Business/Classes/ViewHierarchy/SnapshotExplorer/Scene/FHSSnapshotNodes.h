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
//  FHSSnapshotNodes.h
//  FLEX
//
//  Created by Tanner Bennett on 1/7/20.
//

#import "FHSViewSnapshot.h"
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Container that holds references to the SceneKit nodes associated with a snapshot.
@interface FHSSnapshotNodes : NSObject

+ (instancetype)snapshot:(FHSViewSnapshot *)snapshot depth:(NSInteger)depth;

@property (nonatomic, readonly) FHSViewSnapshot *snapshotItem;
@property (nonatomic, readonly) NSInteger depth;

/// The view image itself
@property (nonatomic, nullable) SCNNode *snapshot;
/// Goes on top of the snapshot, has rounded top corners
@property (nonatomic, nullable) SCNNode *header;
/// The bounding box drawn around the snapshot
@property (nonatomic, nullable) SCNNode *border;

/// Used to indicate when a view is selected
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
/// Used to indicate when a view is de-emphasized
@property (nonatomic, getter=isDimmed) BOOL dimmed;

@property (nonatomic) BOOL forceHideHeader;

@end

NS_ASSUME_NONNULL_END
