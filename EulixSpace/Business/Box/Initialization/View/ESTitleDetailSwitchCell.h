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
//  ESSpaceTunSwitchCell.h
//  EulixSpace
//
//  Created by KongBo on 2023/6/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESSwitchType) {
    ESSwitchTypeText,
    ESSwitchTypeSwitch,
};

@protocol ESTitleDetailSwitchListItemProtocol

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSAttributedString *detailAtr;
@property (nonatomic, assign) BOOL isOn ;
@property (nonatomic, assign) ESSwitchType switchType;
@property (nonatomic, strong) NSString * platformAddress;
@property (nonatomic, assign) BOOL isBind;
@end

@class ESTitleDetailSwitchCell;
typedef void (^ESSwichValueChangedBlock)(ESTitleDetailSwitchCell *switchCell, BOOL newValue);

@interface ESTitleDetailSwitchCell : ESBaseCell

@property (nonatomic, copy) ESSwichValueChangedBlock changedBlock;

- (void)setSwitchOn:(BOOL)isOn;

@end

NS_ASSUME_NONNULL_END