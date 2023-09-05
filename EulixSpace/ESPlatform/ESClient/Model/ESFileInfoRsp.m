#import "ESFileInfoRsp.h"

@implementation ESFileInfoRsp

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"betag": @"betag", @"category": @"category", @"createdAt": @"createdAt", @"fileCount": @"fileCount", @"isDir": @"isDir", @"mime": @"mime", @"modifyAt": @"modifyAt", @"name": @"name", @"operationAt": @"operationAt", @"parentUuid": @"parentUuid", @"path": @"path", @"size": @"size", @"trashed": @"trashed", @"uuid": @"uuid" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"betag", @"category", @"createdAt", @"fileCount", @"isDir", @"mime", @"modifyAt", @"name", @"operationAt", @"parentUuid", @"path", @"size", @"trashed", @"uuid"];
  return [optionalProperties containsObject:propertyName];
}

@end
