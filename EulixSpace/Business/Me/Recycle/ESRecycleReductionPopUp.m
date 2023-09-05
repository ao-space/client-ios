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
//  ESRecycleReductionPopUp.m
//  EulixSpace
//
//  Created by qu on 2022/3/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESRecycleReductionPopUp.h"

@implementation ESRecycleReductionPopUp
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
        self.pointOutLabel.text = NSLocalizedString(@"Are you sure you want to restore the selected files?", @"是否确定还原选中的文件？") ;
        [self.delectCompleteBtn setTitle:NSLocalizedString(@"Restore", @"还原") forState:UIControlStateNormal];
    }
    return self;
}

- (void)didClickCancelBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recycleReductionPopUp:didClickCancelBtn:)]) {
        [self.popUpdelegate recycleReductionPopUp:self didClickCancelBtn:nil];
    }
}

- (void)didClickDelectCompleteBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recycleReductionPopUp:didClickCompleteBtn:)]) {
        [self.popUpdelegate recycleReductionPopUp:self didClickCompleteBtn:nil];
    }
}

@end
