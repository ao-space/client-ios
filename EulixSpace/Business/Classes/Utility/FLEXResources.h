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
//  FLEXResources.h
//  FLEX
//
//  Created by Ryan Olson on 6/8/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLEXResources : NSObject

#pragma mark - FLEX Toolbar Icons

@property (readonly, class) UIImage *closeIcon;
@property (readonly, class) UIImage *dragHandle;
@property (readonly, class) UIImage *globalsIcon;
@property (readonly, class) UIImage *hierarchyIcon;
@property (readonly, class) UIImage *recentIcon;
@property (readonly, class) UIImage *moveIcon;
@property (readonly, class) UIImage *selectIcon;

#pragma mark - Toolbar Icons

@property (readonly, class) UIImage *bookmarksIcon;
@property (readonly, class) UIImage *openTabsIcon;
@property (readonly, class) UIImage *moreIcon;
@property (readonly, class) UIImage *gearIcon;
@property (readonly, class) UIImage *scrollToBottomIcon;

#pragma mark - Content Type Icons

@property (readonly, class) UIImage *jsonIcon;
@property (readonly, class) UIImage *textPlainIcon;
@property (readonly, class) UIImage *htmlIcon;
@property (readonly, class) UIImage *audioIcon;
@property (readonly, class) UIImage *jsIcon;
@property (readonly, class) UIImage *plistIcon;
@property (readonly, class) UIImage *textIcon;
@property (readonly, class) UIImage *videoIcon;
@property (readonly, class) UIImage *xmlIcon;
@property (readonly, class) UIImage *binaryIcon;

#pragma mark - 3D Explorer Icons

@property (readonly, class) UIImage *toggle2DIcon;
@property (readonly, class) UIImage *toggle3DIcon;
@property (readonly, class) UIImage *rangeSliderLeftHandle;
@property (readonly, class) UIImage *rangeSliderRightHandle;
@property (readonly, class) UIImage *rangeSliderTrack;
@property (readonly, class) UIImage *rangeSliderFill;

#pragma mark - Misc Icons

@property (readonly, class) UIImage *checkerPattern;
@property (readonly, class) UIColor *checkerPatternColor;
@property (readonly, class) UIImage *hierarchyIndentPattern;

@end
