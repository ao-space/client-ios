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
//  ESInputNormalController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESInputNormalController.h"
#import "UIColor+ESHEXTransform.h"
#import "ESToast.h"

@interface ESInputNormalController ()
@end

@implementation ESInputNormalController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * text = [NSString stringWithFormat:@"%@  ", NSLocalizedString(@"done", @"完成")];
    UIBarButtonItem * doneBtn = [self barItemWithTitle:text selector:@selector(onDoneBtn)];
    doneBtn.tintColor = ESColor.primaryColor;
    self.navigationItem.rightBarButtonItem = doneBtn;
    
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mTextField becomeFirstResponder];
}

- (void)dealloc {
}

- (void)setupViews {
    UITextField * tf = [[UITextField alloc] init];
    tf.textAlignment = NSTextAlignmentLeft;
    tf.keyboardType = self.keyboardType;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;

    if (self.defaultString) {
        tf.text = self.defaultString;
    } else if (self.placeholderString) {
        tf.placeholder = self.placeholderString;
    }

    [self.view addSubview:tf];
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(26);
        make.right.mas_equalTo(self.view).mas_offset(-26);
        make.top.mas_equalTo(self.view).mas_offset(20);
    }];
    self.mTextField = tf;
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(26);
        make.right.mas_equalTo(self.view).mas_offset(-26);
        make.top.mas_equalTo(tf.mas_bottom).mas_offset(15);
        make.height.mas_equalTo(1);
    }];
}

- (void)onDoneBtn {
    if (self.checkInputBlock) {
        NSString * result = self.checkInputBlock(self.mTextField.text);
        if (result == nil && self.doneBlock) {
            self.doneBlock(self.mTextField.text);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [ESToast toastError:result];
        }
        return;
    }
    if (self.doneBlock) {
        self.doneBlock(self.mTextField.text);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
