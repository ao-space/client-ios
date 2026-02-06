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
//  EulixSpaceTests.m
//  EulixSpaceTests
//
//  Created by Ye Tao on 2021/7/6.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESAES.h"
#import "ESFileDefine.h"
#import "ESGatewayManager.h"
#import "ESLocalPath.h"
#import "ESRSA.h"
#import "ESRSACenter.h"
#import "ESRSAPair+openssl.h"
#import "ESTransferManager.h"
#import "ESApiClient.h"
#import "ESLogger.h"
#import "ESNetworkRequestManager.h"
#import "ESLanTransferManager.h"
#import <XCTest/XCTest.h>

@interface EulixSpaceTests : XCTestCase

@end

@implementation EulixSpaceTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRSAExample {
    ESRSAPair *pair = ESRSACenter.defaultPair;
    NSString *plain = @"Hello world";
    NSString *publicEncrypt = [pair publicEncrypt:plain];
    XCTAssertTrue([[pair privateDecrypt:publicEncrypt] isEqualToString:plain]);
}

- (void)testAESExample {
    NSString *key = [NSString randomKeyWithLength:16];
    NSString *plain = @"Hello world";
    NSMutableString *ivString = NSMutableString.string;
    for (NSUInteger index = 0; index < key.length; index++) {
        [ivString appendFormat:@"%C", 0];
    }
    NSString *aseEncrypt = [plain aes_cbc_encryptWithKey:key iv:ivString];
    NSString *aesDecrypt = [aseEncrypt aes_cbc_decryptWithKey:key iv:ivString];
    XCTAssertTrue([aesDecrypt isEqualToString:plain]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        ESRSAPair *pair = ESRSACenter.defaultPair;
        NSString *plain = @"Hello world";
        NSString *publicEncrypt = [pair publicEncrypt:plain];
        XCTAssertTrue([[pair privateDecrypt:publicEncrypt] isEqualToString:plain]);
    }];
}

- (void)testSignatureExample {
    ESRSAPair *pair = ESRSACenter.defaultPair;
    NSString *plain = @"Hello world";
    NSString *signature = [pair sign:plain];
    XCTAssertTrue([pair verifySignature:signature plainText:plain]);
}

- (void)testContentTypeExample {
    XCTAssertTrue([ContentTypeForPathExtension(@"png") isEqualToString:@"image/png"]);
}

- (void)testCompareExample {
    XCTAssertTrue([@"0.5.0" compare:@"0.5.1" options:NSNumericSearch] == NSOrderedAscending);
    XCTAssertTrue([@"0.5.1" compare:@"0.5.1" options:NSNumericSearch] == NSOrderedSame);
    XCTAssertTrue([@"0.5.10" compare:@"0.5.9" options:NSNumericSearch] == NSOrderedDescending);
}

- (void)testLoggerWriteToFile {
    ESLogger *logger = [ESLogger sharedLogger];
    logger.enabled = YES;
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"eslogger-%@.log", NSUUID.UUID.UUIDString]];
    logger.loggingFile = tmpPath;

    [logger debugLog:@"UnitTest" message:@"logger_file_write_%@", @"ok"];

    NSData *data = [NSData dataWithContentsOfFile:tmpPath];
    XCTAssertNotNil(data);
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([content containsString:@"logger_file_write_ok"]);

    [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
}

- (void)testNetworkRequestInvalidIdStatus {
    ESNetworkRequestServiceStatus status = [ESNetworkRequestManager requestTaskStatusWithId:-1];
    XCTAssertEqual(status, ESNetworkRequestServiceStatus_Unknow);
}

