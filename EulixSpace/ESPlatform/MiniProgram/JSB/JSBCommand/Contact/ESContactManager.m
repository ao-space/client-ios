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
//  ESContactManager.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESContactManager.h"
#import <Contacts/Contacts.h>
#import "UIWindow+ESVisibleVC.h"
#import "UIImage+ESCompress.h"
#import "ESPermissionController.h"

static CGFloat const ESThumbImageMaxSize = (1024*15);

@interface ESContactManager ()

@property (nonatomic, copy) ESContactManagerFetchContactHandler fetchContactHandler;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) CNContactStore *store;
@property (nonatomic, copy) NSString *vCardContactFilePath;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, copy) NSString *customCacheFileDir;

@property (nonatomic, assign) NSUInteger counter;
@property (nonatomic, assign) BOOL justCountInfo;

@end

@implementation ESContactManager

- (void)fetchContactVCardFileWithCustomCacheFileDir:(NSString *)dir
                                  completionHandler:(ESContactManagerFetchContactHandler)handler {
    self.customCacheFileDir = dir;
    self.justCountInfo = NO;
    [self fetchContactVCardFile:handler];
}

- (void)fetchContactCount:(ESContactManagerFetchContactHandler)handler {
    self.justCountInfo = YES;
    [self fetchContactVCardFile:handler];
}

- (void)fetchContactVCardFile:(ESContactManagerFetchContactHandler)handler {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status != CNAuthorizationStatusAuthorized &&
        status != CNAuthorizationStatusNotDetermined) {
//        NSLog(@"您的通讯录暂未允许访问，请去设置->隐私里面授权!");
        [self showJumpSettingDialog];
        if (handler) {
            handler(NO, nil, 0, [NSError errorWithDomain:@"ESContactManagerErrorDomain" code:1001 userInfo:@{@"message" : @"您的通讯录暂未允许访问，请去设置->隐私里面授权!"}]);
        }
        return;
    }
    
    self.fetchContactHandler = handler;
    if (status == CNAuthorizationStatusNotDetermined) {
        [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [self fetchContact];
                return;
            }
            
            if (handler) {
                handler(NO, nil, 0, error);
            }
            return;
            
        }];
        return;
   }
    
    ESPerformBlockAsyn(^{
        if (self.justCountInfo) {
            [self fetchContactCount];
            return;
        }
        
        [self fetchContact];
    });
  
    return;
}

- (void)showJumpSettingDialog {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"contact_dialog_title", @"”傲空间“想访问您的通讯录")
//                                                                   message: NSLocalizedString(@"contact_dialog_message", @"用于导入联系人功能")
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle: NSLocalizedString(@"contact_dialog_cancel_bt_title", @"不允许")
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction *_Nonnull action){
//                                                   }];
//    UIAlertAction *turnOn = [UIAlertAction actionWithTitle:NSLocalizedString(@"contact_dialog_confirm_bt_title", @"好的")
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction *_Nonnull action) {
//                                                       [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//                                                   }];
//
//    [alert addAction:cancel];
//    [alert addAction:turnOn];
//    UIViewController *topVisibelVC = [UIWindow visibleViewController];
//    [topVisibelVC presentViewController:alert animated:YES completion:nil];
    [ESPermissionController showPermissionView:ESPermissionTypeAddressBook];
}

- (CNContactStore *)store {
    if (!_store) {
        _store = [CNContactStore new];
    }
    return _store;
}

- (NSArray *)fetchKeys {
    return @[CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactOrganizationNameKey,
             CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactPhoneticOrganizationNameKey,CNContactBirthdayKey,
             CNContactNonGregorianBirthdayKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,
             CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey];
}

- (void)fetchContactCount {
    if (_isProcessing) {
        return;
    }
    _isProcessing = YES;

    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:[self fetchKeys]];
    __block NSInteger count = 0;
    NSError *error;
    [self.store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        count += 1;
    }];
    
    if (error != nil) {
        ESPerformBlockOnMainThread(^{
            self.fetchContactHandler(NO, nil, 0, error);
        });
        _isProcessing = NO;
        return;
    }
    
    ESPerformBlockOnMainThread(^{
        self.fetchContactHandler(YES, @"", count, nil);
    });
    _isProcessing = NO;
}

