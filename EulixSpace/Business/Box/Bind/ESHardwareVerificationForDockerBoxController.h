//
//  ESHardwareVerificationForDockerBoxController.h
//  EulixSpace
//
//  Created by dazhou on 2023/7/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"
#import "ESSecurityEmailMamager.h"
#import "ESBoxBindViewModel.h"
#import "ESNotifiResp.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESHardwareVerificationForDockerBoxController : YCViewController
@property (nonatomic, assign) ESAuthenticationType authType;
@property (nonatomic, strong) ESAuthApplyRsp * applyRsp;

@property (nonatomic, copy) void (^searchedBlock)(ESAuthenticationType authType, ESBoxBindViewModel *viewModel, ESAuthApplyRsp * applyRsp);
@end

NS_ASSUME_NONNULL_END
