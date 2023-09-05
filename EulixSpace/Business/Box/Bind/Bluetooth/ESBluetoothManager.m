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
//  ESBluetoothManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBluetoothManager.h"
#import "ESGlobalMacro.h"

@interface ESBluetoothItem ()

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSDictionary<NSString *, id> *advertisementData;

@end

@implementation ESBluetoothItem

+ (instancetype)itemFrom:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData {
    ESBluetoothItem *item = [ESBluetoothItem new];
    item.peripheral = peripheral;
    item.advertisementData = advertisementData;
    item.name = advertisementData[@"kCBAdvDataLocalName"];
    return item;
}

@end

@interface ESBluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@property (nonatomic, strong) CBCharacteristic *readCharacteristic;

@property (nonatomic, copy) NSString *serviceUUID;

@property (nonatomic, copy) NSString *localName;

@property (nonatomic, copy) void (^onConnection)(ESBluetoothItem *item);

@property (nonatomic, copy) void (^onPrepare)(BOOL done);
@property (nonatomic, copy) void (^poweredOnBlock)(BOOL on);

@property (nonatomic, strong) ESBluetoothItem *item;

@property (nonatomic, assign) BOOL didDiscoverCharacteristics;

@property (nonatomic, assign) BOOL didDiscoverServices;
@property (nonatomic, assign) CBManagerState state;
@end

@implementation ESBluetoothManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = CBManagerStateUnknown;
    }
    return self;
}

- (BOOL)isBluetoothAuthorized {
    if (_centralManager == nil) {
        [self centralManager];
    }
   
    if (@available(iOS 13.1, *)) {
        ESDLog(@"[ESBluetoothManager] isBluetoothAuthorized %ld", CBCentralManager.authorization);
        return CBCentralManager.authorization == CBManagerAuthorizationAllowedAlways;
    } else if (@available(iOS 13.0, *)) {
        ESDLog(@"[ESBluetoothManager] isBluetoothAuthorized %ld", _centralManager.authorization);
        return _centralManager.authorization == CBManagerAuthorizationAllowedAlways;
    }

    return YES;
}

- (BOOL)isBluetoothNotDetermined {
    if (@available(iOS 13.1, *)) {
        ESDLog(@"[ESBluetoothManager] isBluetoothAuthorized %ld", CBCentralManager.authorization);
        return CBCentralManager.authorization == CBManagerAuthorizationNotDetermined;
    } else if (@available(iOS 13.0, *)) {
        ESDLog(@"[ESBluetoothManager] isBluetoothAuthorized %ld", _centralManager.authorization);
        return _centralManager.authorization == CBManagerAuthorizationNotDetermined;
    }

    return YES;
}

- (CBCentralManager *)centralManager {
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @(NO)}];
    }
    return _centralManager;
}

- (void)isPoweredOn:(void (^)(BOOL on))completion {
    if (self.centralManager.state == CBManagerStatePoweredOn && completion) {
        completion(YES);
        return;
    }
    if (self.centralManager.state == CBManagerStatePoweredOff && completion) {
        completion(NO);
        return;
    }
    
    self.poweredOnBlock = completion;
}

- (void)prepare:(void (^)(BOOL done))completion {
    self.onPrepare = completion;
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        if (self.onPrepare) {
            self.onPrepare(YES);
        }
        self.onPrepare = nil;
    }
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            ESDLog(@"[Bluetooth] CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            ESDLog(@"[Bluetooth] CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            ESDLog(@"[Bluetooth] CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            ESDLog(@"[Bluetooth] CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff: {
            ESDLog(@"[Bluetooth] CBManagerStatePoweredOff");
        } break;
        case CBManagerStatePoweredOn: {
            ESDLog(@"[Bluetooth] CBManagerStatePoweredOn");
        } break;
        default:
            break;
    }
    self.state = central.state;
    if (self.onPrepare) {
        self.onPrepare(_centralManager.state == CBManagerStatePoweredOn);
    }
    self.onPrepare = nil;
    
    if (self.poweredOnBlock) {
        self.poweredOnBlock(_centralManager.state == CBManagerStatePoweredOn);
    }
}

- (void)stopScan {
    ESDLog(@"[Bluetooth] stopScan");

    [_centralManager stopScan];
    if (self.peripheral) {
        [_centralManager cancelPeripheralConnection:self.peripheral];
    }
    self.serviceUUID = nil;
    self.localName = nil;
    self.peripheral = nil;
    self.item = nil;
    self.readCharacteristic = nil;
    self.writeCharacteristic = nil;
    self.onConnection = nil;
    self.didDiscoverServices = NO;
    self.didDiscoverCharacteristics = NO;
}