- (void)fetchContact {
    if (_isProcessing) {
        return;
    }
    _isProcessing = YES;

    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:[self fetchKeys]];
    __block BOOL firstContact = YES;
    __block BOOL requestSuccess = YES;
    __block NSInteger count = 0;
    self.vCardContactFilePath = [self cacheContactFilePath];
    NSError *error;
    [self.store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSMutableString *contactStr = [self generateVCardStringWithContacts:contact firstContact:firstContact];
        firstContact = NO;
        if (![self writeString:contactStr toFilePath:self.vCardContactFilePath]) {
            requestSuccess = NO;
            *stop = YES;
        } else {
            count += 1;
        }
    }];
    
    if (error != nil || !requestSuccess) {
        ESPerformBlockOnMainThread(^{
            self.fetchContactHandler(NO, nil, 0, error);
        });
        _isProcessing = NO;
        return;
    }
    
    ESPerformBlockOnMainThread(^{
        self.fetchContactHandler(YES, (count > 0 ? self.vCardContactFilePath : nil), count, nil);
    });
    [self resetFileHandler];
    _isProcessing = NO;
}

// MARK: ios9之后的通讯录转Vcard(版本3.0)字符串
- (NSMutableString *)generateVCardStringWithContacts:(CNContact *)contact firstContact:(BOOL)first {
     self.counter  = 0;
    NSMutableString *vcard = [NSMutableString string];
    
    if(!first) {
        [vcard appendFormat:@"\n"];
    }
    
    [self addBaseInfo:contact vCardStr:vcard];
    // Mail
    [self appEmailInfoWithContact:contact vCardStr:vcard];
    
    // Tel
    [self addTelInfoWithContact:contact vCardStr:vcard];
    
    // Address
    [self addAddressInfoWithContact:contact vCardStr:vcard];
    
    [self addthumbnailImageInfoWithContact:contact vCardStr:vcard];
    
    [vcard appendFormat:@"END:VCARD"];
    return vcard;
}

- (void)addBaseInfo:(CNContact *)contact vCardStr:(NSMutableString *)vcard {
    NSString *firstName = contact.givenName;
    firstName = (firstName ?
                 firstName : @"");
    NSString *lastName = contact.familyName;
    lastName = (lastName ? lastName : @"");
    NSString *middleName = contact.middleName;
    NSString *prefix = contact.namePrefix;
    NSString *suffix = contact.nameSuffix;
    NSString *nickName = contact.nickname;
    NSString *firstNamePhonetic = contact.phoneticGivenName;
    NSString *lastNamePhonetic = contact.phoneticFamilyName;
    NSString *organization = contact.organizationName;
    NSString *jobTitle = contact.jobTitle;
    NSString *department = contact.departmentName;
    
    NSString *compositeName = [NSString stringWithFormat:@"%@%@", lastName, firstName];
     [vcard appendFormat:@"BEGIN:VCARD\nVERSION:3.0\nN:%@;%@;%@;%@;%@\n",
             (lastName ? lastName : @""),
             (firstName ? firstName : @""),
             (middleName ? middleName : @""),
             (prefix ? prefix : @""),
             (suffix ? suffix : @"")
             ];
    
    [vcard appendFormat:@"FN:%@\n",compositeName];
    if(nickName.length > 0) [vcard appendFormat:@"NICKNAME:%@\n",nickName];
    if(firstNamePhonetic.length > 0) [vcard appendFormat:@"X-PHONETIC-FIRST-NAME:%@\n",firstNamePhonetic];
    if(lastNamePhonetic.length > 0) [vcard appendFormat:@"X-PHONETIC-LAST-NAME:%@\n",lastNamePhonetic];
    
    // Work
    if(organization.length > 0)  [vcard appendFormat:@"ORG:%@;%@\n",(organization?
                                                                            
                                                                            organization:@""),(department?department:@"")];
    
    if(jobTitle.length > 0)  [vcard appendFormat:@"TITLE:%@\n",jobTitle];
}

- (void)appEmailInfoWithContact:(CNContact *)contact vCardStr:(NSMutableString *)vcard {
    if(contact.emailAddresses.count > 0) {
        for (int k = 0; k < contact.emailAddresses.count; k++) {
            CNLabeledValue<NSString*>* emailObject = contact.emailAddresses[k];
            NSString *label = emailObject.label;
            NSString *email = emailObject.value;
            NSString *labelLower = [label lowercaseString];
            
            [vcard appendFormat:@"EMAIL;type=INTERNET;type=WORK:%@\n",email];
            
            if ([labelLower isEqualToString:@"home"])  [vcard appendFormat:@"EMAIL;type=INTERNET;type=HOME:%@\n",email];
            else if ([labelLower isEqualToString:@"work"])  [vcard appendFormat:@"EMAIL;type=INTERNET;type=WORK:%@\n",email];
            else {//类型解析不出来的
                 _counter++;
                 [vcard stringByAppendingFormat:@"item%ld.EMAIL;type=INTERNET:%@\nitem%ld.X-ABLabel:%@\n", _counter, email, _counter, label];
            }
        }
    }
}

