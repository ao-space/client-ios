#import "ESFileInfoPub.h"

@implementation ESFileInfoPub

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
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"betag": @"betag", @"category": @"category", @"createdAt": @"createdAt", @"fileCount": @"fileCount", @"isDir": @"isDir", @"mime": @"mime", @"modifyAt": @"modifyAt", @"name": @"name", @"operationAt": @"operationAt", @"parentUuid": @"parentUuid", @"path": @"path", @"size": @"size", @"trashed": @"trashed", @"uuid": @"uuid",@"isSelected":@"isSelected",@"duration":@"duration",@"searchKey":@"searchKey"}];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"betag", @"category", @"createdAt", @"fileCount", @"isDir", @"mime", @"modifyAt", @"name", @"operationAt", @"parentUuid", @"path", @"size", @"trashed", @"uuid",@"isSelected",@"duration",@"searchKey"];
  return [optionalProperties containsObject:propertyName];
}

@end
