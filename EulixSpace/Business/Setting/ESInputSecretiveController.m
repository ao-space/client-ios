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
//  ESInputSecretiveController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESInputSecretiveController.h"

@interface ESInputSecretiveController ()
@property (nonatomic, strong) UIButton * eyeBtn;
@end

@implementation ESInputSecretiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupViews {
    [super setupViews];
    
    [self.eyeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(26);
        make.centerY.mas_equalTo(self.mTextField);
        make.right.mas_equalTo(self.view).mas_offset(-26);
    }];
    
    self.mTextField.secureTextEntry = YES;
    self.mTextField.clearButtonMode = UITextFieldViewModeNever;
    [self.mTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(26);
        make.right.mas_equalTo(self.eyeBtn.mas_left).mas_offset(-26);
        make.top.mas_equalTo(self.view).mas_offset(20);
    }];
}

- (void)onEyeBtn:(UIButton *)btn {
    if (btn.tag == 0) {
        btn.tag = 1;
        [btn setImage:[UIImage imageNamed:@"eye_open"] forState:UIControlStateNormal];
        self.mTextField.secureTextEntry = NO;
    } else {
        btn.tag = 0;
        [btn setImage:[UIImage imageNamed:@"eye_close"] forState:UIControlStateNormal];
        self.mTextField.secureTextEntry = YES;
    }
}

- (UIButton *)eyeBtn {
    if (!_eyeBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"eye_close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onEyeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        _eyeBtn = btn;
        btn.tag = 0;
    }
    return _eyeBtn;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