- (void)addTelInfoWithContact:(CNContact *)contact vCardStr:(NSMutableString *)vcard {
    if(contact.phoneNumbers.count > 0) {
        for (int k = 0; k < contact.phoneNumbers.count; k++) {
            CNLabeledValue<CNPhoneNumber*>* phoneObject = contact.phoneNumbers[k];
            NSString *label = phoneObject.label;
            NSString *number = [phoneObject.value stringValue];
            NSString *labelLower = [label lowercaseString];

            if ([labelLower isEqualToString:@"mobile"] || [labelLower isEqualToString:@"_$!<mobile>!$_"])  [vcard appendFormat:@"TEL;type=CELL:%@\n",number];
            else if ([labelLower isEqualToString:@"home"] || [labelLower isEqualToString:CNLabelHome])  [vcard appendFormat:@"TEL;type=HOME:%@\n",number];
            else if ([labelLower isEqualToString:@"work"] || [labelLower isEqualToString:CNLabelWork]) [vcard appendFormat:@"TEL;type=WORK:%@\n",number];
            else if ([labelLower isEqualToString:@"main"] || [labelLower isEqualToString:@"_$!<main>!$_"])  [vcard appendFormat:@"TEL;type=MAIN:%@\n",number];
            else if ([labelLower isEqualToString:@"homefax"] || [labelLower isEqualToString:@"_$!<homefax>!$_"])  [vcard appendFormat:@"TEL;type=HOME;type=FAX:%@\n",number];
            else if ([labelLower isEqualToString:@"workfax"] || [labelLower isEqualToString:@"_$!<workfax>!$_"])  [vcard appendFormat:@"TEL;type=WORK;type=FAX:%@\n",number];
            else if ([labelLower isEqualToString:@"pager"] || [labelLower isEqualToString:@"_$!<pager>!$_"])  [vcard appendFormat:@"TEL;type=PAGER:%@\n",number];
            else if([labelLower isEqualToString:@"other"] || [labelLower isEqualToString:CNLabelOther])  [vcard appendFormat:@"TEL;type=OTHER:%@\n",number];
            else { //类型解析不出来的
                _counter++;
                 [vcard appendFormat:@"item%ld.TEL:%@\nitem%ld.X-ABLabel:%@\n", _counter, number, _counter,label];
            }
        }
    }
}

- (void)addAddressInfoWithContact:(CNContact *)contact vCardStr:(NSMutableString *)vcard {
    if(contact.postalAddresses.count > 0) {
        for (int k = 0; k < contact.postalAddresses.count; k++) {
            CNLabeledValue<CNPostalAddress*>* addressObject = contact.postalAddresses[k];
            NSString *label = addressObject.label;
            CNPostalAddress *address = addressObject.value;
            NSString *labelLower = [label lowercaseString];
            NSString* country = address.country;
            NSString* city = address.city;
            NSString* state = address.state;
            NSString* subLocality = address.subLocality;
            NSString* street = [address.street containsString:@"\n"] ?
                               [address.street stringByReplacingOccurrencesOfString:@"\n" withString:@" "] : address.street;
            NSString* zip = address.postalCode;
            NSString* countryCode = address.ISOCountryCode;
            NSString *type = @"";
            NSString *labelField = @"";
            _counter++;
            
            if([labelLower isEqualToString:@"work"]) type = @"WORK";
            else if([labelLower isEqualToString:@"home"]) type = @"HOME";
            else if(label && [label length] > 0)
            {
                labelField = [NSString stringWithFormat:@"item%ld.X-ABLabel:%@\n",_counter,label];
            }
            
            [vcard appendFormat:@"item%ld.ADR;type=%@:;;%@;%@;%@;%@;%@\n%@item%ld.X-ABADR:%@\n",
                     _counter,
                     type,
                     (street ? street : @""),
                     (city ? city : @""),
                     (state ? state : @""),
                     (zip ? zip : @""),
                     (country ? country : @""),
                     labelField,
                     _counter,
                     (countryCode ? countryCode : @"")
                     ];
            if (subLocality.length > 0) {
                [vcard appendFormat:@"item%ld.X-APPLE-SUBLOCALITY:%@\n",
                 _counter,
                 (subLocality ? subLocality : @"")
                ];
            }
        }
    }
}

