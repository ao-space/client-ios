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
//  ESPicModel.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPicModel.h"
#import <WCDB/WCDB.h>
#import "NSObject+YYModel.h"
#import "ESSmarPhotoCacheManager.h"
#import "ESDateTransferManager.h"

@implementation ESPicModel

//+ (instancetype)instanceWithUUIDItem:(ESUUIDItemModel *)uuidItem  {
//    ESPicModel *pic = [[ESPicModel alloc] init];
//    NSMutableArray *ablumIdStringList = [NSMutableArray array];
//    [uuidItem.album_ids enumerateObjectsUsingBlock:^(NSNumber * _Nonnull ablumId, NSUInteger idx, BOOL * _Nonnull stop) {
//        [ablumIdStringList addObject:[NSString stringWithFormat:@"#%lu#", [ablumId integerValue]]];
//    }];
//    pic.albumIds = [ablumIdStringList yy_modelToJSONString];
//    pic.uuid = uuidItem.uuid;
//
//    pic.category = uuidItem.category;
//    pic.like = uuidItem.like;
//    pic.size = uuidItem.size;
//    pic.shootAt = uuidItem.shootAt;
//    pic.name = uuidItem.name;
//    pic.duration = [uuidItem.duration integerValue];
//    pic.path = uuidItem.path;
//    pic.like = uuidItem.like;
//    return  pic;
//}

- (NSString * _Nullable)cacheUrl {
    NSString *url = [ESSmarPhotoCacheManager cachePathWithPic:self];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:url];
    return exist ? url : nil;
}

- (NSString * _Nullable)compressUrl {
    NSString *url = [ESSmarPhotoCacheManager compressCachePathWithPic:self];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:url];
    return exist ? url : nil;
}

- (NSArray * _Nullable)albumIdList {
    if (self.albumIds.length <= 0) {
        return nil;
    }
    NSData *jsonData = [(NSString *)self.albumIds dataUsingEncoding : NSUTF8StringEncoding];
    NSArray *list = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    return list;
}
- (BOOL)isPicture {
    return [self.category isEqualToString:@"picture"];
}


-(void)setDate:(NSString *)date {
    _date = date;
    NSDate *picDate = [[ESDateTransferManager shareInstance] transferByDateString:date];
    NSDateComponents *dateComponents = [[ESDateTransferManager shareInstance] getComponentsWithDate:picDate];
    self.date_year = dateComponents.year;
    self.date_month = dateComponents.month;
    self.date_day = dateComponents.day;
}

WCDB_IMPLEMENTATION(ESPicModel)
WCDB_SYNTHESIZE(ESPicModel, uuid)
WCDB_SYNTHESIZE(ESPicModel, name)
WCDB_SYNTHESIZE(ESPicModel, size)
WCDB_SYNTHESIZE(ESPicModel, date)
WCDB_SYNTHESIZE(ESPicModel, date_year)
WCDB_SYNTHESIZE(ESPicModel, date_month)
WCDB_SYNTHESIZE(ESPicModel, date_day)

WCDB_SYNTHESIZE(ESPicModel, path)
WCDB_SYNTHESIZE(ESPicModel, shootAt)
WCDB_SYNTHESIZE(ESPicModel, like)
WCDB_SYNTHESIZE(ESPicModel, duration)
WCDB_SYNTHESIZE(ESPicModel, category)
WCDB_SYNTHESIZE(ESPicModel, albumIds)
WCDB_SYNTHESIZE(ESPicModel, cacheUrl)

WCDB_PRIMARY(ESPicModel, uuid) //主键
WCDB_UNIQUE(ESPicModel, uuid)


@end

