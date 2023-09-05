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
//  UIButton+ESStyle.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UIButton+ESStyle.h"

@implementation UIButton (ESStyle)

- (void)setLeftTextRightImageStyle {
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.imageView.bounds.size.width, 0, self.imageView.bounds.size.width)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width, 0, -self.titleLabel.bounds.size.width)];
}

- (void)setLeftTextRightImageStyleOffset:(CGFloat)offset {
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -(self.imageView.bounds.size.width + offset / 2), 0, self.imageView.bounds.size.width + offset / 2)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width + offset / 2, 0, -(self.titleLabel.bounds.size.width + offset / 2))];
}

- (void)setTopTextBottomImageStyle {
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(self.imageView.bounds.size.height ,-self.imageView.bounds.size.width, 0.0,0.0)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0, -self.titleLabel.bounds.size.width)];
}

- (void)setTopTextBottomImageStyleOffset:(CGFloat)padding {
    CGRect imageRect = self.imageView.frame;
    CGRect titleRect = self.titleLabel.frame;
    
    CGFloat totalHeight = imageRect.size.height + padding + titleRect.size.height;
    CGFloat selfHeight = self.frame.size.height;
    CGFloat selfWidth = self.frame.size.width;
           
    self.titleEdgeInsets = UIEdgeInsetsMake(((selfHeight - totalHeight)/2 - titleRect.origin.y),
                                                            (selfWidth/2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                                            -((selfHeight - totalHeight)/2 - titleRect.origin.y),
                                                            -(selfWidth/2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2);
                    
    self.imageEdgeInsets = UIEdgeInsetsMake(((selfHeight - totalHeight)/2 + titleRect.size.height + padding - imageRect.origin.y),
                                                            (selfWidth /2 - imageRect.origin.x - imageRect.size.width / 2),
                                                            -((selfHeight - totalHeight)/2 + titleRect.size.height + padding - imageRect.origin.y),
                                                            -(selfWidth /2 - imageRect.origin.x - imageRect.size.width / 2));
}

- (void)setBottomTextTopImageStyleOffset:(CGFloat)padding {
    self.titleEdgeInsets = UIEdgeInsetsMake(self.imageView.frame.size.height + padding * 2, - self.imageView.bounds.size.width, .0, .0);
    self.imageEdgeInsets = UIEdgeInsetsMake(.0, (self.titleLabel.bounds.size.width + 5) / 2,
                                            self.titleLabel.frame.size.height + padding * 2, - (self.titleLabel.bounds.size.width + 5) / 2);
}

- (void)setBottomTextTopImageStyle2Offset:(CGFloat)padding {
    self.titleEdgeInsets = UIEdgeInsetsMake(self.imageView.frame.size.height + padding * 2, - self.imageView.bounds.size.width, .0, .0);
    self.imageEdgeInsets = UIEdgeInsetsMake(.0, (self.titleLabel.bounds.size.width) / 2,
                                            self.titleLabel.frame.size.height + padding * 2, - (self.titleLabel.bounds.size.width) / 2);
}

@end
