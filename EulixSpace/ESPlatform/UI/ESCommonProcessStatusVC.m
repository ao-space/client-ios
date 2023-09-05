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
//  ESDeleteProcessStatusVC.m
//  EulixSpace
//
//  Created by KongBo on 2023/4/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESCommonProcessStatusVC.h"
#import "ESNetworkRequestManager.h"
#import "UIViewController+ESPresent.h"
#import "UIWindow+ESVisibleVC.h"

@interface ESCommonProcessStatusVC ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSInteger retryCount;

@end

@implementation ESCommonProcessStatusVC

- (void)showFrom:(UIViewController *)vc {
    self.view.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.3];
    UIView *window = [UIWindow keyWindow];
    [window addSubview:self.view];
}

- (void)hidden:(BOOL)immediately {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateProcess:0];
    [self creatTimerStartQueryProcessStatus];
}

- (void)updateProcess:(CGFloat)process {
    self.processMessageLabel.text = [NSString stringWithFormat:@"%@...%ld%%",   [self customProcessTitle], (NSInteger)(process * 100)];
    [super updateProcess:process];
}

- (void)updateProcessWithTimerQueryStatus {
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"async_task_info"
                                                queryParams:@{@"taskId" : ESSafeString(self.taskId)}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        strongfy(self)
        if (![response isKindOfClass:[NSDictionary class]]) {
            [self endQuery];
            return;
        }
        
        if (self.processUpdateBlock == nil) {
            [self endQuery];
            return;
        }
//        const (
//            AsyncTaskStatusInit       = "init"
//            AsyncTaskStatusProcessing = "processing"
//            AsyncTaskStatusSuccess    = "success"
//            AsyncTaskStatusFailed     = "failed"
//        )
        if ([response[@"taskStatus"] isEqualToString:@"failed"]) {
            [self endQuery];
            self.processUpdateBlock(NO, YES, 0);
            return;
        }
        
        if ([response[@"taskStatus"] isEqualToString:@"success"]) {
            [self endQuery];
            self.processUpdateBlock(YES, YES, 1);
            return;
        }
        
        NSInteger processed = [response[@"processed"] intValue];
        NSInteger total = [response[@"total"] intValue];
        if (total > 0 && processed >= 0) {
            CGFloat process = (CGFloat)processed / total;
            [self updateProcess: process];
            self.processUpdateBlock(NO, NO, process);
        }
      
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (self.retryCount < 0) {
                [self endQuery];
                self.processUpdateBlock(YES, YES, 0);
            }
            self.retryCount--;
        }];
}

- (void)endQuery {
    [self timerStop];
}

- (void)creatTimerStartQueryProcessStatus {
    //0.创建队列
    if(!self.timer){
        dispatch_queue_t queue = dispatch_get_main_queue();
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

        //3.要调用的任务
        dispatch_source_set_event_handler(self.timer, ^{
            [self updateProcessWithTimerQueryStatus];
        });
        //4.开始执行
        dispatch_resume(self.timer);
        
        self.retryCount = 3;
    }
}
   
- (void)timerStop {
    @synchronized (self){
        if (self.timer) {
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
    }
}

@end
