//
//  YCPopMenu.m
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/21.
//
//

#import "YCPopMenu.h"

const NSUInteger YCPopMenuNoSelectionIndex = NSNotFound;

@interface YCPopMenu () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, copy) void (^actionBlock)(NSUInteger index, id data);

@property (nonatomic, copy) void (^touchUpInsideBlock)(void);

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) UIView *sender;

@property (nonatomic, assign) BOOL visible;

@property (nonatomic, weak) id owner;

@property (nonatomic, assign) YCPopMenuDirection direction; //default is YCPopMenuDirectionUp

@property (nonatomic, weak) UIView *cover; //`PopMenu` is on the top of cover, and cover is on the top of key window

@property (nonatomic, weak) UIView *coverContent;

@property (nonatomic, strong) Class cellClass;

@property (nonatomic, strong) UIView *roundedView;

@property (nonatomic, assign) CGPoint point;

@property (nonatomic, strong) UIView *arrow;

@end

@implementation YCPopMenu

+ (instancetype)popMenuWithCellClass:(Class)cellClass
                           dataArray:(NSArray *)dataArray
                         actionBlock:(void (^)(NSUInteger, id))actionBlock {
    YCPopMenu *menu = [[YCPopMenu alloc] init];
    [menu registerMenuCell:cellClass];
    menu.dataArray = dataArray;
    menu.actionBlock = actionBlock;
    return menu;
}

#pragma mark - Initialize

- (instancetype)init {
    self = [super init];
    if (self) {
        _vector = CGVectorMake(0, 0);
        _animationDuration = 0.3;
        _cornerRadius = 4;
        _animated = YES;
        _direction = YCPopMenuDirectionUp;
        self.shadow = YES;
        _maxCellCount = 6;
        _dismissWhenSelectedMenu = YES;
        _arrowSize = CGSizeMake(10, 5);
        _damping = 1;
        _initialSpringVelocity = 0;
        _options = UIViewAnimationOptionCurveEaseInOut;
    }
    return self;
}

- (void)customUI {
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = NO;
    if (self.cornerRadius > 0) {
        _tableView.layer.cornerRadius = self.cornerRadius;
        _tableView.layer.masksToBounds = YES;
    }
}

- (void)setShadow:(BOOL)shadow {
    _shadow = shadow;
    if (shadow) {
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 3;
    } else {
        self.layer.shadowColor = nil;
        self.layer.shadowOffset = CGSizeMake(3, 3);
        self.layer.shadowOpacity = 0;
        self.layer.shadowRadius = 0;
    }
}

- (void)registerMenuCell:(Class)cls {
    if (!cls) {
        return;
    }
    self.cellClass = cls;
    [self.tableView registerClass:cls forCellReuseIdentifier:NSStringFromClass(cls)];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sectionArray) {
        return self.sectionArray.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.sectionArray.count > section) {
        return [self.sectionArray[section] floatValue];
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.customSectionBlock) {
        return self.customSectionBlock(section);
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sectionArray) {
        return [self.dataArray[section] count];
    }
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<YCPopMenuItemProtocol> data = [self objectAtIndexPath:indexPath];
    if ([data respondsToSelector:@selector(menuHeight)]) {
        return data.menuHeight;
    }
    CGSize size = self.menuSize;
    if (size.height == 0 || size.width == 0) {
        size = [self.cellClass menuSize];
    }
    return size.height;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionArray) {
        NSArray *array = self.dataArray[indexPath.section];
        return array[indexPath.row];
    } else {
        return self.dataArray[indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(self.cellClass);
    id<YCPopMenuItemProtocol> data = [self objectAtIndexPath:indexPath];
    NSString *cellIdentifier = nil;
    if ([data respondsToSelector:@selector(cellIdentifier)] && [data cellIdentifier]) {
        cellIdentifier = [data cellIdentifier];
    } else {
        cellIdentifier = NSStringFromClass(self.cellClass);
    }

    UITableViewCell<YCPopMenuCellProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell respondsToSelector:@selector(line)]) {
        cell.line.hidden = indexPath.row == self.dataArray.count - 1;
    }
    NSParameterAssert([cell respondsToSelector:@selector(reloadWithData:)]);
    [cell reloadWithData:data];
    if (self.customCellBlock) {
        self.customCellBlock(cell, indexPath);
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionBlock) {
        id<YCPopMenuItemProtocol> data = [self objectAtIndexPath:indexPath];
        if ([data respondsToSelector:@selector(available)]) {
            BOOL available = [data available];
            if (!available) {
                return;
            }
        }
        self.actionBlock(indexPath.row, data);
    }
    if (self.dismissWhenSelectedMenu) {
        [self hide];
    }
}

