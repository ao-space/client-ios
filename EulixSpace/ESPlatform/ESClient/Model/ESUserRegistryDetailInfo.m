#import "ESUserRegistryDetailInfo.h"

@implementation ESUserRegistryDetailInfo

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"clientInfos": @"clientInfos", @"createdAt": @"createdAt", @"subDomain": @"subDomain", @"userDomain": @"userDomain", @"userId": @"userId", @"userType": @"userType" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"clientInfos", @"createdAt", @"subDomain", @"userDomain", @"userId", @"userType"];
  return [optionalProperties containsObject:propertyName];
}

@end
