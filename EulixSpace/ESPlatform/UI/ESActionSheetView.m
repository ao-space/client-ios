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


#import "ESActionSheetView.h"
#import "ESActionSheetButton.h"
#define SELF_Width self.bounds.size.width
#define SELF_Height self.bounds.size.height

static CGFloat kTopMargin = 20.f;
@interface ESActionSheetView ()<UIGestureRecognizerDelegate> {
    NSString *_title;
    NSString *_subtitle;
    NSString *_message;

    NSAttributedString *_atTitle;
    NSAttributedString *_atSubtitle;
    NSAttributedString *_atMessage;

    CGFloat _titleHeight;
    CGFloat _subtitleHeight;
    CGFloat _messageHeight;
    CGFloat _headViewHeight;
    CGFloat _contentViewHeight;
    CGFloat _textMargin;

}
// 所有控件的容器
@property (strong, nonatomic) UIView *contentView;
// 显示标题
@property (strong, nonatomic) UILabel *titleLabel;
// 显示子标题
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

// 顶部显示提示文字的view
@property (strong, nonatomic) UIView *headView;
// 底部取消按钮
@property (strong, nonatomic) ESActionSheetButton *cancelBtn;
// 选项
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
// 点击手势
@property (strong, nonatomic) NSArray<ESActionSheetButton *> *actionSheetButtons;

@end

@implementation ESActionSheetView

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle actionSheetButtons:(NSArray<ESActionSheetButton *> *)actionSheetButtons {
    if (self = [super init]) {
        _title = title;
        _subtitle = subtitle;
        _actionSheetButtons = actionSheetButtons;
        [self commonInit];
    }
    return self;

}

