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
//  ESCommentVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/13.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESInstallSetting1GeneralVC.h"
#import "ESMeSettingCell2.h"
#import <Masonry/Masonry.h>
#import "NSArray+ESTool.h"
#import "ESCacheCleanTools.h"
#import "ESToast.h"
#import "ESBoxManager.h"
#import "ESLocalizableDefine.h"
#import "ESPushNewsSettingVC.h"
#import "ESAboutViewController.h"
#import "ESSecuritySettimgController.h"
#import "ESAccountInfoStorage.h"
#import "ESSettingCacheManagerVC.h"
#import "ESCacheCleanTools+ESBusiness.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "ESSecurityEmailMamager.h"
#import "ESV2PowerVC.h"
#import "ESLanguageVC.h"
#import "ESInputSettingVC.h"
#import "ESKFZInputSettingVC.h"
#import "ESCellMoelKFZ.h"

#import "ESBindSecurityEmailBySecurityCodeController.h"

@interface ESInstallSetting1GeneralVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) ESCellMoelKFZ * cacheModel;
@property (nonatomic, strong) ESCellMoelKFZ * securitySettingModel;

@property (nonatomic, strong) ESSecurityEmailSetModel * emailInfo;

@property (nonatomic, strong) NSString * domin;
@end

@implementation ESInstallSetting1GeneralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionInstallBlock  = ^(NSArray *errorArray){
        if(errorArray.count < 1){
            for(int i = 0; i < self.dataArr.count; i++){
                ESCellMoelKFZ * model = self.dataArr[i];
                model.error1 = 0;
                model.error2 = 0;
                self.dataArr[i] = model;
            }
            [self.tableView reloadData];
            return;
        }
        
        if(errorArray.count == 1){
            for(int j = 0; j< errorArray.count; j++){
                NSString *errorCode =errorArray[j];
                
                if([errorCode intValue]== 80011){
                    ESCellMoelKFZ * model = self.dataArr[1];
                    model.error1 = 80011;
                    self.dataArr[1] = model;
                }else{
                    ESCellMoelKFZ * model = self.dataArr[1];
                    model.error1 = 0;
                    self.dataArr[1] = model;
                }
                
                if([errorCode intValue]== 80013){
                    ESCellMoelKFZ * model = self.dataArr[1];
                    model.error2 = 80013;
                    self.dataArr[1] = model;
                }else{
                    ESCellMoelKFZ * model = self.dataArr[1];
                    model.error2 = 0;
                    self.dataArr[1] = model;
                }
                
                if([errorCode intValue]== 80012){
                    ESCellMoelKFZ * model = self.dataArr[2];
                    model.error1 = 80012;
                    self.dataArr[2] = model;
                }else {
                    ESCellMoelKFZ * model = self.dataArr[2];
                    model.error1 = 0;
                    self.dataArr[2] = model;
                }
                if([errorCode intValue]== 80014){
                    ESCellMoelKFZ * model = self.dataArr[2];
                    model.error2 = 80014;
                    self.dataArr[2] = model;
                }else{
                    ESCellMoelKFZ * model = self.dataArr[2];
                    model.error2 = 0;
                    self.dataArr[2] = model;
                }
            }
        }else {
            for(int j = 0; j< errorArray.count; j++){
                NSString *errorCode =errorArray[j];
                
                if([errorCode intValue]== 80011){
                    ESCellMoelKFZ * model = self.dataArr[1];
                    model.error1 = 80011;
                    self.dataArr[1] = model;
                }
                
                if([errorCode intValue]== 80013){
                    ESCellMoelKFZ * model = self.dataArr[1];
                    model.error2 = 80013;
                    self.dataArr[1] = model;
                }
                
                if([errorCode intValue]== 80012){
                    ESCellMoelKFZ * model = self.dataArr[2];
                    model.error1 = 80012;
                    self.dataArr[2] = model;
                }
                if([errorCode intValue]== 80014){
                    ESCellMoelKFZ * model = self.dataArr[2];
                    model.error2 = 80014;
                    self.dataArr[2] = model;
                }
            }
        }
        
        [self.tableView reloadData];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    weakfy(self)
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"application_name", @"应用名称");
//        model.value = self.dicData[@"imageName"];
        model.hasArrow = YES;
        model.type = 1000;
        NSArray *array = [self.dicData[@"imageName"] componentsSeparatedByString:@"/"];
        if(array.count > 1){
            NSString *str = array[array.count -1];
            if(str.length > 30){
                model.value = [str substringToIndex:30];
            }else{
                model.value = str;
            }
        }else{
            NSString *str = self.dicData[@"imageName"];
            if(str.length > 30){
                model.value = [str substringToIndex:30];
            }else{
                model.value = str;
            }
        }
  

        model.onClick = ^{
            ESLanguageVC * ctl = [ESLanguageVC new];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [self.dataArr addObject:model];
        self.securitySettingModel = model;

    }
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"service_name", @"服务名称");
        model.type = 1001;
