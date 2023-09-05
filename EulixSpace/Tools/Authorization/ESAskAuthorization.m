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
// Created by Ye Tao on 2021/9/29.
// Copyright (c) 2021 eulix.xyz. All rights reserved.
//

#import "ESAskAuthorization.h"
#import "ESThemeDefine.h"
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import "ESPermissionController.h"

@implementation ESAskAuthorization {
}

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)askAuthorizationPhotoLibrary:(UIViewController *)viewController completion:(void (^)(BOOL hasPermission))completion {
    switch (PHPhotoLibrary.authorizationStatus) {
        case PHAuthorizationStatusAuthorized:
            completion(YES);
            break;
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(status == PHAuthorizationStatusAuthorized);
                });
            }];
        } break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusLimited: {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:TEXT_PHOTO_POWER_SETTING message:TEXT_ERR_PERMISSION_PHOTO_LIBRARY preferredStyle:UIAlertControllerStyleAlert];
//            [alert addAction:[UIAlertAction actionWithTitle:TEXT_CANCEL
//                                                      style:UIAlertActionStyleCancel
//                                                    handler:nil]];
//            [alert addAction:[UIAlertAction actionWithTitle:TEXT_TURN_ON_NOW
//                                                      style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction *action) {
//                                                        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//                                                    }]];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
                [ESPermissionController showPermissionView:ESPermissionTypeAlbum];
                
//                [viewController presentViewController:alert animated:YES completion:nil];
            });
        } break;
    }
}

- (void)askAuthorizationLocationManager:(void (^)(BOOL hasFullPermissions))completion {
    switch (CLLocationManager.authorizationStatus) {
            //case kCLAuthorizationStatusNotDetermined:
            //    break;
            //case kCLAuthorizationStatusRestricted:
            //    break;
            //case kCLAuthorizationStatusDenied:
            //    break;
            //case kCLAuthorizationStatusAuthorizedWhenInUse:
            //    break;
        case kCLAuthorizationStatusAuthorizedAlways:
            completion(YES);
            break;
        default: {

            completion(NO);
        } break;
    }
}

@end
