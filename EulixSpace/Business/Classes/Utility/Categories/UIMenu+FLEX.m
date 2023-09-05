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
//  UIMenu+FLEX.m
//  FLEX
//
//  Created by Tanner on 1/28/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "UIMenu+FLEX.h"

@implementation UIMenu (FLEX)

+ (instancetype)flex_inlineMenuWithTitle:(NSString *)title image:(UIImage *)image children:(NSArray *)children {
    return [UIMenu
        menuWithTitle:title
        image:image
        identifier:nil
        options:UIMenuOptionsDisplayInline
        children:children
    ];
}

- (instancetype)flex_collapsed {
    return [UIMenu
        menuWithTitle:@""
        image:nil
        identifier:nil
        options:UIMenuOptionsDisplayInline
        children:@[[UIMenu
            menuWithTitle:self.title
            image:self.image
            identifier:self.identifier
            options:0
            children:self.children
        ]]
    ];
}

@end
