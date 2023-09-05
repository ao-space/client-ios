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
//  ESLaunchlntroductionVC.m
//  EulixSpace
//
//  Created by qu on 2021/7/15.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLaunchlntroductionVC.h"
#import "ESAgreementWebVC.h"
#import "ESGlobalMacro.h"
#import "ESCommonToolManager.h"
#import "ESLaunchIntroductionView.h"

@interface ESLaunchlntroductionVC ()

@end

@implementation ESLaunchlntroductionVC

- (void)viewDidLoad {
    if (ScreenHeight < 668) {
        [ESLaunchIntroductionView sharedWithImages:@[@"yd_1", @"yd_2", @"yd_3"] buttonImage:@"" buttonFrame:CGRectMake(ScreenWidth / 2 - 551 / 4, ScreenHeight - 150, 551 / 2, 45)];

    } else {
        if ([ESCommonToolManager isEnglish]) {
            [ESLaunchIntroductionView sharedWithImages:@[@"yd_1_en", @"yd_2_en", @"yd_3_en"] buttonImage:@"" buttonFrame:CGRectMake(ScreenWidth / 2 - 551 / 4, ScreenHeight - 150, 551 / 2, 45)];
        }else{
            [ESLaunchIntroductionView sharedWithImages:@[@"yd_1", @"yd_2", @"yd_3"] buttonImage:@"" buttonFrame:CGRectMake(ScreenWidth / 2 - 551 / 4, ScreenHeight - 150, 551 / 2, 45)];
        }
    }

    self.navigationController.navigationBar.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSAgreementNotification:) name:@"didSAgreementNotification" object:nil];
}
- (void)lntroductionView:(ESLaunchIntroductionView *_Nullable)lntroductionView didLinkClick:(UIButton *_Nullable)button {
    ESAgreementWebVC *vc = [ESAgreementWebVC new];
    vc.agreementType = ESConcealtAgreement;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSAgreementNotification:(NSNotification *)notifi {
    ESAgreementWebVC *vc = [ESAgreementWebVC new];
    vc.agreementType = ESConcealtAgreement;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
