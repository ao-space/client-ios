#import "ESEncryptAuthDTO.h"

@implementation ESEncryptAuthDTO

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"accessToken": @"accessToken", @"algorithmConfig": @"algorithmConfig", @"aoid": @"aoid", @"autoLogin": @"autoLogin", @"autoLoginExpiresAt": @"autoLoginExpiresAt", @"boxName": @"boxName", @"boxUUID": @"boxUUID", @"encryptedSecret": @"encryptedSecret", @"expiresAt": @"expiresAt", @"expiresAtEpochSeconds": @"expiresAtEpochSeconds", @"refreshToken": @"refreshToken", @"requestId": @"requestId" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"accessToken", @"algorithmConfig", @"aoid", @"autoLogin", @"autoLoginExpiresAt", @"boxName", @"boxUUID", @"encryptedSecret", @"expiresAt", @"expiresAtEpochSeconds", @"refreshToken", @"requestId"];
  return [optionalProperties containsObject:propertyName];
}

@end
