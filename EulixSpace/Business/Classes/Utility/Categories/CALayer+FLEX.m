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
//  CALayer+FLEX.m
//  FLEX
//
//  Created by Tanner on 2/28/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "CALayer+FLEX.h"

@interface CALayer (Private)
@property (nonatomic) BOOL continuousCorners;
@end

@implementation CALayer (FLEX)

static BOOL respondsToContinuousCorners = NO;

+ (void)load {
    respondsToContinuousCorners = [CALayer
        instancesRespondToSelector:@selector(setContinuousCorners:)
    ];
}

- (BOOL)flex_continuousCorners {
    if (respondsToContinuousCorners) {
        return self.continuousCorners;
    }
    
    return NO;
}

- (void)setFlex_continuousCorners:(BOOL)enabled {
    if (respondsToContinuousCorners) {
        if (@available(iOS 13, *)) {
            self.cornerCurve = kCACornerCurveContinuous;
        } else {
            self.continuousCorners = enabled;
//            self.masksToBounds = NO;
    //        self.allowsEdgeAntialiasing = YES;
    //        self.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge | kCALayerBottomEdge;
        }
    }
}

@end