- (instancetype)initWithTitle:(NSAttributedString *)title
                     subtitle:(NSAttributedString *)subtitle
                      message:(NSAttributedString *)message
           actionSheetButtons:(NSArray<ESActionSheetButton *> *)actionSheetButtons {
    if (self = [super init]) {
        _atTitle = title;
        _atSubtitle = subtitle;
        _atMessage = message;
        _actionSheetButtons = actionSheetButtons;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithActionSheetButtons:(NSArray<ESActionSheetButton *> *)actionSheetButtons {
    return [self initWithTitle:nil subtitle:nil actionSheetButtons:actionSheetButtons];
}

- (void)commonInit {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.cancelBtn];
    [self addGestureRecognizer:self.tapGesture];
    if (!_actionSheetButtons) return;
    _cancelBtnHeight = 64.f;
    _cancelBtnTopAndBottomMargin = 10.f;
    _leftAndRightMargin = 20.f;
    _cornerRadius = 10.f;
    _textMargin = 28.0f;
    _seperatorHeight = 1.f / [UIScreen mainScreen].scale;
    [self setupHeadView];

    for (ESActionSheetButton *btn in _actionSheetButtons) {
        // 给按钮添加点击响应方法, 在响应方法中调用他的block即可
        [btn addTarget:self action:@selector(actionSheetBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        // 添加按钮
        [self.contentView addSubview:btn];
    }
}

- (void)setupHeadView {
    CGFloat labelMaxWidth = [UIScreen mainScreen].bounds.size.width - 2 * _leftAndRightMargin - 2 * _textMargin;
    
    if (_title || _atTitle) {
        [self.headView addSubview:self.titleLabel];
        
        // 设置了标题 才添加titleLabel
        if (_atTitle) {
            self.titleLabel.attributedText = _atTitle;
            _titleHeight = [self sizeLabelToFit:_atTitle width:labelMaxWidth height:MAXFLOAT].height;
        } else  {
            self.titleLabel.text = _title;
            // 计算标题的高度  最大宽度为屏幕的宽度减去左右的间隙
            _titleHeight = [_title boundingRectWithSize:CGSizeMake(labelMaxWidth, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: self.titleLabel.font}
                                                context:nil].size.height;
        }
        _headViewHeight += (kTopMargin + _titleHeight);
    }
    
    if (_subtitle || _atSubtitle) {
        [self.headView addSubview:self.subtitleLabel];
        if (_atSubtitle) {
            self.subtitleLabel.attributedText = _atSubtitle;
            _subtitleHeight = [self sizeLabelToFit:_atSubtitle width:labelMaxWidth height:MAXFLOAT].height;
        } else {
            self.subtitleLabel.text = _subtitle;
            _subtitleHeight = [_subtitle boundingRectWithSize:CGSizeMake(labelMaxWidth, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: self.subtitleLabel.font}
                                                      context:nil].size.height;
        }
      
        _headViewHeight += (kTopMargin + _subtitleHeight);
    }
    
    if (_message || _atMessage) {
        [self.headView addSubview:self.messageLabel];
        if (_atMessage) {
            self.messageLabel.attributedText = _atMessage;
            _messageHeight = [self sizeLabelToFit:_atMessage width:labelMaxWidth height:MAXFLOAT].height;
        } else {
            self.messageLabel.text = _message;
            _messageHeight = [_message boundingRectWithSize:CGSizeMake(labelMaxWidth, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: self.messageLabel.font}
                                                context:nil].size.height;
        }
        _headViewHeight += (kTopMargin + _messageHeight);
    }
    if (_headView) {
        // 只有在设置了标题或者子标题的时候才需要添加headView
        [self.contentView addSubview:_headView];
    }
    // headView的高度最小为44
    _headViewHeight = MAX(44.f, _headViewHeight);
}

- (CGSize)sizeLabelToFit:(NSAttributedString *)aString width:(CGFloat)width height:(CGFloat)height {
   UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, height)];
   tempLabel.attributedText = aString;
   tempLabel.numberOfLines = 0;
   [tempLabel sizeToFit];
   CGSize size = tempLabel.frame.size;
   size = CGSizeMake(ceil(size.width), ceil(size.height));
   return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.superview) { // window
        self.frame = self.superview.bounds;
        CGFloat contentViewWidth = SELF_Width - 2*_leftAndRightMargin;
        if (_headView) {
            self.headView.frame = CGRectMake(0, 0, contentViewWidth, _headViewHeight);
            [self setCornerRadiusForView:self.headView isForTop:YES];
            if (_titleLabel && _subtitleLabel &&_messageLabel) {
                // 无_subtitleLabel的时候,titleLabel 竖直方向居中
                // titleLabel 和 separatorView的距离为 kTopMargin/2
                self.titleLabel.frame = CGRectMake(_textMargin, kTopMargin, contentViewWidth - 2 * _textMargin, _titleHeight);
                self.subtitleLabel.frame = CGRectMake(_textMargin, CGRectGetMaxY(_titleLabel.frame)+kTopMargin/2, contentViewWidth - 2 * _textMargin, _subtitleHeight);
                self.messageLabel.frame = CGRectMake(_textMargin, CGRectGetMaxY(_subtitleLabel.frame)+kTopMargin/2, contentViewWidth - 2 * _textMargin, _messageHeight);
            }
            else if (_titleLabel && _subtitleLabel) {
                // 无_subtitleLabel的时候,titleLabel 竖直方向居中
                // titleLabel 和 separatorView的距离为 kTopMargin/2
                self.titleLabel.frame = CGRectMake(_textMargin, kTopMargin, contentViewWidth, _titleHeight);
                self.subtitleLabel.frame = CGRectMake(_textMargin, CGRectGetMaxY(_titleLabel.frame)+kTopMargin/2, contentViewWidth, _subtitleHeight);
            }
            else if (_titleLabel) {
                self.titleLabel.frame = CGRectMake(_textMargin, self.headView.bounds.origin.y, self.headView.bounds.size.width, self.headView.bounds.size.height);
            }
            else if (_subtitleLabel) {
                self.subtitleLabel.frame = CGRectMake(_textMargin, self.headView.bounds.origin.y, self.headView.bounds.size.width, self.headView.bounds.size.height);
            }
        }

        CGFloat btnY = _headViewHeight;
        
        for (int i=0; i<_actionSheetButtons.count; i++) {
            ESActionSheetButton *btn = _actionSheetButtons[i];
            btnY += _seperatorHeight;
            btn.frame = CGRectMake(0, btnY, contentViewWidth, btn.btnHeight);
            btnY += btn.btnHeight;
            if (i == 0) {
                if (_headView == nil) { // 没有提示文字
                    if (_actionSheetButtons.count == 1) {
                        // 只有一个按钮 设置四个圆角
                        btn.layer.masksToBounds = YES;
                        btn.layer.cornerRadius = _cornerRadius;
                    }
                    else {
                        // 有多个按钮的时候, 设置第一个按钮上两个角为圆角
                        [self setCornerRadiusForView:btn isForTop:YES];
                    }
                }
                else {
                    if (_actionSheetButtons.count == 1) {
                        // _headView的时候, 并且只有一个按钮, 设置第一个按钮下面两个角为圆角
                        [self setCornerRadiusForView:btn isForTop:NO];
                    }
                }
            }
            else if (i == _actionSheetButtons.count - 1) {
                // 设置最后一个按钮的最后两个角为圆角
                [self setCornerRadiusForView:btn isForTop:NO];

            }

        }
        
        self.cancelBtn.frame = CGRectMake(0, btnY+_cancelBtnTopAndBottomMargin, contentViewWidth, _cancelBtnHeight);
        self.cancelBtn.layer.masksToBounds = YES;
        self.cancelBtn.layer.cornerRadius = _cornerRadius;
        
        self.contentView.frame = CGRectMake(_leftAndRightMargin, (self.bounds.size.height-_contentViewHeight - kBottomHeight + _cancelBtnTopAndBottomMargin), contentViewWidth, _contentViewHeight);
    }
}


