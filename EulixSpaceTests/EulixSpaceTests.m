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
#import <ESClient/ESDefaultApi.h>
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

@end
