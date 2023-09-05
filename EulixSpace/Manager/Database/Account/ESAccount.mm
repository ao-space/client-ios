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
//  ESAccount.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/27.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAccount.h"
#import "ESAccount+WCTTableCoding.h"
#import "ESAccountManager.h"
#import "NSDate+Format.h"
#import "ESNetworking.h"

@implementation ESAccount

WCDB_IMPLEMENTATION(ESAccount)
WCDB_SYNTHESIZE(ESAccount, boxUUID)
WCDB_SYNTHESIZE(ESAccount, userId)

WCDB_SYNTHESIZE(ESAccount, autoUploadImage)
WCDB_SYNTHESIZE(ESAccount, autoUploadVideo)
WCDB_SYNTHESIZE(ESAccount, autoUploadBackground)
WCDB_SYNTHESIZE(ESAccount, autoUploadWWAN)

WCDB_SYNTHESIZE(ESAccount, autoUploadPath)
WCDB_SYNTHESIZE(ESAccount, lastSyncPromptTime)
WCDB_SYNTHESIZE(ESAccount, lastSyncCompleteTime)
WCDB_SYNTHESIZE(ESAccount, uploadCountOfToday)

WCDB_PRIMARY(ESAccount, boxUUID)

- (BOOL)autoUpload {
    return self.autoUploadImage || self.autoUploadVideo;
}

- (BOOL)canAutoUpload {
    if (self.autoUploadWWAN == NO) {
        if (([ESNetworking shared].reachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN &&
             [ESNetworking shared].reachabilityStatus != AFNetworkReachabilityStatusReachableViaWiFi)){
            return NO;
        }
    }
    return self.autoUpload;
}

- (void)save {
    [ESAccountManager.manager saveAccount:self];
}

- (NSString *)userId {
    if (!_userId) {
        _userId = self.boxUUID;
    }
    return _userId;
}

- (BOOL)shouldShowSyncPrompt {
    if (self.autoUpload) {
        return NO;
    }
    NSDate *promptTime = [NSDate dateWithTimeIntervalSince1970:self.lastSyncPromptTime];
    if ([NSCalendar.currentCalendar isDateInToday:promptTime]) {
        return NO;
    }
    self.lastSyncPromptTime = NSDate.date.timeIntervalSince1970;
    [self save];
    return YES;
}

- (NSString *)lastSyncCompleteTimeString {
    if (self.lastSyncCompleteTime < 1) {
        return @"";
    }
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:self.lastSyncCompleteTime];
    return [time stringFromFormat:@"YYYY-MM-dd HH:mm:ss"];
}

@end