#pragma mark - Visible

- (void)setSenderView:(UIView *)view {
    self.sender = view;
}

- (void)animation {
    if (_animated) { //重做弹出动画
        __block CGRect oldFrame = self.frame;
        //CGFloat arrowY = self.arrow.frame.origin.y;
        if (self.visible) {
            [self addArrow];
            CGRect frame = oldFrame;
            if (self.direction == YCPopMenuDirectionUp) {
                frame.origin.y += frame.size.height;
            }
            frame.size.height = 0;
            self.frame = frame;
            frame.origin = CGPointZero;
            self.tableView.frame = frame;
            self.cover.alpha = 0;
            if (self.direction == YCPopMenuDirectionUp) {
                CGRect arrowFrame = self.arrow.frame;
                arrowFrame.origin.y -= oldFrame.size.height;
                self.arrow.frame = arrowFrame;
            }
        } else {
            self.cover.alpha = 1;
            [self.arrow removeFromSuperview];
        }
        [UIView animateWithDuration:self.animationDuration
            delay:0
            usingSpringWithDamping:_damping
            initialSpringVelocity:_initialSpringVelocity
            options:_options
            animations:^{
                if (self.visible) {
                    self.frame = oldFrame;
                    oldFrame.origin = CGPointZero;
                    self.tableView.frame = oldFrame;
                    self.cover.alpha = 1;
                    if (self.direction == YCPopMenuDirectionUp) {
                        CGRect arrowFrame = self.arrow.frame;
                        arrowFrame.origin.y += oldFrame.size.height;
                        self.arrow.frame = arrowFrame;
                    }
                } else {
                    CGRect frame = oldFrame;
                    if (self.direction == YCPopMenuDirectionUp) {
                        frame.origin.y += frame.size.height;
                    }
                    frame.size.height = 0;
                    self.frame = frame;
                    frame.origin = CGPointZero;
                    self.tableView.frame = frame;
                    self.cover.alpha = 0;
                }
            }
            completion:^(BOOL finished) {
                if (!self.visible) {
                    [self removeFromSuperview];
                    [self.cover removeFromSuperview];
                }
            }];
    } else {
        if (!self.visible) {
            [self.arrow removeFromSuperview];
            [self.cover removeFromSuperview];
            [self removeFromSuperview];
        } else {
            [self addArrow];
            [self layoutIfNeeded];
        }
    }
}

- (void)hide {
    self.visible = NO;
    [self animation];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.actionBlock) {
        self.actionBlock(YCPopMenuNoSelectionIndex, nil);
    }
    [self hide];
}

static inline CGRect CGRectOffsetVector(CGRect rect, CGVector vector) {
    rect.origin.x += vector.dx;
    rect.origin.y += vector.dy;
    return rect;
}

- (void)setCoverEdgeInsets:(UIEdgeInsets)coverEdgeInsets {
    _coverEdgeInsets = coverEdgeInsets;
    CGRect frame = self.coverContent.frame;
    frame.origin.x += coverEdgeInsets.left;
    frame.origin.y += coverEdgeInsets.top;
    frame.size.width -= (coverEdgeInsets.left + coverEdgeInsets.right);
    frame.size.height -= (coverEdgeInsets.top + coverEdgeInsets.bottom);
    self.coverContent.frame = frame;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    return !CGRectContainsPoint(self.tableView.frame, point);
}

- (void)addCover {
    UIScrollView *cover = [[UIScrollView alloc] init];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:cover];
    UIView *coverContent = [[UIView alloc] init];
    [cover addSubview:coverContent];
    if (self.coverColor) {
        coverContent.backgroundColor = self.coverColor;
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tap:)];
    [cover addGestureRecognizer:tap];
    tap.delegate = self;
    self.cover = cover;
    self.coverContent = coverContent;
    [self.cover addSubview:self];
    cover.contentSize = window.frame.size;
    self.cover.frame = window.frame;
    self.coverContent.frame = self.cover.bounds;
    [self setCoverEdgeInsets:self.coverEdgeInsets];
}

