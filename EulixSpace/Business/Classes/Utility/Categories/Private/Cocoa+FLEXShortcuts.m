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
//  Cocoa+FLEXShortcuts.m
//  Pods
//
//  Created by Tanner on 2/24/21.
//  
//

#import "Cocoa+FLEXShortcuts.h"

@implementation UIAlertAction (FLEXShortcuts)
- (NSString *)flex_styleName {
    switch (self.style) {
        case UIAlertActionStyleDefault:
            return @"Default style";
        case UIAlertActionStyleCancel:
            return @"Cancel style";
        case UIAlertActionStyleDestructive:
            return @"Destructive style";
            
        default:
            return [NSString stringWithFormat:@"Unknown (%@)", @(self.style)];
    }
}
@end
