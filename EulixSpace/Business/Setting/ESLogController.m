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
//  ESLogController.m
//  EulixSpace
//
//  Created by dazhou on 2022/6/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESLogController.h"



@interface ESLogController ()
@property (nonatomic, strong) NSMutableArray * fileList;
@property (nonatomic, strong) NSString * logDir;
@property (nonatomic, strong) NSFileManager * fileManager;

@end

@implementation ESLogController


- (NSFileManager *)fileManager {
    if (!_fileManager) {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        _fileManager = fileManager;
    }
    return _fileManager;
}

- (NSString *)logDir {
    if (!_logDir) {
        NSString * documents = [[[[NSFileManager defaultManager]
            URLsForDirectory:NSDocumentDirectory
                   inDomains:NSUserDomainMask] lastObject] path];
        NSString * logDir = [documents stringByAppendingString:@"/Logs"];
        _logDir = logDir;
    }
    return _logDir;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"日志分享";
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];

    [self readData];
}

- (void)readData {
    NSError *error = nil;
    NSArray * fileList = [[NSArray alloc] init];
    fileList = [self.fileManager contentsOfDirectoryAtPath:self.logDir error:&error];
    
    fileList = [fileList sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        if ([obj1 caseInsensitiveCompare:obj2] == NSOrderedAscending) {
            return YES;
        } else {
            return NO;
        }
    }];
    
    self.fileList = [NSMutableArray arrayWithArray:fileList];
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString * title = [self.fileList objectAtIndex:indexPath.row];
        NSString * filePath = [[NSString alloc] initWithFormat:@"%@/%@", self.logDir, title];
        BOOL exist = [self.fileManager fileExistsAtPath:filePath];
        if (exist) {
            NSError * error;
            [self.fileManager removeItemAtPath:filePath error:&error];
            if (error) {
                
            }
            [self readData];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [self.fileList objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long row = indexPath.row;
    NSString * title = [self.fileList objectAtIndex:row];
    NSString * filePath = [[NSString alloc] initWithFormat:@"file://%@/%@", self.logDir, title];
    NSURL *shareURL = [NSURL URLWithString:filePath];
    
    [self shareUrl:shareURL];
    return;
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@""
                                                                    message:@"只看P2P的日志？"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){
        [self shareUrl:shareURL];
    }];
    UIAlertAction *turnOn = [UIAlertAction actionWithTitle:@"YES"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
        [self processP2PLog:title];
    }];
    
    [alert addAction:cancel];
    [alert addAction:turnOn];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)processP2PLog:(NSString *)title {
    NSString * filePath = [[NSString alloc] initWithFormat:@"file://%@/%@", self.logDir, title];
    NSURL * url = [[NSURL alloc] initWithString:filePath];
    NSError * error;
    NSData * data = [NSData dataWithContentsOfURL:url];

    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray * arr = [string componentsSeparatedByString:@"\n"];
    
    NSMutableString * mutableString = [[NSMutableString alloc] init];
    
    for (NSString * str in arr) {
        if ([str containsString:@"[p2p]"] || [str containsString:@"[P2P]"]) {
            [mutableString appendString:str];
            [mutableString appendString:@"\n"];
        }
    }
    
    NSString * p2pFilePath = [[NSString alloc] initWithFormat:@"/%@/p2p_%@", self.logDir, title];

    BOOL success = [mutableString writeToFile:p2pFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (success) {
        NSString * t = [@"file:/" stringByAppendingFormat:@"%@", p2pFilePath];
        NSURL * p2pFileUrl = [[NSURL alloc] initWithString:t];
        [self shareUrl:p2pFileUrl];
    } 
}

- (void)shareUrl:(NSURL *)shareURL {
    NSArray *activityItems = [[NSArray alloc] initWithObjects:shareURL, nil];
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    };
    
    vc.completionWithItemsHandler = myBlock;
    
    [self presentViewController:vc animated:YES completion:nil];
}


@end