- (void)addArrow {
    CGSize size = self.arrowSize;
    if (CGSizeEqualToSize(CGSizeZero, size)) {
        return;
    }
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    frame.origin.x = CGRectGetWidth(self.frame) / 2 + self.arrowOffset.horizontal;
    UIView *arrow = [UIView new];
    CAShapeLayer *arrowLayer = [[CAShapeLayer alloc] init];
    [arrow.layer addSublayer:arrowLayer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (self.direction == YCPopMenuDirectionUp) {
        frame.origin.y = CGRectGetHeight(self.frame);
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake(size.width, 0)];
        [path addLineToPoint:CGPointMake(size.width / 2, size.height)];
        [path addLineToPoint:CGPointZero];
    } else if (self.direction == YCPopMenuDirectionDown) {
        frame.origin.y = -self.arrowSize.height;
        [path moveToPoint:CGPointMake(0, size.height)];
        [path addLineToPoint:CGPointMake(size.width, size.height)];
        [path addLineToPoint:CGPointMake(size.width / 2, 0)];
        [path addLineToPoint:CGPointMake(0, size.height)];
    }
    arrowLayer.fillColor = [UIColor whiteColor].CGColor;
    arrowLayer.strokeColor = nil;
    arrowLayer.path = path.CGPath;
    arrow.frame = frame;
    arrowLayer.frame = arrow.bounds;
    [self addSubview:arrow];
    self.arrow = arrow;
}

- (void)setupLayout:(CGPoint)point {
    self.point = point;
    CGRect frame = CGRectZero;
    frame.origin = point;
    NSParameterAssert(self.cellClass);
    CGSize size = self.menuSize;
    if (size.height == 0 || size.width == 0) {
        size = [self.cellClass menuSize];
    }
    CGFloat height = 0;
    if (self.sectionArray) {
        for (NSUInteger section = 0; section < self.sectionArray.count; section++) {
            NSArray *array = self.dataArray[section];
            height += [self.sectionArray[section] floatValue];
            height += array.count * size.height;
        }
    } else {
        height = size.height * MIN(self.dataArray.count, self.maxCellCount);
    }
    if ([self.dataArray.firstObject respondsToSelector:@selector(menuHeight)]) {
        height = 0;
        NSUInteger count = MIN(self.dataArray.count, self.maxCellCount);
        for (NSUInteger index = 0; index < count; ++index) {
            id<YCPopMenuItemProtocol> item = self.dataArray[index];
            height += item.menuHeight;
        }
    }
    height += self.tableView.tableHeaderView.frame.size.height + self.tableView.tableFooterView.frame.size.height + self.headerView.frame.size.height;
    if (self.dataArray.count >= self.maxCellCount) {
        _tableView.scrollEnabled = YES;
    }
    if (self.direction == YCPopMenuDirectionUp) {
        frame.origin.y -= height;
    }
    frame.size.height = height;
    frame.size.width = size.width;
    frame = CGRectOffsetVector(frame, self.vector);
#ifdef DEBUG
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSString *errorInfo = nil;
    if (CGRectGetMaxX(frame) > CGRectGetMaxX(window.frame)) {
        errorInfo = [NSString stringWithFormat:@"[%.2f] is BEYOND window width [%.2f]",
                                               CGRectGetMaxX(frame),
                                               CGRectGetMaxX(window.frame)];
    }
    if (CGRectGetMaxY(frame) > CGRectGetMaxY(window.frame)) {
        errorInfo = [NSString stringWithFormat:@"[%.2f] is BEYOND window height [%.2f]",
                                               CGRectGetMaxY(frame),
                                               CGRectGetMaxY(window.frame)];
    }
    if (CGRectGetMinX(frame) < 0 || CGRectGetMinY(frame) < 0) {
        errorInfo = [NSString stringWithFormat:@"[%@] is BEYOND window origin",
                                               NSStringFromCGPoint(frame.origin)];
    }
    NSAssert(!errorInfo, errorInfo);
#endif
    self.frame = frame;
    [self customUI];
    frame.origin = CGPointZero;
    if (self.headerView) {
        [self addSubview:self.headerView];
        self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.headerView.frame), 0, 0, 0);
    }
    self.tableView.frame = frame;
}

- (void)showFromPoint:(CGPoint)point {
    [self addCover];
    [self setupLayout:point];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
    self.visible = YES;
    if (self.customViewBlock) {
        self.customViewBlock(self);
    }
    [self animation];
}

- (void)showFromView:(UIView *)view {
    NSParameterAssert(view);
    self.sender = view;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [self.sender.superview convertRect:self.sender.frame toView:window];
    CGPoint point = rect.origin;
    if (self.direction == YCPopMenuDirectionDown) {
        point = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    }
    [self showFromPoint:point];
}

- (void)reloadData {
    [self setupLayout:self.point];
    [self.tableView reloadData];
}

#pragma mark - Lazy Load

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self addSubview:_tableView];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.sectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
    return _tableView;
}

@end
