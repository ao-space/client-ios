#import "ESShareDetailRsp.h"

@implementation ESShareDetailRsp

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"autoFill": @"autoFill", @"boxTime": @"boxTime", @"createTime": @"createTime", @"expiredTime": @"expiredTime", @"extractedCode": @"extractedCode", @"fileCount": @"fileCount", @"fileName": @"fileName", @"haveExploredTimes": @"haveExploredTimes", @"isDir": @"isDir", @"maxExploredTimes": @"maxExploredTimes", @"shareId": @"shareId", @"shareUrl": @"shareUrl" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"autoFill", @"boxTime", @"createTime", @"expiredTime", @"extractedCode", @"fileCount", @"fileName", @"haveExploredTimes", @"isDir", @"maxExploredTimes", @"shareId", @"shareUrl"];
  return [optionalProperties containsObject:propertyName];
}

@end