- (void)testRoutersContainsCoreFileApis {
    NSString *testDir = [NSString stringWithUTF8String:__FILE__].stringByDeletingLastPathComponent;
    NSString *routerPath = [[testDir stringByAppendingPathComponent:@"../EulixSpace/Resource/eulix.bundle/routers.json"] stringByStandardizingPath];
    NSData *routerData = [NSData dataWithContentsOfFile:routerPath];
    XCTAssertNotNil(routerData);
    NSString *content = [[NSString alloc] initWithData:routerData encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(content);

    XCTAssertTrue([content containsString:@"\"eulixspace-file-service\""]);
    XCTAssertTrue([content containsString:@"/space/v1/api/file/upload"]);
    XCTAssertTrue([content containsString:@"/space/v1/api/file/download"]);
    XCTAssertTrue([content containsString:@"/space/v1/api/multipart/create"]);
    XCTAssertTrue([content containsString:@"/space/v1/api/file/list"]);
}

- (void)testGatewayLanHostOverrideOnlyForSameBox {
    ESBoxItem *activeBox = [ESBoxItem fromInviteMemberWithBoxUUID:@"box-a"
                                                           authKey:@"auth-a"
                                                        userDomain:@"a.local"
                                                              aoid:@"aoid-a"];
    ESBoxItem *sameReachableBox = [ESBoxItem fromInviteMemberWithBoxUUID:@"box-a"
                                                                  authKey:@"auth-a2"
                                                               userDomain:@"a2.local"
                                                                     aoid:@"aoid-a"];
    ESBoxItem *otherReachableBox = [ESBoxItem fromInviteMemberWithBoxUUID:@"box-b"
                                                                   authKey:@"auth-b"
                                                                userDomain:@"b.local"
                                                                      aoid:@"aoid-b"];

    XCTAssertTrue([ESGatewayManager shouldUseLanHost:@"http://192.168.0.10:80"
                                        reachableBox:sameReachableBox
                                           activeBox:activeBox]);
    XCTAssertFalse([ESGatewayManager shouldUseLanHost:@"http://192.168.0.11:80"
                                         reachableBox:otherReachableBox
                                            activeBox:activeBox]);
    XCTAssertFalse([ESGatewayManager shouldUseLanHost:@""
                                         reachableBox:sameReachableBox
                                            activeBox:activeBox]);
}

- (void)testGatewayRejectsStaleBoxRequest {
    ESBoxItem *activeBox = [ESBoxItem fromInviteMemberWithBoxUUID:@"box-a"
                                                           authKey:@"auth-a"
                                                        userDomain:@"a.local"
                                                              aoid:@"aoid-a"];
    ESBoxItem *sameBoxNewObj = [ESBoxItem fromInviteMemberWithBoxUUID:@"box-a"
                                                               authKey:@"auth-a2"
                                                            userDomain:@"a2.local"
                                                                  aoid:@"aoid-a"];
    ESBoxItem *staleBox = [ESBoxItem fromInviteMemberWithBoxUUID:@"box-b"
                                                          authKey:@"auth-b"
                                                       userDomain:@"b.local"
                                                             aoid:@"aoid-b"];

    XCTAssertTrue([ESGatewayManager isActiveBoxRequest:sameBoxNewObj activeBox:activeBox]);
    XCTAssertFalse([ESGatewayManager isActiveBoxRequest:staleBox activeBox:activeBox]);
    XCTAssertTrue([ESGatewayManager isActiveBoxRequest:nil activeBox:activeBox]);
}

- (void)testLanCertResponseExtraction {
    NSString *certA = [ESLanTransferManager extractLanCertFromResponse:@{@"cert" : @"abc"}];
    XCTAssertEqualObjects(certA, @"abc");

    NSString *certB = [ESLanTransferManager extractLanCertFromResponse:@{@"results" : @"def"}];
    XCTAssertEqualObjects(certB, @"def");

    NSString *certC = [ESLanTransferManager extractLanCertFromResponse:@{@"results" : @{@"cert" : @"ghi"}}];
    XCTAssertEqualObjects(certC, @"ghi");

    NSString *certD = [ESLanTransferManager extractLanCertFromResponse:@"jkl"];
    XCTAssertEqualObjects(certD, @"jkl");

    NSString *certE = [ESLanTransferManager extractLanCertFromResponse:@{}];
    XCTAssertNil(certE);
}

@end
