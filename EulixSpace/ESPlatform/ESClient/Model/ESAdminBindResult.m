#import "ESAdminBindResult.h"

@implementation ESAdminBindResult

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
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"aoId": @"aoId", @"authKey": @"authKey", @"boxName": @"boxName", @"boxUuid": @"boxUuid", @"clientUUID": @"clientUUID", @"regKey": @"regKey", @"userDomain": @"userDomain",@"code":@"code"}];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"aoId", @"authKey", @"boxName", @"boxUuid", @"clientUUID", @"regKey", @"userDomain",@"code"];
  return [optionalProperties containsObject:propertyName];
}

@end
