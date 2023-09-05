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
//  FLEXSystemLogMessage.m
//  FLEX
//
//  Created by Ryan Olson on 1/25/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXSystemLogMessage.h"

@implementation FLEXSystemLogMessage

+ (instancetype)logMessageFromASLMessage:(aslmsg)aslMessage {
    NSDate *date = nil;
    NSString *sender = nil, *text = nil;
    long long identifier = 0;

    const char *timestamp = asl_get(aslMessage, ASL_KEY_TIME);
    if (timestamp) {
        NSTimeInterval timeInterval = [@(timestamp) integerValue];
        const char *nanoseconds = asl_get(aslMessage, ASL_KEY_TIME_NSEC);
        if (nanoseconds) {
            timeInterval += [@(nanoseconds) doubleValue] / NSEC_PER_SEC;
        }
        date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }

    const char *s = asl_get(aslMessage, ASL_KEY_SENDER);
    if (s) {
        sender = @(s);
    }

    const char *messageText = asl_get(aslMessage, ASL_KEY_MSG);
    if (messageText) {
        text = @(messageText);
    }

    const char *messageID = asl_get(aslMessage, ASL_KEY_MSG_ID);
    if (messageID) {
        identifier = [@(messageID) longLongValue];
    }

    FLEXSystemLogMessage *message = [[self alloc] initWithDate:date sender:sender text:text messageID:identifier];
    message->_aslMessage = aslMessage;
    return message;
}

+ (instancetype)logMessageFromDate:(NSDate *)date text:(NSString *)text {
    return [[self alloc] initWithDate:date sender:nil text:text messageID:0];
}

- (id)initWithDate:(NSDate *)date sender:(NSString *)sender text:(NSString *)text messageID:(long long)identifier {
    self = [super init];
    if (self) {
        _date = date;
        _sender = sender;
        _messageText = text;
        _messageID = identifier;
    }

    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        if (self.messageID) {
            // Only ASL uses messageID, otherwise it is 0
            return self.messageID == [object messageID];
        } else {
            // Test message texts and dates for OS Log
            return [self.messageText isEqual:[object messageText]] &&
                    [self.date isEqualToDate:[object date]];
        }
    }
    
    return NO;
}

- (NSUInteger)hash {
    return (NSUInteger)self.messageID;
}

- (NSString *)description {
    NSString *escaped = [self.messageText stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    return [NSString stringWithFormat:@"(%@) %@", @(self.messageText.length), escaped];
}

@end
