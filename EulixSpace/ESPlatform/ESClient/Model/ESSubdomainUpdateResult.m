#import "ESSubdomainUpdateResult.h"

@implementation ESSubdomainUpdateResult

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"boxUUID": @"boxUUID", @"code": @"code", @"error": @"error", @"recommends": @"recommends", @"subdomain": @"subdomain", @"success": @"success", @"userId": @"userId" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"boxUUID", @"code", @"error", @"recommends", @"subdomain", @"success", @"userId"];
  return [optionalProperties containsObject:propertyName];
}

@end
