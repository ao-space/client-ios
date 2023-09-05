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
//  ESSecurityEmailBindSuccessController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSecurityEmailBindSuccessController.h"
#import "UIColor+ESHEXTransform.h"
#import "UIFont+ESSize.h"
#import "ESTapTextView.h"

@interface ESSecurityEmailBindSuccessController ()

@end

@implementation ESSecurityEmailBindSuccessController

- (void)onLeft {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Bind security email", @"绑定密保邮箱");
    UIBarButtonItem * item = [self barItemWithTitle:@"" selector:@selector(onLeft)];
    self.navigationItem.leftBarButtonItem = item;
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"result_success"]];
    [self.view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.width.height.mas_offset(30);
        make.top.mas_offset(70);
    }];
    
    UILabel * label1 = [[UILabel alloc] init];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.numberOfLines = 0;
    label1.text = NSLocalizedString(@"security email bind success", @"密保邮箱绑定成功");
    label1.textColor = [UIColor es_colorWithHexString:@"#333333"];
    label1.font = ESFontPingFangMedium(14);
    [self.view addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(iv.mas_bottom).offset(20);
    }];
    
    UILabel * label2 = [[UILabel alloc] init];
    label2.numberOfLines = 0;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = NSLocalizedString(@"Currently bound mailbox", @"当前绑定邮箱");
    label2.textColor = [UIColor es_colorWithHexString:@"#333333"];
    label2.font = ESFontPingFangMedium(20);
    [self.view addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(label1.mas_bottom).offset(50);
    }];
    
    UILabel * label3 = [[UILabel alloc] init];
    label3.numberOfLines = 0;
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = self.email;
    label3.textColor = [UIColor es_colorWithHexString:@"#337AFF"];
    label3.font = ESFontPingFangMedium(28);
    [self.view addSubview:label3];
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(label2.mas_bottom).offset(20);
    }];
    
    ESTapTextView * tapView = [[ESTapTextView alloc] init];
    [self.view addSubview:tapView];
    [tapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(label3.mas_bottom).offset(30);
    }];
    weakfy(self);
    NSMutableArray * tapList = [NSMutableArray array];
    ESTapModel * model = [[ESTapModel alloc] init];
    model.text = NSLocalizedString(@"back", @"返回");
    model.textColor = [UIColor es_colorWithHexString:@"#337AFF"];
    model.underlineColor = [UIColor es_colorWithHexString:@"#337AFF"];
    model.textFont = ESFontPingFangMedium(12);
    model.onTapTextBlock = ^{
        __block UIViewController * dstCtl;
        __block int value = -1;
        [weak_self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(viewModelJump)]) {
                int tmp = [obj performSelector:@selector(viewModelJump)];
                if (tmp > value) {
                    dstCtl = obj;
                }
            }
        }];
        if (dstCtl) {
            [weak_self.navigationController popToViewController:dstCtl animated:YES];
        }
    };
    [tapList addObject:model];
    
    NSString * content = NSLocalizedString(@"back", @"返回");
    [tapView setShowData:content tap:tapList];
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
