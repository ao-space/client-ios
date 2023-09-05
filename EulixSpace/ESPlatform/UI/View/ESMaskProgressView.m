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
//  ESSectorProgressView.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/20.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMaskProgressView.h"

#define kDegreesToRadians(x) (M_PI*(x)/180.0)

@interface ESMaskProgressView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property(nonatomic, assign) CGFloat progressPerFrame;
@property (nonatomic, strong) NSTimer *timer;

@property(nonatomic, assign) CGSize progressSize;
@property(nonatomic, assign) CGFloat startProgress;
@property(nonatomic, assign) CGFloat endProgress;
@property(nonatomic, assign) CGFloat currentProgress;

@property(nonatomic, strong) UIColor  *fillColor;
@property(nonatomic, copy) dispatch_block_t progressFinishBlock;

@end

@implementation ESMaskProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
       self.backgroundColor = [ESColor colorWithHex:0x000000 alpha:0.5];
        _currentProgress = CGFLOAT_MAX;
    }
    return self;
}

- (void)setProgress:(CGFloat)toProgress
   withTimeInterval:(NSTimeInterval)timeInterval
         finshBlock:(dispatch_block_t)progressFinishBlock {
    self.progressFinishBlock = progressFinishBlock;
    [self setProgress:toProgress withTimeInterval:timeInterval];
}

- (void)reset {
    _currentProgress = CGFLOAT_MAX;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)setProgress:(CGFloat)toProgress withTimeInterval:(NSTimeInterval)timeInterval {
    [self startProgressFrom: -0.25 toProgress: (-0.25 + toProgress) withTimeInterval:timeInterval];
}

- (void)startProgressFrom:(CGFloat)startProgress toProgress:(CGFloat)toProgress withTimeInterval:(NSTimeInterval)timeInterval {
    if (toProgress < startProgress || toProgress > 1) {
        return;
    }
    _progressSize = self.bounds.size;
    
    _startProgress = startProgress;
    _endProgress = toProgress;
    
    if (_currentProgress == CGFLOAT_MAX) {
        _currentProgress = startProgress;
    }
    
    _progressPerFrame =  (toProgress - _currentProgress) / (timeInterval / 0.1 );
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    
    [path moveToPoint:CGPointMake(_progressSize.width / 2, _progressSize.height / 2)];
    [path addArcWithCenter:CGPointMake(_progressSize.width / 2, _progressSize.height / 2)
                    radius:_progressRadius
                startAngle:_startProgress * M_PI * 2
                  endAngle:_currentProgress * M_PI * 2
                 clockwise:YES];

        path.usesEvenOddFillRule = YES;
    
    if (!_shapeLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor= [UIColor blackColor].CGColor;
        shapeLayer.fillRule= kCAFillRuleEvenOdd;
        
        self.layer.mask = shapeLayer;
        _shapeLayer = shapeLayer;
    }
    
    [self refreshProgressWithTimer];
}

- (void)refreshProgressWithTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }

    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshPerFrame) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)refreshPerFrame {
    _currentProgress += _progressPerFrame;

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path moveToPoint:CGPointMake(_progressSize.width / 2, _progressSize.height / 2)];
    [path addArcWithCenter:CGPointMake(_progressSize.width / 2, _progressSize.height / 2)
                    radius:_progressRadius
                startAngle:_startProgress * M_PI * 2
                  endAngle:_currentProgress * M_PI * 2
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(_progressSize.width / 2, _progressSize.height / 2)];
        path.usesEvenOddFillRule = YES;
    _shapeLayer.path = path.CGPath;
    self.layer.mask = _shapeLayer;
    
    if (_currentProgress >= _endProgress) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
     
        if (_progressFinishBlock) {
            _progressFinishBlock();
        }
    }
}


@end
