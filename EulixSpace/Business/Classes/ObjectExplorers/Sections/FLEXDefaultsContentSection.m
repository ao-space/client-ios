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
//  FLEXDefaultsContentSection.m
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXDefaultsContentSection.h"
#import "FLEXDefaultEditorViewController.h"
#import "FLEXUtility.h"

@interface FLEXDefaultsContentSection ()
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSArray *keys;
@property (nonatomic, readonly) NSDictionary *unexcludedDefaults;
@end

@implementation FLEXDefaultsContentSection
@synthesize keys = _keys;

#pragma mark Initialization

+ (instancetype)forObject:(id)object {
    return [self forDefaults:object];
}

+ (instancetype)standard {
    return [self forDefaults:NSUserDefaults.standardUserDefaults];
}

+ (instancetype)forDefaults:(NSUserDefaults *)userDefaults {
    FLEXDefaultsContentSection *section = [self forReusableFuture:^id(FLEXDefaultsContentSection *section) {
        section.defaults = userDefaults;
        section.onlyShowKeysForAppPrefs = YES;
        return section.unexcludedDefaults;
    }];
    return section;
}

#pragma mark - Overrides

- (NSString *)title {
    return @"Defaults";
}

- (void (^)(__kindof UIViewController *))didPressInfoButtonAction:(NSInteger)row {
    return ^(UIViewController *host) {
        if ([FLEXDefaultEditorViewController canEditDefaultWithValue:[self objectForRow:row]]) {
            // We use titleForRow: to get the key because self.keys is not
            // necessarily in the same order as the keys being displayed
            FLEXVariableEditorViewController *controller = [FLEXDefaultEditorViewController
                target:self.defaults key:[self titleForRow:row] commitHandler:^{
                    [self reloadData:YES];
                }
            ];
            [host.navigationController pushViewController:controller animated:YES];
        } else {
            [FLEXAlert showAlert:@"Oh No…" message:@"We can't edit this entry :(" from:host];
        }
    };
}

- (UITableViewCellAccessoryType)accessoryTypeForRow:(NSInteger)row {
    return UITableViewCellAccessoryDetailDisclosureButton;
}

#pragma mark - Private

- (NSArray *)keys {
    if (!_keys) {
        if (self.onlyShowKeysForAppPrefs) {
            // Read keys from preferences file
            NSString *bundle = NSBundle.mainBundle.bundleIdentifier;
            NSString *prefsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences"];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.plist", prefsPath, bundle];
            self.keys = [NSDictionary dictionaryWithContentsOfFile:filePath].allKeys;
        } else {
            self.keys = self.defaults.dictionaryRepresentation.allKeys;
        }
    }

    return _keys;
}

- (void)setKeys:(NSArray *)keys {
    _keys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSDictionary *)unexcludedDefaults {
    // Case: no excluding
    if (!self.onlyShowKeysForAppPrefs) {
        return self.defaults.dictionaryRepresentation;
    }

    // Always regenerate key allowlist when this method is called
    _keys = nil;

    // Generate new dictionary from unexcluded keys
    NSArray *values = [self.defaults.dictionaryRepresentation
        objectsForKeys:self.keys notFoundMarker:NSNull.null
    ];
    return [NSDictionary dictionaryWithObjects:values forKeys:self.keys];
}

#pragma mark - Public

- (void)setOnlyShowKeysForAppPrefs:(BOOL)onlyShowKeysForAppPrefs {
    if (onlyShowKeysForAppPrefs) {
        // This property only applies if we're using standardUserDefaults
        if (self.defaults != NSUserDefaults.standardUserDefaults) return;
    }

    _onlyShowKeysForAppPrefs = onlyShowKeysForAppPrefs;
}

@end
