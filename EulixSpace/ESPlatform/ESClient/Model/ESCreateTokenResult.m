#import "ESCreateTokenResult.h"

@implementation ESCreateTokenResult

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"accessToken": @"accessToken", @"algorithmConfig": @"algorithmConfig", @"autoLoginExpiresAt": @"autoLoginExpiresAt", @"encryptedSecret": @"encryptedSecret", @"expiresAt": @"expiresAt", @"expiresAtEpochSeconds": @"expiresAtEpochSeconds", @"refreshToken": @"refreshToken", @"requestId": @"requestId" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"accessToken", @"algorithmConfig", @"autoLoginExpiresAt", @"encryptedSecret", @"expiresAt", @"expiresAtEpochSeconds", @"refreshToken", @"requestId"];
  return [optionalProperties containsObject:propertyName];
}

@end
