//
//  ESSpaceMainKeyModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceMainKeyModule.h"
#import "ESSpaceMainKeyCell.h"
#import "ESDIDDocManager.h"
#import "ESBoxManager.h"
#import "ESCommonToolManager.h"

@interface ESSpaceMainKeyModule ()

@property (nonatomic, strong) ESDIDDocModel *docModel;
@end

@implementation ESSpaceMainKeyModule

- (instancetype)init {
    if (self = [super init]) {
        self.docModel = [[ESDIDDocManager shareInstance] getLatestDIDDocModelByBoxUId:ESBoxManager.activeBox.uniqueKey];
    }
    return self;
}

//credentialType 由原来的 device (设备端),  binder (绑定端), password (密码)， 改成了 device (设备端),  binder (绑定端), passwordondevice (存储在设备上的空间密码), passwordonbinder(存储在绑定手机的空间密码)
-(NSArray *)mainKey1Data {
    ESVerificationBaseMethod *method = [self.docModel getVerificationMethodByType:@"device"];
    ESSpaceMainKeyItem *mainKeyItem = [ESSpaceMainKeyItem new];
    mainKeyItem.title =  NSLocalizedString(@"account_serverkey", @"傲空间服务器凭证");
    mainKeyItem.publicKeyHash = [method keyHash];
    mainKeyItem.cacheLocation = NSLocalizedString(@"account_server", @"傲空间服务器");
    mainKeyItem.lastUpdateTime = [method keyTimeNormal];

    return @[mainKeyItem];
}

-(NSArray *)mainKey2Data {
    ESVerificationBaseMethod *method = [self.docModel getVerificationMethodByType:@"binder"];
    ESSpaceMainKeyItem *mainKeyItem = [ESSpaceMainKeyItem new];
    mainKeyItem.title = NSLocalizedString(@"account_boundphonekey", @"绑定手机凭证");
    mainKeyItem.publicKeyHash = [method keyHash];
    mainKeyItem.cacheLocation = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"me_member_phone", @"绑定手机"), [ESCommonToolManager judgeIphoneType:@""]];
    mainKeyItem.lastUpdateTime = [method keyTimeNormal];

    return @[mainKeyItem];
}

-(NSArray *)secondary1Data {
    ESVerificationBaseMethod *method = [self.docModel getVerificationMethodByType:@"passwordondevice"];
    NSMutableArray *list = [NSMutableArray array];
    if (method != nil) {
        ESSpaceMainKeyItem *mainKeyItem = [ESSpaceMainKeyItem new];
        mainKeyItem.title = NSLocalizedString(@"account_securepasswordkey" ,@"安全密码凭证");
        mainKeyItem.publicKeyHash = [method keyHash];
        mainKeyItem.cacheLocation = NSLocalizedString(@"account_server", @"傲空间服务器");
        mainKeyItem.lastUpdateTime = [method keyTimeNormal];
        [list addObject:mainKeyItem];
    }

    ESVerificationBaseMethod *method2 = [self.docModel getVerificationMethodByType:@"passwordonbinder"];
    if (method2 != nil) {
        ESSpaceMainKeyItem *mainKeyItem2 = [ESSpaceMainKeyItem new];
        mainKeyItem2.title = NSLocalizedString(@"account_securepasswordkey" ,@"安全密码凭证");
        mainKeyItem2.publicKeyHash = [method2 keyHash];
        mainKeyItem2.cacheLocation = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"me_member_phone", @"绑定手机"), [ESCommonToolManager judgeIphoneType:@""]];
        mainKeyItem2.lastUpdateTime = [method2 keyTimeNormal];
        [list addObject:mainKeyItem2];
    } else if (method != nil) {
        ESSpaceMainKeyItem *mainKeyItem2 = [ESSpaceMainKeyItem new];
        mainKeyItem2.title = NSLocalizedString(@"account_securepasswordkey" ,@"安全密码凭证");
        mainKeyItem2.publicKeyHash = [method keyHash];
        mainKeyItem2.cacheLocation = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"me_member_phone", @"绑定手机"), [ESCommonToolManager judgeIphoneType:@""]];
        mainKeyItem2.lastUpdateTime = [method keyTimeNormal];
        [list addObject:mainKeyItem2];
    }
   
    return [list copy];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *viewSection = [[UIView alloc] init];
    viewSection.backgroundColor = [UIColor clearColor];
    return viewSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (id _Nullable)bindDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listData.count > indexPath.section) {
        return self.listData[indexPath.section];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 297;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ESSpaceMainKeyCell class];
}


- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    return NO;
}

@end
