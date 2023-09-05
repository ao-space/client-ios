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
//  UITextField+Range.m
//  FLEX
//
//  Created by Tanner on 6/13/17.
//

#import "UITextField+Range.h"

@implementation UITextField (Range)

- (NSRange)flex_selectedRange {
    UITextRange *r = self.selectedTextRange;
    if (r) {
        NSInteger loc = [self offsetFromPosition:self.beginningOfDocument toPosition:r.start];
        NSInteger len = [self offsetFromPosition:r.start toPosition:r.end];
        return NSMakeRange(loc, len);
    }

    return NSMakeRange(NSNotFound, 0);
}

@end
