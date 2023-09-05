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
//  ESTimelineFrameItem.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/30.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTimelineFrameItem.h"
#import <WCDB/WCDB.h>
#import "ESCommonToolManager.h"

@implementation ESTimelineFrameItem

WCDB_IMPLEMENTATION(ESTimelineFrameItem)
WCDB_SYNTHESIZE(ESTimelineFrameItem, localID)
WCDB_SYNTHESIZE(ESTimelineFrameItem, dateWithType)
WCDB_SYNTHESIZE(ESTimelineFrameItem, timelineType)
WCDB_SYNTHESIZE(ESTimelineFrameItem, count)
WCDB_SYNTHESIZE(ESTimelineFrameItem, year)
WCDB_SYNTHESIZE(ESTimelineFrameItem, month)
WCDB_SYNTHESIZE(ESTimelineFrameItem, day)

WCDB_PRIMARY(ESTimelineFrameItem, localID) //主键


- (NSString *)dateWithTypeTranslate {
    if ([ESCommonToolManager isEnglish]) {
        NSString *translateDate = self.dateWithType;
//        "photo data"="%lu-%lu-%lu %@";
        if ([translateDate containsString:@"年"] && [translateDate containsString:@"月"] && [translateDate containsString:@"日"]) {
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
            
            NSRange dayRang = [translateDate rangeOfString:@"日"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"日" withString:@"" options:NSRegularExpressionSearch range:dayRang];

            //星期转换
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期日" withString:@"Sunday"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期一" withString:@"Monday"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期二" withString:@"Tuesday"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期三" withString:@"Wednesday"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期四" withString:@"Thursday"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期五" withString:@"Friday"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期六" withString:@"Saturday"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"星期" withString:@""];

            return translateDate;
        }

        if ([translateDate containsString:@"年"] && [translateDate containsString:@"月"]) {
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"月" withString:@""];
            return translateDate;
        }
        
        if ([translateDate containsString:@"年"]) {
            translateDate = [translateDate stringByReplacingOccurrencesOfString:@"年" withString:@""];
            return translateDate;
        }
        
        return translateDate;
    }
    
    return self.dateWithType;
}
@end
