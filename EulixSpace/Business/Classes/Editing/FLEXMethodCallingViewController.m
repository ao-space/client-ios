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
//  FLEXMethodCallingViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 5/23/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXMethodCallingViewController.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXFieldEditorView.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXObjectExplorerViewController.h"
#import "FLEXArgumentInputView.h"
#import "FLEXArgumentInputViewFactory.h"
#import "FLEXUtility.h"

@interface FLEXMethodCallingViewController ()
@property (nonatomic, readonly) FLEXMethod *method;
@end

@implementation FLEXMethodCallingViewController

+ (instancetype)target:(id)target method:(FLEXMethod *)method {
    return [[self alloc] initWithTarget:target method:method];
}

- (id)initWithTarget:(id)target method:(FLEXMethod *)method {
    NSParameterAssert(method.isInstanceMethod == !object_isClass(target));

    self = [super initWithTarget:target data:method commitHandler:nil];
    if (self) {
        self.title = method.isInstanceMethod ? @"Method: " : @"Class Method: ";
        self.title = [self.title stringByAppendingString:method.selectorString];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.actionButton.title = @"Call";

    // Configure field editor view
    self.fieldEditorView.argumentInputViews = [self argumentInputViews];
    self.fieldEditorView.fieldDescription = [NSString stringWithFormat:
        @"Signature:\n%@\n\nReturn Type:\n%s",
        self.method.description, (char *)self.method.returnType
    ];
}

- (NSArray<FLEXArgumentInputView *> *)argumentInputViews {
    Method method = self.method.objc_method;
    NSArray *methodComponents = [FLEXRuntimeUtility prettyArgumentComponentsForMethod:method];
    NSMutableArray<FLEXArgumentInputView *> *argumentInputViews = [NSMutableArray new];
    unsigned int argumentIndex = kFLEXNumberOfImplicitArgs;

    for (NSString *methodComponent in methodComponents) {
        char *argumentTypeEncoding = method_copyArgumentType(method, argumentIndex);
        FLEXArgumentInputView *inputView = [FLEXArgumentInputViewFactory argumentInputViewForTypeEncoding:argumentTypeEncoding];
        free(argumentTypeEncoding);

        inputView.backgroundColor = self.view.backgroundColor;
        inputView.title = methodComponent;
        [argumentInputViews addObject:inputView];
        argumentIndex++;
    }

    return argumentInputViews;
}

- (void)actionButtonPressed:(id)sender {
    // Gather arguments
    NSMutableArray *arguments = [NSMutableArray new];
    for (FLEXArgumentInputView *inputView in self.fieldEditorView.argumentInputViews) {
        // Use NSNull as a nil placeholder; it will be interpreted as nil
        [arguments addObject:inputView.inputValue ?: NSNull.null];
    }

    // Call method
    NSError *error = nil;
    id returnValue = [FLEXRuntimeUtility
        performSelector:self.method.selector
        onObject:self.target
        withArguments:arguments
        error:&error
    ];
    
    // Dismiss keyboard and handle committed changes
    [super actionButtonPressed:sender];

    // Display return value or error
    if (error) {
        [FLEXAlert showAlert:@"Method Call Failed" message:error.localizedDescription from:self];
    } else if (returnValue) {
        // For non-nil (or void) return types, push an explorer view controller to display the returned object
        returnValue = [FLEXRuntimeUtility potentiallyUnwrapBoxedPointer:returnValue type:self.method.returnType];
        FLEXObjectExplorerViewController *explorer = [FLEXObjectExplorerFactory explorerViewControllerForObject:returnValue];
        [self.navigationController pushViewController:explorer animated:YES];
    } else {
        [self exploreObjectOrPopViewController:returnValue];
    }
}

- (FLEXMethod *)method {
    return _data;
}

@end
