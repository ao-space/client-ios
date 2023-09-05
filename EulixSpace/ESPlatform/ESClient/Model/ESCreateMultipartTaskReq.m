#import "ESCreateMultipartTaskReq.h"

@implementation ESCreateMultipartTaskReq

- (instancetype)init {
  self = [super init];
  if (self) {
    // initialize property's default value, if any
    
  }
  return self;
}


/**
 * Maps json key to property name.
 * This method is used by `JSONModel`.
 */
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"betag": @"betag", @"businessId": @"businessId", @"createTime": @"createTime", @"fileName": @"fileName", @"folderId": @"folderId", @"folderPath": @"folderPath", @"mime": @"mime", @"modifyTime": @"modifyTime", @"size": @"size", @"albumId" : @"albumId" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"businessId", @"createTime", @"folderId", @"folderPath", @"mime", @"modifyTime", @"albumId"];
  return [optionalProperties containsObject:propertyName];
}

@end