//        model.value = self.dicData[@"imageName"];
        
        NSArray *array = [self.dicData[@"imageName"] componentsSeparatedByString:@"/"];
        if(array.count > 1){
            NSString *str = array[array.count - 1];
            NSString *characters = [self removeSpecialCharacters:str];
            if(characters.length > 40){
                NSString *stringOne = [characters substringToIndex:40];
                model.value = stringOne;
            }else{
                model.value = characters;
            }
     
        }else{
            NSString *str = self.dicData[@"imageName"];
            if(str.length < 1){
                str = @"";
            }
            NSString *characters = [self removeSpecialCharacters:str];
            if(characters.length > 40){
                NSString *stringOne = [characters substringToIndex:40];
                model.value = stringOne;
            }else{
                model.value = characters;
            }
        }
        self.domin = model.value;
//        model.value = self.dicData[@"imageName"];
        model.hasArrow = YES;
        model.onClick = ^{
            ESSettingCacheManagerVC *pushVC = [ESSettingCacheManagerVC new];
            [weak_self.navigationController pushViewController:pushVC animated:YES];
        };
        [self.dataArr addObject:model];
    }
    
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"domain_name_prefix", @"域名前缀");
        model.type = 1002;
        NSArray *array = [self.dicData[@"imageName"] componentsSeparatedByString:@"/"];
        if(array.count > 1){
            NSString *str = array[array.count -1];
            NSString *characters = [self removeSpecialCharacters:str];
            if(characters.length > 20){
                NSString *stringOne = [characters substringToIndex:20];
                model.value = stringOne;
            }else{
                model.value = characters;
            }
            
        }else{
         //   model.value = self.dicData[@"imageName"];
            NSString *str = self.dicData[@"imageName"];
            NSString *characters = [self removeSpecialCharacters:str];
            if(characters.length > 20){
                NSString *stringOne = [characters substringToIndex:20];
                model.value = stringOne;
            }else{
                model.value = characters;
            }
        }
        
        model.hasArrow = YES;
        model.onClick = ^{
            ESLanguageVC * ctl = [ESLanguageVC new];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [self.dataArr addObject:model];
        self.securitySettingModel = model;

    }
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"page_link", @"网页链接");
        model.hasArrow = NO;
        model.type = 1003;
        NSDictionary *dic = [ESBoxManager cacheInfoForBox:ESBoxManager.activeBox];
        NSString *userDomain = dic[@"userDomain"];
        NSArray *array = [self.dicData[@"imageName"] componentsSeparatedByString:@"/"];
        NSString *urlStr;
        if(array.count > 1){
            urlStr =array[1];
        }else{
            urlStr = self.dicData[@"imageName"];
        }
  
       
        NSString *characters = [self removeSpecialCharacters:urlStr];
        NSString *stringOne;
        if(characters.length > 20){
           stringOne = [characters substringToIndex:20];
        }else{
            stringOne = characters;
        }
        
        NSString *webUrl = [NSString stringWithFormat:@"https://%@-%@",stringOne,userDomain];
        model.value = webUrl;
        model.onClick = ^{
            ESSettingCacheManagerVC *pushVC = [ESSettingCacheManagerVC new];
            [weak_self.navigationController pushViewController:pushVC animated:YES];
        };
        [self.dataArr addObject:model];
    }
    
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"performance_limitations", @"性能限制");
        model.value = NSLocalizedString(@"unlimited", @"不限制");
        model.hasArrow = NO;
        model.onClick = ^{
            ESLanguageVC * ctl = [ESLanguageVC new];
            [weak_self.navigationController pushViewController:ctl animated:YES];
        };
        [self.dataArr addObject:model];
        self.securitySettingModel = model;

    }
    {
        ESCellMoelKFZ * model = [[ESCellMoelKFZ alloc] init];
        model.title = NSLocalizedString(@"self_start", @"开机自启动");
        model.value = @"是";
        model.hasArrow = NO;
        model.onClick = ^{
            ESSettingCacheManagerVC *pushVC = [ESSettingCacheManagerVC new];
            [weak_self.navigationController pushViewController:pushVC animated:YES];
        };
        [self.dataArr addObject:model];
    }
}

