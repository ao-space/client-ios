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
//  NSString+LeeLabelAddtion.m
//  FrameWork
//
//  Created by LeeMiao on 2017/9/1.
//  Copyright © 2017年 Limiao. All rights reserved.
//

#import "NSString+LeeLabelAddtion.h"

@implementation NSString (LeeLabelAddtion)


-(CGFloat)heightWithStrAttri:(NSDictionary<NSString *,id> *)attribute withLabelWidth:(CGFloat)width{

    CGFloat height = 0;
    if (self.length) { //NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|
        CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
        height = rect.size.height;
    }
    return height;
}


-(CGFloat)widthWithStrAttri:(NSDictionary<NSString *,id> *)attribute{

    CGFloat width = 0;
    if (self.length) {
        CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil];
        width = rect.size.width;
    }
    return width;
}


+ (CGFloat)heightOfOneLineWithStrAttri:(NSDictionary<NSString *,id> *)attribute{
    CGFloat height = 0;
    CGRect rect    = [@"LeeAddtion" boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    
    height = rect.size.height;
    return height;
}


#pragma mark ------



-(CGFloat)heightWithFont:(UIFont *)font withLabelWidth:(CGFloat)width{
    CGFloat height = 0;
    if (self.length) {
        CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: font} context:nil];
        
        height = rect.size.height;
    }
    return height;
    
}

- (CGFloat)widthWithFont:(UIFont *)font{
    CGFloat width = 0;
    
    if (self.length) {
        CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName: font} context:nil];
        
        width = rect.size.width;
    }
    
    return width;
    
}

+ (CGFloat)heightOfOneLineWithFont:(UIFont *)font{
    CGFloat height = 0;
    CGRect rect    = [@"LeeAddtion" boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |  NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: font} context:nil];
    height = rect.size.height;
    return height;
}
    
+ (CGSize)getSizeByString:(NSString *)string fontSize:(CGFloat)font size:(CGSize)maxsize {
    CGSize size = [string boundingRectWithSize:maxsize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
    return size;
}





@end
