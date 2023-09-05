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
//  FLEXKeyboardHelpViewController.m
//  FLEX
//
//  Created by Ryan Olson on 9/19/15.
//  Copyright © 2015 f. All rights reserved.
//

#import "FLEXKeyboardHelpViewController.h"
#import "FLEXKeyboardShortcutManager.h"

@interface FLEXKeyboardHelpViewController ()

@property (nonatomic) UITextView *textView;

@end

@implementation FLEXKeyboardHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.textView];
#if TARGET_OS_SIMULATOR
    self.textView.text = FLEXKeyboardShortcutManager.sharedManager.keyboardShortcutsDescription;
#endif
    self.textView.backgroundColor = UIColor.blackColor;
    self.textView.textColor = UIColor.whiteColor;
    self.textView.font = [UIFont boldSystemFontOfSize:14.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.title = @"Simulator Shortcuts";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
}

- (void)donePressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