- (void)clearCache {
    weakfy(self);
    [ESCacheCleanTools clearAllCache];
    [ESToast toastSuccess:TEXT_ME_ALREADY_CLEARED_CACHE];
    [ESCacheCleanTools cacheSizeWithCompletion:^(NSString *size) {
        [weak_self initData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESMeSettingCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMeSettingCell"];
    ESCellMoelKFZ * model = [self.dataArr getObject:indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row  > 2){
        return;
    }
    ESCellMoelKFZ * model = [self.dataArr getObject:indexPath.row];
    ESKFZInputSettingVC *vc = [ESKFZInputSettingVC new];
    vc.type = indexPath.row;
    vc.model = model;

    NSMutableArray *list = [NSMutableArray new];
    vc.updateName = ^(NSString *name) {
        NSString *str;
        if(indexPath.row == 2){
            str = name;
        }
        for (ESCellMoelKFZ *info in self.dataArr) {
            if([info.title isEqual:model.title]){
                info.value = name;
            }else if(indexPath.row == 1){
                self.domin = model.value;
            }else if([info.title isEqual:NSLocalizedString(@"page_link", @"网页链接")]){
                NSString *characters = [self removeSpecialCharacters:str];
                NSDictionary *dic = [ESBoxManager cacheInfoForBox:ESBoxManager.activeBox];
                NSString *userDomain = dic[@"userDomain"];
                NSString *webUrl = [NSString stringWithFormat:@"https://%@-%@",characters,userDomain];
                info.value = webUrl;
            }
            [list addObject:info];
        }
        self.dataArr = list;
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESMeSettingCell2 class] forCellReuseIdentifier:@"ESMeSettingCell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _tableView;
}

- (void)dealloc {
    
}

-(void)setDicData:(NSDictionary *)dicData{
    _dicData = dicData;
    [self initData];
    [self.tableView reloadData];
}


- (NSString *)removeSpecialCharacters:(NSString *)value{
    if(value.length < 1){
        return @"";
    }
    NSMutableString *string = [NSMutableString stringWithString:value];
    unichar c;
    for(int i=0;i<string.length;i++){
        c = [string characterAtIndex:i];
        if(![self charIsNum:c]){
            //First determine if it is a number. If it is not a number, continue to determine whether it is a letter.
            if(![self charIsZimu:c]){
                //If it is not a letter, it means neither a number nor a letter
                NSString *str = [NSString stringWithCharacters:&c length:1];
                NSLog(@" removeSpecialCharacters str=%@",str);
                NSRange range = NSMakeRange(i, 1);
                [string deleteCharactersInRange:range];
                --i;
            }
        }
    }

    NSString *newstr = [NSString stringWithString:string];
    NSLog(@" removeSpecialCharacters after str=%@",newstr);
    return newstr;
}

//Judging whether it is a number
-(BOOL)charIsNum:(unichar)chars{
    if(isdigit(chars)){
        return YES;
    }
    else {
        return NO;
    }
}

//Determine if it is a letter
-(BOOL)charIsZimu:(unichar)chars{
      if((chars<'A'||chars>'Z')&&(chars<'a'||chars>'z'))
      {
            return  NO;
      }
      else {
            return YES;
      }
}
@end