- (void)writeValue:(NSData *)value {
    NSParameterAssert(value && self.writeCharacteristic);
    ESDLog(@"[Bluetooth] writeValue %@", value);
    [self.peripheral writeValue:value forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)scanPeripheral:(NSString *)serviceUUID
             localName:(NSString *)localName
          onConnection:(void (^)(ESBluetoothItem *item))onConnection {
    ESDLog(@"[Bluetooth] Scan Peripheral %@ localName : %@", serviceUUID, localName);
    [self stopScan];
//    NSParameterAssert(serviceUUID && localName);
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        self.onConnection = onConnection;
        self.serviceUUID = serviceUUID;
        self.localName = localName;
        [self.centralManager scanForPeripheralsWithServices:nil
                                                    options:@{
                                                        CBCentralManagerScanOptionAllowDuplicatesKey: @(NO),
                                                    }];
    } else {
        if (onConnection) {
            onConnection(nil);
        }
    }
}

#pragma mark - Connect Peripheral

- (void)centralManager:(CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary<NSString *, id> *)advertisementData
                     RSSI:(NSNumber *)RSSI {
    if (![advertisementData[@"kCBAdvDataIsConnectable"] boolValue] || !peripheral.name) {
        return;
    }
    /*
     {
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = "eulixspace-4887b4bd99a33e8a";
     kCBAdvDataRxPrimaryPHY = 129;
     kCBAdvDataRxSecondaryPHY = 0;
     kCBAdvDataTimestamp = "662017933.055214";
     }
     */
    NSString *localName = advertisementData[@"kCBAdvDataLocalName"];
    if (![localName isEqualToString:self.localName]) {
        return;
    }
    ESDLog(@"[Bluetooth] matched peripheral.name %@", peripheral.name);
    ESDLog(@"[Bluetooth] matched advertisementData : %@", advertisementData);
    self.item = [ESBluetoothItem itemFrom:peripheral advertisementData:advertisementData];
    [self connectPeripheral:self.item.peripheral];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
    ESDLog(@"[Bluetooth] connectPeripheral %@", peripheral);
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    ESDLog(@"[Bluetooth] didConnectPeripheral %@", peripheral);
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:self.serviceUUID]]];
    [self.centralManager stopScan];
    // 可以停止扫描
    ESDLog(@"[Bluetooth] 连接成功 停止扫描");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        ESDLog(@"[Bluetooth] Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    if (self.didDiscoverServices) {
        return;
    }
    self.didDiscoverServices = YES;
    for (CBService *service in peripheral.services) {
        ESDLog(@"[Bluetooth] 获取UUID：%@", service);
        //4887B4BD-99A3-3E8A-0000-000000000000
        if ([service.UUID.UUIDString isEqualToString:self.serviceUUID]) {
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (self.didDiscoverCharacteristics) {
        return;
    }
    self.didDiscoverCharacteristics = YES;
    ESDLog(@"[Bluetooth] didDiscoverCharacteristicsForService %@", service);
    for (CBCharacteristic *cha in service.characteristics) {
        ESDLog(@"[Bluetooth] CBCharacteristic %@", cha);
        if (cha.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            self.writeCharacteristic = cha;
        } else if (cha.properties & CBCharacteristicPropertyNotify) {
            self.readCharacteristic = cha;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
        }
    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 拿到外设发送过来的数据
    ESDLog(@"[Bluetooth] didUpdateValueForCharacteristic %@", characteristic.value);
    if ([self.delegate respondsToSelector:@selector(bluetooth:readValue:)]) {
        [self.delegate bluetooth:self.item readValue:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        ESDLog(@"[Bluetooth] 订阅失败");
        ESDLog(@"[Bluetooth] %@", error);
        return;
    }
    if (characteristic.isNotifying) {
        ESDLog(@"[Bluetooth] 订阅成功");
        if (self.onConnection) {
            self.onConnection(self.item);
        }
        self.onConnection = nil;
    } else {
        ESDLog(@"[Bluetooth] 取消订阅");
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    ESDLog(@"[Bluetooth] didFailToConnectPeripheral %@", peripheral);
    if (self.onConnection) {
        self.onConnection(nil);
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    ESDLog(@"[Bluetooth] didDisconnectPeripheral %@ error : %@", peripheral, error);
    if (!self.item) {
        return;
    }
    if (self.onConnection) {
        self.onConnection(nil);
    }
    if ([self.delegate respondsToSelector:@selector(bluetooth:onClose:)]) {
        [self.delegate bluetooth:self.item onClose:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
}

@end