- (void)switchToHideState {
    self.alpha = 0;
    self.contentView.frame = CGRectMake(_leftAndRightMargin, self.bounds.size.height, SELF_Width-2*_leftAndRightMargin, _contentViewHeight);
}

- (void)switchToShowState {
    self.alpha = 1.f;
    self.contentView.frame = CGRectMake(_leftAndRightMargin, (self.bounds.size.height-_contentViewHeight), SELF_Width-2*_leftAndRightMargin, _contentViewHeight);
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.frame = window.bounds;
    [window addSubview:self];
    
    [self computeContentViewHeight];
    
    [self switchToHideState];
    [UIView animateWithDuration:0.25 animations:^{
        [self switchToShowState];
    } completion:nil];
}

- (void)computeContentViewHeight {
    _contentViewHeight = _headViewHeight;
    for (ESActionSheetButton *btn in _actionSheetButtons) {
        _contentViewHeight += (btn.btnHeight+_seperatorHeight);
    }
    // 计算contentView的高度
    _contentViewHeight += (_cancelBtnHeight + 2*_cancelBtnTopAndBottomMargin);
}


- (void)tapHandler:(UITapGestureRecognizer *)tapGesture {
    [self hide];
}

- (void)cancelBtnOnClick:(ESActionSheetButton *)btn {
    [self hide];
}

- (void)actionSheetBtnOnClick:(ESActionSheetButton *)btn {
    if (btn.handler) {
        btn.handler(self, btn);
    }
    [self hide];
}


- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        [self switchToHideState];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

- (void)dealloc {
//    NSLog(@"销毁----");
}

- (void)setCornerRadiusForView:(UIView *)targetView isForTop:(BOOL)isForTop {
    // 需要设置的圆角-- 上下左右组合
    UIRectCorner rectCorner = isForTop ? (UIRectCornerTopLeft|UIRectCornerTopRight) : (UIRectCornerBottomLeft|UIRectCornerBottomRight);
    // UIBezierPath
    UIBezierPath *headViewPath = [UIBezierPath bezierPathWithRoundedRect:targetView.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(_cornerRadius, _cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = headViewPath.CGPath;
    // 使用maskView来完成
    targetView.layer.mask = maskLayer;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _tapGesture) {
        CGFloat locationY = [gestureRecognizer locationInView:self].y;
        //        NSLog(@"%f ----", locationY);
        //         点击位置不在contentView上面
        return locationY < self.contentView.frame.origin.y || locationY > CGRectGetMaxY(self.contentView.frame);
    }
    return YES;
    
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
    }
    return _contentView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        tapGesture.delegate = self;
        _tapGesture = tapGesture;
    }
    return _tapGesture;
}

- (ESActionSheetButton *)cancelBtn {
    if (!_cancelBtn) {
        ESActionSheetButton *cancelBtn = [[ESActionSheetButton alloc] init];
        [cancelBtn addTarget:self action:@selector(cancelBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle: NSLocalizedString(@"cancel", @"取消")  forState:UIControlStateNormal];
        [cancelBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        cancelBtn.backgroundColor = [ESColor.systemBackgroundColor colorWithAlphaComponent:0.98];
        _cancelBtn = cancelBtn;
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor blackColor];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor blackColor];
        _subtitleLabel = titleLabel;
    }
    return _subtitleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor blackColor];
        _messageLabel = titleLabel;
    }
    return _messageLabel;
}

- (UIView *)headView {
    if (!_headView) {
        UIView *headView = [UIView new];
        headView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.98];
        
        _headView = headView;
    }
    return _headView;
}

- (void)leftAlignmentStyle {
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _subtitleLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.textAlignment = NSTextAlignmentLeft;
}
@end
