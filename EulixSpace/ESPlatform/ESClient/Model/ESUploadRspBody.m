#import "ESUploadRspBody.h"

@implementation ESUploadRspBody

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"betag": @"betag", @"bucketName": @"bucketName", @"category": @"category", @"createdAt": @"createdAt", @"executable": @"executable", @"fileCount": @"fileCount", @"isDir": @"isDir", @"mime": @"mime", @"modifyAt": @"modifyAt", @"name": @"name", @"operationAt": @"operationAt", @"parentUuid": @"parentUuid", @"path": @"path", @"size": @"size", @"tags": @"tags", @"transactionId": @"transactionId", @"trashed": @"trashed", @"userId": @"userId", @"uuid": @"uuid", @"version": @"version" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"betag", @"bucketName", @"category", @"createdAt", @"executable", @"fileCount", @"isDir", @"mime", @"modifyAt", @"name", @"operationAt", @"parentUuid", @"path", @"size", @"tags", @"transactionId", @"trashed", @"userId", @"uuid", @"version"];
  return [optionalProperties containsObject:propertyName];
}

@end
