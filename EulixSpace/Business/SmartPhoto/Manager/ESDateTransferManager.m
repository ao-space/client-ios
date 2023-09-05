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
//  ESDateTransferManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/29.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDateTransferManager.h"

@interface ESDateTransferManager ()

@property (nonatomic, strong) NSDateFormatter *format;
@property (nonatomic, strong) NSCalendar *calendar;



@end

@implementation ESDateTransferManager

+ (instancetype)shareInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        [instance setDateFormat:@"yyyy-MM-dd"];
        [instance setCalendarComponentType: NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday];
    });
    return instance;
}

- (void)setDateFormat:(NSString *)dateFormat {
    self.format.dateFormat = dateFormat;
}

- (nullable NSDate *)transferByDateString:(NSString *)dateStr {
    return [self.format dateFromString:dateStr];
}

- (NSDateFormatter *)format {
    if (!_format) {
        _format = [[NSDateFormatter alloc] init];
    }
    return _format;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
     }
    return _calendar;
}

- (NSDateComponents *)getComponentsWithDate:(NSDate *)date {
    return [self.calendar components:self.calendarComponentType fromDate:date];
}
@end



