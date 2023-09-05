#import "ESDeviceTokenRes.h"

@implementation ESDeviceTokenRes

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"boxUUID": @"boxUUID", @"clientUUID": @"clientUUID", @"createAt": @"createAt", @"deviceToken": @"deviceToken", @"deviceType": @"deviceType", @"extra": @"extra", @"updateAt": @"updateAt", @"userId": @"userId" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"boxUUID", @"clientUUID", @"createAt", @"deviceToken", @"deviceType", @"extra", @"updateAt", @"userId"];
  return [optionalProperties containsObject:propertyName];
}

@end
