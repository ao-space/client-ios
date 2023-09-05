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
//  ESAddAlbumCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/11/2.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAddAlbumCell.h"

@interface ESAddAlbumCell ()


@end

@implementation ESAddAlbumCell

- (void)bindData:(id)data {
    self.icon.image = [UIImage imageNamed:@"action_sheet_add_album"];
    self.titleLabel.text = NSLocalizedString(@"New Album", @"新建相簿");
}

@end
