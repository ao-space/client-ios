#import "ESCreateMemberResult.h"

@implementation ESCreateMemberResult

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"algorithmConfig": @"algorithmConfig", @"authKey": @"authKey", @"boxUUID": @"boxUUID", @"code": @"code", @"message": @"message", @"requestId": @"requestId", @"userDomain": @"userDomain" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"algorithmConfig", @"authKey", @"boxUUID", @"code", @"message", @"requestId", @"userDomain"];
  return [optionalProperties containsObject:propertyName];
}

@end
