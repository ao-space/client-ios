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
//  ESBluetoothManager.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@interface ESBluetoothItem : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *productId;

@property (nonatomic, copy) NSString *desc;

@end

@protocol ESBluetoothManagerDelegate <NSObject>

- (void)bluetooth:(ESBluetoothItem *)bluetooth readValue:(NSData *)readValue;

- (void)bluetooth:(ESBluetoothItem *)bluetooth onClose:(NSError *)error;

@end

@interface ESBluetoothManager : NSObject

+ (instancetype)manager;

- (BOOL)isBluetoothAuthorized;
- (BOOL)isBluetoothNotDetermined;

@property (nonatomic, weak) id<ESBluetoothManagerDelegate> delegate;

- (void)isPoweredOn:(void (^)(BOOL on))completion;

- (void)prepare:(void (^)(BOOL done))completion;

- (void)scanPeripheral:(NSString *)uuid
             localName:(NSString *)localName
          onConnection:(void (^)(ESBluetoothItem *item))onConnection;

- (void)stopScan;

- (void)writeValue:(NSData *)value;

@property (nonatomic, copy) void (^onClose)(void);

@end