- (void)addthumbnailImageInfoWithContact:(CNContact *)contact vCardStr:(NSMutableString *)vcard {
    if (contact.thumbnailImageData == nil) {
        return;
    }
    NSData *thumbImageData = contact.thumbnailImageData;
    if ([self needCompress:thumbImageData]) {
        thumbImageData = [self compressImage:thumbImageData];
    }
    NSString *imageBase64Str = [thumbImageData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];

    NSString *imageStr = [@"PHOTO;ENCODING=b;TYPE=JPEG:" stringByAppendingString:imageBase64Str];
    NSMutableString *imageStrMt = [[NSMutableString alloc] initWithString:imageStr];
    
    [imageStrMt replaceOccurrencesOfString:@"\r" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, imageStrMt.length)];
    [imageStrMt replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, imageStrMt.length)];

    NSUInteger seekIndex = 0;
    NSUInteger totalLength = [imageStrMt length];

    while (seekIndex + 75 < totalLength) {
        @autoreleasepool {
            if (seekIndex == 0) { // 第一行
                NSString *tempPerLineStr = [imageStrMt substringWithRange:NSMakeRange(seekIndex, 75)];
                [vcard appendFormat:@"%@\n", tempPerLineStr];
                seekIndex += 75;

            } else {
                NSString *tempPerLineStr = [imageStrMt substringWithRange:NSMakeRange(seekIndex, 74)];
                [vcard appendFormat:@" %@\n", tempPerLineStr];
                seekIndex += 74;

            }
        }
    }

    if (seekIndex < totalLength) {
        NSString *tempPerLineStr = [imageStrMt substringWithRange:NSMakeRange(seekIndex, totalLength - seekIndex)];
        [vcard appendFormat:@" %@\n", tempPerLineStr];
    }
    
}

- (BOOL)needCompress:(NSData *)imageData {
    return imageData.length / 1000 > 200;
}

- (NSData *)compressImage:(NSData *)imageData {
    UIImage *image = [UIImage imageWithData:imageData];
    NSData *compressData = [image compressImageWithLimitLength:ESThumbImageMaxSize canResize:YES];
    return compressData;
}

- (NSString *)addBaseInfo:(CNContact *)contact isFirst:(BOOL)first {
    NSString *vcard = @"";
    NSString *firstName = contact.givenName;
    firstName = (firstName ?
                 firstName : @"");
    NSString *lastName = contact.familyName;
    lastName = (lastName ? lastName : @"");
    NSString *middleName = contact.middleName;
    NSString *prefix = contact.namePrefix;
    NSString *suffix = contact.nameSuffix;
    NSString *nickName = contact.nickname;
    NSString *firstNamePhonetic = contact.phoneticGivenName;
    NSString *lastNamePhonetic = contact.phoneticFamilyName;
    NSString *organization = contact.organizationName;
    NSString *jobTitle = contact.jobTitle;
    NSString *department = contact.departmentName;
    
    NSString *compositeName = [NSString stringWithFormat:@"%@%@",firstName,lastName];
    
    if(!first) {
        vcard = [vcard stringByAppendingFormat:@"\n"];
    }
    
    vcard = [vcard stringByAppendingFormat:@"BEGIN:VCARD\nVERSION:3.0\nN:%@;%@;%@;%@;%@\n",
             (firstName ?
              firstName : @""),
             (lastName ? lastName : @""),
             (middleName ? middleName : @""),
             (prefix ?
              prefix : @""),
             (suffix ? suffix : @"")
             ];
    
    vcard = [vcard stringByAppendingFormat:@"FN:%@\n",compositeName];
    if(nickName.length > 0) vcard = [vcard stringByAppendingFormat:@"NICKNAME:%@\n",nickName];
    if(firstNamePhonetic.length > 0) vcard = [vcard stringByAppendingFormat:@"X-PHONETIC-FIRST-NAME:%@\n",firstNamePhonetic];
    if(lastNamePhonetic.length > 0) vcard = [vcard stringByAppendingFormat:@"X-PHONETIC-LAST-NAME:%@\n",lastNamePhonetic];
    
    // Work
    if(organization.length > 0) vcard = [vcard stringByAppendingFormat:@"ORG:%@;%@\n",(organization?
                                                                            
                                                                            organization:@""),(department?department:@"")];
    
    if(jobTitle.length > 0) vcard = [vcard stringByAppendingFormat:@"TITLE:%@\n",jobTitle];
    return vcard;
}

- (NSString *)cacheContactFilePath {
    NSString *cacheFolder = self.customCacheFileDir ?: [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    NSString *writePath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", timeSp, @"vcf"]];
    return writePath;
}

- (BOOL)writeString:(NSString *)writeStr toFilePath:(NSString *)filePath {
    if (_fileHandle) {
        [_fileHandle seekToEndOfFile];
        NSData *stringData = [writeStr dataUsingEncoding:NSUTF8StringEncoding];
        [_fileHandle writeData:stringData]; // 追加写入数据
        return YES;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        if (!_fileHandle) {
            return NO;
        }
        [_fileHandle seekToEndOfFile]; //将节点跳到文件的末尾
        
        NSData *stringData = [writeStr dataUsingEncoding:NSUTF8StringEncoding];
        [_fileHandle writeData:stringData]; // 追加写入数据
        return YES;
    } else {
        NSError *error;
        [writeStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (void)resetFileHandler {
    [_fileHandle closeFile];
    _fileHandle = nil;
}

@end
